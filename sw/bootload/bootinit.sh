#!/bin/sh

cd `dirname $0`

echo "Press ^C to stop"
./bootloader.py -n

echo "Performing requested bootloader operations..."
./bootloader.py $@
