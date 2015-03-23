# dockerfiles
Dockerfiles for various services

## 389 with TLS
A 389ds instance with TLS authentication.
Run with docker-compose up, or with

    #docker run --rm -ti --entrypoint /entrypoint.sh --hostname myhost.docker  389:tls

A Certification Authority with two certs is created:
  
    - the server certificate
    - a user certificate

You can manipulate certificates connecting to the 
machine volume /etc/dirsrv/slapd-$hostname

    #certutil -d /etc/dirsrv/slapd-$hostname -L
