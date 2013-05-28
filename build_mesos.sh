#!/bin/bash
#
# Usage: clean build (will compile all files)
#
#     $ ./build_mesos.sh clean
#
#  or $ ./build_mesos.sh 
#
#  will use current libmesos-${version}.so, if exists
#
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
with_java=true
origdir="$(pwd)"
mesos_root_dir=usr/lib/${name}
#use old debian init.d scripts or ubuntu upstart
dist="debian"

CLEAN="false"
if [ $# -ge 1 ]; then
  if [ $1 == "clean" ]; then
	echo "got clear arg"
    CLEAN="true"
  fi
fi

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
  git --no-pager log --pretty=format:"%h%x09%an%x09%ad%x09%s" --decorate --graph > CHANGELOG 
fi

if [ ${CLEAN} == "true" ]; then
  echo "cleaning previous build"
  rm -rf build
  mkdir build
fi

if [ ! -f "configure" ]; then
  autoreconf -f -i -Wall,no-obsolete
fi

cd build
if [ ! -f "deb/usr/local/lib/libmesos-${version}.so" ]; then
  if $with_java ; then
    ../configure JAVA_HOME=${JAVA_HOME}
  else
    ../configure
  fi
  make
  if [ ! -d "deb" ]; then
    mkdir deb
  fi
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
mkdir -p ${mesos_root_dir}/doc
mkdir -p etc/default
mkdir -p etc/${name}

mkdir -p usr/local/var/mesos/deploy

#copy git changelog
cp ../../CHANGELOG ${mesos_root_dir}/doc

#copy config files
cp ${origdir}/conf etc/mesos/mesos.conf
cp ${origdir}/default/mesos etc/default/mesos
cp ${origdir}/default/master etc/default/mesos-master
cp ${origdir}/default/slave etc/default/mesos-slave
if [ $dist == "debian" ]; then
  mkdir -p etc/init.d
  # preserve executable flag
  cp -p ${origdir}/init.d/master.init etc/init.d/mesos-master
  cp -p ${origdir}/init.d/slave.init etc/init.d/mesos-slave
else
  mkdir -p etc/init
  cp ${origdir}/init/master.upstart etc/init/mesos-master
  cp ${origdir}/init/slave.upstart etc/init/mesos-slave
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
    --deb-recommends "default-jre-headless | java6-runtime-headless" \
    --deb-recommends "lxc" --deb-recommends "python >= 2.6" \
    -d "libcurl3" \
    --after-install "/sbin/ldconfig" \
    -s dir \
    -- .
mv ${name}*.deb ${origdir}
popd
