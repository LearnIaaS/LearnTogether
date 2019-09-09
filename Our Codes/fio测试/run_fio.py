#!/usr/bin/python

import json
import os
import configparser


cf = configparser.ConfigParser()
path = os.path.abspath('.')
path = path + "/config.ini"

cf.read(path)

dic = cf.items("FIO")
cmd = "";

for item in dic:
	command = item[0].encode('unicode-escape').decode('string_escape')
	value = item[1].encode('unicode-escape').decode('string_escape')
	result = " --" + command + "=" + value
	cmd = cmd + result

print cmd

cmd = "fio" + cmd
print cmd

result = os.system(cmd + " > ./result.json")
if result == 0:
    print("fio success")
else:
    print("fio error")

f = file('result.json')
test = json.load(f)

jobs = test['jobs']
jobs = jobs[0]
read = jobs['read']
bw = read['bw']
iops = read['iops']
slat_ns = read['slat_ns']
clat_ns = read['clat_ns']

usr_cpu = jobs['usr_cpu']
sys_cpu = jobs['sys_cpu']
ctx = jobs['ctx']
majf = jobs['majf']
minf = jobs['minf']
iodepth_level = jobs['iodepth_level']

print "read:"
print "IOPS={a}, BW={b}MiB/s".format(a=iops, b=bw) 
print "slat(usec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=slat_ns['min'], b=slat_ns['max'], \
		c=slat_ns['mean'], d=slat_ns['stddev'])
print "clat(nsec):min={a}, max={b}, mean={c}, stddev={d}"\
		.format(a=clat_ns['min'], b=clat_ns['max'], \
		c=clat_ns['mean'], d=clat_ns['stddev'])
print "cpu:"
print "usr={a}%, sys={b}%, ctx={c}, majf={d}, minf={e}"\
		.format(a=usr_cpu, b=sys_cpu, c=ctx, d=majf, e=minf)

print "IO depths:"
t_1=iodepth_level['1']
t_2=iodepth_level['2']
t_3=iodepth_level['4']
t_4=iodepth_level['8']
t_5=iodepth_level['16']
t_6=iodepth_level['32']
t_7=iodepth_level['>=64']
print "1={a}%, 2={b}%, 4={c}%, 8={d}%, 16={e}%, 32={f}%, >=64={g}%"\
		.format(a=t_1, b=t_2, c=t_3, d=t_4, e=t_5, f=t_6, g=t_7)
