#!/bin/sh

set -x
cp /Users/iceman/Developer/OS-X-Voodoo-PS2-Controller/build/Products/Release/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext/Contents/MacOS/VoodooPS2Trackpad /System/Library/Extensions/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext/Contents/MacOS/VoodooPS2Trackpad 
kextunload /System/Library/Extensions/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext
kextload /System/Library/Extensions/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext