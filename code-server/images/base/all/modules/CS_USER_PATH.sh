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

function __isenabled_feature_user_path() {
    
    declare __FUP_BASE="/home/u"
    declare __FUP_SUFFIX="User"
    declare __FUP_SUFFIX_REGEX='^/.+$'
    declare __FUP_DEFAULT=""

    
    if [[ -z ${__SETTINGS[USER_HOME]+x} ]]; then
        true
    elif [[ "${__SETTINGS[USER_HOME]}x" == "x" ]]; then
        true
    else
        declare __FUP_BASE="${__SETTINGS[USER_HOME]}"
    fi

    if [[ -z ${__D_C_USER_PATH+x} ]]; then
        true
    elif [[ "${__D_C_USER_PATH}x" == "x" ]]; then
        true
    else
        declare __FUP_SUFFIX="${__D_C_USER_PATH}"
    fi

    if [[ "${__FUP_SUFFIX}" =~ ${__FUP_SUFFIX_REGEX} ]]; then
        declare __FUP_DEFAULT="${__FUP_SUFFIX}"
    else
        declare __FUP_DEFAULT="${__FUP_BASE}/${__FUP_SUFFIX}"
    fi

    __SETTINGS[CS_USER_PATH]="${__FUP_DEFAULT}"

    if [[ -z ${CS_USER_PATH+x} ]]; then
        __log i -- "(CS_USER_PATH) Using default '${__SETTINGS[CS_USER_PATH]}'.\n"
        return 0
    elif [[ "${CS_USER_PATH}x" == "x" ]]; then
        __log i -- "(CS_USER_PATH) Using default '${__SETTINGS[CS_USER_PATH]}'.\n"
        return 0
    elif [[ "${CS_USER_PATH}" =~ ${__FUP_SUFFIX_REGEX} ]]; then
        __SETTINGS[CS_USER_PATH]="${CS_USER_PATH}"
        __log i -- "(CS_USER_PATH) Provided path '${CS_USER_PATH}' is a full path. Using it '${__SETTINGS[CS_USER_PATH]}'.\n"
        return 0
    else
        __SETTINGS[CS_USER_PATH]="${__FUP_BASE}/${CS_USER_PATH}"
        __log i -- "(CS_USER_PATH) Provided path '${CS_USER_PATH}' is a sub path. Using it '${__SETTINGS[CS_USER_PATH]}'.\n"
        return 0
    fi
    return 254;
}

__init_function_register_always 150 __isenabled_feature_user_path

function __psp_feature_user_path() {
    if [[ -z ${__SETTINGS[CS_USER_PATH]+x} ]]; then
        __init_results_add "CS_USER_PATH" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_USER_PATH]}x" == "x" ]]; then
        __init_results_add "CS_USER_PATH" "Disabled"
        return 0
    else
        __init_results_add "CS_USER_PATH" "${__SETTINGS[CS_USER_PATH]}"
        __START_PARAMETERS+=("${__SETTINGS[CS_USER_PATH]}")
        return 0
    fi
    return 254
}
# MUST RUN LAST AS IT MUST BE THE LAST TO ADD INFORMATION TO THE PARAMTER ARRAY!!!!
__init_function_register_always 2000 __psp_feature_user_path
