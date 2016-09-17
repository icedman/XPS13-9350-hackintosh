#!/bin/sh

BASE=$(pwd)

source "$BASE/config"
source "$BASE/scripts/_deploy.sh"
source "$BASE/scripts/disassemble.sh"
source "$BASE/scripts/compile.sh"
source "$TOOLS/patch_hda/patch_hda.sh"

function acpi_patching()
{
    disassemble

    #just preserve files
    ignore_acpi_file "SSDT-0"
    ignore_acpi_file "SSDT-1"
    ignore_acpi_file "SSDT-2"
    ignore_acpi_file "SSDT-3"
    ignore_acpi_file "SSDT-4"
    ignore_acpi_file "SSDT-6"
    ignore_acpi_file "SSDT-14"

    test_compile_all

    _tidy_exec "_find_acpi" "Search specification tables by syscl/Yating Zhou"

    #
    # DSDT Patches.
    #
    _PRINT_MSG "--->: ${BLUE}Patching DSDT.dsl${OFF}"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "rename_DSM"" "remove all _DSM methods"
    _tidy_exec "patch_acpi DSDT xps9350_patches/brightness "keyboard"" "brightness keys"
    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "fix_PARSEOP_ZERO"" "Fix PARSEOP_ZERO"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "fix_ADBG"" "Fix ADBG Error"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/graphics "graphics_Rename-GFX0"" "Rename GFX0 to IGPU"
    # _tidy_exec "patch_acpi DSDT usb "usb_7-series"" "7-series/8-series USB"
    # _tidy_exec "patch_acpi DSDT usb "usb_prw_0x0d_xhc"" "Fix USB _PRW"
    #_tidy_exec "patch_acpi DSDT battery "battery_Acer-Aspire-E1-571"" "Acer Aspire E1-571"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_IRQ"" "IRQ Fix"
    # _tidy_exec "patch_acpi DSDT system "system_SMBUS"" "SMBus Fix"
    # _tidy_exec "patch_acpi DSDT system "system_ADP1"" "AC Adapter Fix"
    # _tidy_exec "patch_acpi DSDT system "system_MCHC"" "Add MCHC"
    # _tidy_exec "patch_acpi DSDT system "system_WAK2"" "Fix _WAK Arg0 v2"
    # _tidy_exec "patch_acpi DSDT system "system_IMEI"" "Add IMEI"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_Mutex"" "Fix Non-zero Mutex"
    # _tidy_exec "patch_acpi DSDT xps9350_patches/brightness "system_OSYS"" "OS Check Fix"
    _tidy_exec "patch_acpi DSDT xps9350_patches/brightness "system_OSYS_win8"" "OS Check Fix"

    # _tidy_exec "perl -i -pe 's/HDA/HDEF/g' $BUILD/precompiled/DSDT.dsl" "rename HDA to HDEF"
    _tidy_exec "patch_acpi DSDT xps9350_patches/audio "rename_HDAS-HDEF"" "rename HDA to HDEF"

    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/audio "audio_HDEF-layout3"" "Add audio Layout 1"

    #_tidy_exec "patch_acpi DSDT syscl "audio_B0D3_HDAU"" "Rename B0D3 to HDAU"
    # _tidy_exec "patch_acpi DSDT syscl "remove_glan"" "Remove GLAN device"
    # _tidy_exec "patch_acpi DSDT syscl "syscl_iGPU_MEM2"" "iGPU TPMX to MEM2"
    # _tidy_exec "patch_acpi DSDT syscl "syscl_IMTR2TIMR"" "IMTR->TIMR, _T_x->T_x"
    # _tidy_exec "patch_acpi DSDT syscl "syscl_ALSD2ALS0"" "ALSD->ALS0"

    test_compile "DSDT"

    #
    # SaSsdt Patches.
    #
    if [ $NoSaSsdt -eq 1 ]; then
        _PRINT_MSG "--->: ${RED}SaSsdt not found${OFF}"
        exit
        else
        _PRINT_MSG "--->: ${BLUE}Patching ${SaSsdt}.dsl${OFF}"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/syntax "remove_DSM"" "remove all _DSM methods"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/graphics "graphics_Rename-GFX0"" "Rename GFX0 to IGPU"
        #_tidy_exec "patch_acpi ${SaSsdt} syscl "syscl_Iris_Pro"" "Rename HD4600 to Iris Pro"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/graphics "graphics_PNLF"" "Brightness fix (Skylake)"
        #_tidy_exec "patch_acpi ${SaSsdt} syscl "audio_B0D3_HDAU"" "Rename B0D3 to HDAU"
        #_tidy_exec "patch_acpi ${SaSsdt} syscl "audio_Intel_HD4600"" "Insert HDAU device"
        test_compile "${SaSsdt}"
    fi

    #
    # Build it now
    #
    compile
}

function patch_apple_hda()
{
    _PRINT_MSG "--->: ${BLUE}PatchHDA (${AUDIO_CODEC})${OFF}"

    _tidy_exec "createAppleHDAInjector "$AUDIO_CODEC"" "build audio injector"
}

function ssdtGen()
{
    echo "todo!"
}

function deploy_ACPI_Patches()
{
    _PRINT_MSG "--->: ${BLUE}Deploy ACPI patches${OFF}"

    _tidy_exec "cp $BASE/ssdts/* $ACPI/patched/" "copy prebuilt SSDTs"
    _tidy_exec "cp $ACPI/patched/* /Volumes/EFI/EFI/CLOVER/ACPI/patched/" "copying files to CLOVER/ACPI/patched"
}

function main()
{
    acpi_patching
    deploy_ACPI_Patches

    # patch_apple_hda
}

#==================================== START =====================================

main "$@"

#================================================================================

exit ${RETURN_VAL}
