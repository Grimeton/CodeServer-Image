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

function __isenabled_cs_verbose() {
    
    __SETTINGS[CS_VERBOSE]=""

    if [[ -z ${CS_VERBOSE+x} ]]; then
        true
    elif [[ "${CS_VERBOSE}x" == "x" ]]; then
        true
    elif __test_variable_text_true "${CS_VERBOSE}"; then
        declare -gx __LOG_VERBOSE="1"
        __SETTINGS[CS_VERBOSE]=1
    else
        true
    fi

    if [[ "${__SETTINGS[CS_VERBOSE]}x" == "x" ]]; then
        __log i -- "(CS_VERBOSE) Configuring verbose mode... Disabled.\n"
        return 0
    else
        __log i -- "(CS_VERBOSE) Configuring verbose mode... Enabled.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 10 __isenabled_cs_verbose
function __start_cs_verbose() {
    if [[ ${__SETTINGS[CS_VERBOSE]:+x} ]]; then
        true
    else
        declare -gx __LOG_VERBOSE=1
    fi
    return 0
}
__init_function_register_always 1001 __start_cs_verbose

function __psp_cs_verbose() {

    if __init_codeserver_startup_options_available "verbose"; then
        true
    else
        return 0
    fi
    
    
    if [[ ${__SETTINGS[CS_VERBOSE]+x} ]]; then
        __init_results_add "CS_VERBOSE" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_VERBOSE]}x" == "x" ]]; then
        __init_results_add "CS_VERBOSE" "Disabled"
        return 0
    else
        declare -gx __LOG_VERBOSE="1"
        __init_results_add "CS_VERBOSE" "Enabled"
        __START_PARAMETERS+=("--verbose")
        return 0
    fi
    return 254
}
__init_function_register 1800 __psp_cs_verbose
