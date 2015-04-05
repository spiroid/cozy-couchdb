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
    curl

RUN pip install supervisor

# Create Cozy users, without home directories.
RUN useradd -M cozy

# Configure CouchDB
RUN mkdir /usr/local/cozy
RUN mkdir /etc/cozy \
&& chown -hR cozy /etc/cozy
RUN pwgen -1 > /etc/cozy/couchdb.login
RUN pwgen -1 >> /etc/cozy/couchdb.login
RUN chmod 640 /etc/cozy/couchdb.login
RUN mkdir /var/run/couchdb \
&& chown -hR couchdb /var/run/couchdb \
&& su - couchdb -c 'couchdb -b' \
&& sleep 5 \
&& while ! curl -s 127.0.0.1:5984; do sleep 5; done \
&& curl -s -X PUT 127.0.0.1:5984/_config/admins/$(head -n1 /etc/cozy/couchdb.login) -d "\"$(tail -n1 /etc/cozy/couchdb.login)\""

RUN printf "[httpd]\nport = 5984\nbind_address = 0.0.0.0\n" > /etc/couchdb/local.d/docker.ini

# Configure Supervisor.
ADD supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor \
&& chmod 777 /var/log/supervisor \
&& /usr/local/bin/supervisord -c /etc/supervisord.conf

# Import Supervisor configuration files.
ADD supervisor/couchdb.conf /etc/supervisor/conf.d/couchdb.conf
RUN chmod 0644 /etc/supervisor/conf.d/*

# Clean APT cache for a lighter image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 5984

VOLUME ["/var/lib/couchdb", "/etc/cozy", "/usr/local/cozy", "/var/log/couchdb"]
CMD [ "/usr/local/bin/supervisord", "-n", "-c", "/etc/supervisord.conf" ]