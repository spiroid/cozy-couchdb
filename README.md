# @Deprecated

This docker image is not maintained anymore, and shouldn't be used.
Please have a look at [that cozy repository](https://github.com/spiroid/cozy/tree/refactor-compose-v2) that
is based on a standard couchdb docker image instead.

# Cozy couchdb

Couchdb image for the [cozy cloud](https://cozy.io) stack


## Pull the image

```
$ docker pull spiroid/cozy-couchdb
```


## Build it yourself

```
$ git clone git@github.com:spiroid/cozy-couchdb.git
$ cd cozy-couchdb
$ doker build -t spiroid/cozy-couchdb .
```

## Run:

With docker-compose:

```
configuration:
    image: spiroid/cozy-conf

couchdata:
    image: spiroid/cozy-couchdb-data

couchdb:
    image: spiroid/cozy-couchdb
    volumes_from:
        - couchdata
        - configuration
    volumes:
        - $HOME/cozy-cloud/var/log/couchdb:/var/log/couchdb
```

replace $HOME by your actual home directory


## Related images

This configuration image was created to work with the following images:

  * [cozy conf](https://github.com/spiroid/cozy-conf)
  * [cozy couchdb data](https://github.com/spiroid/cozy-couchdb-data) 
  * [cozy controller](https://github.com/spiroid/cozy-controller)
  * [cozy data indexer](https://github.com/spiroid/cozy-data-indexer)
  


## Inspirations

 * https://forum.cozy.io/t/deployer-cozy-avec-docker-et-des-containers-autonomes/468
