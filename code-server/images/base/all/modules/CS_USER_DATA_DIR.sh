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
function __isenabled_cs_user_data_dir() {

    declare __FUDD_USER_HOME="/home"
    declare __FUDD_USER_DATA_DIR="User"
    declare __FUDD_USER_DATA_DIR_REGEX='^/.+$'
    declare __FUTT_DEFAULT=""

    if [[ -z ${__SETTINGS[USER_HOME]+x} ]]; then
        true
    elif [[ "${__SETTINGS[USER_HOME]}x" == "x" ]]; then
        true
    else
        declare __FUDD_USER_HOME="${__SETTINGS[USER_HOME]}"
    fi

    if [[ -z ${__D_C_USER_DATA_DIR+x} ]]; then
        true
    elif [[ "${__D_C_USER_DATA_DIR}x" == "x" ]]; then
        true
    else
        declare __FUDD_USER_DATA_DIR="${__D_C_USER_DATA_DIR}"
    fi

    if [[ "${__FUDD_USER_DATA_DIR}" =~ ${__FUDD_USER_DATA_DIR_REGEX} ]]; then
        declare __FUDD_DEFAULT="${__FUDD_USER_DATA_DIR}"
    else
        declare __FUDD_DEFAULT="${__FUDD_USER_HOME}/${__FUDD_USER_DATA_DIR}"
    fi

    __SETTINGS[CS_USER_DATA_DIR]="${__FUDD_DEFAULT}"

    if [[ -z ${CS_USER_DATA_DIR+x} ]]; then
        true
    elif [[ "${CS_USER_DATA_DIR}x" == "x" ]]; then
        true
    elif [[ "${CS_USER_DATA_DIR}" =~ ${__FUDD_USER_DATA_DIR_REGEX} ]]; then
        __SETTINGS[CS_USER_DATA_DIR]="${CS_USER_DATA_DIR}"
    else
        __SETTINGS[CS_USER_DATA_DIR]="${__FUDD_USER_HOME}/${CS_USER_DATA_DIR}"
    fi
    __log i -- "(CS_USER_DATA_DIR) Configuring user data directory... '${__SETTINGS[CS_USER_DATA_DIR]}'.\n"
    return 0
}
__init_function_register_always 150 __isenabled_cs_user_data_dir

function __psp_cs_user_data_dir() {


    if __init_codeserver_startup_options_available "user-data-dir"; then
        true
    else
        return 0
    fi
    

    if [[ -z ${__SETTINGS[CS_USER_DATA_DIR]+x} ]]; then
        __init_results_add "CS_USER_DATA_DIR" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_USER_DATA_DIR]}x" == "x" ]]; then
        __init_results_add "CS_USER_DATA_DIR" "Disabled"
        return 0
    else
        __init_results_add "CS_USER_DATA_DIR" "${__SETTINGS[CS_USER_DATA_DIR]}"
        __START_PARAMETERS+=("--user-data-dir" "${__SETTINGS[CS_USER_DATA_DIR]}")
        return 0
    fi
    return 254
}

__init_function_register_always 1800 __psp_cs_user_data_dir
