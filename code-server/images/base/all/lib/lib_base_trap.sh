#!/usr/bin/env bash
#
#
# Copyright (c) 2020, <grimeton@gmx.net>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the software/distribution.
#
# 3. If we meet some day, and you think this stuff is worth it, 
#    you can buy me a beer in return, Grimeton.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
if ! (return 0 2>/dev/null); then
    echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
    exit 254
fi

set -o nounset

#####
#
# - __trap_function_register
#
# - Description:
#   Takes the name of signal and a function and registers it to the signal.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - The name of ID of the signal.
#   - #2 [IN|MANDATORY]: FUNCTION_NAME - The name of the EXISTING function to be registered to the given signal
#
# - Return values:
#   - 0 on success
#   - >0 on failure
#
function __trap_function_register() {
    unset __T_TFR_ERROR __P_TFR_SIGNALNAME __P_TFR_FUNCTIONNAME __T_TFR_MSG_TXT __T_TFR_SIGNAL_ARRAYNAME __T_TFR_SIGNAL_ARRAY
    unset -n __T_TFR_ERROR __P_TFR_SIGNALNAME __P_TFR_FUNCTIONNAME __T_TFR_MSG_TXT __T_TFR_SIGNAL_ARRAYNAME __T_TFR_SIGNAL_ARRAY
    declare -i __T_TFR_ERROR=0
    declare __T_TFR_MSG_TXT="'FUNC:${FUNCNAME[0]}':"
    declare __P_TFR_SIGNALNAME=""

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __trap_signal_name "${@:1:1}" __P_TFR_SIGNALNAME; then
        __T_TFR_MSG_TXT+="'${__P_TFR_SIGNALNAME}':"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_TFR_FUNCTIONNAME="${@:2:1}"
    fi

    declare __T_TFR_SIGNAL_ARRAYNAME=""
    if __trap_signal_array_create "${__P_TFR_SIGNALNAME}" __T_TFR_SIGNAL_ARRAYNAME; then
        declare -n __T_TFR_SIGNAL_ARRAY="${__T_TFR_SIGNAL_ARRAYNAME}"
    else
        __log e -- "${__T_TFR_MSG_TXT} Cannot get the array name for signal: '${__P_TFR_SIGNALNAME}'."
        return 111
    fi

    if __test_function_exists "${__P_TFR_FUNCTIONNAME}"; then
        if __array_add "${!__T_TFR_SIGNAL_ARRAY}" "${__P_TFR_FUNCTIONNAME}"; then
            true
        else
            __T_TFR_ERROR=$?
            __log e -- "${__T_TFR_MSG_TXT} Could not add function '${__P_TFR_FUNCTIONNAME}' to signal's array. Aready exists (${__T_TFR_ERROR})."
            return 112
        fi
    else
        __T_TFR_ERROR=$?
        __log e -- "${__T_TFR_MSG_TXT} Function '${__P_TFR_FUNCTIONNAME}' does not exist (${__T_TFR_ERROR})."
        return 113
    fi

    if [[ ${#__T_TFR_SIGNAL_ARRAY[@]} -gt 0 ]]; then
        if __trap_signal_registered "${__P_TFR_SIGNALNAME}"; then
            return 0
        elif __trap_signal_register "${__P_TFR_SIGNALNAME}"; then
            return 0
        else
            __T_TFR_ERROR=$?
            __log -- "${__T_TFR_TXT_MSG} Could not register for signal '${__P_TFR_SIGNALNAME}' (${__T_TFR_ERROR})."
            return 121
        fi
    elif __trap_signal_registered "${__P_TFR_SIGNALNAME}"; then
        if __trap_signal_unregister "${__P_TFR_SIGNALNAME}"; then
            return 0
        else
            __T_TFR_ERROR=$?
            __log e -- "${__T_TFR_TXT_MSG} Could not unregister from signal '${__P_TFR_SIGNALNAME}' (${__T_TFR_ERROR})."
            return 122
        fi
    fi
    return 31
}
#####
#
# - __trap_function_registered
#
# Takes the name of a signal and a function and checks if said function is registered on the given signal
#
# - Parameters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - The name of the signal the function should be registered on.
#   - #2 [IN|MANDATORY]: FUNCTION_NAME - The name of the function that is registered on the given signal.
#
# - Return values:
#   - 0 on success/found
#   - >0 on failure/not found
#
function __trap_function_registered() {
    unset __T_TFRR_ERROR __P_TFRR_SIGNALNAME __P_TFRR_FUNCTIONNAME __T_TFRR_MSG_TXT __T_TFRR_SIGNAL_ARRAYNAME __T_TFRR_SIGNAL_ARRAY
    unset -n __T_TFRR_ERROR __P_TFRR_SIGNALNAME __P_TFRR_FUNCTIONNAME __T_TFRR_MSG_TXT __T_TFRR_SIGNAL_ARRAYNAME __T_TFRR_SIGNAL_ARRAY
    declare -i __T_TFRR_ERROR=0
    declare __T_TFRR_MSG_TXT="'FUNC:${FUNCNAME[0]}':"
    declare __P_TFRR_SIGNALNAME=""
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __trap_signal_name "${@:1:1}" __P_TFRR_SIGNALNAME; then
        __T_TFRR_MSG_TXT+="'SIG:${__P_TFRR_SIGNALNAME}':"
    else
        return 102
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        # DO NOT TEST if the function really exists. That's not part of the deal here
        declare __P_TFRR_FUNCTIONNAME="${@:2:1}"
    fi

    declare __T_TFRR_SIGNAL_ARRAYNAME=""
    if __trap_signal_arrayname_get "${__P_TFRR_SIGNALNAME}" __T_TFRR_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TFRR_SIGNAL_ARRAYNAME}"; then
            declare -n __T_TFRR_SIGNAL_ARRAY="${__T_TFRR_SIGNAL_ARRAYNAME}"
        else
            return 111
        fi
    else
        __T_TFRR_ERROR=$?
        __log e -- "${__T_TFRR_MSG_TXT} Cannot get name of array for signal '${__P_TFRR_SIGNALNAME}' (${__T_TFRR_ERROR})."
        return 112
    fi

    __array_contains "${!__T_TFRR_SIGNAL_ARRAY}" "${__P_TFRR_FUNCTIONNAME}"

}
#####
#
# - __trap_function_unregister
#
# Takes the name of a signal and a function and unregisters it if it is registered on the given signal
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - The name of the signal
#   - #2 [IN|MANDATORY]: FUNCTION_NAME - The name of the function
#
# - Return values:
#   - 0 on success
#   - >0 on failure
#
function __trap_function_unregister() {

    unset __T_TFU_ERROR __P_TFU_SIGNALNAME __P_TFU_FUNCTIONNAME __T_TFU_MSG_TXT __T_TFU_SIGNAL_ARRAYNAME __T_TFU_SIGNAL_ARRAY
    unset -n __T_TFU_ERROR __P_TFU_SIGNALNAME __P_TFU_FUNCTIONNAME __T_TFU_MSG_TXT __T_TFU_SIGNAL_ARRAYNAME __T_TFU_SIGNAL_ARRAY
    declare -i __T_TFU_ERROR=0
    declare __T_TFU_MSG_TXT="'FUNC:${FUNCNAME[0]}':"
    declare __P_TFU_SIGNALNAME=""
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __trap_signal_name "${@:1:1}" __P_TFU_SIGNALNAME; then
        __T_TFU_MSG_TXT+="'SIG:${__P_TFU_SIGNALNAME}':"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_TFU_FUNCTIONNAME="${@:2:1}"
    fi

    declare __T_TFU_SIGNAL_ARRAYNAME=""
    if __trap_signal_arrayname_get "${__P_TFU_SIGNALNAME}" __T_TFU_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TFU_SIGNAL_ARRAYNAME}"; then
            declare -n __T_TFU_SIGNAL_ARRAY="${__T_TFU_SIGNAL_ARRAYNAME}"
        else
            return 0
        fi
    else
        __T_TFU_ERROR=$?
        __log e -- "${__T_TFU_MSG_TXT} Cannot get array's name for signal '${__P_TFU_SIGNALNAME}' (${__T_TFU_ERROR})."
        return 104
    fi

    if __array_contains "${!__T_TFU_SIGNAL_ARRAY}" "${__P_TFU_FUNCTIONNAME}"; then
        if __array_remove "${!__T_TFU_SIGNAL_ARRAY}" "${__P_TFU_FUNCTIONNAME}"; then
            return 0
        else
            __T_TFU_ERROR=$?
            __log e -- "${__T_TFU_TXT_MSG} Could not remove '${__P_TFU_FUNCTIONNAME}' from signal '${__P_TFU_SIGNALNAME}' (${__T_TFU_ERROR})."
            return 111
        fi
    else
        return 112
    fi

}
#####
#
# - __trap_signal_exists
#
# Takes the name of a signal and returns 0 if the signal is valid.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Name of the signal
#
# - Return values:
#   - 0 on success
#   - >0 on failure
#
function __trap_signal_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 99
    fi

    trap -p "${@:1:1}" >/dev/null 2>&1

}
#####
#
# - __trap_signal_register
#
# Takes the name of a signal and registers to it.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - The name of the signal to register to
#
# - Return values:
#   - 0 on success
#   - >0 on failure
#
function __trap_signal_register() {

    unset __P_TSR_SIGNALNAME __T_TSR_MSG_TXT
    unset -n __P_TSR_SIGNALNAME __T_TSR_MSG_TXT
    declare -- __P_TSR_SIGNALNAME=""
    declare -- __T_TSR_MSG_TXT="'${FUNCNAME[0]}':"
    if [[ "${@:1:1}x" == "x" ]]; then
        return 102
    elif __trap_signal_name "${@:1:1}" __P_TSR_SIGNALNAME; then
        __T_TSR_MSG_TXT+="'${__P_TSR_SIGNALNAME}':"
    else
        return 103
    fi

    if __trap_signal_registered "${__P_TSR_SIGNALNAME}"; then
        return 0
    elif trap "__trap_run "${__P_TSR_SIGNALNAME}"" "${__P_TSR_SIGNALNAME}" >/dev/null 2>&1; then
        return 0
    else
        __T_TSR_ERROR=$?
        __log e -- "Could not register for signal '${__P_TSR_SIGNALNAME}' (${__T_TSR_ERROR})."
        return 104
    fi
    return 1
}
#####
#
# - __trap_signal_registered
#
# Takes the name of a signal and checks if we're registered to it already.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Name of the signal to test for.
#
# - Return values:
#   - 0 on success
#   - >0 on failure
#
function __trap_signal_registered() {
    unset __P_TSRR_SIGNALNAME __T_TSRR_MSG_TXT
    unset -n __P_TSRR_SIGNALNAME __T_TSRR_MSG_TXT
    declare __P_TSRR_SIGNALNAME=""
    declare -- __T_TSRR_MSG_TXT="'${FUNCNAME[0]}':"
    if [[ "${@:1:1}x" == "x" ]]; then
        return 102
    elif __trap_signal_name "${@:1:1}" __P_TSRR_SIGNALNAME; then
        __T_TSRR_MSG_TXT+="'${__P_TSRR_SIGNALNAME}':"
    else
        return 103
    fi

    trap -p "${__P_TSRR_SIGNALNAME}" | grep "__trap_run" >/dev/null 2>&1

}
#####
#
# - __trap_signal_unregister
#
# - Description:
#       Takes the name of a signal and unregisters from it, if registered.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - The name of the signal we want to unregister from
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#

