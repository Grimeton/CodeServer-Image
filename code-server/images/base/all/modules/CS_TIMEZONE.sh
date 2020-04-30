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

function __isenabled_cs_timezone() {

    declare __FT_DEFAULT=""
    declare __FT_PACKAGES=""

    if [[ -z ${__D_C_TIMEZONE+x} ]]; then
        true
    else
        declare __FT_DEFAULT="${__D_C_TIMEZONE}"
    fi

    if [[ -z ${__D_C_TIMEZONE_PACKAGES+x} ]]; then
        true
    else
        declare __FT_PACKAGES="${__D_C_TIMEZONE_PACKAGES}"
    fi

    __SETTINGS[CS_TIMEZONE]="${__FT_DEFAULT}"
    __SETTINGS[CS_TIMEZONE_PACKAGES]="${__FT_PACKAGES}"

    if [[ -z ${CS_TIMEZONE+x} ]]; then
        true
    elif [[ "${CS_TIMEZONE}x" == "x" ]]; then
        true
    else
        __SETTINGS[CS_TIMEZONE]="${CS_TIMEZONE}"
    fi

    if [[ -z ${CS_TIMEZONE_PACKAGES+x} ]]; then
        true
    elif [[ "${CS_TIMEZONE_PACKAGES}x" == "x" ]]; then
        true
    else
        __SETTINGS[CS_TIMEZONE_PACKAGES]="${CS_TIMEZONE_PACKAGES}"
    fi

    if [[ "${__SETTINGS[CS_TIMEZONE]}x" == "x" ]]; then
        __SETTINGS[CS_TIMEZONE_PACKAGES]=""
        __log i -- "(CS_TIMEZONE) Checking for timezones... Disabled.\n"
        return 0
    else
        __log i -- "(CS_TIMEZONE) Checking for timezones.... Enabled: '${__SETTINGS[CS_TIMEZONE]}'.\n"
        if [[ "${__SETTINGS[CS_TIMEZONE_PACKAGES]}x" != "x" ]]; then
            __log i -- "(CS_TIMEZONE) Using packages: '${__SETTINGS[CS_TIMEZONE_PACKAGES]}'.\n"
        fi
        return 0
    fi
    return 254
}

__init_function_register_always 150 __isenabled_cs_timezone

function __psp_cs_timezone() {
    if [[ -z ${__SETTINGS[CS_TIMEZONE]:+x} ]]; then
        __init_results_add "CS_TIMEZONE" "None"
    else
        __init_results_add "CS_TIMEZONE" "${__SETTINGS[CS_TIMEZONE]}"
    fi

    if [[ -z ${__SETTINGS[CS_TIMEZONE_PACKAGES]:+x} ]]; then
        __init_results_add "CS_TIMEZONE_PACKAGES" "None"
    else
        __init_results_add "CS_TIMEZONE_PACKAGES" "${__SETTINGS[CS_TIMEZONE_PACKAGES]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_timezone
