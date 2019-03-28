FROM ubuntu:18.04


ENV DEBIAN_FRONTEND=noninteractive

# Helpers
RUN apt-get update && apt-get install -y vim xterm pulseaudio cups 

RUN apt-get -y dist-upgrade 
RUN apt-get install -y  mate-desktop-environment-core mate-desktop-environment mate-indicator-applet ubuntu-mate-themes ubuntu-mate-wallpapers firefox sudo

RUN apt-get install -y wget

RUN wget https://download.nomachine.com/download/6.5/Linux/nomachine_6.5.6_9_amd64.deb -O /nomachine.deb

RUN dpkg -i /nomachine.deb

RUN apt-get clean
RUN apt-get autoclean

RUN echo 'pref("browser.tabs.remote.autostart", false);' >> /usr/lib/firefox/browser/defaults/preferences/vendor-firefox.js

#Instalar ldap client
RUN apt-get update && apt-get install libpam-ldap libnss-ldap nss-updatedb libnss-db nscd ldap-utils -y

# enable ldap user authentification
RUN sed -i 's/^\(passwd\|group\|shadow\):\(.*\)/#\1: \2/gm' /etc/nsswitch.conf &&\
    sed -i '$a passwd: files ldap' /etc/nsswitch.conf &&\
    sed -i '$a group: files ldap' /etc/nsswitch.conf &&\
    sed -i '$a shadow: files ldap' /etc/nsswitch.conf &&\
    # set timezone
    ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
 

RUN groupadd -r nomachine -g 433 && \
useradd -u 431 -r -g nomachine -d /home/nomachine -s /bin/bash -c "NoMachine" nomachine && \
mkdir /home/nomachine && \
chown -R nomachine:nomachine /home/nomachine && \
echo 'nomachine:nomachine' | chpasswd

RUN echo "nomachine    ALL=(ALL) ALL" >> /etc/sudoers

EXPOSE 4000
EXPOSE 22

VOLUME [ "/home/nomachine" ]

ADD nxserver.sh /

RUN chmod +x /nxserver.sh

ENTRYPOINT ["/nxserver.sh"]
