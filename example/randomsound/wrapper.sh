#!/bin/sh
./emergency_button_daemon.pl /dev/cu.usbserial-A900fr01 ./playaction.sh > wrapper.log 2>&1
