#!/bin/bash

set -x

yum list installed
yum list updates
yum -y update
yum -y install tree gcc gcc-c++ automak

wget http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz
tar -zxvf cmake-2.8.10.2.tar.gz
cd cmake-2.8.10.2
./bootstrap
make
amke install

yum install -y python-pip
yum -y install epel-release
yum -y install cmake3
ln -s /usr/bin/cmake3 /usr/bin/cmake
