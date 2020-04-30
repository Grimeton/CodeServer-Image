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

function __isenabled_feature_user_shell() {
    declare __FUS_DEFAULT="/bin/bash"

    if [[ -z ${__D_C_USER_SHELL+x} ]]; then
        true
    elif [[ "${__D_C_USER_SHELL}x" == "x" ]]; then
        true
    else
        declare __FUS_DEFAULT="${__D_C_USER_SHELL}"
    fi

    __SETTINGS[USER_SHELL]="${__FUS_DEFAULT}"

    if [[ -z ${CS_USER_SHELL+x} ]]; then
        true
    elif [[ "${CS_USER_SHELL}x" == "x" ]]; then
        true
    else
        __SETTINGS[USER_SHELL]="${CS_USER_SHELL}"
    fi
    __log i -- "(CS_USER_SHELL) Configuring user default shell... '${__SETTINGS[USER_SHELL]}'.\n"
    return 0
}

__init_function_register_always 60 __isenabled_feature_user_shell

function __psp_cs_user_shell() {
    if [[ -z ${__SETTINGS[USER_SHELL]:+x} ]]; then
        __init_results_add "CS_USER_SHELL" "None"
    else
        __init_results_add "CS_USER_SHELL" "${__SETTINGS[USER_SHELL]}"
    fi
    return 0

}
__init_function_register_always 1800 __psp_cs_user_shell
