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

function __isenabled_cs_web_auth() {

    declare __FWA_DEFAULT=""

    if [[ -z ${__D_C_WEB_AUTH+x} ]]; then
        true
    else
        __FWA_DEFAULT="${__D_C_WEB_AUTH}"
    fi

    __SETTINGS[CS_WEB_AUTH]="${__FWA_DEFAULT}"

    if __test_variable_exists CS_WEB_AUTH; then
        if __test_variable_empty CS_WEB_AUTH; then
            true
        else
            __SETTINGS[CS_WEB_AUTH]="${CS_WEB_AUTH}"
        fi
    else
        true
    fi

    if [[ "${__SETTINGS[CS_WEB_AUTH]}x" == "x" ]]; then
        __log i -- "(CS_WEB_AUTH) Configuring integrated webserver authorisation mode... None.\n"
        return 0
    else
        __log i -- "(CS_WEB_AUTH) Configuring integrated webserver authorisation mode... Password.\n"
        return 0
    fi

}
__init_function_register_always 150 __isenabled_cs_web_auth

function __psp_cs_web_auth() {

    if __init_codeserver_startup_options_available "auth"; then
        true
    else
        return 0
    fi
    

    if [[ -z ${__SETTINGS[CS_WEB_AUTH]+x} ]]; then
        __init_results_add "CS_WEB_AUTH" "Disabled"
        __START_PARAMETERS+=("--auth" "none")
        return 0
    elif [[ "${__SETTINGS[CS_WEB_AUTH]}x" == "x" ]]; then
        __init_results_add "CS_WEB_AUTH" "Disabled"
        __START_PARAMETERS+=("--auth" "none")
        return 0
    else
        __init_results_add "CS_WEB_AUTH" "Enabled"
        __START_PARAMETERS+=("--auth" "password")
        declare -gx PASSWORD="${__SETTINGS[CS_WEB_AUTH]}"
        return 0
    fi
    return 1
}
__init_function_register_always 1800 __psp_cs_web_auth
