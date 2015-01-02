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
./build_mesos --ref 0.21.0 --version 0.21.0
```

### Debian Wheezy

Default gcc on Wheezy is 4.7 which isn't compatible with Mesos >= 0.21. A workaround is using
gcc 4.6 which could be used along with 4.7:

```
apt-get install gcc-4.6 g++-4.6
```

just specify `cxx` and `cc` flags:

```
./build_mesos --ref 0.21.1-rc2 --version 0.21.1 --cxx "g++-4.6" --cc "gcc-4.6"
```

### Requirements

  * you'll definitely need ~2GB RAM for compilation
    * if fact due to `make -j $(($(num_cores)*2))` you need cca 2GB per core
  * Ruby (build scripts uses [FPM](https://github.com/jordansissel/fpm))

    ```
    $ sudo apt-get install ruby1.9.1 ruby1.9.1-dev build-essential
    $ gem install fpm
    $ sudo apt-get install build-essential python-dev autoconf automake git make libssl-dev libcurl4-nss-dev libtool libsasl2-dev
    ```
  * Java support
    * e.g. `openjdk-7-jre-headless`, `openjdk-7-jdk` ,`maven`
  * Python packages
    * Debian: `python-setuptools`

  * Mesos >= 0.14
    * Debian: `libsasl2-dev`
  * Mesos >= 0.21
    * Debian: `libapr1-dev libsvn-dev`

## Puppet

Package could be automatically configured by a [Puppet module](https://github.com/deric/puppet-mesos)

## Authors

   * Tomas Barton
   * Jason Dusek
   * Jeremy Lingmann
   * Chris Buben

