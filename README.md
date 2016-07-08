# Buildenvironment for Jenkins 2.x server running in docker

**Features:**

  * Support for latest jenkins lts version (2.7.1)
  * SSL support
  * Support for LDAP
  * Makefile for easy (re-)building new containers
  * Use of docker-compose for easy starting/stopping containers
  * Use of sep. network space (see: _networks:_ in docker-compose.yml)
  * Use of persistent folders (see: _volumes:_ in docker-compose.yml)
  * Highly customizable via plugins (see: _assets/build/etc/plugins.txt_) and
    environmental files (see: _assets/env/*_)

**Notice:** Always use 'make' when building a new container!!

## Build new container:

    make

## Remove container:

    make clean

## Start container:

    docker-compose up [-d]

**Notice:** Jenkins can be accessed via https://\<docker-host-ip\>

## Stop container:

    docker-compose down [-v]
