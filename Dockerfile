FROM debian:latest
MAINTAINER Rony Dray <contact@obigroup.fr>

RUN echo 'deb http://http.debian.net/debian wheezy main contrib non-free' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get install -y \
    g++ \
    couchdb \
    python-pip \
    wget \
    pwgen \
    curl \
    && apt-get clean

# Clean APT cache for a lighter image
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install supervisor

# Create Cozy users, without home directories.
RUN useradd -M cozy \
&& useradd -M cozy-data-system

# Configure CouchDB
RUN mkdir /etc/cozy \
&& chown -hR cozy /etc/cozy \
&& pwgen -1 > /etc/cozy/couchdb.login \
&& pwgen -1 >> /etc/cozy/couchdb.login \
&& chmod 640 /etc/cozy/couchdb.login \
&& mkdir /var/run/couchdb \
&& chown -hR couchdb /var/run/couchdb
RUN su - couchdb -c 'couchdb -b'
RUN sleep 5
# RUN while ! curl -s 127.0.0.1:5984; do sleep 5; done
RUN curl -s -X PUT 127.0.0.1:5984/_config/admins/$(head -n1 /etc/cozy/couchdb.login) -d "\"$(tail -n1 /etc/cozy/couchdb.login)\""

RUN printf "[httpd]\nport = 5984\nbind_address = 0.0.0.0\n" > /etc/couchdb/local.d/docker.ini

# Configure Supervisor.
ADD supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor \
&& chmod 774 /var/log/supervisor \
&& /usr/local/bin/supervisord -c /etc/supervisord.conf

# Import Supervisor configuration files.
ADD supervisor/couchdb.conf /etc/supervisor/conf.d/couchdb.conf
RUN chmod 0644 /etc/supervisor/conf.d/*

#Add file for backup/restore
ADD sh/backup.sh /home/backup.sh
ADD sh/restore.sh /home/restore.sh

# EXPOSE 5984

VOLUME ["/etc/cozy", "/var/lib/couchdb/"]
CMD [ "/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]