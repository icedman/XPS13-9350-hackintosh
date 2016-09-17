#!/bin/sh

# base on the scripts of:
# syscl/Yating Zhou/lighting from bbs.PCBeta.com
# Merge for Dell Precision M3800 and XPS15 (9530).
#

#================================= GLOBAL VARS ==================================

#
# The script expects '0.5' but non-US localizations use '0,5' so we export
# LC_NUMERIC here (for the duration of the deploy.sh) to prevent errors.
#
export LC_NUMERIC="en_US.UTF-8"

#
# Prevent non-printable/control characters.
#
unset GREP_OPTIONS
unset GREP_COLORS
unset GREP_COLOR

#
# Display style setting.
#
BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
OFF="\033[m"

#
# Define two status: 0 - Success, Turn on,
#                    1 - Failure, Turn off
#
kBASHReturnSuccess=0
kBASHReturnFailure=1

#
#--------------------------------------------------------------------------------
#

function _PRINT_MSG()
{
    local message=$1

    case "$message" in
      OK*    ) local message=$(echo $message | sed -e 's/.*OK://')
               echo "[  ${GREEN}OK${OFF}  ] ${message}."
               ;;

      FAILED*) local message=$(echo $message | sed -e 's/.*://')
               echo "[${RED}FAILED${OFF}] ${message}."
               ;;

      ---*   ) local message=$(echo $message | sed -e 's/.*--->://')
               echo "[ ${GREEN}--->${OFF} ] ${message}"
               ;;

      NOTE*  ) local message=$(echo $message | sed -e 's/.*NOTE://')
               echo "[ ${RED}Note${OFF} ] ${message}."
               ;;
    esac
}


#
#--------------------------------------------------------------------------------
#

function _tidy_exec()
{
    if [ $gDebug -eq 0 ];
      then
        #
        # Using debug mode to output all the details.
        #
        _PRINT_MSG "DEBUG: $2"
        echo $1
        $1
      else
        #
        # Make the output clear.
        #
        $1 >/tmp/report 2>&1 && RETURN_VAL=${kBASHReturnSuccess} || RETURN_VAL=${kBASHReturnFailure}

        if [ "${RETURN_VAL}" == ${kBASHReturnSuccess} ];
          then
            _PRINT_MSG "OK: $2"
          else
            _PRINT_MSG "FAILED: $2"
            cat /tmp/report

            if [ $gHaltOnError -eq 1 ]; then
                exit
            fi
        fi

        rm /tmp/report &> /dev/null
    fi
}



#
#--------------------------------------------------------------------------------
#

function _find_acpi()
{
    NoDptfTa=1
    NoSaSsdt=1
    NoSgRef=1
    NoOptRef=1

    #
    # Search specification tables by syscl/Yating Zhou.
    #
    number=$(ls "${BUILD}"/raw/SSDT*.dsl | wc -l)

    #
    # Search DptfTa.
    #
    for ((index = 1; index <= ${number}; index++))
    do
      grep -i "DptfTa" "${BUILD}"/raw/SSDT-${index}.dsl &> /dev/null && RETURN_VAL=0 || RETURN_VAL=1

      if [ "${RETURN_VAL}" == 0 ];
        then
          DptfTa=SSDT-${index}
          NoDptfTa=0
      fi
    done

    #
    # Search SaSsdt.
    #
    for ((index = 1; index <= ${number}; index++))
    do
      grep -i "SaSsdt" "${BUILD}"/raw/SSDT-${index}.dsl &> /dev/null && RETURN_VAL=0 || RETURN_VAL=1

      if [ "${RETURN_VAL}" == 0 ];
        then
          SaSsdt=SSDT-${index}
          NoSaSsdt=0
      fi
    done

    #
    # Search SgRef.
    #
    for ((index = 1; index <= ${number}; index++))
    do
      grep -i "SgRef" "${BUILD}"/raw/SSDT-${index}.dsl &> /dev/null && RETURN_VAL=0 || RETURN_VAL=1

      if [ "${RETURN_VAL}" == 0 ];
        then
          SgRef=SSDT-${index}
          NoSgRef=0
      fi
    done

    #
    # Search OptRef.
    #
    for ((index = 1; index <= ${number}; index++))
    do
      grep -i "OptRef" "${BUILD}"/raw/SSDT-${index}.dsl &> /dev/null && RETURN_VAL=0 || RETURN_VAL=1

      if [ "${RETURN_VAL}" == 0 ];
        then
          OptRef=SSDT-${index}
          NoOptRef=0
      fi
    done
}


#
#--------------------------------------------------------------------------------
#

function patch_acpi()
{
    "${TOOLS}"/patchmatic "${BUILD}"/precompiled/$1.dsl "${BASE}"/patches/$2/$3.txt "${BUILD}"/precompiled/$1.dsl
}
