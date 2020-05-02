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

function __isenabled_install_microsoft_packagelists() {

    declare __IMP_DEFAULT=""
    declare __IMP_ACTIVATED=""
    declare __IMP_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX='^(prod|islow|ifast)(|:|:source|:pkg|:fpkg)$'
    declare __IMP_PACKAGELISTS_REPOSITORY_DEFAULT="prod:pkg"
    declare -a __IMP_NEEDED_PACKAGES_LIBRARY=("microsoft")
    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Configuring Microsoft Package Lists...\n"

    if [[ ${#__IMP_NEEDED_PACKAGES_LIBRARY[@]} -gt 0 ]]; then
        for __T_PACKAGE in "${__IMP_NEEDED_PACKAGES_LIBRARY[@]}"; do
            if __lib_package_load "${__T_PACKAGE}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Successfully loaded package '${__T_PACKAGE}'.\n"
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not load package '${__T_PACKAGE}'. Exiting ($?).\n"
                return 112
            fi
        done
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_PACKAGELISTS+x} ]]; then
        true
    else
        declare __IMP_DEFAULT="${__D_C_INSTALL_MICROSOFT_PACKAGELISTS}"
    fi

    if [[ -z ${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX+x} ]]; then
        true
    elif [[ "${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX}x" == "x" ]]; then
        true
    else
        declare __IMP_REGEX_PACKAGELISTS_REPOSITORY="${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX}"
    fi

    if [[ -z ${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT+x} ]]; then
        true
    elif [[ "${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT}x" == "x" ]]; then
        true
    elif [[ "${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT}" =~ ${__IMP_REGEX_PACKAGELISTS_REPOSITORY} ]]; then
        declare __IMP_PACKAGELISTS_REPOSITORY_DEFAULT="${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT}"
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]}x" == "x" ]]; then
        true
    else
        __IMP_ACTIVATED="1"
    fi
    __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]="${__IMP_DEFAULT}"
    if [[ -z ${CS_INSTALL_MICROSOFT_PACKAGELISTS+x} ]]; then
        true
    elif [[ "${CS_INSTALL_MICROSOFT_PACKAGELISTS}x" == "x" ]]; then
        true
    elif __variable_text CS_INSTALL_MICROSOFT_PACKAGELISTS 1; then
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]="1"
    elif __variable_text CS_INSTALL_MICROSOFT_PACKAGELISTS 0; then
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]=""
    fi

    if [[ "${__IMP_ACTIVATED}x" != "x" ]]; then
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]="1"
    fi

    if [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]}x" == "x" ]]; then
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists installation disabled.\n"
        return 0
    fi

    __SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]=""
    if __variable_exists CS_MICROSOFT_PACKAGELISTS_FILENAME; then
        if __variable_empty CS_MICROSOFT_PACKAGELISTS_FILENAME; then
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists filename configured... No.\n"
        else
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]="${CS_MICROSOFT_PACKAGELISTS_FILENAME}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists filename configured... Yes: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]}'.\n"
        fi
    else
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists filename configured... No.\n"
    fi

    __SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]=""
    if __variable_exists CS_MICROSOFT_PACKAGELISTS_LOCATION; then
        if __variable_empty CS_MICROSOFT_PACKAGELISTS_LOCATION; then
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists location configured... No.\n"
        else
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]="${CS_MICROSOFT_PACKAGELISTS_LOCATION}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists location configured... Yes: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]}'.\n"
        fi
    else
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists location configured... No.\n"
    fi

    __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]=""
    if __variable_exists CS_MICROSOFT_PACKAGELISTS_REPOSITORY; then
        if __variable_empty CS_MICROSOFT_PACKAGELISTS_REPOSITORY; then
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]="${__IMP_PACKAGELISTS_REPOSITORY_DEFAULT}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists repository type configured... No.\n"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Using default settings: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'.\n"
        elif [[ ${CS_MICROSOFT_PACKAGELISTS_REPOSITORY} =~ ${__IMP_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX} ]]; then
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]="${CS_MICROSOFT_PACKAGELISTS_REPOSITORY}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists repository type configured... Yes.\n"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Configured repository type valid: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'. Going to use it!\n"
        else
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]="${__IMP_PACKAGELISTS_REPOSITORY_DEFAULT}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists repository type configured... Yes.\n"
            __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Configured repository type invalid: '${CS_MICROSOFT_PACKAGELISTS_REPOSITORY}'.\n"
            __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Reverting to default: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'.\n"
        fi
    else
        __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]="${__IMP_PACKAGELISTS_REPOSITORY_DEFAULT}"
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Package lists repository type configured... No.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Using default settings: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'.\n"
    fi
    declare __T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH=""
    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Getting repository branch for repository type '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'...\n"
    if __microsoft_packagelists_repository_branch_get "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}" __T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH; then
        __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]="${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}"
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Repository branch: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]}'.\n"
    else
        __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]=""
        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Cannot get repository branch. This should NEVER happen ($?).\n"
    fi
    unset __T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH

    declare __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE=""
    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Getting repository installation type for repository type '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}'.\n"
    if __microsoft_packagelists_repository_installtype_get "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY]}" __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE; then
        __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]="${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}"
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Installatype '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]}'.\n"
    else
        __SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]=""
        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Cannot get installation type. This should NEVER happen ($?).\n"
    fi
    unset __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE
}

__init_function_register_always 180 __isenabled_install_microsoft_packagelists

function __install_microsoft_packagelists() {

    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]}x" == "x" ]]; then
        return 0
    fi

    declare __IMP_NEEDED_PACKAGES_DISTRIBUTION=("apt-transport-https" "ca-certificates" "curl" "gnupgs")
    declare __IMP_NEEDED_PACKAGES_LIBRARY=("microsoft")
    if __pm_ready; then
        if [[ ${#__IMP_NEEDED_PACKAGES_DISTRIBUTION[@]} -gt 0 ]]; then
            if __pm_package_install "${__IMP_NEEDED_PACKAGES_DISTRIBUTION[@]}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Successfully installed '${__IMP_NEEDED_PACKAGES_DISTRIBUTION[@]}'.\n"
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Need packages '${__IMP_NEEDED_PACKAGES_DISTRIBUTION[@]}' could not be installed ($?).\n"
                return 111
            fi
        fi
    fi
    if [[ ${#__IMP_NEEDED_PACKAGES_LIBRARY[@]} -gt 0 ]]; then
        for __T_PACKAGE in "${__IMP_NEEDED_PACKAGES_LIBRARY[@]}"; do
            if __lib_package_load "${__T_PACKAGE}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Successfully loaded package '${__T_PACKAGE}'.\n"
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not load package '${__T_PACKAGE}'. Exiting ($?).\n"
                return 112
            fi
        done
    fi
    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Starting list installation...\n"
    if __microsoft_install_microsoft_packagelists; then
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Microsoft package lists successfully installed. Forcing package manager cache update...\n"
        __pm_cache_update
        return 0
    else
        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Error installing the Microsoft package lists. Disabling the package lists feature.\n"
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]="1"
        return 3
    fi

    return 0
}

__init_function_register_always 210 __install_microsoft_packagelists
function __psp_cs_install_microsoft_packagelists() {
    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]:+x} ]]; then
        __init_results_add "CS_INSTALL_MICROSOFT_PACKAGELISTS" "Disabled"
    else
        __init_results_add "CS_INSTALL_MICROSOFT_PACKAGELISTS" "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_install_microsoft_packagelists
