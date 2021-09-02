# Use the latest Alpine image
FROM debian:latest
MAINTAINER "Christopher Gray" <christophermjgray@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive TZ=UTC

# Initial updates and install core utilities
RUN apt-get update -qq -y && \
    apt-get upgrade -y && \
    apt-get install -y \
       wget \
       curl \
       apt-transport-https \
       lsb-release \
       ca-certificates \
       gnupg2 \
       software-properties-common \
       locales \
       cron    
RUN dpkg-reconfigure locales

# Install Webmin
RUN echo root:password | chpasswd && \
    echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
    update-locale LANG=C.UTF-8 && \
    wget http://www.webmin.com/download/deb/webmin-current.deb \
    sudo dpkg -i webmin-current.deb
    apt-get update && \
    apt-get upgrade && \
    apt-get clean

EXPOSE 10000
ENV LC_ALL C.UTF-8

WORKDIR /home
RUN echo "#! /bin/bash" > entrypoint.sh && \
    echo "sed -i 's;ssl=1;ssl=0;' /etc/webmin/miniserv.conf && systemctl enable cron && service webmin start && tail -f /dev/null" >> entrypoint.sh && \
    chmod 755 entrypoint.sh

CMD /home/entrypoint.sh
