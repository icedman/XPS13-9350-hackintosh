#!/bin/sh

set -x
cp ./etc/* /etc/
cp ./sleepwatcher /usr/local/sbin/sleepwatcher
cp ./com.syscl.externalfix.sleepwatcher.plist /Library/LaunchDaemons/
launchctl load /Library/LaunchDaemons/com.syscl.externalfix.sleepwatcher.plist 