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
__lib_require "base_variable"

function __isenabled_feature_microsoft_dotnet_telemetry_optout() {

    declare __MDTO_DEFAULT="1"

    if [[ -z ${__D_C_MICROSOFT_DOTNET_TELEMETRY_OPTOUT+x} ]]; then
        true
    else
        declare __MDTO_DEFAULT="${__D_C_MICROSOFT_DOTNET_TELEMETRY_OPTOUT}"
    fi

    __SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]="${__MDTO_DEFAULT}"

    if [[ -z ${CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT+x} ]]; then
        true
    elif [[ "${CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT}x" == "x" ]]; then
        true
    elif __variable_text CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT 1; then
        __SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]="1"
    elif __variable_text CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT 0; then
        __SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]=""
    fi

    if [[ "${__SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]}x" == "x" ]]; then
        __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Checking for dotNet telemetry optout... Disabled.\n"
        return 0
    else
        __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Checking for dotNet telemtry optout.... Enabled.\n"
        return 0
    fi
    return 254
}

__init_function_register_always 150 __isenabled_feature_microsoft_dotnet_telemetry_optout

function __post_feature_microsoft_dotnet_telemetry_optout() {
    if [[ -z ${__SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]}x" == "x" ]]; then
        declare __T_RESULT=0
    else
        declare __T_RESULT=1
    fi
    if [[ ! -d "/etc/profile.d" ]]; then
        __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Directory '/etc/profile.d' does not exist. Attempting to create it...\n"
        if mkdir -p "/etc/profile.d"; then
            __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Creating directory '/etc/profile.d' success.\n"
        else
            __log e -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Problems creating '/etc/profile.d' ($?).\n"
            return 131
        fi
    fi
    __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Settings value to '${__T_RESULT}'.\n"
    if echo "DOTNET_CLI_TELEMETRY_OPTOUT=${__T_RESULT}" >/etc/profile.d/01-dotnet-telemetry.sh; then
        __log i -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Successfully set value of '/etc/profile.d/01-dotnet-telemetry.sh' to '${__T_RESULT}'.\n"
        return 0
    else
        __log e -- "(CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT) Problems setting value of '/etc/profile.d/01-dotnet-telemetry.sh' to '${__T_RESULT}' ($?).\n"
        return 141
    fi
    return 254
}

__init_function_register_always 750 __post_feature_microsoft_dotnet_telemetry_optout
function __psp_cs_microsoft_dotnet_telemetry_optout() {
    if [[ -z ${__SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]:+x} ]]; then
        __init_results_add "CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT" "Disabled"
    else
        __init_results_add "CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT" "${__SETTINGS[CS_MICROSOFT_DOTNET_TELEMETRY_OPTOUT]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_microsoft_dotnet_telemetry_optout
