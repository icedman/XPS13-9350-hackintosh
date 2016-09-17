#!/bin/sh
set -x
kextstat -l -k | awk '{n = sprintf("%d", $4); print n, $6}' | sort -n
