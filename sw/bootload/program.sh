#!/bin/sh

echo "Press ^C to stop"
`dirname $0`/bootloader.py -P /dev/ttyS0 -n

echo "Programming..."
`dirname $0`/bootloader.py -P /dev/ttyS0 -p $@
