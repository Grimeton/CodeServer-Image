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

function __package_cs_timezone() {

    if [[ -z ${__SETTINGS[CS_TIMEZONE]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_TIMEZONE]}x" == "x" ]]; then
        return 0
    fi

    if [[ -z ${__SETTINGS[CS_TIMEZONE_PACKAGES]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_TIMEZONE_PACKAGES]}x" == "x" ]]; then
        return 0
    fi
    __pm_package_install_list_add "${__SETTINGS[CS_TIMEZONE_PACKAGES]}"
}
__init_function_register_always 300 __package_cs_timezone

function __post_cs_timezone() {
    if [[ -z ${__SETTINGS[CS_TIMEZONE]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_TIMEZONE]}x" == "x" ]]; then
        return 0
    fi

    __log i -- "(CS_TIMEZONE) Setting up the timezone...\n"
    declare __T_TZ_FULL_PATH="/usr/share/zoneinfo/${__SETTINGS[CS_TIMEZONE]}"
    if [[ -f "${__T_TZ_FULL_PATH}" ]]; then

        # set the link to the new timezone
        if [ -L /etc/localtime ]; then
            __log i -- "(CS_TIMEZONE) Old link to '/etc/localtime' exists. Removing...\n"
            if rm /etc/localtime; then
                __log i -- "(CS_TIMEZONE) Old link removed successfully.\n"
            else
                __log e -- "(CS_TIMEZONE) Removing old link failed ($?)\n"
                return 111
            fi
        fi
        __log i -- "(CS_TIMEZONE) Setting new link to '/etc/localtime'.\n"
        if ln -s "${__T_TZ_FULL_PATH}" /etc/localtime; then
            __log i -- "(CS_TIMEZONE) Succes!\n"
        else
            __log e -- "(CS_TIMEZONE) Could not link '/etc/localtime' to new timezone '${__T_TZ_FULL_PATH}' ($?).\n"
            return 121
        fi

        __log i -- "(CS_TIMEZONE) Checking if '/etc/timezone' exists.\n"
        if [[ -f "/etc/timezone" ]]; then
            __log i -- "(CS_TIMEZONE) Deleting...\n"
            if rm "/etc/timezone"; then
                __log i -- "(CS_TIMEZONE) Done.\n"
            else
                __log e -- "(CS_TIMEZONE) Error deleting '/etc/timezone' ($?).\n"
                return 131
            fi
        else
            __log i -- "(CS_TIMEZONE) Does not exist.\n"
        fi

        # update /etc/timezone
        __log i -- "(CS_TIMEZONE) Updating '/etc/timezone' to new timezone.\n"
        if echo "${__SETTINGS[CS_TIMEZONE]}" >/etc/timezone; then
            __log i -- "(CS_TIMEZONE) Success.\n"
        else
            __log e -- "(CS_TIMEZONE) Could not update '/etc/timezone' ($?).\n"
            return 141
        fi
        __log i -- "(CS_TIMEZONE) New timezone '${__SETTINGS[CS_TIMEZONE]}' installed.\n"
        return 0
    else
        __log e -- "(CS_TIMEZONE) Timezone '${__SETTINGS[CS_TIMEZONE]}' could not be found. Giving up...\n"
        return 1
    fi
    return 254
}
__init_function_register_always 750 __post_cs_timezone
function __psp_cs_timezone() {
    if [[ -z ${__SETTINGS[CS_TIMEZONE]:+x} ]]; then
        __init_results_add "CS_TIMEZONE" "None"
    else
        __init_results_add "CS_TIMEZONE" "${__SETTINGS[CS_TIMEZONE]}"
    fi

    if [[ -z ${__SETTINGS[CS_TIMEZONE_PACKAGES]:+x} ]]; then
        __init_results_add "CS_TIMEZONE_PACKAGES" "None"
    else
        __init_results_add "CS_TIMEZONE_PACKAGES" "${__SETTINGS[CS_TIMEZONE_PACKAGES]}"
    fi

    return 0
}
__init_function_register_always 1800 __psp_cs_timezone
