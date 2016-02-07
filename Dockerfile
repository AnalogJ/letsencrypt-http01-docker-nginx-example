FROM phusion/baseimage
MAINTAINER jason@thesparktree.com

# Install Nginx and Letsencrypt dependencies
RUN \
  apt-get update && \
  apt-get install -y nginx && \
  apt-get install -y openssl curl sed grep mktemp git && \
  rm -rf /var/lib/apt/lists/*

# install letsencrypt.sh into /srv/letsencrypt
RUN git clone https://github.com/lukas2511/letsencrypt.sh.git /srv/letsencrypt

# configure letsencrypt.sh
RUN chmod +x /srv/letsencrypt/letsencrypt.sh && \
	mkdir -p /srv/letsencrypt/.acme-challenges && \
	mkdir -p /var/www/ && \
	ln -s /srv/letsencrypt/.acme-challenges /var/www/letsencrypt


### The following section is specifically for enabling templates.
### This allows you to dynamically specify the domain at runtime.

# Create confd folder structure
RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64
RUN chmod u+x  /usr/local/bin/confd
COPY ./conf.d /etc/confd/conf.d
COPY ./templates /etc/confd/templates


# Run the startup.sh script when baseimage-docker's init system runs
COPY ./startup.sh /etc/my_init.d/startup.sh
RUN chmod u+x  /etc/my_init.d/startup.sh


VOLUME ["/srv/letsencrypt/certs"]

EXPOSE 80
EXPOSE 443

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
