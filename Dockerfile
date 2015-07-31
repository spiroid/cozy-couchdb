# Need a debian sid for now to get decent version of couchdb
FROM debian:sid
MAINTAINER Rony Dray <contact@obigroup.fr>, Jonathan Dray <jonathan.dray@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get install --quiet --assume-yes --no-install-recommends \
    couchdb \
    && apt-get clean

# Clean APT cache for a lighter image
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create Cozy users, without home directories
RUN useradd -M cozy \
&& useradd -M cozy-data-system

# Copy couch db configuration file for cozy cloud
ADD couchdb/cozy.ini /etc/couchdb/local.d/cozy.ini

# Generate a random login and password for couchdb
RUN mkdir /etc/cozy \
&& chown -hR cozy /etc/cozy \
&& COUCH_LOGIN=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`; \
echo $COUCH_LOGIN > /etc/cozy/couchdb.login \
&& sed -ir "s/<login>/${COUCH_LOGIN}/g" /etc/couchdb/local.d/cozy.ini \
&& COUCH_PASSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`; \
echo $COUCH_PASSWD >> /etc/cozy/couchdb.login \
&& sed -ir "s/<pwd>/${COUCH_PASSWD}/g" /etc/couchdb/local.d/cozy.ini \
&& chown couchdb /etc/couchdb/local.d/cozy.ini \
&& chmod 640 /etc/cozy/couchdb.login \
&& mkdir /var/run/couchdb \
&& chown -hR couchdb /var/run/couchdb


# Expose couch port to make it easier for other docker containers
EXPOSE 5984

VOLUME ["/etc/cozy", "/etc/couchdb/", "/var/lib/couchdb/"]

# Setting config dir to couch main directory
WORKDIR /var/lib/couchdb

# Default user when running the container
USER couchdb
CMD ["/usr/bin/couchdb"]
