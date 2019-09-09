#!/bin/bash

set -x

mkdir /mnt/nas0/
yum -y install python-pip
pip install configparser
yum -y install fio
yum -y install libaio-devel