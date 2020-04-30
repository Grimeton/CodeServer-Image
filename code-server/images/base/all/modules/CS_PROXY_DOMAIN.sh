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

function __isenabled_cs_proxy_domain() {

    declare __FPD_PROXYDOMAIN=""

    if [[ -z ${__D_C_PROXY_DOMAIN+x} ]]; then
        true
    else
        declare __FPD_PROXYDOMAIN="${__D_C_PROXY_DOMAIN}"
    fi

    __SETTINGS[CS_PROXYDOMAIN]="${__FPD_PROXYDOMAIN}"

    if [[ -z ${CS_PROXY_DOMAIN+x} ]]; then
        true
    elif [[ "${CS_PROXY_DOMAIN}x" == "x" ]]; then
        true
    else
        __SETTINGS[CS_PROXYDOMAIN]="${CS_PROXY_DOMAIN}"
    fi

    if [[ "${__SETTINGS[CS_PROXYDOMAIN]}x" == "x" ]]; then
        __log i -- "(CS_PROXY_DOMAIN) Checking if we have the proxy domain configured... Disabled.\n"
    else
        __log i -- "(CS_PROXY_DOMAIN) Checking if we have the proxy domain configured... Enabled.\n"
        __log i -- "(CS_PROXY_DOMAIN) Domains: '${__SETTINGS[CS_PROXYDOMAIN]}'.\n"
    fi
    return 0
}

__init_function_register_always 150 __isenabled_cs_proxy_domain

function __psp_cs_proxy_domain() {

    if __init_codeserver_startup_options_available "proxy-domain"; then
        true
    else
        return 0
    fi
    

    if [[ -z ${__SETTINGS[CS_PROXYDOMAIN]+x} ]]; then
        __init_results_add "CS_PROXYDOMAIN" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_PROXYDOMAIN]}x" == "x" ]]; then
        __init_results_add "CS_PROXYDOMAIN" "Disabled"
        return 0
    else
        for __T_PD in ${__SETTINGS[CS_PROXYDOMAIN]}; do
            __START_PARAMETERS+=("--proxy-domain" "${__T_PD}")
        done
        __init_results_add "CS_PROXYDOMAIN" "${__SETTINGS[CS_PROXYDOMAIN]}"
        return 0
    fi
    return 254
}
__init_function_register_always 1800 __psp_cs_proxy_domain
