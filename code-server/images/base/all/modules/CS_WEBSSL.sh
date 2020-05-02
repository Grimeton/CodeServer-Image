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

function __isenabled_cs_webssl_cert() {

    __SETTINGS[CS_WEBSSL_CERT]=""
    __SETTINGS[CS_WEBSSL_KEY]=""

    if __variable_exists CS_WEBSSL_CERT; then
        if __variable_empty CS_WEBSSL_CERT; then
            true
        else
            __SETTINGS[CS_WEBSSL_CERT]="${CS_WEBSSL_CERT}"
        fi
    else
        true
    fi

    if __variable_exists CS_WEBSSL_KEY; then
        if __variable_empty CS_WEBSSL_KEY; then
            true
        else
            __SETTINGS[CS_WEBSSL_KEY]="${CS_WEBSSL_KEY}"
        fi
    else
        true
    fi

    if __variable_exists CS_WEBSSL_KEY_PERMISSIONS; then
        if __variable_empty CS_WEBSSL_KEY_PERMISSIONS; then
            true
        else
            __SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]="${CS_WEBSSL_KEY_PERMISSIONS}"
        fi
    fi

    if __variable_exists CS_WEBSSL_CERT_PERMISSIONS; then
        if __variable_empty CS_WEBSSL_CERT_PERMISSIONS; then
            true
        else
            __SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]="${CS_WEBSSL_CERT_PERMISSIONS}"
        fi
    fi

    if [[ "${__SETTINGS[CS_WEBSSL_CERT]}x" == "x" ]]; then
        __log i -- "(CS_WEBSSL) Testing if SSL/TLS is enabled... Disabled.\n"
    else
        __log i -- "(CS_WEBSSL) Testing if SSL/TLS is enabled... Enabled.\n"
    fi
    return 0
}

__init_function_register_always 150 __isenabled_cs_webssl_cert

