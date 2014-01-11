# Mesos packaging

Build scripts to create a binary package with [FPM](https://github.com/jordansissel/fpm) for simple installation in a cluster.

Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks. It can run Hadoop, MPI, Hypertable, Spark (a new framework for low-latency interactive and iterative jobs), and other applications. Currently is in the Apache Incubator and going through rapid development, though stable enough for a production usage. See [Mesos website](http://incubator.apache.org/mesos/) for more details.

## Requirements

  * ruby
  * prerequisites:

       gem install fpm
       sudo apt-get install python-dev autoconf automake git make libssl-dev libcurl3

  * jdk, tested on Oracle java, but it should work on openjdk as well:

       sudo apt-get install oracle-java7-jdk

## Building package

Build deb package for Debian/Ubuntu with following:

        sudo ./build_mesos --repo https://git-wip-us.apache.org/repos/asf/mesos.git?ref=0.15.0 --nominal-version 0.15.0

## TODO

   * RedHat/CentOS RPM support

## Authors

   * Tomas Barton
   * Jason Dusek
   * Jeremy Lingmann
   * Chris Buben

