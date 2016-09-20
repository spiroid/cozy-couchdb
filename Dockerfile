# Need a debian sid for now to get decent version of couchdb
FROM debian:sid
MAINTAINER Jonathan Dray <jonathan.dray@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && apt-get install --quiet --assume-yes --no-install-recommends \
    couchdb \
    && apt-get clean

# Clean APT cache for a lighter image
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add cozy specific configuration file
ADD cozy.ini /etc/couchdb/local.d/cozy.ini

# Container entry point
COPY docker-entrypoint.sh /usr/local/bin/

# Fix directories & permissions
RUN mkdir /var/run/couchdb \
&& chown -hR couchdb /var/run/couchdb \
&& chown couchdb /etc/couchdb/local.d/cozy.ini

# Expose couch port to make it easier for other docker containers
EXPOSE 5984

VOLUME ["/var/lib/couchdb/", "/var/log/couchdb"]

# Setting config dir to couch main directory
WORKDIR /var/lib/couchdb

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default user when running the container
USER couchdb
CMD ["couchdb"]
