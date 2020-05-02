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

function __isenabled_cs_debug() {

    declare __CSD_DEFAULT=""
    if [[ -z ${__D_C_DEBUG+x} ]]; then
        true
    elif [[ "${__D_C_DEBUG}x" == "x" ]]; then
        declare __CSD_DEFAULT=""
    elif __variable_text __D_C_DEBUG 1; then
        declare __CSD_DEFAULT="1"
    elif __variable_text __D_C_DEBUG 0; then
        declare __CSD_DEFAULT=""
    fi

    __SETTINGS[DEBUG]="${__CSD_DEFAULT}"

    if [[ -z ${CS_DEBUG+x} ]]; then
        true
    elif [[ "${CS_DEBUG}x" == "x" ]]; then
        __SETTINGS[DEBUG]="${__CSD_DEFAULT}"
    elif __variable_text CS_DEBUG 1; then
        __SETTINGS[DEBUG]="1"
    elif __variable_text CS_DEBUG 0; then
        __SETTINGS[DEBUG]=""
    fi

    if [[ "${__SETTINGS[DEBUG]}x" == "x" ]]; then
        __log i -- "(CS_DEBUG) Checking if we enable debug... Disabled.\n"
    else
        __log i -- "(CS_DEBUG) Checking if we enable debug... Enabled.\n"
        declare -gx __LOG_DEBUG="1"
    fi
    return 0

}
function __start_cs_debug() {
    if [[ ${__SETTINGS[CS_DEBUG]:+x} ]]; then
        true
    else
        declare -gx __LOG_DEBUG=1
    fi
    return 0
}
__init_function_register_always 1001 __start_cs_debug

function __psp_cs_debug() {
    if [[ -z ${__SETTINGS[DEBUG]:+x} ]]; then
        __init_results_add "CS_DEBUG" "Disabled"
        return 0
    else
        __init_results_add "CS_DEBUG" "Enabled"
        declare -gx __LOG_DEBUG="1"
        return 0
    fi
    return 254
}
__init_function_register_always 5 __isenabled_cs_debug
__init_function_register_always 1001 __psp_cs_debug
