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

function __isenabled_feature_user_id() {

    declare -i __FUD_UID_DEFAULT=1000
    declare -i __FUD_UID_MIN=1000
    declare -i __FUD_UID_MAX=50000
    declare __FUD_REGEX_UID='^[0-9]{4,5}$'

    if [[ ${__D_C_UID_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_UID_REGEX}x" == "x" ]]; then
        true
    else
        declare __FUD_REGEX_UID="${__D_C_UID_REGEX}"
    fi

    if [[ -z ${__D_C_UID_MIN+x} ]]; then
        true
    elif [[ "${__D_C_UID_MIN}x" == "x" ]]; then
        true
    elif [[ "${__D_C_UID_MIN}" =~ ${__FUD_REGEX_UID} ]]; then
        declare -i __FUD_UID_MIN=${__D_C_UID_MIN}
    fi

    if [[ -z ${__D_C_UID_MAX+x} ]]; then
        true
    elif [[ "${__D_C_UID_MAX}x" == "x" ]]; then
        true
    elif [[ "${__D_C_UID_MAX}" =~ ${__FUD_REGEX_UID} ]]; then
        declare -i __FUD_UID_MAX=${__D_C_UID_MAX}
    fi

    if [[ -z ${__D_C_UID+x} ]]; then
        true
    elif [[ "${__D_C_UID}x" == "x" ]]; then
        true
    elif [[ "${__D_C_UID}" == ${__FUD_REGEX_UID} ]]; then
        declare -i __FUD_UID_DEFAULT=${__D_C_UID}
    fi

    if [[ ${__FUD_UID_MIN} -gt ${__FUD_UID_MAX} ]]; then
        declare -i __FUD_UID_MIN=${__FUD_UID_MAX}
    fi

    if [[ ${__FUD_UID_MAX} -lt ${__FUD_UID_MIN} ]]; then
        declare -i __FUD_UID_MAX=${__FUD_UID_MIN}
    fi

    if [[ ${__FUD_UID_DEFAULT} -lt ${__FUD_UID_MIN} ]]; then
        declare -i __FUD_UID_DEFAULT=$(((${__FUD_UID_MIN} + ${__FUD_UID_MAX}) / 2))
    fi

    if [[ ${__FUD_UID_DEFAULT} -gt ${__FUD_UID_MAX} ]]; then
        declare -i __FUD_UID_DEFAULT=$(((${__FUID_UID_MIN} + ${__FUD_UID_MAX}) / 2))
    fi

    __SETTINGS[UID]=${__FUD_UID_DEFAULT}

    if [[ -z ${CS_UID+x} ]]; then
        __log i -- "(CS_UID) Using default: '${__SETTINGS[UID]}'.\n"
        return 0
    elif [[ "${CS_UID}x" == "x" ]]; then
        __log i -- "(CS_UID) Using default: '${__SETTINGS[UID]}'.\n"
        return 0
    elif [[ "${CS_UID}" =~ ${__FUD_REGEX_UID} ]]; then
        declare -i __T_UID=${CS_UID}
        if [[ ${__T_UID} -ge ${__FUD_UID_MIN} ]]; then
            if [[ ${__T_UID} -le ${__FUD_UID_MAX} ]]; then
                __SETTINGS[UID]=${__T_UID}
                __log i -- "(CS_UID) Provided UID valid: '${__T_UID}'. Using it!\n"
                return 0
            else
                __log e -- "(CS_UID) Provided uid too big: '${CS_UID}'.\n"
                __log e -- "(CS_UID) Using default: '${__SETTINGS[UID]}'.\n"
                return 0
            fi
        else
            __log e -- "(CS_UID) Provided uid too small: '${CS_UID}'.\n"
            __log e -- "(CS_UID) Using default: '${__SETTINGS[UID]}'.\n"
            return 0
        fi

    else
        __log e -- "(CS_UID) Provided UID invalid: '${CS_UID}'.\n"
        __log e -- "(CS_UID) Using default: '${__SETTINGS[UID]}'.\n"
        return 0
    fi
    return 254
}
__init_function_register_always 40 __isenabled_feature_user_id

function __isenabled_feature_user_name() {
    declare __FUN_USERNAME_DEFAULT="u"
    declare __FUN_REGEX_USERNAME='^[a-z]([a-z0-9_]+)?$'

    if [[ -z ${__D_C_USER_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_USER_REGEX}x" == "x" ]]; then
        true
    else
        declare __FUN_REGEX_USERNAME="${__D_C_USER_REGEX}"
    fi

    if [[ -z ${__D_C_USER+x} ]]; then
        true
    elif [[ "${__D_C_USER}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER}" =~ ${__FUN_REGEX_USERNAME} ]]; then
        declare __FUN_USERNAME_DEFAULT="${__D_C_USER}"
    fi

    __SETTINGS[USER]="${__FUN_USERNAME_DEFAULT}"

    if [[ -z ${CS_USER+x} ]]; then
        __log i -- "(CS_USER) Using default: '${__SETTINGS[USER]}'.\n"
        return 0
    elif [[ "${CS_USER}x" == "x" ]]; then
        __log i -- "(CS_USER) Using default: '${__SETTINGS[USER]}'.\n"
        return 0
    elif [[ "${CS_USER}" =~ ${__FUN_REGEX_USERNAME} ]]; then
        __log i -- "(CS_USER) Provided username valid: '${CS_USER}'. Going to use it!\n"
        __SETTINGS[USER]="${CS_USER}"
        return 0
    else
        __log e -- "(CS_USER) Provided username invalid: '${CS_USER}'.\n"
        __log e -- "(CS_USER) Using default: '${__SETTINGS[USER]}'.\n"
        return 0
    fi
    return 254
}

__init_function_register_always 45 __isenabled_feature_user_name

function __feature_user_name_add_user() {

    __log i -- "(CS_USER) Adding user...\n"
    for __T_KEY in UID USER GID GROUP USER_HOME USER_SHELL; do
        if [[ -z ${__SETTINGS[${__T_KEY}]+x} ]]; then
            __log e -- "(CS_USER) Setting '${__T_KEY}' is missing.\n"
            return 101
        elif [[ "${__SETTINGS[${__T_KEY}]}x" == "x" ]]; then
            __log e -- "(CS_USER) Settings "${__T_KEY}' is empty.\n"'
            return 102
        fi
    done

    if __group_exists "${__SETTINGS[GID]}"; then
        __log e -- "(CS_USER) GID: '${__SETINGS[GID]}' already exists. Getting a new one...\n"
        declare -i __T_GID=0
        if __group_id_next __T_GID; then
            __log i -- "(CS_USER) GID: New one: '${__T_GID}'.\n"
            if declare -i __P_GID=${__T_GID}; then
                unset __T_GID
            else
                __log e -- "(CS_USER) GID: New one not numeric...\n"
                return 111
            fi
        else
            __log e -- "(CS_USER) GID: Could not get new one. Exiting ($?).\n"
            return 112
        fi
    elif declare -i __P_GID=${__SETTINGS[GID]}; then
        true
    else
        __log e -- "(CS_USER) GID: Id is not numeric...\n"
        return 113
    fi

    if __group_exists "${__SETTINGS[GROUP]}"; then
        __log e -- "(CS_USER) GID: Group name already exists '${__SETTINGS[GROUP]}'. Exiting...\n"
        return 114
    else
        declare __P_GROUP="${__SETTINGS[GROUP]}"
    fi

    if __user_exists "${__SETTINGS[UID]}"; then
        __log e -- "(CS_USER) UID: '${__SETTINGS[UID]}' already exists. Getting a new one...\n"
        declare -i __T_UID=0
        if __user_id_next __T_UID; then
            __log i -- "(CS_USER) UID: New one: '${__T_UID}'.\n"
            if declare -i __P_UID=${__T_UID}; then
                unset __T_UID
            else
                __log e -- "(CS_USER) UID: Not generic. Exiting ($?).\n"
                return 121
            fi
        else
            __log e -- "(CS_USER) UID: Could not get new UID. Exiting ($?).\n"
            return 122
        fi
    elif declare -i __P_UID=${__SETTINGS[UID]}; then
        true
    else
        __log e -- "(CS_USER) UID is not numeric '${__SETTINGS[UID]}' ($?).\n"
        return 123
    fi

    if __user_exists "${__SETTINGS[USER]}"; then
        __log e -- "UID: Username '${__SETTINGS[USER]}' already exists... Exiting.\n"
        return 124
    else
        declare __P_USER="${__SETTINGS[USER]}"
    fi

    declare __P_SHELL="${__SETTINGS[USER_SHELL]}"
    declare __P_HOME="${__SETTINGS[USER_HOME]}"
    if [[ -e "${__SETTINGS[USER_HOME]}" ]]; then
        declare __P_HOME_EXISTS="1"
    else
        declare __P_HOME_EXISTS=""
    fi
    if __group_add -g "${__P_GID}" "${__P_GROUP}"; then
        __log i -- "(CS_USER) GID: Added group '${__P_GROUP}' with GID: '${__P_GID}' successfully.\n"
    else
        __log e -- "(CS_USER) GID: Problem adding group '${__P_GROUP}' with GID: '${__P_GID}' ($?).\n"
        return 131
    fi
    if [[ "${__P_HOME_EXISTS}x" == "x" ]]; then
        declare __P_CREATE_HOME="-m"
    else
        declare __P_CREATE_HOME=""
    fi

    if __user_add -d "${__P_HOME}" -g "${__P_GID}" -s "${__P_SHELL}" -u ${__P_UID} -N ${__P_CREATE_HOME} "${__P_USER}"; then
        __log i -- "(CS_USER): Added user '${__P_USER}' successfully.\n"
    else
        __log e -- "(CS_USER): Adding user '${__P_USER}' not successfully ($?)\n"
        return 141
    fi
    unset __P_CREATE_HOME
    if [[ "${__P_HOME_EXISTS}x" != "x" ]]; then
        if chown "${__P_USER}":"${__P_GROUP}" "${__P_HOME}"; then
            true
        else
            __log e -- "(CS_USER) HOME: Could not change owner of user's home directory ($?).\n"
            return 151
        fi

        if chmod 0755 "${__P_HOME}"; then
            true
        else
            __log e -- "(CS_USER) HOME: Could not change the permissions of the user's home directory ($?).\n"
            return 152
        fi

        if [[ -d "/etc/skel" ]]; then

            while read __T_FILE; do
                if [[ "${__T_FILE}" == "/etc/skel" ]]; then
                    continue
                fi

                declare __T_FILE_NEW="${__T_FILE//\/etc\/skel/${__P_HOME}}"

                if [[ -e "${__T_FILE_NEW}" ]]; then
                    continue
                fi

                if [[ -d "${__T_FILE}" ]]; then
                    if mkdir -p "${__T_FILE_NEW}"; then
                        continue
                    else
                        __log e -- "HOME: Problems creating directory: '${__T_FILE_NAME}'.\n"
                    fi
                    continue

                elif [[ -f "${__T_FILE}" ]]; then
                    if cp -a "${__T_FILE}" "${__T_FILE_NEW}"; then
                        continue
                    else
                        __log e -- "(CS_USER) HOME: Problems copying '${__T_FILE}' to '${__T_FILE_NEW}' ($?).\n"
                    fi
                    continue
                elif [[ -L "${__T_FILE}" ]]; then
                    declare __T_FILE_REAL=""
                    if __T_FILE_REAL="$(realpath "${__T_FILE}")"; then
                        if ln -s "${__T_FILE_REAL}" "${__T_FILE_NEW}"; then
                            true
                        else
                            __log e -- "(CS_USER) HOME: Problems linking from '${__T_FILE}(${__T_FILE_REAL})' to '${__T_FILE_NEW}' ($?).\n"
                        fi
                    else
                        __log e -- "(CS_USER) HOME: Problems getting real path of '${__T_FILE}' ($?).\n"
                    fi
                    unset __T_FILE_REAL
                    continue
                fi
            done < <(find /etc/skel)
        fi
        return 0
    else
        return 0
    fi

    return 254
}
__init_function_register_always 650 __feature_user_name_add_user

function __psp_cs_uid() {
    if [[ -z ${__SETTINGS[UID]:+x} ]]; then
        __init_results_add "CS_UID" "None"
    else
        __init_results_add "CS_UID" "${__SETTINGS[UID]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_uid

function __psp_cs_user() {
    if [[ -z ${__SETTINGS[USER]:+x} ]]; then
        __init_results_add "CS_USER" "None"
    else
        __init_results_add "CS_USER" "${__SETTINGS[USER]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_user
