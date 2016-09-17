#!/bin/sh

set -x

sudo chmod -Rf 755 /Library/Extensions
sudo chown -Rf 0:0 /Library/Extensions
sudo touch /Library/Extensions

sudo chmod -Rf 755 /System/Library/Extensions
sudo chown -Rf 0:0 /System/Library/Extensions
sudo touch /System/Library/Extensions

sudo kextcache -Boot -U /


