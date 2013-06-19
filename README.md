# Mesos Debian packaging

Build scripts to create a Mesos Debian package with FPM for simple installation in a cluster. 

Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks. It can run Hadoop, MPI, Hypertable, Spark (a new framework for low-latency interactive and iterative jobs), and other applications. Currently is in the Apache Incubator and going through rapid development, though stable enough for a production usage. See (Mesos website)[http://incubator.apache.org/mesos/] for more details.

## Requirements

  * FPM (https://github.com/jordansissel/fpm)
  * python (2.6 or newer)
  * python-dev
  * ruby
  * git
  * autoconf
  * make
  * g++
  * java
  * lxc

in commands: 

       gem install fpm
       sudo apt-get install python-dev autoconf automake git make libssl-dev libcurl3

define in e.g. `~/.bash_profile` a `MAINTAINER` variable

	export MAINTAINER="email@example.com"

## Building deb package

	./build_mesos.sh

## Authors

   * Tomas Barton

