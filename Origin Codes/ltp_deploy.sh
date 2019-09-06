#!/bin/bash

set -x

yum -y install gcc gcc-c++ bzip2 wget
yum -y install epel-release
yum -y install cmake3
ln -s /usr/bin/cmake3 /usr/bin/cmake
wget https://github.com/linux-test-project/ltp/releases/download/20190517/ltp-full-20190517.tar.bz2

tar -xjf ltp-full-20190517.tar.bz2

cd ltp-full-20190517/

./configure
make
make install
