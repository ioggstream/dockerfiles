#!/usr/bin/bash
# Create a TLS enabled directory server instance
# - set 
# - import into certdb: CACert, ServerCert, UserCert
set -e
ROOT_DN="cn=directory manager"
ROOT_PASS="password"
INIT_LDIF="todo.ldif"
CERT_CA="CA certificate"
CERT_CA_SN="cn=CAcert"
CERT_SERVER="Server-Cert"
HOSTNAME=$(hostname)
CERT_SERVER_SN="cn=$HOSTNAME"
BASEDIR="/etc/dirsrv/slapd-$(hostname -s)"
LOGDIR="/var/log/dirsrv/slapd-$(hostname -s)"
CERT_CLIENT="cn=r"
DOMAINNAME=$(dnsdomainname)

# Validate configuration variables
: ${DOMAINNAME:?Missing domain name}

#
# Utilities
#
log(){
    # Log to stderr
    logger -s -t entrypoint.sh "$@"
    }
#
# functions for setup
#
my_certutil(){
    certutil -d ${BASEDIR} -f ${BASEDIR}/pwdfile.txt -z ${BASEDIR}/noise.txt $@
    }
patch_disable_selinux_systemd(){
    rm -fr /usr/lib/systemd/system;
    sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/*
    sed -i '/if (@errs = startServer($inf))/,/}/d' /usr/lib64/dirsrv/perl/*
    }

create_cacert(){
    # Create a CA-Cert, answering Yes to the first and last question
    echo -e "y\n\ny\n"|\
        my_certutil -S -n "${CERT_CA}" -s "${CERT_CA_SN}" -x -t "CT,," -m 1000 -v 120 
    }
create_trusted_cert(){
    # Create a certificate trusted by the local CA for a given user and 
    #  using a random serial number TODO fixme with a sequential serial_no
    local name="$1"
    local sn="$2"
    local serial_no=$RANDOM
    
    my_certutil -S -n "${name}" -s "${sn}" -c "$CERT_CA" -t "u,u,u" -m "${serial_no}" -v 120
    }
export_keycert_to_pem(){
    local certname="$1"
    pk12util -d "$BASEDIR"  -n "NSS Certificate DB:${certname}" -o /dev/stdout -w ${BASEDIR}/pwdfile.txt | \
        openssl pkcs12  -nodes -clcerts -out "${certname}.pem" -password file:${BASEDIR}/pwdfile.txt
    }
export_cert_to_pem(){
    local certname="$1"
    my_certutil -L  -n "${certname}" 
    }

export_cert_to_ldif(){
    local certname="$1"
    my_certutil -L -n "${certname}" -a | python -c '
import sys
for i, x in enumerate(sys.stdin.readlines()):
  if "--" in x: continue
  if i>1: print "", 
  print x,

'
}

install(){  
    log "Installing 389 without SELinux and SystemD with basedir $BASEDIR"
    # Prepare for setup
    patch_disable_selinux_systemd
    sed > /setup.$HOSTNAME.inf -e "s/localhost.localdomain/${HOSTNAME}/g" /setup.inf 

    # Setup ds
    setup-ds.pl --silent --file=/setup.$HOSTNAME.inf --debug

    log "Configuring certmap.conf"
    echo >> "${BASEDIR}/certmap.conf" "
# Map certificate CN to user DN
certmap babel.it        $CERT_CA_SN
babel.it:DNComps
babel.it:FilterComps    cn
babel.it:verifycert     on

"
    log "Installation ok"
}

setup_certificates(){
    # 
    # Create certs: move to entrypoint.sh
    #
    mkdir -p /etc/openldap/cacerts/
    (cd $BASEDIR && {
        # create a noise file and an empty password file
        head /dev/urandom | base64 > noise.txt
        echo > pwdfile.txt
        # cleanup and reinitialize certdb
        rm *.db -f
        certutil -N --empty-password -d "$BASEDIR"
        # create a ca cert
        create_cacert;
        # create a trusted cert signed by the cacert
        create_trusted_cert "${CERT_SERVER}" "cn=$HOSTNAME" 
        # Create hashlinks to actual pem files
        my_certutil -L  -n "$CERT_CA" -a > /etc/openldap/cacerts/cacert.pem
        cacertdir_rehash /etc/openldap/cacerts/
        }
    )
}
    
setup_ssl(){
    #
    # To modify the configuration we need a running instance
    #
    ns-slapd -D $BASEDIR && sleep 3

    ldapmodify -x -D"cn=directory manager" -wpassword <<-EOF
dn: cn=encryption,cn=config
changetype: modify
replace: nsSSL3
nsSSL3: off
-
replace: nsSSLClientAuth
nsSSLClientAuth: allowed
-
add: nsSSL3Ciphers
nsSSL3Ciphers: +all

dn: cn=config
changetype: modify
add: nsslapd-security
nsslapd-security: on
-
replace: nsslapd-ssl-check-hostname
nsslapd-ssl-check-hostname: off

dn: cn=RSA,cn=encryption,cn=config
changetype: add
objectclass: top
objectclass: nsEncryptionModule
cn: RSA
nsSSLPersonalitySSL: ${CERT_SERVER}
nsSSLToken: internal (software)
nsSSLActivation: on

EOF

}

setup_tlsuser(){
#
# Add a user associated with a given certificate
#
# create a trusted cert for the user "cn=r,o=babel,c=it"
create_trusted_cert "cn=r" "cn=r,o=babel,c=it"
export_keycert_to_pem "cn=r"

ldapadd -x  -D"cn=directory manager" -wpassword <<-EOF
dn: cn=r,dc=babel,dc=it
cn: bind dn pseudo user
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetorgperson
sn: bind dn pseudo user
userpassword: password
usercertificate:: $(export_cert_to_ldif cn=r)

EOF
}

restart(){
    #
    # Restart 389
    #
    pkill -f ns-slapd &&
    sleep 3 &&
    ns-slapd -D $BASEDIR && 
    sleep 3
}
test(){
    #
    # Check connection
    #
    # Check connecting to a valid certificate 
    cat > "/ldapclient.env" <<-EOF
    export LDAPTLS_CACERTDIR="$BASEDIR"
    export LDAPTLS_KEY="$CERT_CLIENT" 
    export LDAPTLS_CERT="$CERT_CLIENT" 

EOF

    . /ldapclient.env
    ldapsearch -ZZZ   -LLL \
        -b"dc=babel,dc=it"  cn=r cn
}
#
# Main
#
case "$1" in
    'test')
        test
        ;;
    *)
        install
        setup_certificates
        setup_ssl
        setup_tlsuser
        restart
        test
        tail -F $LOGDIR/{access,errors} --max-unchanged-stats=5
        ;;
esac
