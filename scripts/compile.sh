#!/bin/bash

function test_compile()
{
    if [ $gTestCompileAtEveryStage -eq 0 ]; then
        return
    fi

    TARGET=$1
    _PRINT_MSG "--->: ${BLUE}Test compile ${TARGET}${OFF}"

    cd $BUILD/precompiled

    _tidy_exec "${TOOLS}/iasl -ve -p $BUILD/tmp/${TARGET}.aml ./${TARGET}.dsl" "test compile ${TARGET}.dsl"

    cd $BASE
}

function test_compile_all()
{
    if [ $gTestCompileAtEveryStage -eq 0 ]; then
        return
    fi

    _PRINT_MSG "--->: ${BLUE}Test compile${OFF}"

    cd $BUILD/precompiled
    list=`echo *`

    for aml in $list; do
        _tidy_exec "${TOOLS}/iasl -ve -p $BUILD/tmp/${aml%.*}.aml ./${aml%.*}.dsl" "test compile ${aml%.*}.dsl"
    done

    cd $BASE
}

function compile()
{
    _PRINT_MSG "--->: ${BLUE}Build DSDT and SSDTs${OFF}"

    cd $BUILD/precompiled
    list=`echo *`

    for aml in $list; do
        _tidy_exec "${TOOLS}/iasl -ve -p $ACPI/patched/${aml%.*}.aml ./${aml%.*}.dsl" "compile ${aml%.*}.dsl"
    done

    cd $BASE
}
