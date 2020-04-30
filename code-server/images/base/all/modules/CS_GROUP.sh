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

function __isenabled_cs_gid() {

    __log i -- "(CS_GID) Configuring the future GID.\n"
    declare -i __FGID_GID_DEFAULT=1000
    declare -i __FGID_GID_MAX=59999
    declare -i __FGID_GID_MIN=1000
    declare __FGID_REGEX_GID='^[0-0]{4,5}$'
    declare __FGID_REGEX_NUMBER='^[0-9]+$'

    if [[ -z ${__D_C_GID_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_GID_REGEX}x" == "x" ]]; then
        true
    else
        declare __FGID_REGEX_GID="${__D_C_GID_REGEX}"
    fi

    if [[ -z ${__D_TEXT_REGEX_NUMBER+x} ]]; then
        true
    elif [[ "${__D_TEXT_REGEX_NUMBER}x" == "x" ]]; then
        true
    else
        declare __FGID_REGEX_NUMBER="${__D_TEXT_REGEX_NUMBER}"
    fi

    if [[ -z ${__D_C_GID_MAX+x} ]]; then
        true
    elif [[ "${__D_C_GID_MAX}x" == "x" ]]; then
        true
    elif [[ "${__D_C_GID_MAX}" =~ ${__FGID_REGEX_GID} ]]; then
        declare -i __FGID_GID_MAX=${__D_C_GID_MAX}
    fi

    if [[ -z ${__D_C_GID_MIN+x} ]]; then
        true
    elif [[ "${__D_C_GID_MIN}x" == "x" ]]; then
        true
    elif [[ "${__D_C_GID_MIN}" == ${__FGID_REGEX_GID} ]]; then
        declare -i __FGID_GID_MIN=${__D_C_GID_MIN}
    fi

    if [[ ${__FGID_GID_MAX} -lt ${__FGID_GID_MIN} ]]; then
        declare -i __FGID_GID_MAX=${__FGID_GID_MIN}
    fi
    if [[ ${__FGID_GID_MIN} -gt ${__FGID_GID_MAX} ]]; then
        declare -i __FGID_GID_MIN=${__FGID_GID_MAX}
    fi

    if [[ ${__FGID_GID_DEFAULT} -lt ${__FGID_GID_MIN} ]]; then
        declare -i __FGID_GID_DEFAULT=$(((${__FGID_GID_MIN} + ${__FGID_GID_MAX}) / 2))
    elif [[ ${__FGID_GID_DEFAULT} -gt ${__FGID_GID_MAX} ]]; then
        declare -i __FGID_GID_DEFAULT=$(((${__FGID_GID_MIN} + ${__FGID_GID_MAX}) / 2))
    fi

    if [[ -z ${__D_C_GID+x} ]]; then
        true
    elif [[ "${__D_C_GID}x" == "x" ]]; then
        true
    elif [[ "${__D_C_GID}" =~ ${__FGID_REGEX_GID} ]]; then
        declare -i __FGID_GID_DEFAULT=${__D_C_GID}
    fi

    __SETTINGS[GID]=${__FGID_GID_DEFAULT}

    if [[ -z ${CS_GID+x} ]]; then
        __log i -- "(CS_GID) Using default GID: '${__SETTINGS[GID]}'.\n"
        return 0
    elif [[ "${CS_GID}x" == "x" ]]; then
        __log i -- "(CS_GID) Using default GID: '${__SETTINGS[GID]}'.\n"
        return 0
    elif [[ "${CS_GID}" =~ ${__FGID_REGEX_GID} ]]; then
        declare -i __T_GID=${CS_GID}
        if [[ ${__T_GID} -ge ${__FGID_GID_MIN} ]]; then
            if [[ ${__T_GID} -le ${__FGID_GID_MAX} ]]; then
                __SETTINGS[GID]=${__T_GID}
                __log i -- "(CS_GID) The prodived GID: '${__T_GID}' is valid. Going to use it.\n"
                return 0
            else
                __log e -- "(CS_GID) The provided GID: '${CS_GID}' is too big (Max: '${__FGID_GID_MAX}').\n"
                __log e -- "(CS_GID) Using default GID: '${__SETTINGS[GID]}'.\n"
                return 0
            fi
        else
            __log e -- "(CS_GID) The provided GID: '${CS_GID}' is too small (Min: '${__FGID_GID_MIN}').\n"
            __log e -- "(CS_GID) Using default GID: '${__SETTINGS[GID]}'.\n"
            return 0
        fi
    else
        __log e -- "(CS_GID) The provided GID: '${CS_GID}' is not a number.\n"
        __log e -- "(CS_GID) Using default GID: '${__SETTINGS[GID]}'.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 50 __isenabled_cs_gid
function __isenabled_cs_group() {

    __log i -- "(CS_GROUP) Configuring future group name...\n"
    shopt -s nocasematch

    declare __FUGN_DEFAULT_GROUPNAME="u"
    declare __FUGN_REGEX_GROUPNAME='^[a-z][-a-z0-9_]*$'

    if [[ -z ${__D_C_GROUP_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_GROUP_REGEX}x" == "x" ]]; then
        true
    else
        declare __FUGN_REGEX_GROUPNAME="${__D_C_GROUP_REGEX}"
    fi

    if [[ -z ${__D_C_GROUP+x} ]]; then
        true
    elif [[ "${__D_C_GROUP}x" == "x" ]]; then
        true
    elif [[ "${__D_C_GROUP}" =~ ${__FUGN_REGEX_GROUPNAME} ]]; then
        declare __FUGN_DEFAULT_GROUPNAME="${__D_C_GROUP}"
    fi

    __SETTINGS[GROUP]="${__FUGN_DEFAULT_GROUPNAME}"

    if [[ -z ${CS_GROUP+x} ]]; then
        __log i -- "(CS_GROUP) Using default group name: '${__SETTINGS[GROUP]}'.\n"
        return 0
    elif [[ "${CS_GROUP}x" == "x" ]]; then
        __log i -- "(CS_GROUP) Using default group name: '${__SETTINGS[GROUP]}'.\n"
        return 0
    elif [[ "${CS_GROUP}" =~ ${__FUGN_REGEX_GROUPNAME} ]]; then
        __SETTINGS[GROUP]="${CS_GROUP}"
        __log i -- "(CS_GROUP) Provided group name valid: '${__SETTINGS[GROUP]}'. Using it!\n"
        return 0
    else
        __log e -- "(CS_GROUP) Provided group name is invalid: '${CS_GROUP}'.\n"
        __log e -- "(CS_GROUP) Using default: '${__SETTINGS[GROUP]}'.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 55 __isenabled_cs_group

function __psp_cs_gid() {
    if [[ -z ${__SETTINGS[GID]:+x} ]]; then
        __init_results_add "CS_GID" "Disabled"
    else
        __init_results_add "CS_GID" "${__SETTINGS[GID]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_gid

function __psp_cs_group() {
    if [[ -z ${__SETTINGS[GROUP]:+x} ]]; then
        __init_results_add "CS_GROUP" "Disabled"
    else
        __init_results_add "CS_GROUP" "${__SETTINGS[GROUP]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_group