function __post_cs_webssl_cert() {

    declare __FWC_USERNAME="u"
    declare __FWC_GROUPNAME="u"
    declare __FWC_WEBSSL_CERT_PERMISSIONS="0444"
    declare __FWC_WEBSSL_KEY_PERMISSIONS="0444"
    declare __FWC_REGEX_WEBSSL_CERT_PERMISSIONS='^[0-7]{3,4}$'
    declare __FWC_REGEX_WEBSSL_KEY_PERMISSIONS='^[0-7]{3,4}$'

    if [[ -z ${__D_C_WEBSSL_CERT_PERMISSIONS_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_WEBSSL_CERT_PERMISSIONS_REGEX}x" == "x" ]]; then
        true
    else
        declare __FWC_REGEX_WEBSSL_CERT_PERMISSIONS="${__D_C_WEBSSL_CERT_PERMISSIONS_REGEX}"
    fi

    if [[ -z ${__D_C_WEBSSL_KEY_PERMISSIONS_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_WEBSSL_KEY_PERMISSIONS_REGEX}x" == "x" ]]; then
        true
    else
        declare __FWC_REGEX_WEBSSL_KEY_PERMISSIONS="${__D_C_WEBSSL_KEY_PERMISSIONS_REGEX}"
    fi

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        true
    else
        declare __FWC_USERNAME="${__SETTINGS[USER]}"
    fi

    if [[ -z ${__SETTINGS[GROUPNAME]+x} ]]; then
        true
    else
        declare __FWC_GROUPNAME="${__SETTINGS[GROUPNAME]}"
    fi

    if [[ -z ${__D_C_WEBSSL_CERT_PERMISSIONS+x} ]]; then
        true
    elif [[ "${__D_C_WEBSSL_CERT_PERMISSIONS}x" == "x" ]]; then
        true
    elif [[ "${__D_C_WEBSSL_CERT_PERMISSIONS}" =~ ${__FWC_REGEX_WEBSSL_CERT_PERMISSIONS} ]]; then
        declare __FWC_WEBSSL_CERT_PERMISSIONS="${__D_C_WEBSSL_CERT_PERMISSIONS}"
    fi

    if [[ -z ${__D_C_WEBSSL_KEY_PERMISSIONS+x} ]]; then
        true
    elif [[ "${__D_C_WEBSSL_KEY_PERMISSIONS}x" == "x" ]]; then
        true
    elif [[ "${__D_C_WEBSSL_KEY_PERMISSIONS}" =~ ${__FWC_REGEX_WEBSSL_KEY_PERMISSIONS} ]]; then
        declare __FWC_WEBSSL_KEY_PERMISSIONS="${__D_C_WEBSSL_KEY_PERMISSIONS}"
    fi

    if [[ -z ${__SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]+x} ]]; then
        __SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]="${__FWC_WEBSSL_CERT_PERMISSIONS}"
    elif [[ "${__SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]}x" == "x" ]]; then
        __SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]="${__FWC_WEBSSL_CERT_PERMISSIONS}"
    elif [[ "${__SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]}" =~ ${__FWC_REGEX_WEBSSL_CERT_PERMISSIONS} ]]; then
        true
    else
        __SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]="${__FWC_WEBSSL_CERT_PERMISSIONS}"
    fi

    if [[ -z ${__SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]+x} ]]; then
        __SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]="${__FWC_WEBSSL_KEY_PERMISSIONS}"
    elif [[ "${__SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]}x" == "x" ]]; then
        __SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]="${__FWC_WEBSSL_KEY_PERMISSIONS}"
    elif [[ "${__SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]}" == ${__FWC_REGEX_WEBSSL_KEY_PERMISSIONS} ]]; then
        true
    else
        __SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]="${__FWC_WEBSSL_KEY_PERMISSIONS}"
    fi

    if [[ -z ${__SETTINGS[CS_WEBSSL_CERT]+x} ]]; then
        __SETTINGS[CS_WEBSSL_CERT]=""
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    elif [[ "${__SETTINGS[CS_WEBSSL_CERT]}x" == "x" ]]; then
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    elif [[ -f "${__SETTINGS[CS_WEBSSL_CERT]}" ]]; then
        __log i -- "(CS_WEBSSL) Configuring integrated webserver certificate...\n"
        if [[ -z ${__SETTINGS[CS_WEBSSL_KEY]+x} ]]; then
            __SETTINGS[CS_WEBSSL_KEY]=""
        fi
    else
        __log i -- "(CS_WEBSSL) Configuring integrated webserver certificate...\n"
        __log i -- "(CS_WEBSSL) Certificate '${__SETTINGS[CS_WEBSSL_CERT]}' is invalid. SSL/TLS using auto generataion.\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    fi

    if [[ -z ${__SETTINGS[CS_WEBSSL_KEY]+x} ]]; then
        __log i -- "(CS_WEBSSL) Key file is missing. using auto generation.\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    elif [[ "${__SETTINGS[CS_WEBSSL_KEY]}x" == "x" ]]; then
        __log i -- "(CS_WEBSSL) Key file is missing. using auto generation.\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    elif [[ -f "${__SETTINGS[CS_WEBSSL_KEY]}" ]]; then
        true
    else
        __log i -- "(CS_WEBSSL) Key file '${__SETTINGS[CS_WEBSSL_KEY]}' is invalid. using auto generation.\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    fi

    if __file_access "${__FWC_USERNAME}" r "${__SETTINGS[CS_WEBSSL_CERT]}"; then
        true
    elif chown "${__FWC_USERNAME}":"${__FWC_GROUPNAME}" "${__SETTINGS[CS_WEBSSL_CERT]}"; then
        if chmod "${__SETTINGS[CS_WEBSSL_CERT_PERMISSIONS]}" "${__SETTINGS[CS_WEBSSL_CERT]}"; then
            if __file_access "${__FWC_USERNAME}" r "${__SETTINGS[CS_WEBSSL_CERT]}"; then
                true
            else
                __SETTINGS[CS_WEBSSL_CERT]=""
            fi
        else
            __SETTINGS[CS_WEBSSL_CERT]=""
        fi
    else
        __SETTINGS[CS_WEBSSL_CERT]=""
    fi

    if [[ "${__SETTINGS[CS_WEBSSL_CERT]}x" == "x" ]]; then
        __log i -- "(CS_WEBSSL) Permission problems with 'CS_CERT':'${__SETTINGS[CS_WEBSSL_CERT]}'. Reverting back to auto generation...\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    fi

    if __file_access "${__FWC_USERNAME}" r "${__SETTINGS[CS_WEBSSL_KEY]}"; then
        true
    elif chown "${__FWC_USERNAME}":"${__FWC_GROUPNAME}" "${__SETTINGS[CS_WEBSSL_KEY]}"; then
        if chmod "${__SETTINGS[CS_WEBSSL_KEY_PERMISSIONS]}" "${__SETTINGS[CS_WEBSSL_KEY]}"; then
            true
        else
            __SETTINGS[CS_WEBSSL_KEY]=""
        fi
    else
        __SETTINGS[CS_WEBSSL_KEY]=""
    fi

    if [[ "${__SETTINGS[CS_WEBSSL_KEY]}x" == "x" ]]; then
        __log i -- "(CS_WEBSSL) Permission problems on 'CS_CERT_KEY':'${__SETTINGS[CS_WEBSSL_KEY]}'. Reverting back to auto generation...\n"
        __SETTINGS[CS_WEBSSL_CERT]="/dev/null"
        __SETTINGS[CS_WEBSSL_KEY]=""
        return 0
    fi

    __log i -- "(CS_WEBSSL) Both files provided. Using custom certificate for TLS/SSL!\n"
    __log i -- "(CS_WEBSSL) Certificate file will be: '${__SETTINGS[CS_WEBSSL_CERT]}'.\n"
    __log i -- "(CS_WEBSSL) Key file will be: '${__SETTINGS[CS_WEBSSL_KEY]}'.\n"
    return 0

}

