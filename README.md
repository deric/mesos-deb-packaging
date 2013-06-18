# Mesos Debian packaging

Build scripts to create a Debian package with FPM

## Requirements

  * FPM (https://github.com/jordansissel/fpm)
  * python (2.6 or newer)
  * python-dev
  * git
  * autoconf
  * make
  * g++
  * java
  * lxc

in commands: 

       gem install fpm
       apt-get install python-dev autoconf automake git make

define in e.g. `~/.bash_profile` a `MAINTAINER` variable

	export MAINTAINER="email@example.com"

## Building package

	./build_mesos.sh



