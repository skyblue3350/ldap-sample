FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /var/run/sshd

RUN apt-get update \
 && apt-get install -y \
   libnss-ldapd \
   libpam-ldapd \
   openssh-server

RUN apt-get install -y vim

RUN echo "session optional        pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session

COPY files/nsswitch.conf /etc
COPY files/init.sh /

ENTRYPOINT ["bash"]
CMD ["/init.sh"]
