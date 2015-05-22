FROM debian:sid
MAINTAINER Rony Dray <contact@obigroup.fr>, Jonathan Dray <jonathan.dray@gmail.com>

# Install packages
RUN apt-get -y update
RUN apt-get install -y \
    g++ \
    couchdb \
    python-pip \
    wget \
    curl

# Clean APT cache for a lighter image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure CouchDB
RUN mkdir /var/run/couchdb && \
    chown couchdb /var/run/couchdb

# Copy couch db configuration file for cozy cloud
ADD couchdb/cozy.ini /etc/couchdb/local.d/cozy.ini

# Generate a random password for couch admin user
RUN COUCH_PASSWD=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}`; \
    echo $COUCH_PASSWD > /var/lib/couchdb/.passwd && \
    sed -ir "s/<admin>/${COUCH_PASSWD}/g" /etc/couchdb/local.d/cozy.ini && \
    chown couchdb /etc/couchdb/local.d/cozy.ini

#Add file for backup/restore
ADD sh/backup.sh /usr/local/bin/backup.sh
ADD sh/restore.sh /usr/local/bin/restore.sh

# Expose couch port to make it easier for other docker containers
EXPOSE 5984

# Default user when running the container
USER couchdb

# Configuration and data directories as volumes
VOLUME ["/etc/couchdb/", "/var/lib/couchdb/"]

# Setting config dir to couch main directory
WORKDIR /var/lib/couchdb

# Main command
CMD ["/usr/bin/couchdb"]