__init_function_register_always 750 __post_cs_webssl_cert

function __psp_cs_webssl_cert() {

    for __T_KEY in cert cert-key; do
        if __init_codeserver_startup_options_available "${__T_KEY}"; then
            true
        else
            return 0
        fi
    done

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        declare __FWC_USERNAME="u"
    else
        declare __FWC_USERNAME="${__SETTINGS[USER]}"
    fi

    if [[ -z ${__SETTINGS[CS_WEBSSL_CERT]+x} ]]; then
        __init_results_add "CS_WEBSSL_CERT" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_WEBSSL_CERT]}x" == "x" ]]; then
        __init_results_add "CS_WEBSSL_CERT" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_WEBSSL_CERT]}" == "/dev/null" ]]; then
        __init_results_add "CS_WEBSSL_CERT" "Automatic"
        __START_PARAMETERS+=("--cert")
        return 0
    elif __file_access "${__FWC_USERNAME}" r "${__SETTINGS[CS_WEBSSL_CERT]}"; then
        if __file_access "${__FWC_USERNAME}" r "${__SETTINGS[CS_WEBSSL_KEY]}"; then
            __init_results_add "CS_WEBSSL_CERT" "${__SETTINGS[CS_WEBSSL_CERT]}"
            __init_results_add "CS_WEBSSL_KEY" "${__SETTINGS[CS_WEBSSL_KEY]}"
            __START_PARAMETERS+=("--cert" "${__SETTINGS[CS_WEBSSL_CERT]}")
            __START_PARAMETERS+=("--cert-key" "${__SETTINGS[CS_WEBSSL_KEY]}")
            return 0
        else
            __init_results_add "CS_WEBSSL_CERT" "Automatic"
            __START_PARAMETERS+=("--cert")
            return 0
        fi
    else
        __init_results_add "CS_WEBSSL_CERT" "Automatic"
        __START_PARAMETERS+=("--cert")
        return 0
    fi
    return 254
}
__init_function_register_always 1800 __psp_cs_webssl_cert
