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

function __isenabled_cs_enable_ssh_host_key() {

    declare __FSHK_OWNER="u"
    declare __FSHK_GROUP="u"
    declare __FSHK_DEFAULT=""
    declare __FSHK_MODE="0440"
    declare __FSHK_MODE_REGEX='^[0-7]{3,4}$'

    if [[ -z ${__D_TEXT_REGEX_PERMISSION_MODE+x} ]]; then
        true
    elif [[ "${__D_TEXT_REGEX_PERMISSION_MODE}x" == "x" ]]; then
        true
    else
        declare __FSHK_MODE_REGEX="${__D_TEXT_REGEX_PERMISSION_MODE}"
    fi

    if [[ -z ${__D_C_ENABLE_SSH_HOST_KEY_MODE+x} ]]; then
        true
    elif [[ "${__D_C_ENABLE_SSH_HOST_KEY_MODE}x" == "x" ]]; then
        true
    elif [[ "${__D_C_ENABLE_SSH_HOST_KEY_MODE}" =~ ${__FSHK_MODE_REGEX} ]]; then
        declare __FSHK_MODE="${__D_C_ENABLE_SSH_HOST_KEY_MODE}"
    fi

    if [[ -z ${__D_C_ENABLE_SSH_HOST_KEY+x} ]]; then
        true
    else
        declare __FSHK_DEFAULT="${__D_C_ENABLE_SSH_HOST_KEY}"
    fi

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        true
    elif [[ "${__SETTINGS[USER]}x" == "x" ]]; then
        true
    else
        declare __FSHK_OWNER="${__SETTINGS[USER]}"
    fi

    if [[ -z ${__SETTINGS[GROUPNAME]+x} ]]; then
        true
    elif [[ "${__SETTINGS[GROUPNAME]}x" == "x" ]]; then
        true
    else
        declare __FSHK_OWNER="${__SETTINGS[GROUPNAME]}"
    fi

    if [[ -z ${__D_C_SSH_HOST_KEY_MODE+x} ]]; then
        true
    elif [[ "${__D_C_SSH_HOST_KEY_MODE}x" == "x" ]]; then
        true
    elif [[ "${__D_C_SSH_HOST_KEY_MODE}" =~ ${__FSHK_MODE_REGEX} ]]; then
        declare __FSHK_MODE="${__D_C_SSH_HOST_KEY_MODE}"
    fi

    __SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]="${__FSHK_OWNER}"
    __SETTINGS[CS_ENABLE_SSH_HOST_KEY_GROUP]="${__FSHK_GROUP}"
    __SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]="${__FSHK_MODE}"
    __SETTINGS[CS_ENABLE_SSH_HOST_KEY]="${__FSHK_DEFAULT}"

    if [[ -z ${CS_ENABLE_SSH_HOST_KEY+x} ]]; then
        true
    elif [[ "${CS_ENABLE_SSH_HOST_KEY}x" == "x" ]]; then
        true
    else
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY]="${CS_ENABLE_SSH_HOST_KEY}"
    fi

    if [[ -z ${_CS_ENABLE_SSH_HOST_KEY_MODE+x} ]]; then
        true
    elif [[ "${CS_ENABLE_SSH_HOST_KEY_MODE}x" == "x" ]]; then
        true
    elif [[ "${CS_ENABLE_SSH_HOST_KEY_MODE}" =~ ${__FSHK_MODE_REGEX} ]]; then
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]="${CS_ENABLE_SSH_HOST_KEY_MODE}"
    else
        true
    fi

    if [[ "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}x" == "x" ]]; then
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_GROUP]=""
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]=""
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]=""
        __log i -- "(CS_ENABLE_SSH_HOST_KEY) Configuring builtin SSH host key... Disabled.\n"
        return 0
    else
        __log i -- "(CS_ENABLE_SSH_HOST_KEY) Configuring builtin SSH host key... Enabled.\n"
        return 0
    fi
    return 254
}

__init_function_register_always 150 __isenabled_cs_enable_ssh_host_key

function __post_cs_enable_ssh_host_key() {

    if [[ -z ${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}x" == "x" ]]; then
        return 0
    fi

    declare __FSHK_OWNER="u"
    declare __FSHK_GROUP="u"
    declare __FSHK_MODE="0440"

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        true
    elif [[ "${__SETTINGS[USER]}x" == "x" ]]; then
        true
    else
        declare __FSHK_OWNER="${__SETTINGS[USER]}"
    fi

    if [[ -z ${__SETTINGS[GROUPNAME]+x} ]]; then
        true
    elif [[ "${__SETTINGS[GROUPNAME]}x" == "x" ]]; then
        true
    else
        declare __FSHK_OWNER="${__SETTINGS[GROUPNAME]}"
    fi

    if [[ -z ${__SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]}x" == "x" ]]; then
        true
    else
        declare __FSHK_MODE="${__SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]}"
    fi

    if [[ -f "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}" ]]; then
        if __test_file_access_read_by_user "${__FSHK_OWNER}" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}"; then
            true
        elif chown "${__FSHK_OWNER}":"${__FSHK_GROUP}" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}"; then
            if chmod "${__FSHK_MODE}" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}"; then
                true
            else
                __SETTINGS[CS_ENABLE_SSH_HOST_KEY]=""
            fi
        else
            __SETTINGS[CS_ENABLE_SSH_HOST_KEY]=""
        fi
    else
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY]=""
    fi
    if [[ "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}x" == "x" ]]; then
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_GROUP]=""
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]=""
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]=""
        __log i -- "(CS_ENABLE_SSH_HOST_KEY) Configuring SSH host key... Disabled.\n"
        return 0
    else
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_GROUP]="${__FSHK_GROUP}"
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_MODE]="${__FSHK_MODE}"
        __SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]="${__FSHK_OWNER}"
        __log i -- "(CS_ENABLE_SSH_HOST_KEY) Configuring SSH host key... Enabled: '${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}'.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 750 __post_cs_enable_ssh_host_key

function __psp_cs_enable_ssh_host_key() {

    if __init_codeserver_startup_options_available "ssh-host-key"; then
        true
    else
        return 0
    fi

    if [[ -z ${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]+x} ]]; then
        __init_results_add "CS_ENABLE_SSH_HOST_KEY" "Disabled"
        return 0
    elif [[ "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}x" == "x" ]]; then
        __init_results_add "CS_ENABLE_SSH_HOST_KEY" "Disabled"
        return 0
    elif [[ ! -f "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}" ]]; then
        __log e -- "The configured 'CS_ENABLE_SSH_HOST_KEY':'${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}' does not exist anymore. Not using it!\n"
        __init_results_add "CS_ENABLE_SSH_HOST_KEY" "Disabled"
        return 0
    elif ! __test_file_access_read_by_user "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]}" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}"; then
        __log e -- "The configured 'CS_ENABLE_SSH_HOST_KEY':'${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}' cannot be accessed by its configured owner: '${__SETTINGS[CS_ENABLE_SSH_HOST_KEY_OWNER]}' anymore. Not using it!\n"
        __init_results_add "CS_ENABLE_SSH_HOST_KEY" "Disabled"
        return 0
    else
        __init_results_add "CS_ENABLE_SSH_HOST_KEY" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}"
        __START_PARAMETERS+=("--ssh-host-key" "${__SETTINGS[CS_ENABLE_SSH_HOST_KEY]}")
        return 0
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_enable_ssh_host_key
