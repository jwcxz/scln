#!/usr/bin/env python2

import argparse, time
from bootlib import *

p = argparse.ArgumentParser(description="Send Actions to the LED Controller Bootloader");

p.add_argument('-P', '--port', dest='port', action='store', default='/dev/ttyUSB0',
        help='communications port');

p.add_argument('-n', '--nops', dest='nops', action='store_true',
        help='send a string of NOPs to initialize the bootloader (stop with ctrl+C)');

p.add_argument('-m', '--mask', dest='mask', action='store', default=None,
        help='set device mask for all operations');

p.add_argument('-a', '--address', dest='address', action='store', default=None,
        help='set device address');

p.add_argument('-e', '--eset', dest='eset', action='store', default=None,
        nargs=2, help='set eeprom at address to contain a byte of data',
        metavar=('EEADDR', 'DATA'));

p.add_argument('-g', '--eget', dest='eget', action='store', default=None,
        help='read data from an address on the eeprom');

p.add_argument('-p', '--prog', dest='file', action='store', default=None,
        help='program the device');


p.add_argument('-d', '--display', dest='disp', action='store_true',
        help='display the device address');

p.add_argument('-f', '--finish', dest='finish', action='store_true',
        help='enable flash after programming');

p.add_argument('-r', '--boot', dest='boot', action='store_true',
        help='run the application');

args = p.parse_args();

btldr = Bootloader(args.port);
# wait for the bootloader to activate
btldr.activate();

if args.nops == True:
    while True:
        btldr.write(btldr.CMDS['NOP']);
        time.sleep(0.250);

if args.mask != None: 
    print "applying mask 0x%02x" % int(args.mask);
    btldr.mask(int(args.mask));
    time.sleep(.1);

if args.address != None: 
    print "setting device address 0x%02x" % int(args.address);
    btldr.setaddr(int(args.address));
    time.sleep(.1);

if args.eset != None:
    print "setting eeprom address 0x%02x to contain 0x%02x" % (int(args.eset[0]), int(args.eset[1]));
    btldr.eset(int(args.eset[0]), int(args.eset[1]));
    time.sleep(.1);

if args.eget != None:
    print "reading eeprom address 0x%02x" % (int(args.eget));
    btldr.eget(int(args.eget));
    time.sleep(.1);

if args.file != None:
    print "programming with %s" % args.file;
    btldr.program(args.file);
    time.sleep(.1);

if args.disp == True:
    print "displaying device address";
    btldr.disp();
    time.sleep(.1);

if args.finish == True:
    print "re-enabling the application section";
    btldr.finish();
    time.sleep(.1);

if args.boot == True:
    print "booting the device";
    btldr.boot();
    time.sleep(.1);
