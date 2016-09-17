#!/bin/sh
set -x
kextstat | grep -y acpiplat
kextstat | grep -y appleintelcpu
kextstat | grep -y applelpc
kextstat | grep -y applehda
