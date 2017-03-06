#!/bin/sh

BASE=$(pwd)

source "$BASE/config"
source "$BASE/scripts/_deploy.sh"
source "$BASE/scripts/disassemble.sh"
source "$BASE/scripts/compile.sh"

function acpi_patching()
{
    disassemble

    # #just preserve files
    # ignore_acpi_file "SSDT-0"
    ignore_acpi_file "SSDT-1"
    # ignore_acpi_file "SSDT-2"
    # ignore_acpi_file "SSDT-3"
    # ignore_acpi_file "SSDT-4"
    # ignore_acpi_file "SSDT-6"
    # ignore_acpi_file "SSDT-14"

    test_compile_all

    _tidy_exec "_find_acpi" "Search specification tables by syscl/Yating Zhou"

    #
    # DSDT Patches.
    #
    _PRINT_MSG "--->: ${BLUE}Patching DSDT.dsl${OFF}"

    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "rename_DSM"" "remove all _DSM methods"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/misc "misc_Skylake-LPC"" "Skylake LPC"

    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "fix_PARSEOP_ZERO"" "Fix PARSEOP_ZERO"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/syntax "fix_ADBG"" "Fix ADBG Error"

    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/graphics "graphics_Rename-GFX0"" "Rename GFX0 to IGPU"
    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/usb "usb_prw_0x6d_xhc_skl"" "Fix USB _PRW"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_IRQ"" "IRQ Fix"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_SMBUS"" "SMBus Fix"
    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_ADP1"" "AC Adapter Fix"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_MCHC"" "Add MCHC"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_WAK2"" "Fix _WAK Arg0 v2"
    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_IMEI"" "Add IMEI"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_Mutex"" "Fix Non-zero Mutex"

    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_RTC"" "RTC Fix"
    _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_Shutdown"" "Fix Shutdown"
    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_Shutdown2"" "Fix Shutdown2"

    #
    # Modificate ACPI for macOS to load devices correctly
    #
    _tidy_exec "patch_acpi DSDT syscl "syscl_PPMCnPMCR"" "PPMC and PMCR combine together credit syscl"
    _tidy_exec "patch_acpi DSDT syscl "syscl_DMAC"" "Insert DMAC(PNP0200)"
    _tidy_exec "patch_acpi DSDT syscl "syscl_MATH"" "Make Device(MATH) load correctly in macOS"
    _tidy_exec "patch_acpi DSDT syscl "syscl_SLPB"" "SBTN->SLPB with correct _STA 0x0B"


    _tidy_exec "patch_acpi DSDT xps9350_patches/brightness "system_OSYS"" "OS Check Fix"

    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/system "system_OSYS_win8"" "OS Check Fix"
    # _tidy_exec "patch_acpi DSDT iceman "system_OSYS"" "OS Check Fix"


    # _tidy_exec "perl -i -pe 's/HDA/HDEF/g' $BUILD/precompiled/DSDT.dsl" "rename HDA to HDEF"
    _tidy_exec "patch_acpi DSDT xps9350_patches/audio "rename_HDAS-HDEF"" "rename HDA to HDEF"

    # _tidy_exec "patch_acpi DSDT Laptop-DSDT-Patch/audio "audio_HDEF-layout3"" "Add audio Layout 1"
    # use layout-id 13 for cloverHDA
    _tidy_exec "patch_acpi DSDT iceman "audio"" "Audio layout"

    _tidy_exec "patch_acpi DSDT syscl "syscl_iGPU_MEM2"" "iGPU TPMX to MEM2"
    _tidy_exec "patch_acpi DSDT syscl "syscl_IMTR2TIMR"" "IMTR->TIMR, _T_x->T_x"
    _tidy_exec "patch_acpi DSDT syscl "syscl_ALSD2ALS0"" "ALSD->ALS0"

    # _tidy_exec "patch_acpi DSDT iceman "keyboard_applesmart"" "brightness keys"
    _tidy_exec "patch_acpi DSDT iceman "keyboard_voodoops2"" "brightness keys"

    #_tidy_exec "patch_acpi DSDT debug "debug"" "ACPI debug"
    #_tidy_exec "patch_acpi DSDT debug "instrument_LID"" "ACPI debug"
    #_tidy_exec "patch_acpi DSDT debug "instrument_Qxx"" "ACPI debug"
    #_tidy_exec "patch_acpi DSDT debug "instrument_Lxx"" "ACPI debug"
    #_tidy_exec "patch_acpi DSDT debug "instrument_WAK_PTS"" "ACPI debug"
    #perl -i -pe 's/ADBG \("HDA/\\rmdt\.p1\("HDA/g' $BUILD/precompiled/DSDT.dsl

    # for what advantage? ans: (double press-- display sleep; quick press-- shutdown/sleep box)
    # _tidy_exec "perl -i -pe 's/PBTN/PWRB/g' $BUILD/precompiled/DSDT.dsl" "rename PBTN to PWRB"
    # i don't like it... produces garbled screen/artifacts
    # default is better: quick doulbe press for display sleep; long press-- shutdown/sleep box)
    # no artifacts
    

    #test_compile "DSDT"

    # SaSsdt Patches.
    #
    if [ $NoSaSsdt -eq 1 ]; then
        _PRINT_MSG "--->: ${RED}SaSsdt not found${OFF}"
        exit
        else
        _PRINT_MSG "--->: ${BLUE}Patching ${SaSsdt}.dsl${OFF}"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/syntax "remove_DSM"" "remove all _DSM methods"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/graphics "graphics_Rename-GFX0"" "Rename GFX0 to IGPU"
        _tidy_exec "patch_acpi ${SaSsdt} Laptop-DSDT-Patch/graphics "graphics_PNLF"" "Brightness fix (Skylake)"
        #_tidy_exec "patch_acpi ${SaSsdt} syscl "audio_B0D3_HDAU"" "Rename B0D3 to HDAU"
        
        #test_compile "${SaSsdt}"
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

    #_tidy_exec "cp $BASE/ssdts/*.aml $ACPI/patched/" "copy prebuilt SSDTs"
    _tidy_exec "cp $ACPI/patched/*.aml /Volumes/EFI/EFI/CLOVER/ACPI/patched/" "copying files to CLOVER/ACPI/patched"
}

function main()
{
    #
    # Get argument.
    #
    gArgv=$(echo "$@" | tr '[:lower:]' '[:upper:]')
    if [[ "$gArgv" == *"-D"* || "$gArgv" == *"-DEBUG"* ]];
      then
        #
        # Yes, we do need debug mode.
        #
        _PRINT_MSG "NOTE: Use ${BLUE}DEBUG${OFF} mode"
        gDebug=0
      else
        #
        # No, we need a clean output style.
        #
        gDebug=1
    fi

    acpi_patching
    deploy_ACPI_Patches
}

#==================================== START =====================================

main "$@"

#================================================================================

exit ${RETURN_VAL}
