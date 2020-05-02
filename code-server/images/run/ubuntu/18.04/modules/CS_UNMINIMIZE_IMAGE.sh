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
# 0.5 - only on 18.04 and up
#

if ! (return 0 2>/dev/null); then
    echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
    exit 254
fi

function __isenabled_feature_unminimize_image() {

    declare __UI_DEFAULT=""

    if [[ -z ${__D_C_UNMINIMIZE_IMAGE+x} ]]; then
        true
    elif [[ "${__D_C_UNMINIMIZE_IMAGE}x" == "x" ]]; then
        __UI_DEFAULT=""
    elif __variable_text __D_C_UNMINIMIZE_IMAGE 1; then
        __UI_DEFEAULT="1"
    elif __variable_text __D_C_UNMINIMIZE_IMAGE 0; then
        __UI_DEFAULT=""
    fi

    __SETTINGS[UNMINIMIZE_IMAGE]="${__UI_DEFAULT}"

    if [[ -z ${CS_UNMINIMIZE_IMAGE+x} ]]; then
        true
    elif [[ "${CS_UNMINIMIZE_IMAGE}x" == "x" ]]; then
        true
    elif __variable_text CS_UNMINIMIZE_IMAGE 1; then
        __SETTINGS[UNMINIMIZE_IMAGE]="1"
    elif __variable_text CS_UNMINIMIZE_IMAGE 0; then
        __SETTINGS[UNMINIMIZE_IMAGE]=""
    fi

    if [[ "${__SETTINGS[UNMINIMIZE_IMAGE]}x" == "x" ]]; then
        __log i -- "(CS_UNMINIMIZE_IMAGE) Checking if we have to unminimize the image... No.\n"
        return 0
    else
        __log i -- "(CS_UNMINIMIZE_IMAGE) Checking if we have to unminimize the image... Yes.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 150 __isenabled_feature_unminimize_image

function __run_unminimize_image() {
    if [[ -z ${__SETTINGS[UNMINIMIZE_IMAGE]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[UNMINIMIZE_IMAGE]}x" == "x" ]]; then
        return 0
    fi
    if [[ -f /usr/local/sbin/unminimize ]]; then
        __log_banner -i -- "(CS_UNMINIMIZE_IMAGE) START: unminimize"
        declare -gx DEBIAN_FRONTEND=noninteractive
        declare -i __T_ERROR=0
        yes | /usr/local/sbin/unminimize
        for __T_PS in "${PIPESTATUS[@]}"; do
            if [[ "${__T_PS}" != "0" ]]; then
                __T_ERROR=${__T_PS}
            fi
        done
        unset DEBIAN_FRONTEND
        # it can happen that unminimize image errors out for some reason. That's 
        # a problem of the script and not ours. We just go on and everything is fine.
        if [[ ${__T_ERROR} -eq 0 ]]; then
            __log i -- "(CS_UNMINIMIZE_IMAGE) Unminimizing successful.\n"
            __log_banner -i -- "(CS_UNMINIMIZE_IMAGE) END: 'unminimize'.\n"
            return 0
        else
            __log e -- "(CS_UNMINIMIZE_IMAGE) Uminimizing error: '${__T_ERROR}'.\n"
            __log_banner e -- "(CS_UNMINIMIZE_IMAGE) END: 'unminimize'.\n"
            return 0
        fi
    else
        __log e -- "(CS_UNMINIMIZE_IMAGE) Command '/usr/local/sbin/unminimize' not found.\n"
        return 141
    fi
    return 254
}

__init_function_register_always 350 __run_unminimize_image
function __psp_cs_unminimize_image() {
    if [[ -z ${__SETTINGS[CS_UNMINIMIZE_IMAGE]:+x} ]]; then
        __init_results_add "CS_UNMINIMIZE_IMAGE" "Disabled"
    else
        __init_results_add "CS_UNMINIMIZE_IMAGE" "Enabled"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_unminimize_image
