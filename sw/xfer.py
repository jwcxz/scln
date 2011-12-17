#!/usr/bin/env python2

import math, time, serial, sys

def convert(d):
    return chr(min(255, max(0, int(d, 16))));

if len(sys.argv) < 2:
    serport = "/dev/ttyS0"
else:
    serport = sys.argv[1]

cxn = serial.Serial(serport, 9600);
print ":: opened", cxn.portstr;

data = sys.stdin.readlines();
print ":: read data from stdin"

if len(data) == 1: data = data[0].split(' ');

tx = "";
for d in data:
    tx += convert(d);

cxn.write(tx);

print "done"
sys.exit(0);
