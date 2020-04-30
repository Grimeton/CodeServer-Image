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

function __isenabled_cs_user_home() {
    declare __FUH_DEFAULT_BASE="/home"
    declare __FUH_DEFAULT_SUFFIX="u"
    declare __FUH_DEFAULT_SUFFIX_REGEX='^/.+$'

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        true
    elif [[ "${__SETTINGS[USER]}x" == "x" ]]; then
        true
    else
        declare __FUH_DEFAULT_SUFFIX="${__SETTINGS[USER]}"
    fi

    declare __FUH_DEFAULT="${__FUH_DEFAULT_BASE}/${__FUH_DEFAULT_SUFFIX}"

    if [[ -z ${__D_C_USER_HOME+x} ]]; then
        true
    elif [[ "${__D_C_USER_HOME}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_HOME}" =~ ${__FUH_DEFAULT_SUFFIX_REGEX} ]]; then
        declare __FUH_DEFAULT="${__D_C_USER_HOME}"
    else
        declare __FUH_DEFAULT="${__FUH_DEFAULT_BASE}/${__D_C_USER_HOME}"
    fi

    __SETTINGS[USER_HOME]="${__FUH_DEFAULT}"

    if [[ -z ${CS_USER_HOME+x} ]]; then
        true
    elif [[ "${CS_USER_HOME}x" == "x" ]]; then
        true
    elif [[ "${CS_USER_HOME}" =~ ${__FUH_DEFAULT_SUFFIX_REGEX} ]]; then
        __SETTINGS[USER_HOME]="${CS_USER_HOME}"
    else
        __SETTINGS[USER_HOME]="${__FUH_DEFAULT_BASE}/${CS_USER_HOME}"
    fi

    __log i -- "(CS_USER_HOME) Configuring user home... '${__SETTINGS[USER_HOME]}'.\n"
    return 0
}

__init_function_register_always 70 __isenabled_cs_user_home

function __psp_cs_user_home() {
    if [[ -z ${__SETTINGS[USER_HOME]:+x} ]]; then
        __init_results_add "CS_USER_HOME" "None"
    else
        __init_results_add "CS_USER_HOME" "${__SETTINGS[USER_HOME]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_user_home
