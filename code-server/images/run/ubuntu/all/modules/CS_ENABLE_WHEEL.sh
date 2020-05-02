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
__lib_require "base_variable"
function __isenabled_feature_wheel() {

    declare __FW_DEFAULT=""

    if [[ -z ${__D_C_ENABLE_WHEEL+x} ]]; then
        true
    elif [[ "${__D_C_ENABLE_WHEEL}x" == "x" ]]; then
        __FW_DEFAULT=""
    elif __variable_text __D_C_ENABLE_WHEEL 1; then
        __FW_DEFAULT="1"
    elif __variable_text __D_C_ENABLE_WHEEL 0; then
        __FW_DEFAULT=""
    fi

    __SETTINGS[CS_ENABLE_WHEEL]="${__FW_DEFAULT}"

    if [[ -z ${CS_ENABLE_WHEEL+x} ]]; then
        true
    elif [[ "${CS_ENABLE_WHEEL}x" == "x" ]]; then
        true
    elif __variable_text CS_ENABLE_WHEEL 1; then
        __SETTINGS[CS_ENABLE_WHEEL]="1"
    elif __variable_text CS_ENABLE_WHEEL 0; then
        __SETTINGS[CS_ENABLE_WHEEL]=""
    fi

    if [[ "${__SETTINGS[CS_ENABLE_WHEEL]}x" == "x" ]]; then
        __log i -- "(CS_ENABLE_WHEEL) Checking if we enable the 'wheel' feature... Disabled.\n"
        return 0
    else
        __log i -- "(CS_ENABLE_WHEEL) Checking if we enable the 'wheel' feature... Enabled.\n"
        return 0
    fi
    return 254
}

__init_function_register_always 150 __isenabled_feature_wheel

function __pre_feature_wheel() {

    if [[ -z ${__SETTINGS[CS_ENABLE_WHEEL]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_ENABLE_WHEEL]}x" == "x" ]]; then
        return 0
    fi
    __log i -- "(CS_ENABLE_WHEEL) Testing if group 'wheel' exists...\n"
    if __group_name_exists "wheel"; then
        __log i -- "(CS_ENABLE_WHEEL) Group 'wheel' exists.\n"
    else
        __log i -- "(CS_ENABLE_WHEEL) Group 'wheel' does not exist... Attempting to create it.\n"
        if __group_add -r wheel; then
            __log i -- "(CS_ENABLE_WHEEL) Group 'wheel' created successfully.\n"
        else
            __log e -- "(CS_ENABLE_WHEEL) Could not create group 'wheel' ($?).\n"
            return 111
        fi
    fi
    __log i -- "(CS_ENABLE_WHEEL) Patching '/etc/pam.d/su'...\n"
    if [[ -f /etc/pam.d/su ]]; then
        if sed -iE 's/^#.*auth.*sufficient.*pam_wheel.so.*trust$/auth       sufficient pam_wheel.so trust/g' /etc/pam.d/su; then
            __log i -- "(CS_ENABLE_WHEEL) Patching '/etc/pam.d/su' success.\n"
            return 0
        else
            __log i -- "(CS_ENABLE_WHEEL) Problems patching '/etc/pam.d/su' ($?).\n"
            return 121
        fi
    else
        __log e -- "(CS_ENABLE_WHEEL) '/etc/pam.d/su' does not exist.\n"
        return 131
    fi
    return 254
}

__init_function_register_always 250 __pre_feature_wheel
function __post_cs_enable_wheel() {
    if [[ -z ${__SETTINGS[CS_ENABLE_WHEEL]:+x} ]]; then
        return 0
    fi
    if [[ -z ${__SETTINGS[USER]:+x} ]]; then
        return 0
    fi

    if usermod -G wheel -a "${__SETTINGS[USER]}"; then
        return 0
    else
        return $?
    fi
    return 254
}
__init_function_register_always 750 __post_cs_enable_wheel

function __psp_cs_enable_wheel() {
    if [[ -z ${__SETTINGS[CS_ENABLE_WHEEL]:+x} ]]; then
        __init_results_add "CS_ENABLE_WHEEL" "Disabled"
    else
        __init_results_add "CS_ENABLE_WHEEL" "Enabled"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_enable_wheel
