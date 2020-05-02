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

function __isenabled_install_microsoft_dotnet_sdk() {

    declare __IMDS_DEFAULT=""
    declare __IMDS_DEFAULT_PACKAGENAME="dotnet-sdk-3.1"
    declare __IMDS_REGEX_PACKAGENAME='^dotnet-sdk.*$'

    if [[ -z ${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX}x" == "x" ]]; then
        true
    else
        declare __IMDS_REGEX_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_DOTNET_SDK+x} ]]; then
        true
    else
        declare __IMDS_DEFAULT="${__D_C_INSTALL_MICROSOFT_DOTNET_SDK}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE+x} ]]; then
        true
    else
        declare __IMDS_DEFAULT_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE}"
    fi

    if [[ "${__IMDS_DEFAULT}x" == "x" ]]; then
        true
    elif [[ "${__IMDS_DEFAULT}" =~ ${__IMDS_REGEX_PACKAGENAME} ]]; then
        true
    else
        __IMDS_DEFAULT="${__IMDS_DEFAULT_PACKAGENAME}"
    fi

    __SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]="${__IMDS_DEFAULT}"

    if [[ -z ${CS_INSTALL_MICROSOFT_DOTNET_SDK+x} ]]; then
        true
    elif [[ "${CS_INSTALL_MICROSOFT_DOTNET_SDK}x" == "x" ]]; then
        true
    elif [[ "${CS_INSTALL_MICROSOFT_DOTNET_SDK}" =~ ${__IMDS_REGEX_PACKAGENAME} ]]; then
        __SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]="${CS_INSTALL_MICROSOFT_DOTNET_SDK}"
    elif __variable_text CS_INSTALL_MICROSOFT_DOTNET_SDK 1; then
        __SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]="${__IMDS_DEFAULT_PACKAGENAME}"
    elif __variable_text CS_INSTALL_MICROSOFT_DOTNET_SDK 0; then
        __SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]=""
    fi

    if [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}x" == "x" ]]; then
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Checking if .NET SDK is to be installed.... Disabled.\n"
        return 0
    else
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]="1"
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Checking if .NET SDK is to be installed... Enabled.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Using package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}'.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Enabling installation of Microsoft package lists (CS_INSTALL_MICROSOFT_PACKAGELISTS).\n"
        return 0
    fi
    return 254
}

__init_function_register_always 175 __isenabled_install_microsoft_dotnet_sdk

function __packages_install_microsoft_dotnet_sdk() {
    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}x" == "x" ]]; then
        return 0
    elif [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]}x" == "x" ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]}x" != "x" ]]; then
        return 0
    fi

    if __pm_package_install_list_add "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"; then
        return 0
    else
        return 1
    fi
    return 254
}

__init_function_register_always 315 __packages_install_microsoft_dotnet_sdk

function __fix_package_install_microsoft_dotnet_sdk() {

    declare __IMDS_DEFAULT_PACKAGENAME="dotnet-sdk-3.1"
    declare __IMDS_REGEX_PACKAGENAME='^dotnet-sdk-.+$'

    if [[ -z ${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX}x" == "x" ]]; then
        true
    else
        declare __IMDS_REGEX_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE}x" == "x" ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE}" =~ ${__IMDS_REGEX_PACKAGENAME} ]]; then
        declare __IMDS_DEFAULT_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE}"
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}x" == "x" ]]; then
        return 0
    elif [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]}x" == "x" ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]}x" != "x" ]]; then
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Microsoft package lists installation was aborted.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Checking if we have to remove the package from the installation list...\n"
        if __pm_package_install_list_contains "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"; then
            __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Removing package from installation list.\n"
            if __pm_package_install_list_remove "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}' successfully removed.\n"
                return 0
            else
                __log e -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Problems removing '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}' from package list ($?).\n"
                return 111
            fi
        else
            __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Package not in the list.\n"
            return 0
        fi
    fi
    __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Checking if package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}' is available...\n"
    if __pm_package_available "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"; then
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}' is available.\n"
        return 0
    else
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}' is not available.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Reverting to default package '${__IMDS_DEFAULT_PACKAGENAME}'.\n"
        if __pm_package_install_list_remove "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"; then
            if __pm_package_install_list_add "${__IMDS_DEFAULT_PACKAGENAME}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Successfully added package '${__IMDS_DEFAULT_PACKAGENAME}' to the list.\n"
                __SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]="${__IMDS_DEFAULT_PACKAGENAME}"
                return 0
            else
                __log e -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Problems adding package '${__IMDS_DEFAULT_PACKAGENAME}' to the list ($?).\n"
                return 121
            fi
        else
            __log e -- "(CS_INSTALL_MICROSOFT_DOTNET_SDK) Problems removing package '${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}'  from the list ($?).\n"
            return 122
        fi
    fi
    return 254
}

__init_function_register_always 455 __fix_package_install_microsoft_dotnet_sdk
function __psp_cs_install_microsoft_dotnet_sdk() {
    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]:+x} ]]; then
        __init_results_add "CS_INSTALL_MICROSOFT_DOTNET_SDK" "Disabled"
    else
        __init_results_add "CS_INSTALL_MICROSOFT_DOTNET_SDK" "${__SETTINGS[CS_INSTALL_MICROSOFT_DOTNET_SDK]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_install_microsoft_dotnet_sdk
