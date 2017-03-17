#!/bin/sh
set -x
pmset -a hibernatemode 0
rm /var/vm/sleepimage
mkdir /var/vm/sleepimage

rm /private/var/vm/sleepimage
mkdir /private/var/vm/sleepimage