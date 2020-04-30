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
if ! (return 0 2>/dev/null); then
    echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
    exit 254
fi

function __isenabled_cs_install_docker() {
    declare __ID_DEFAULT=""
    declare __ID_SOCKET_DEFAULT="/var/run/docker.sock"
    declare __ID_SOCKET_ENFORCE=""

    if [[ -z ${__D_C_INSTALL_DOCKER+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_DOCKER}x" == "x" ]]; then
        __ID_DEFAULT=""
    elif __test_variable_text __D_C_INSTALL_DOCKER 1; then
        __ID_DEFAULT="1"
    elif __test_varible_text __D_C_INSTALL_DOCKER 0; then
        __ID_DEFAULT=""
    fi

    if [[ -z ${__D_C_INSTALL_DOCKER_SOCKET+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_DOCKER_SOCKET}x" == "x" ]]; then
        true
    else
        __ID_SOCKET_DEFAULT="${__D_C_INSTALL_DOCKER_SOCKET}"
    fi

    if [[ -z ${__D_C_INSTALL_DOCKER_SOCKET_ENFORCE+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_DOCKER_SOCKET_ENFORCE}x" == "x" ]]; then
        __ID_SOCKET_ENFORCE=""
    elif __test_variable_text __D_C_INSTALL_DOCKER_SOCKET_ENFORCE 1; then
        __ID_SOCKET_ENFORCE="1"
    elif __test_variable_text __D_C_INSTALL_DOCKER_SOCKET_ENFORCE 0; then
        __ID_SOCKET_ENFORCE=""
    fi

    __SETTINGS[CS_INSTALL_DOCKER]="${__ID_DEFAULT}"
    __SETTINGS[CS_INSTALL_DOCKER_SOCKET]="${__ID_SOCKET_DEFAULT}"
    __SETTINGS[CS_INSTALL_DOCKER_SOCKET_ENFORCE]="${__ID_SOCKET_ENFORCE}"

    if [[ -z ${CS_INSTALL_DOCKER+x} ]]; then
        true
    elif [[ "${CS_INSTALL_DOCKER}x" == "x" ]]; then
        true
    elif __test_variable_text CS_INSTALL_DOCKER 1; then
        __SETTINGS[CS_INSTALL_DOCKER]="1"
    elif __test_variable_text CS_INSTALL_DOCKER 0; then
        __SETTINGS[CS_INSTALL_DOCKER]=""
    fi

    if [[ -z ${CS_INSTALL_DOCKER_SOCKET+x} ]]; then
        true
    elif [[ "${CS_INSTALL_DOCKER_SOCKET}x" == "x" ]]; then
        true
    else
        __SETTINGS[CS_INSTALL_DOCKER_SOCKET]="${CS_INSTALL_DOCKER_SOCKET}"
    fi

    if [[ -z ${CS_INSTALL_DOCKER_SOCKET_ENFORCE+x} ]]; then
        true
    elif __test_variable_text CS_INSTALL_DOCKER_SOCKET_ENFORCE 1; then
        __SETTINGS[CS_INSTALL_DOCKER_SOCKET_ENFORCE]="1"
    elif __test_variable_text CS_INSTALL_DOCKER_SOCKET_ENFORCE 0; then
        __SETTINGS[CS_INSTALL_DOCKER_SOCKET_ENFORCE]=""
    fi

    if [[ "${__SETTINGS[CS_INSTALL_DOCKER]}x" == "x" ]]; then
        __SETTINGS[CS_INSTALL_DOCKER_SOCKET]=""
        __log i -- "(CS_INSTALL_DOCKER) Checking if Docker support is needed... No.\n"
        return 0
    else
        __log i -- "(CS_INSTALL_DOCKER) Checking if Docker support is needed... Yes.\n"
        __log i -- "(CS_INSTALL_DOCKER) Using socket '${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}'.\n"
        return 0
    fi
    return 254
}

__init_function_register_always 150 __isenabled_cs_install_docker

function __packages_cs_install_docker() {
    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER]}x" == "x" ]]; then
        return 0
    fi
    __pm_package_install_list_add "docker-cli" "docker-compose"
    return
}

__init_function_register_always 300 __packages_cs_install_docker

function __pre_cs_install_docker() {

    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER]}x" == "x" ]]; then
        return 0
    fi
    __log i -- "(CS_INSTALL_DOCKER) Checking if group 'docker' already exists...\n"
    if __group_exists "docker"; then
        __log w -- "(CS_INSTALL_DOCKER) Group 'docker' already exists...\n"
        return 0
    else
        __log i -- "(CS_INSTALL_DOCKER) Group 'docker' does not exist...\n"
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}x" == "x" ]]; then
        true
    else
        __log i -- "(CS_INSTALL_DOCKER) Checking if we have a docker socket at '${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}'.\n"
        declare __T_DOCKER_SOCKET_GID=""
        if [[ -S "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}" ]]; then
            if __T_DOCKER_SOCKET_GID="$(stat -c %g "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}")"; then
                __log i -- "(CS_INSTALL_DOCKER) We do and the socket's GID is '${__T_DOCKER_SOCKET_GID}'.\n"
            else
                __log i -- "(CS_INSTALL_DOCKER) We do!.\n"
            fi
        else
            __log w -- "(CS_INSTALL_DOCKER) No socket at '${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}'.\n"
        fi

        if [[ "${__T_DOCKER_SOCKET_GID}x" == "x" ]]; then
            unset __T_DOCKER_SOCKET_GID
        elif __group_exists "${__T_DOCKER_SOCKET_GID}"; then
            __log w -- "(CS_INSTALL_DOCKER) The socket's GID '${__T_DOCKER_SOCKET_GID}' is already in use. Not going to use it.\n"
            unset __T_DOCKER_SOCKET_GID
        else
            __log i -- "(CS_INSTALL_DOCKER) The socket's GID '${__T_DOCKER_SOCKET_GID}' is not in use. Going to use it!.\n"
        fi
    fi
    declare __ID_PARAMETERS=("-r")

    if [[ -z ${__T_DOCKER_SOCKET_GID+x} ]]; then
        true
    elif [[ "${__T_DOCKER_SOCKET_GID}x" == "x" ]]; then
        true
    else
        __ID_PARAMETERS+=("-g" "${__T_DOCKER_SOCKET_GID}")
    fi
    __ID_PARAMETERS+=("docker")

    if __group_add "${__ID_PARAMETERS[@]}"; then
        __log i -- "(CS_INSTALL_DOCKER) Created group 'docker' successfully.\n"
        __SETTINGS[CS_INSTALL_DOCKER_GROUP]=1
        return 0
    else
        __log e -- "(CS_INSTALL_DOCKER) Problems creating group 'docker' ($?).\n"
        __SETTINGS[CS_INSTALL_DOCKER_GROUP]=""
        return 121
    fi
    254
}

