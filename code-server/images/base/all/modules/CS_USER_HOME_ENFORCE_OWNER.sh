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
# 1
#
if ! (return 0 2>/dev/null); then
    echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
    exit 254
fi

function __isenabled_cs_user_home_enforce_owner() {

    __log i -- "(CS_USER_HOME_ENFORCE_OWNER) Configuring home directory owner enforcement...\n"
    declare __FUHEO_DEFAULT=""
    if [[ -z ${__D_C_USER_HOME_ENFORCE_OWNER+x} ]]; then
        true
    elif [[ "${__D_C_USER_HOME_ENFORCE_OWNER}x" == "x" ]]; then
        declare __FUHEO_DEFAULT=""
    elif __variable_text __D_C_USER_HOME_ENFORCE_OWNER 1; then
        declare __FUHEO_DEFAULT="1"
    elif __variable_text __D_C_USER_HOME_ENFORCE_OWNER 0; then
        declare __FUHEO_DEFAULT=""
    fi

    __SETTINGS[USER_HOME_ENFORCE_OWNER]="${__FUHEO_DEFAULT}"

    if [[ -z ${CS_USER_HOME_ENFORCE_OWNER+x} ]]; then
        true
    elif [[ "${CS_USER_HOME_ENFORCE_OWNER}x" == "x" ]]; then
        true
    elif __variable_text CS_USER_HOME_ENFORCE_OWNER 1; then
        __SETTINGS[USER_HOME_ENFORCE_OWNER]="1"
    elif __variable_text CS_USER_HOME_ENFORCE_OWNER 0; then
        __SETTINGS[USER_HOME_ENFORCE_OWNER]=""
    fi

    if [[ "${__SETTINGS[USER_HOME_ENFORCE_OWNER]}x" == "x" ]]; then
        __log i -- "(CS_USER_HOME_ENFORCE_OWNER) Home directory owner enforcement... Disabled.\n"
        return 0
    else
        __log i -- "(CS_USER_HOME_ENFORCE_OWNER) Home directory owner enforcement... Enabled.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 100 __isenabled_cs_user_home_enforce_owner

function __post_cs_user_home_enforce_owner() {

    if [[ -z ${__SETTINGS[USER_HOME_ENFORCE_OWNER]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[USER_HOME_ENFORCE_OWNER]}x" == "x" ]]; then
        return 0
    fi

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        return 241
    elif [[ "${__SETTINGS[USER]}x" == "x" ]]; then
        return 242
    fi

    if [[ -z ${__SETTINGS[GROUP]+x} ]]; then
        return 231
    elif [[ "${__SETTINGS[GROUP]}x" == "x" ]]; then
        return 232
    fi

    if [[ -z ${__SETTINGS[USER_HOME]+x} ]]; then
        return 221
    elif [[ "${__SETTINGS[USER_HOME]}x" == "x" ]]; then
        return 222
    elif [[ ! -d "${__SETTINGS[USER_HOME]}" ]]; then
        return 223
    elif [[ "$(realpath "${__SETTINGS[USER_HOME]}")" == "/" ]]; then
        return 224
    fi
    __log i -- "(CS_USER_HOME_ENFORCE_OWNER) Enforcing ownership for '${__SETTINGS[USER]}' on '${__SETTINGS[USER_HOME]}'.\n"
    declare -i __T_ERROR=0
    chown -Rv "${__SETTINGS[USER]}":"${__SETTINGS[GROUP]}" "${__SETTINGS[USER_HOME]}" | __log_stdin d --
    
    for __T_PS in ${PIPESTATUS[@]}; do
        if [[ ${__T_PS} -gt 0 ]]; then
            __T_ERROR=${__T_PS}
        fi
    done

    if [[ ${__T_ERROR} -lt 1 ]]; then
        __log i -- "(CS_USER_HOME_ENFORCE_OWNER) Success!\n"
        return 0
    else
        __log e -- "(CS_USER_HOME_ENFORCE_OWNER) Error. Could not enforce ownership on '${__SETTINGS[USER_HOME]}' (${__T_ERROR}).\n"
        return 123
    fi
    return 254
}
__init_function_register_always 750 __post_cs_user_home_enforce_owner

function __psp_cs_user_home_enforce_owner() {
    if [[ -z ${__SETTINGS[CS_USER_HOME_ENFORCE_OWNER]:+x} ]]; then
        __init_results_add "CS_USER_HOME_ENFOCE_OWNER" "Disabled"
    else
        __init_results_add "CS_USER_HOME_ENFORCE_OWNER" "Enabled"
    fi
    return 0

}
__init_function_register_always 1800 __psp_cs_user_home_enforce_owner
