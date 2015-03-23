#
# Docker instance showing a 389 instance with 
#     - TLS enabled
#     - TLS authentication
# docker build --tag 389:tls .
FROM centos:7
MAINTAINER roberto.polli@par-tec.it
RUN yum -y install 389-ds-base \
	authconfig \
	hostname \
	nss-tools 

VOLUME /etc/openldap/cacerts/
VOLUME /var/lib/dirsrv
VOLUME /etc/dirsrv
VOLUME /var/log/dirsrv


COPY setup.inf /setup.inf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
COPY Dockerfile /Dockerfile
