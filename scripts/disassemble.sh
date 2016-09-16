#!/bin/bash

# disassemble.sh
#
# Creates DSL files from raw Linux extract
#
# Part of DSDT paching process for Haswell Envy 15
#
# Created by RehabMan
#

function disassemble()
{
    if [ ! -d "${BUILD}/tmp" ]; then
        mkdir $BUILD/tmp
    fi
    if [ ! -d "${BUILD}/raw" ]; then
        mkdir $BUILD/raw
    fi
    if [ ! -d "${BUILD}/precompiled" ]; then
        mkdir $BUILD/precompiled
    fi

    rm $BUILD/tmp/*
    rm $BUILD/raw/*
    rm $BUILD/precompiled/*
    rm $ACPI/patched/*

    _tidy_exec "cp ${ACPI}/origin/DSDT.aml ${ACPI}/origin/SSDT* ${BUILD}/tmp" "copy DSDT and SSDT files"
    cd $BUILD/tmp
    _tidy_exec "rm *x.aml" "exclude dynamic"
    list=`echo *`

    for aml in $list; do
        _tidy_exec "${TOOLS}/iasl -da -dl -fe ${BASE}/patches/refs.txt -p ${BUILD}/raw/${aml%.*}.dsl -e ${list//$aml/} -d $aml" "disassemble ${aml%.*}.dsl"
    done

    _tidy_exec "cp ${BUILD}/raw/*.dsl ${BUILD}/precompiled/" "copy to precompiled"

    cd $BASE
}

function ignore_acpi_file()
{
    SSDT_FILE=$1
    rm $BUILD/precompiled/$SSDT_FILE.dsl
    _tidy_exec "cp $CLOVER/ACPI/origin/$SSDT_FILE.aml $CLOVER/ACPI/patched/$SSDT_FILE.aml" "ignoring ${SSDT_FILE}"
}
