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

function __isenabled_cs_enable_updates() {

    declare __FCEN_DEFAULT=""
    if [[ -z ${__D_C_ENABLE_UPDATES+x} ]]; then
        true
    elif [[ "${__D_C_ENABLE_UPDATES}x" == "x" ]]; then
        declare __FCEN_DEFAULT=""
    elif __test_variable_text __D_C_ENABLE_UPDATES 1; then
        declare __FCEN_DEFAULT="1"
    elif __test_variable_text __D_C_ENABLE_UPDATES 0; then
        declare __FCEN_DEFAULT=""
    fi

    __SETTINGS[CS_ENABLE_UPDATES]="${__FCEN_DEFAULT}"
    if __test_variable_exists CS_ENABLE_UPDATES; then
        if __test_variable_empty CS_ENABLE_UPDATES; then
            true
        elif __test_variable_text CS_ENABLE_UPDATES 1; then
            __SETTINGS[CS_ENABLE_UPDATES]="1"
        elif __test_variable_text CS_ENABLE_UPDATES 0; then
            __SETTINGS[CS_ENABLE_UPDATES]=""
        fi
    fi

    if [[ "${__SETTINGS[CS_ENABLE_UPDATES]}x" == "x" ]]; then
        __log i -- "(CS_ENABLE_UPDATES) Configuring Automatic Updates... Disabled.\n"
    else
        __log i -- "(CS_ENABLE_UPDATES) Configuring Automatic Updates... Enabled.\n"
    fi
    return 0
}
__init_function_register_always 150 __isenabled_cs_enable_updates

function __psp_cs_enable_updates() {

    if __init_codeserver_startup_options_available "disable-updates"; then
        true
    else
        return 0
    fi
    
    if [[ -z ${__SETTINGS[CS_ENABLE_UPDATES]+x} ]]; then
        __init_results_add "CS_ENABLE_UPDATES" "Enabled"
        return 0
    elif [[ "${__SETTINGS[CS_ENABLE_UPDATES]}x" == "x" ]]; then
        __init_results_add "CS_ENABLE_UPDATES" "Disabled"
        __START_PARAMETERS+=("--disable-updates")
        return 0
    else
        __init_results_add "CS_ENABLE_UPDATES" "Enabled"
        return 0
    fi
    return 254
}
__init_function_register_always 1800 __psp_cs_enable_updates