__init_function_register_always 250 __pre_cs_install_docker

function __post_cs_install_docker() {
    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER_GROUP]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER_GROUP]}x" == "x" ]]; then
        return 0
    fi

    if [[ -z ${__SETTINGS[USER]+x} ]]; then
        return 241
    elif [[ "${__SETTINGS[USER]}x" == "x" ]]; then
        return 242
    elif ! __user_exists "${__SETTINGS[USER]}"; then
        return 243
    fi
    __log i -- "(CS_INSTALL_DOCKER) Adding '${__SETTINGS[USER]}' to group 'docker'.\n"
    if __group_add "${__SETTINGS[USER]}" "docker"; then
        __log i -- "(CS_INSTALL_DOCKER) Success!\n"
        return 0
    else
        __log e -- "(CS_INSTALL_DOCKER) Error ($?).\n"
        return 1
    fi
    return 254
}

__init_function_register_always 790 __post_cs_install_docker

function __psp_cs_install_docker() {
    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER]}x" == "x" ]]; then
        return 0
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}x" == "x" ]]; then
        return 0
    elif [[ ! -S "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}" ]]; then
        return 201
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_DOCKER_SOCKET_ENFORCE]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET_ENFORCE]}x" == "x" ]]; then
        return 0
    fi

    if ! __group_exists "docker"; then
        return 211
    fi
    declare __T_DOCKER_GID=""
    if ! __group_id_get "docker" __T_DOCKER_GID; then
        return 212
    fi

    declare __T_DOCKER_SOCKET_GID=""

    if ! __T_DOCKER_SOCKET_GID="$(stat -c %g "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}")"; then
        return 213
    fi

    if [[ "${__T_DOCKER_GID}" != "${__T_DOCKER_SOCKET_GID}" ]]; then
        if chgrp "${__T_DOCKER_GID}" "${__SETTINGS[CS_INSTALL_DOCKER_SOCKET]}"; then
            return 0
        else
            return 214
        fi
    else
        return 0
    fi
    return 254

}
__init_function_register_always 1900 __psp_cs_install_docker
