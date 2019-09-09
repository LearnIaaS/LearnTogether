#!/bin/bash

set -x

mkdir /mnt/nas0/
yum -y install python-pip
pip install configparser

yum -y install libaio-devel
yum -y install gtk2
yum -y install gtk2-devel

wget http://brick.kernel.dk/snaps/fio-3.12.tar.gz
tar -zxvf fio-3.12.tar.gz
cd fio-3.12/
./configure --enable-gfio
make
make install