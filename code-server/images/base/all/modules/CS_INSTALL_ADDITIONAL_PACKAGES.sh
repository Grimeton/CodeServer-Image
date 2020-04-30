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

function __isenabled_cs_install_additional_packages() {

    declare __IAP_PACKAGES=""

    if [[ -z ${__D_C_INSTALL_ADDITIONAL_PACKAGES+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_ADDITIONAL_PACKAGES}x" == "x" ]]; then
        declare __IAP_PACKAGES=""
    else
        declare __IAP_PACKAGES="${__D_C_INSTALL_ADDITIONAL_PACKAGES}"
    fi
    __SETTINGS[ADDITIONAL_PACKAGES]="${__IAP_PACKAGES}"

    if [[ -z ${CS_INSTALL_ADDITIONAL_PACKAGES+x} ]]; then
        true
    elif [[ "${CS_INSTALL_ADDITIONAL_PACKAGES}x" == "x" ]]; then
        true
    else
        __SETTINGS[ADDITIONAL_PACKAGES]+="${CS_INSTALL_ADDITIONAL_PACKAGES}"
    fi

    if [[ "${__SETTINGS[ADDITIONAL_PACKAGES]}x" == "x" ]]; then
        __log i -- "(CS_INSTALL_ADDITIONAL_PACKAGES) Checking if additional packages need to be installed... Disabled.\n"
        return 0
    else
        __log i -- "(CS_INSTALL_ADDITIONAL_PACKAGES) Checking if additional packages need to be installed... Enabled.\n"
        __log i -- "(CS_INSTALL_ADDITIONAL_PACKAGES) Additional packages: '${__SETTINGS[ADDITIONAL_PACKAGES]}'.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 150 __isenabled_cs_install_additional_packages

function __provide_cs_install_additional_packages() {
    
    if [[ -z ${__SETTINGS[ADDITIONAL_PACKAGES]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[ADDITIONAL_PACKAGES]}x" == "x" ]]; then
        return 0
    elif __pm_package_install_list_add ${__SETTINGS[ADDITIONAL_PACKAGES]}; then
        return 0
    else
        return 253
    fi
    return 254

}

__init_function_register_always 300 __provide_cs_install_additional_packages

function __psp_cs_install_additional_packages() {
    if [[ -z ${__SETTINGS[ADDITIONAL_PACKAGES]:+x} ]]; then
        __init_results_add "CS_INSTALL_ADDITIONAL_PACKAGES" "None"
    else
        __init_results_add "CS_INSTALL_ADDITIONAL_PACKAGES" "${__SETTINGS[ADDITIONAL_PACKAGES]}"
    fi
    return 0
}

__init_function_register_always 1800 __psp_cs_install_additional_packages
