FROM debian:latest

RUN echo 'deb http://http.debian.net/debian wheezy main contrib non-free' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install g++
RUN apt-get install -y erlang-dev erlang-manpages erlang-base-hipe erlang-eunit erlang-nox erlang-xmerl erlang-inets

RUN apt-get install -y libmozjs-dev libicu-dev libcurl4-gnutls-dev libtool wget pwgen
RUN apt-get install -y wget
RUN apt-get install -y pwgen
RUN apt-get install -y curl

RUN cd /tmp ; wget http://apache.crihan.fr/dist/couchdb/source/1.5.1/apache-couchdb-1.5.1.tar.gz
RUN cd /tmp && tar xvzf apache-couchdb-1.5.1.tar.gz
RUN apt-get install -y make
RUN cd /tmp/apache-couchdb-* ; ./configure && make install

# Configure CouchDB
RUN mkdir /usr/local/cozy
RUN mkdir /etc/cozy
RUN pwgen -1 > /etc/cozy/couchdb.login
RUN pwgen -1 >> /etc/cozy/couchdb.login
RUN chmod 640 /etc/cozy/couchdb.login
RUN /usr/local/bin/couchdb -b && \
sleep 5 && while ! curl -s 127.0.0.1:5984; do sleep 5; done && \
curl -s -X PUT 127.0.0.1:5984/_config/admins/$(head -n1 /etc/cozy/couchdb.login) -d "\"$(tail -n1 /etc/cozy/couchdb.login)\""

RUN printf "[httpd]\nport = 5984\nbind_address = 0.0.0.0\n" >/usr/local/etc/couchdb/local.d/docker.ini

# Clean APT cache for a lighter image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 5984

VOLUME ["/usr/local/var/lib/couchdb", "/etc/cozy", "/usr/local/cozy", "/usr/local/var/log/" , "/usr/local/etc/couchdb"]
CMD ["/usr/local/bin/couchdb"]