function __trap_signal_unregister() {

    unset __P_TSU_SIGNALNAME __T_TSU_ERROR __T_TSU_MSG_TXT
    unset -n __P_TSU_SIGNALNAME __T_TSU_ERROR __T_TSU_MSG_TXT
    declare __P_TSU_SIGNALNAME=""
    declare __T_TSU_MSG_TXT="'${FUNCNAME[0]}':"
    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __trap_signal_name "${@:1:1}" __P_TSU_SIGNALNAME; then
        __T_TSU_MSG_TXT+="'SIG:${__P_TSU_SIGNALNAME}':"
    else
        return 3
    fi

    if __trap_signal_registered "${__P_TSU_SIGNALNAME}"; then
        if trap -- "${__P_TSU_SIGNALNAME}" >/dev/null 2>&1; then
            return 0
        else
            declare -i __T_TSU_ERROR=$?
            __log e -- "${__T_TSU_TXT_MSG} Problem removing trap from signal (${__T_TSU_ERROR})."
            return 2
        fi
    else
        declare -i __T_TSU_ERROR=$?
        __log e -- "${__T_TSU_TXT_MSG} No trap registered for this signal (${__T_TSU_ERROR})."
        return 1
    fi

}
#####
#
# - __trap_signal_name
#
# Takes the id or name of a signal and returns its name.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME|SIGNAL_NUMBER - NAME/NUMBER to convert into the NAME
#   - #2 [OUT|OPTIONAL]: RETURN_VALUE_NAME - Name of an existing variable that should be filled with the result.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __trap_signal_name() {

    unset __P_TSN_SIGNALNAME __P_TSN_SIGNALNUMBER __T_TSN_ERROR
    unset -n __P_TSN_SIGNALNAME __P_TSN_SIGNALNUMBER __T_TSN_ERROR

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif [[ ! "${@:1:1}" =~ ${__D_TEXT_REGEX_NUMBER} ]]; then
        if __trap_signal_exists "${@:1:1}"; then
            declare __P_TSN_SIGNALNAME="${@:1:1}"
        else
            return 3
        fi
    else
        if __trap_signal_exists "${@:1:1}"; then
            declare __P_TSN_SIGNALNUMBER=${@:1:1}
        else
            return 4
        fi
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_TSN_RETURN_NAME=""
    else
        if __test_variable_exists "${@:2:1}"; then
            declare -n __T_TSN_RETURN_NAME="${@:2:1}"
        else
            declare __T_TSN_RETURN_NAME=""
        fi
    fi

    if __test_variable_exists __P_TSN_SIGNALNAME; then
        if [[ -R __T_TSN_RETURN_NAME ]]; then
            __T_TSN_RETURN_NAME="${__P_TSN_SIGNALNAME}"
        else
            echo "${__P_TSN_SIGNALNAME}"
        fi
        return 0
    fi

    if __array_exists __TRAP_SIGNAL_TO_NAME; then
        true
    else
        unset __TRAP_SIGNAL_TO_NAME
        unset -n __TRAP_SIGNAL_TO_NAME
        declare -agx __TRAP_SIGNAL_TO_NAME=()

        while read __T_TSN_LINE; do
            if [[ ${#__T_TSN_LINE} -lt 1 ]]; then
                continue
            else
                unset __T_TSN_TA
                declare -a __T_TSN_TA=()
                IFS="=" read -ra __T_TSN_TA <<<"${__T_TSN_LINE}"
                if [[ ${#__T_TSN_TA[@]} -ne 2 ]]; then
                    continue
                fi
                unset IFS
                __TRAP_SIGNAL_TO_NAME+=([${__T_TSN_TA[0]}]="${__T_TSN_TA[1]}")
                unset IFS
                unset __T_TSN_TA
            fi
        done < <(trap -l | sed -E 's/([0-9]+)\)\ ([A-Z0-9+-]+)/\1=\2\n/g' | tr -d '\t')
    fi

    if [[ -n ${__TRAP_SIGNAL_TO_NAME[${__P_TSN_SIGNALNUMBER}]+x} ]]; then
        if [[ -R __T_TSN_RETURN_NAME ]]; then
            __T_TSN_RETURN_NAME="${__TRAP_SIGNAL_TO_NAME[${__P_TSN_SIGNALNUMBER}]}"
        else
            echo "${__TRAP_SIGNAL_TO_NAME[${__P_TSN_SIGNALNUMBER}]}"
        fi
        return 0
    fi
    return 1
}
#####
#
# - __trap_signal_array_create
#
# - Description:
#   Used to create the array that holds the function names that should be executed
#   when the trap for the signal is raised.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Name of the signal the array should be created for
#   - #2 [OUT|OPTIONAL]: RETURN_ARRAYNAME: Name of a variable that should be filled with the name of the
#                           array that has been created.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __trap_signal_array_create() {

    unset __P_TSAC_SIGNALNAME __T_TSAC_ERROR __T_TSAC_MSG_TXT __T_TSAC_SIGNAL_ARRAYNAME
    unset -n __P_TSAC_SIGNALNAME __T_TSAC_ERROR __T_TSAC_MSG_TXT __T_TSAC_SIGNAL_ARRAYNAME
    declare __P_TSAC_SIGNALNAME=""
    declare -i __T_TSAC_ERROR=0
    declare -- __T_TSAC_MSG_TXT="'${FUNCNAME[0]}':"
    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __trap_signal_name "${@:1:1}" __P_TSAC_SIGNALNAME; then
        __T_TSAC_MSG_TXT+="'${__P_TSAC_SIGNALNAME}':"
    else
        return 3
    fi

    unset __T_TSAC_RESULT

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_TSAC_RETURN_ARRAYNAME=""
    elif __test_variable_exists "${@:2:1}"; then
        declare -n __T_TSAC_RETURN_ARRAYNAME="${@:2:1}"
    else
        declare __T_TSAC_RETURN_ARRAYNAME=""
    fi

    declare -- __T_TSAC_SIGNAL_ARRAYNAME=""
    if __trap_signal_arrayname_get "${__P_TSAC_SIGNALNAME}" __T_TSAC_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TSAC_SIGNAL_ARRAYNAME}"; then
            true
        else
            if declare -agx "${__T_TSAC_SIGNAL_ARRAYNAME}=()"; then
                true
            else
                __log e -- "Cannot create '${__T_TSAC_SIGNAL_ARRAYNAME}'."
                return 11
            fi
        fi
    else
        __log e -- "Could not get signal array's name."
        return 12
    fi

    if [[ -R __T_TSAC_RETURN_ARRAYNAME ]]; then
        __T_TSAC_RETURN_ARRAYNAME="${__T_TSAC_SIGNAL_ARRAYNAME}"
    else
        echo "${__T_TSAC_SIGNAL_ARRAYNAME}"
        true
    fi
    unset __T_TSAC_SIGNAL_ARRAYNAME
    return 0
}
#####
#
# - __trap_signal_array_delete
#
# - Description:
#   Takes the name of a signal and deletes the corresponding array, if exists.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Name of the signal to use
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __trap_signal_array_delete() {

    unset __P_TSAD_SIGNALNAME __T_TSAD_SIGNAL_ARRAYNAME
    unset -n __P_TSAD_SIGNALNAME __T_TSAD_SIGNAL_ARRAYNAME

    declare -- __P_TSAD_SIGNALNAME=""
    declare -- __T_TSAD_SIGNAL_ARRAYNAME=""

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __trap_signal_name "${@:1:1}" __P_TSAD_SIGNALNAME; then
        if __trap_signal_arrayname_get "${__P_TSAD_SIGNALNAME}" __T_TSAD_SIGNAL_ARRAYNAME; then
            true
        else
            return 4
        fi
    else
        return 3
    fi
    if __array_exists "${__T_TSAD_SIGNAL_ARRAYNAME}"; then
        if unset "${__T_TSAD_SIGNAL_ARRAYNAME}"; then
            return 0
        else
            __log e -- "Problems deleteing array '${__T_TSAD_SIGNAL_ARRAYNAME}'."
        fi
    fi
    return 0

}
#####
#
# - __trap_signal_arrayname_get
#
# - Description:
#   Takes the name of a signal and returns the name of the array.
#   This function exists mainly to have a single point of change in case
#   the name ever needs to be changed.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Signal's name.
#   - #2 [OUT|OPTIONAL]: RETURN_ARRAYNAME - Name of an existing variable that should be filled with the array's name.
#
# - Return values:
#   - 0 on success.
#   - >0 on falure.
#
function __trap_signal_arrayname_get() {

    unset __P_TSAG_SIGNALNAME __T_TSAG_ERROR __T_TSAG_SIGNAL_ARRAYNAME __T_TSAG_RETURN_ARRAYNAME
    unset -n __P_TSAG_SIGNALNAME __T_TSAG_ERROR __T_TSAG_SIGNAL_ARRAYNAME __T_TSAG_RETURN_ARRAYNAME
    declare -i __T_TSAG_ERROR=0
    declare __P_TSAG_SIGNALNAME=""

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __trap_signal_name "${@:1:1}" __P_TSAG_SIGNALNAME; then
        true
    else
        return 3
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_TSAG_RETURN_ARRAYNAME=""
    elif __test_variable_exists "${@:2:1}" && [[ ${BASH_SUBSHELL} -lt 1 ]]; then
        declare -n __T_TSAG_RETURN_ARRAYNAME="${@:2:1}"
    else
        declare __T_TSAG_RETURN_ARRAYNAME=""
    fi
    declare __T_TSAG_SIGNAL_ARRAYNAME="__TRAP_SIGNAL_ARRAY_${__P_TSAG_SIGNALNAME//[^a-zA-Z0-9_]/}"

    if [[ -R __T_TSAG_RETURN_ARRAYNAME ]]; then
        __T_TSAG_RETURN_ARRAYNAME="${__T_TSAG_SIGNAL_ARRAYNAME}"
    else
        echo "${__T_TSAG_SIGNAL_ARRAYNAME}"
    fi
    unset __T_TSAG_SIGNAL_ARRAYNAME
    return 0
}
#####
#
# - __trap_run
#
# - Description:
#   Usually called by the shell's trap handler. 
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - the name of the signal that is actually raised.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __trap_run() {
    
    declare -i __T_LAST_ERROR=$?
    unset __P_TR_SIGNALNAME __T_TR_MSG_TXT __T_TR_SIGNAL_ARRAY __T_TR_SIGNAL_ARRAYNAME
    unset -n __P_TR_SIGNALNAME __T_TR_MSG_TXT __T_TR_SIGNAL_ARRAY __T_TR_SIGNAL_ARRAYNAME

    declare -- __P_TR_SIGNALNAME=""
    declare -i __T_TR_ERROR=0
    declare __T_TR_MSG_TXT="'FUNC:${FUNCNAME[0]}':"

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __trap_signal_name "${@:1:1}" __P_TR_SIGNALNAME; then
        __T_TR_MSG_TXT+="'SIG:${__P_TR_SIGNALNAME}':"
    else
        return 102
    fi

    declare __T_TR_SIGNAL_ARRAYNAME=""
    if __trap_signal_arrayname_get "${__P_TR_SIGNALNAME}" __T_TR_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TR_SIGNAL_ARRAYNAME}"; then
            declare -n __T_TR_SIGNAL_ARRAY="${__T_TR_SIGNAL_ARRAYNAME}"
        else
            __T_TR_ERROR=$?
            __log e -- "${__T_TR_MSG_TXT} Array to run trap does not exist (${__T_TR_ERROR})."
            return 103
        fi
    else
        __T_TR_ERROR=$?
        __log e -- "${__T_TR_MSG_TXT} Could not get array name for signal. Not good (${__T_TR_ERROR})."
        return 104
    fi

    declare -a __T_TR_FUNCTIONS_TO_DELETE=()
    declare -A __T_TR_FUNCTIONS_FAILED=()

    if __array_empty __T_TR_SIGNAL_ARRAY; then
        if __trap_unregister "${__P_TR_SIGNALNAME}"; then
            return 0
        else
            __T_TR_ERROR=$?
            __log e -- "${__T_TR_MSG_TXT} Array for signal is empty, but could not unregister the trap (${__T_TR_ERROR})."
            return 111
        fi
    else
        for __T_TR_FUNCTIONNAME in "${__T_TR_SIGNAL_ARRAY[@]}"; do
            __T_TR_ERROR=0
            if __test_function_exists "${__T_TR_FUNCTIONNAME}"; then
                if "${__T_TR_FUNCTIONNAME}" "${__T_LAST_ERROR}"; then
                    continue
                else
                    __T_TR_ERROR=$?
                    __log e -- "${__T_TR_MSG_TXT} Problems running function '${__T_TR_FUNCTIONNAME}' (${__T_TR_ERROR}). Trying to continue..."
                    __T_TR_FUNCTIONS_FAILED+=([${__T_TR_FUNCTIONNAME}]=${__T_TR_ERROR})
                fi
            else
                __T_TR_ERROR=$?
                __T_TR_FUNCTIONS_FAILED+=([${__T_TR_FUNCTIONNAME}]="ENONEXISTANT")
                __T_TR_FUNCTIONS_TO_DELETE+=("${__T_TR_FUNCTIONNAME}")
                __log e -- "${__T_TR_MSG_TXT} '${__T_TR_FUNCTIONNAME}' does not exist (${__T_TR_ERROR}). Going to delete it later."
            fi
        done
    fi

    if [[ ${#__T_TR_FUNCTIONS_TO_DELETE[@]} -gt 0 ]]; then
        for __T_TR_FUNCTION_TO_DELETE in "${__T_TR_FUNCTIONS_TO_DELETE[@]}"; do
            __T_TR_ERROR=0
            if __array_remove "${!__T_TR_SIGNAL_ARRAY}" "${__T_TR_FUNCTION_TO_DELETE}"; then
                continue
            else
                __T_TR_ERROR=$?
                __log e -- "${__T_TR_MSG_TXT} Problems removing function from array (${__T_TR_ERROR})."
                return 31
            fi
        done
    fi

    if [[ ${#__T_TR_FUNCTIONS_FAILED[@]} -gt 0 ]]; then
        __log w -- "${__T_TR_MSG_TXT} Warning '${#__T_TR_FUNCTIONS_FAILED[@]}' have failed ("${!__T_TR_FUNCTIONS_FAILED[@]}")."
    fi
    return 0

}
