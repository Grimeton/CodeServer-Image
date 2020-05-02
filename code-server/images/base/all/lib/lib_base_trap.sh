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

__lib_require "base_variable"

declare -gx __TRAP_LOADED=1
declare -gx __TRAP_REGEX_NUMBER='^[0-9]+$'

if [[ -n ${__D_TEXT_REGEX_NUMBER:+x} ]]; then
    __TRAP_REGEX_NUMBER="${__D_TEXT_REGEX_NUMBER}"
fi

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

    declare __P_TFR_SIGNALNAME=""

    if __trap_signal_name "${@:1:1}" __P_TFR_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __variable_type_function "${@:2:1}"; then
        declare __P_TFR_FUNCTIONNAME="${@:2:1}"
    else
        return 102
    fi

    if __trap_signal_registered "${__P_TFR_SIGNALNAME}"; then
        true
    elif __trap_signal_register "${__P_TFR_SIGNALNAME}"; then
        true
    else
        111
    fi

    declare __T_TFR_SIGNAL_ARRAYNAME=""
    if __trap_signal_arrayname_get "${__P_TFR_SIGNALNAME}" __T_TFR_SIGNAL_ARRAYNAME; then
        true
    else
        return 121
    fi

    if __array_add "${__T_TFR_SIGNAL_ARRAYNAME}" "${__P_TFR_FUNCTIONNAME}"; then
        return 0
    else
        return 1
    fi
    return 254
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

    declare -i __T_TFRR_ERROR=0
    declare __P_TFRR_SIGNALNAME=""
    if __trap_signal_name "${@:1:1}" __P_TFRR_SIGNALNAME; then
        true
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        # DO NOT TEST if the function really exists. That's not part of the deal here
        declare __P_TFRR_FUNCTIONNAME="${@:2:1}"
    fi

    declare __T_TFRR_SIGNAL_ARRAYNAME=""

    if __trap_signal_arrayname_get "${__P_TFRR_SIGNALNAME}" __T_TFRR_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TFRR_SIGNAL_ARRAYNAME}"; then
            if declare -n __T_TFRR_SIGNAL_ARRAY="${__T_TFRR_SIGNAL_ARRAYNAME}"; then
                true
            else
                return 121
            fi
        else
            return 1
        fi
    else
        return 112
    fi

    if __array_contains "${!__T_TFRR_SIGNAL_ARRAY}" "${__P_TFRR_FUNCTIONNAME}"; then
        return 0
    else
        return 1
    fi
    return 254

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

    declare __P_TFU_SIGNALNAME=""
    if __trap_signal_name "${@:1:1}" __P_TFU_SIGNALNAME; then
        true
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_TFU_FUNCTIONNAME="${@:2:1}"
    fi

    declare __T_TFU_SIGNAL_ARRAYNAME=""

    if __trap_signal_registered "${__P_TFU_SIGNALNAME}"; then
        true
    else
        return 111
    fi

    if __trap_signal_arrayname_get "${__P_TFU_SIGNALNAME}" __T_TFU_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TFU_SIGNAL_ARRAYNAME}"; then
            true
        else
            return 121
        fi
    else
        return 122
    fi

    if __array_contains "${__T_TFU_SIGNAL_ARRAYNAME}" "${__P_TFU_FUNCTIONNAME}"; then
        if __array_remove "${__T_TFU_SIGNAL_ARRAYNAME}" "${__P_TFU_FUNCTIONNAME}"; then
            if __array_empty "${__T_TFU_SIGNAL_ARRAYNAME}"; then
                if __trap_signal_unregister "${__P_TFU_SIGNALNAME}"; then
                    return 0
                else
                    return 141
                fi
            else
                return 0
            fi
        else
            return 1
        fi
    else
        return 131
    fi

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
    declare __P_TR_SIGNALNAME=""

    if __trap_signal_name "${@:1:1}" __P_TR_SIGNALNAME; then
        true
    else
        return 101
    fi

    declare __T_TR_SIGNAL_ARRAYNAME=""
    if __trap_signal_registered "${__P_TR_SIGNALNAME}"; then
        if __trap_signal_arrayname_get "${__P_TR_SIGNALNAME}" "__T_TR_SIGNAL_ARRAYNAME"; then
            if declare -n __T_TR_SIGNAL_ARRAY="${__T_TR_SIGNAL_ARRAYNAME}"; then
                true
            else
                return 111
            fi
        else
            return 112
        fi
    else
        return 113
    fi

    declare -a __T_TR_FUNCTIONS_TO_DELETE=()
    declare -A __T_TR_FUNCTIONS_FAILED=()

    if __array_empty "${!__T_TR_SIGNAL_ARRAY}"; then
        if __trap_signal_unregister "${__P_TR_SIGNALNAME}"; then
            return 0
        else
            return 121
        fi
    else
        for __T_TR_FUNCTIONNAME in "${__T_TR_SIGNAL_ARRAY[@]}"; do
            declare -i __T_TR_ERROR=0
            if __variable_type_function "${__T_TR_FUNCTIONNAME}"; then
                if "${__T_TR_FUNCTIONNAME}" "${__T_LAST_ERROR}"; then
                    continue
                else
                    __T_TR_ERROR=$?
                    __T_TR_FUNCTIONS_FAILED+=([${__T_TR_FUNCTIONNAME}]=${__T_TR_ERROR})
                fi
            else
                __T_TR_ERROR=$?
                __T_TR_FUNCTIONS_FAILED+=([${__T_TR_FUNCTIONNAME}]="ENONEXISTANT")
                __T_TR_FUNCTIONS_TO_DELETE+=("${__T_TR_FUNCTIONNAME}")
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
                return 141
            fi
        done
    fi

    if [[ ${#__T_TR_FUNCTIONS_FAILED[@]} -gt 0 ]]; then
        __log w -- "${__T_TR_MSG_TXT} Warning '${#__T_TR_FUNCTIONS_FAILED[@]}' have failed ("${!__T_TR_FUNCTIONS_FAILED[@]}")."
    fi
    return 0

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

    declare __P_TSAC_SIGNALNAME=""
    declare -i __T_TSAC_ERROR=0
    if __trap_signal_name "${@:1:1}" __P_TSAC_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __variable_exists "${@:2:1}"; then
        declare -n __T_TSAC_RETURN_ARRAYNAME="${@:2:1}"
    else
        declare __T_TSAC_RETURN_ARRAYNAME=""
    fi

    __T_TSAC_RETURN_ARRAYNAME=""

    declare __T_TSAC_SIGNAL_ARRAYNAME=""

    if __trap_signal_arrayname_get "${__P_TSAC_SIGNALNAME}" __T_TSAC_SIGNAL_ARRAYNAME; then
        if __array_exists "${__T_TSAC_SIGNAL_ARRAYNAME}"; then
            true
        else
            if declare -agx "${__T_TSAC_SIGNAL_ARRAYNAME}=()"; then
                true
            else
                return 201
            fi
        fi
    else
        return 202
    fi

    if [[ -R __T_TSAC_RETURN_ARRAYNAME ]]; then
        __T_TSAC_RETURN_ARRAYNAME="${__T_TSAC_SIGNAL_ARRAYNAME}"
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

    declare __P_TSAD_SIGNALNAME=""
    declare __T_TSAD_SIGNAL_ARRAYNAME=""

    if __trap_signal_name "${@:1:1}" __P_TSAD_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __trap_signal_arrayname_get "${__P_TSAD_SIGNALNAME}" __T_TSAD_SIGNAL_ARRAYNAME; then
        true
    else
        return 111
    fi

    if __array_exists "${__T_TSAD_SIGNAL_ARRAYNAME}"; then
        if unset "${__T_TSAD_SIGNAL_ARRAYNAME}"; then
            return 0
        else
            return 1
        fi
    else
        return 0
    fi
    return 254

}
#####
#
# - __trap_signal_array_exists
#
# - Description:
#   Takes the name of a signal and and checks if the array exists.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: SIGNAL_NAME - Name of the signal to use
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __trap_signal_array_exists() {

    declare __P_TSAE_SIGNALNAME=""
    declare __T_TSAE_SIGNAL_ARRAYNAME=""

    if __trap_signal_name "${@:1:1}" __P_TSAE_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __trap_signal_arrayname_get "${__P_TSAE_SIGNALNAME}" __T_TSAE_SIGNAL_ARRAYNAME; then
        true
    else
        return 111
    fi

    if __array_exists "${__T_TSAE_SIGNAL_ARRAYNAME}"; then
        return 0
    else
        return 1
    fi
    return 254

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

    declare -i __T_TSAG_ERROR=0
    declare __P_TSAG_SIGNALNAME=""

    if __trap_signal_name "${@:1:1}" __P_TSAG_SIGNALNAME; then
        true
    else
        return 101
    fi

    #if __variable_exists "${@:2:1}" && [[ ${BASH_SUBSHELL} -lt 1 ]]; then
    if __variable_exists "${@:2:1}"; then
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
    return 0
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
        return 101
    fi

    if trap -p "${@:1:1}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
    return 254

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

    if __trap_signal_exists "${@:1:1}"; then
        if [[ "${@:1:1}" =~ ${__TRAP_REGEX_NUMBER} ]]; then
            declare __P_TSN_SIGNALNUMBER=${@:1:1}
        else
            declare __P_TSN_SIGNALNAME="${@:1:1}"
        fi
    else
        return 101
    fi

    if __variable_exists "${@:2:1}"; then
        declare -n __T_TSN_RETURN_NAME="${@:2:1}"
    else
        declare __T_TSN_RETURN_NAME=""
    fi

    __T_TSN_RETURN_NAME=""

    if __variable_exists __P_TSN_SIGNALNAME; then
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
                unset IFS
                if [[ ${#__T_TSN_TA[@]} -ne 2 ]]; then
                    continue
                fi
                __TRAP_SIGNAL_TO_NAME+=([${__T_TSN_TA[0]}]="${__T_TSN_TA[1]}")
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

    declare __P_TSR_SIGNALNAME=""
    if __trap_signal_name "${@:1:1}" __P_TSR_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __trap_signal_registered "${__P_TSR_SIGNALNAME}"; then
        return 1
    elif trap "__trap_run "${__P_TSR_SIGNALNAME}"" "${__P_TSR_SIGNALNAME}" >/dev/null 2>&1; then
        if __trap_signal_array_exists "${__P_TSR_SIGNALNAME}"; then
            return 0
        elif __trap_signal_array_create "${__P_TSR_SIGNALNAME}"; then
            return 0
        else
            return 121
        fi
    else
        return 111
    fi
    return 254
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

    declare __P_TSRR_SIGNALNAME=""

    if __trap_signal_name "${@:1:1}" __P_TSRR_SIGNALNAME; then
        true
    else
        return 101
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

    declare __P_TSU_SIGNALNAME=""
    if __trap_signal_name "${@:1:1}" __P_TSU_SIGNALNAME; then
        true
    else
        return 101
    fi

    if __trap_signal_registered "${__P_TSU_SIGNALNAME}"; then
        if trap -- "${__P_TSU_SIGNALNAME}" >/dev/null 2>&1; then
            declare __T_TSU_ARRAYNAME=""
            if __trap_signal_arrayname_get "${__P_TSU_SIGNALNAME}" __T_TSU_ARRAYNAME; then
                if __array_exists "${__T_TSU_ARRAYNAME}"; then
                    if unset "${__T_TSU_ARRAYNAME}"; then
                        return 0
                    else
                        return 111
                    fi
                else
                    return 0
                fi
            else
                return 112
            fi
            return 0
        else
            return 113
        fi
    else
        return 1
    fi
}

