# Mesos packaging

Mesos is a cluster manager that provides efficient resource isolation and sharing across distributed applications, or frameworks.  See [Mesos website](http://mesos.apache.org/) for more details.

NOTE: if you build Mesos on system with e.g. `libcurl4-nss-dev` it will be hardlinked to this implementation library. On Debian `libcurl-dev` is the virtual package for:

  * `libcurl-dev`
  * `libcurl4-nss-dev`
  * `libcurl4-openssl-dev`

## GCC compatibility

| **Mesos version \ GCC** | gcc 4.4 | gcc 4.6 | gcc 4.7 | gcc 4.8 | gcc 4.9 |
|------------------------:|:-------:|:-------:|:-------:|:-------:|:-------:|
|  0.20                   |    ✔    |    ✔    |     ✔   |    ✔    |    ✔    |
|  0.21                   |    ✔    |    ✔    |     ✖   |    ✔    |    ✔    |
|  0.22                   |    ✖    |    ✖    |     ✖   |    ✔    |    ✔    |

Mesos is compiled with C++11 support.

## Mesos configuration

Mesos arguments could be specified by creating files structure in `/etc/mesos-slave` or in `/etc/mesos-master`.

For specifing e.g. `--isolation=cgroups` you would create

```
  /etc
    /mesos-slave
      isolation       # with contents 'cgroups'
```

In similar manner you can restrict hardware resources used by mesos-slave:

```
  /etc
    /mesos-slave
      /resources
        cpu          # with contents e.g. '5'
```

## Building package

Build deb package for Debian/Ubuntu with following:

```
./build_mesos --repo https://git-wip-us.apache.org/repos/asf/mesos.git?ref=0.15.0 --version 0.15.0
```

or supply just `ref` to tag in the (default) repo:
```
./build_mesos --ref 0.22.1 --build-version p1
```

If you want to activate GPU support (Mesos >= 0.29.0), you'll need to first have a local copy of bleeding edge of Mesos (as there is no rev yet). You'll also have installed the nVidia GDK as instructed in the [nVidia Guide](http://c99.millennium.berkeley.edu/documentation/latest/gpu-support/)

```
./build_mesos --src-dir=/path/to/mesos --enable-gpu
```

Then don't forget to look at the [nVidia doc](http://c99.millennium.berkeley.edu/documentation/latest/gpu-support/) to run Mesos Agent with the proper tags

### Debian Wheezy

Default gcc on Wheezy is 4.7 which isn't compatible with Mesos >= 0.21. A workaround is using
gcc 4.6 which could be used along with 4.7:

```
apt-get install gcc-4.6 g++-4.6
```

just specify `cxx` and `cc` flags:

```
./build_mesos --ref 0.21.1-rc2 --build-version 1 --cxx "g++-4.6" --cc "gcc-4.6"
```

### Compiled gcc from source

See [gcc instructions](https://gcc.gnu.org/wiki/InstallingGCC).
```
export LD_LIBRARY_PATH="/root/gcc-4.8.4/lib64"
export LD_RUN_PATH="/root/gcc-4.8.4/lib64"
export PATH="/root/gcc-4.8.4/bin:$PATH"
```

### Requirements

  * you'll definitely need ~2GB RAM for compilation
    * if fact due to `make -j $(($(num_cores)*2))` you need cca 2GB per core
  * Ruby (build scripts uses [FPM](https://github.com/jordansissel/fpm))
  * If using GPU, you must have followed the [nVidia Guide](http://c99.millennium.berkeley.edu/documentation/latest/gpu-support/) and installed requirements

#### Debian Jessie

  * install following packages

    ```
    $ sudo apt-get install build-essential ruby2.1 ruby2.1-dev rubygems
    $ gem install fpm
    $ sudo apt-get install build-essential python-dev autoconf automake git make libssl-dev libtool libsasl2-dev
    ```
  * some version of `libcurl-dev` (provided by multiple packages)
  * Mesos >= 0.21
    * Debian: `libapr1-dev libsvn-dev`


#### Debian Wheezy
    ```
    $ sudo apt-get install ruby1.9.1 ruby1.9.1-dev build-essential
    $ gem install fpm
    $ sudo apt-get install build-essential python-dev autoconf automake git make libssl-dev libtool libsasl2-dev
    ```
  * Java support
    * e.g. `openjdk-7-jre-headless`, `openjdk-7-jdk` ,`maven`
  * Python packages
    * Debian: `python-setuptools`

  * Mesos >= 0.14
    * Debian: `libsasl2-dev`
  * Mesos >= 0.21
    * Debian: `libapr1-dev libsvn-dev`

#### Ubuntu Xenial on Power + GPU (ppc64le) (should also work on Trusty on Power)

  * If you're using Power architecture (ppc64le) to compile, you may need to compile from source FPM. 
```
sudo apt-get update -qq
sudo apt-get install -y --force-yes \
  tar \
  wget \
  tree \
  autoconf \
  automake \
  git \
  make \
  gcc \
  libcurl4-nss-dev \
  libsasl2-dev \
  libsasl2-modules \
  libssl-dev \
  libapr1-dev \
  libsvn-dev \
  libffi-dev \
  openjdk-8-jdk \
  maven \
  autoconf libtool \
  build-essential \
  python-setuptools \
  python-dev \
  python-boto \
  ruby \
  ruby-dev \
  rubygems-integration \
  rake-compiler \
  bsdtar

# This is to build Marathon
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo apt-get update -yqq
sudo apt-get install -yqq --force-yes sbt

# Some gem dependencies
sudo gem install \
  yard \
  rspec \
  rubygems-tasks \
  bundler \
  tasks \
  task \
  custom_require

# We need to install FPM manually as it doesn't run on Xenial on Power
cd ~
git clone https://github.com/jordansissel/fpm.git
cd ~/fpm
bundle install 
make
sudo make install 

# This is hacky as the default nvidia script doesn't check for arch
case "$(arch)" in 
  "x86_64" | "amd64" )
    ARCH="amd64"
  ;;
  "ppc64le" | "ppc64el" ) 
    ARCH="ppc64le"
  ;;
esac

wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/gdk/gdk_linux_${ARCH}_352_79_release.run
chmod +x gdk_linux_${ARCH}_352_79_release.run
sudo ./gdk_linux_${ARCH}_352_79_release.run --installdir=/opt/nvidia-gdk --silent
echo "/opt/nvidia-gdk/usr/src/gdk/nvml/lib" | sudo tee /etc/ld.so.conf.d/nvidia-gdk.conf 
sudo ldconfig

# Using trunk
cd ~
git clone https://git-wip-us.apache.org/repos/asf/mesos.git 

git clone https://github.com/deric/mesos-deb-packaging.git

cd mesos-deb-packaging
./build-mesos --src-dir=${HOME}/mesos --enable-gpu
```


## Puppet

Package could be automatically configured by a [Puppet module](https://github.com/deric/puppet-mesos)

## Authors

   * Tomas Barton
   * Jason Dusek
   * Jeremy Lingmann
   * Chris Buben

