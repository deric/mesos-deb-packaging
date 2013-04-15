#!/bin/bash
set -e
set -u
name=mesos
version=0.13.0
description="Apache Mesos is a cluster manager that provides efficient resource isolation
 and sharing across distributed applications, or frameworks. It can run Hadoop,
 MPI, Hypertable, Spark (a new framework for low-latency interactive and
 iterative jobs), and other applications."
url="http://incubator.apache.org/mesos/"
arch="amd64"
section="misc"
package_version=""
origdir="$(pwd)"
mesos_root_dir=usr/lib/${name}
#use old debian init.d scripts or ubuntu upstart
dist="debian"

# add e.g. to ~/.bash_profile 'export MAINTAINER="your@email.com"'
# if variable not set, use default value
if [[ -z "$MAINTAINER" ]]; then
  MAINTAINER="${USER}@localhost"
fi

#_ MAIN _#
rm -rf ${name}*.deb
mkdir -p tmp && pushd tmp
if [ ! -d ${name}/.git ]; then
  rm -rf ${name}
  git clone git://github.com/apache/mesos.git
  cd ${name}
else
  cd ${name}
  git pull 
fi

if [ ! -f "configure" ]; then
  autoreconf -f -i -Wall,no-obsolete
fi

#TODO: add param for cleaning build dir
cd build
if [ ! -f "deb/usr/local/lib/libmesos-${version}.so" ]; then
  ../configure
  make
  mkdir deb
  make install DESTDIR=`pwd`/deb
fi

if [ ! -d "deb" ]; then
  echo "expected 'deb' dir in `pwd`"
  exit 1
fi

cd deb
echo "entering package root `pwd`"
echo "building deb package ..."

#create directory structure
mkdir -p ${mesos_root_dir}
mkdir -p etc/default
mkdir -p etc/${name}/conf

cp ${origdir}/mesos.default etc/default/mesos
if [ $dist == "debian" ]; then
  mkdir -p etc/init.d
  # preserve executable flag
  cp -p ${origdir}/mesos.mesos-master.init etc/init.d/mesos-master
  cp -p ${origdir}/mesos.mesos-slave.init etc/init.d/mesos-slave
else
  mkdir -p etc/init
  cp ${origdir}/mesos.mesos-master.upstart etc/init/mesos-master
  cp ${origdir}/mesos.mesos-slave.upstart etc/init/mesos-slave
fi
mkdir -p var/log/${name}

#_ MAKE DEBIAN _#
fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="${url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    -m "$MAINTAINER" \
   --prefix=/ \
    -d "default-jre-headless | java6-runtime-headless" -d "lxc" \
    -s dir \
    -- .
mv ${name}*.deb ${origdir}
popd
