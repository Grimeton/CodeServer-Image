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

function __isenabled_install_locales() {

    declare __IL_DEFAULT=""
    declare __IL_LOCALES_PACKAGES="locales"

    if [[ -z ${__D_C_LOCALES+x} ]]; then
        true
    else
        declare __IL_DEFAULT="${__D_C_LOCALES}"
    fi
    if [[ -z ${__D_C_LOCALES_PACKAGES+x} ]]; then
        true
    else
        declare __IL_LOCALES_PACKAGES="${__D_C_LOCALES_PACKAGES}"
    fi

    __SETTINGS[LOCALES]="${__IL_DEFAULT}"
    __SETTINGS[LOCALES_PACKAGES]="${__IL_LOCALES_PACKAGES}"

    if [[ -z ${CS_LOCALES+x} ]]; then
        true
    elif [[ "${CS_LOCALES}x" == "x" ]]; then
        true
    else
        __SETTINGS[LOCALES]="${CS_LOCALES}"
    fi

    if [[ -z ${CS_LOCALES_PACKAGES+x} ]]; then
        true
    elif [[ "${CS_LOCALES_PACKAGES}x" == "x" ]]; then
        true
    else
        __SETTINGS[LOCALES_PACKAGES]="${CS_LOCALES_PACKAGES}"
    fi

    if [[ "${__SETTINGS[LOCALES]}x" == "x" ]]; then
        __SETTINGS[LOCALES_PACKAGES]=""
        __log i -- "(CS_LOCALES) Checking if we have to install locales... No.\n"
        return 0
    else
        __log i -- "(CS_LOCALES) Checking if we have to install locales... Yes: '${__SETTINGS[LOCALES]}'.\n"
        if [[ "${__SETTINGS[LOCALES_PACKAGES]}x" != "x" ]]; then
            __log i -- "(CS_LOCALES) Using packages: '${__SETTINGS[LOCALES_PACKAGES]}'.\n"
        fi
        return 0
    fi
    return 254
}
__init_function_register_always 150 __isenabled_install_locales

function __packages_install_locales() {
    if [[ -z ${__SETTINGS[LOCALES]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[LOCALES]}x" == "x" ]]; then
        return 0
    elif [[ -z ${__SETTINGS[LOCALES_PACKAGES]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[LOCALES_PACKAGES]}x" == "x" ]]; then
        return 0
    fi
    if __pm_package_install_list_add "${__SETTINGS[LOCALES_PACKAGES]}"; then
        return 0
    else
        return 1
    fi
    return 254
}
__init_function_register_always 300 __packages_install_locales

function __post_install_locales() {

    if [[ -z ${__SETTINGS[LOCALES]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[LOCALES]}x" == "x" ]]; then
        return 0
    fi
    __log i -- "(CS_LOCALES) Installing locales... '${__SETTINGS[LOCALES]}'.\n"
    # let's get a list of locales
    declare __T_LOCALE_DEFAULT=""
    declare -a __T_LOCALES=()
    declare -a __T_LOCALE_FILES=()
    declare __T_NEW_LOCALE=""
    # global ones
    if [[ -f "/usr/share/i18n/SUPPORTED" ]]; then
        __T_LOCALE_FILES+=("/usr/share/i18n/SUPPORTED")
    fi

    # and local ones... this should be empty, but we never know ;-P
    if [[ -f "/usr/local/share/i18n/SUPPORTED" ]]; then
        __T_LOCALE_FILES+=("/usr/local/share/i18n/SUPPORTED")
    fi

    if [[ ${#__T_LOCALE_FILES[@]} -lt 1 ]]; then
        __log i -- "(CS_LOCALES) No locales on system found. Aborting.\n"
        return 1
    fi

    while read __T_LINE; do
        for __T_LOCALE in ${__SETTINGS[LOCALES]}; do
            declare __T_LOCALE_REGEX="^${__T_LOCALE}.*"
            if [[ ${__T_LINE} =~ ${__T_LOCALE_REGEX} ]]; then
                if [[ "${__T_LOCALE_DEFAULT}x" == "x" ]]; then
                    __T_LOCALE_DEFAULT="${__T_LINE}"
                fi
                __T_LOCALES+=("${__T_LINE}")
            fi
        done
    done < <(cat "${__T_LOCALE_FILES[@]}")

    if [[ "${__T_LOCALE_DEFAULT}x" == "x" ]]; then
        __log e -- "(CS_LOCALES) No locales found.\n"
        return 121
    fi

    __log_banner i -- "(CS_LOCALES) BEGIN: 'local-gen'."
    __log i -- "(CS_LOCALES) Beginning generation of locales...\n"

    if [[ -f "/etc/locale.gen" ]]; then
        rm -f "/etc/locale.gen"
    fi

    (for __T_LOCALE in "${__T_LOCALES[@]}"; do
        echo "${__T_LOCALE}"
    done) >"/etc/locale.gen"

    if locale-gen; then
        __log i -- "(CS_LOCALES) Generating locales... Success.\n"
        __log_banner i -- "(CS_LOCALES) END: 'locale-gen'."
    else
        __log e -- "(CS_LOCALES) Problem generating locales... ($?)\n"
        __log_banner e -- "(CS_LOCALES) END: 'locale-gen'."
        return 131
    fi

    __log_banner i -- "(CS_LOCALES) BEGIN: 'update-locale'."
    __log i -- "(CS_LOCALES) Beginning update of locales...\n"
    if update-locale LANG="${__T_LOCALE_DEFAULT// */}" LANGUAGE="${__T_LOCALE_DEFAULT// */}" LC_ALL="${__T_LOCALE_DEFAULT// */}"; then
        __log i -- "(CS_LOCALES) Locales updated successfully.\n"
        __log_banner i -- "(CS_LOCALES) END: 'update-locale'."
    else
        __log e -- "(CS_LOCALES) Problem updating locales ($?).\n"
        __log_banner e -- "(CS_LOCALES) END: 'update-locale'."
        return 141
    fi

    __log i -- "Locales installed: '${__T_LOCALES[@]}'.\n"
    __log i -- "Default locale: '${__T_LOCALE_DEFAULT}'.\n"
    return 0
}

__init_function_register_always 750 __post_install_locales

function __psp_cs_locales() {
    if [[ -z ${__SETTINGS[CS_LOCALES]:+x} ]]; then
        __init_results_add "CS_LOCALES" "None"
    else
        __init_results_add "CS_LOCALES" "${__SETTINGS[CS_LOCALES]}"
    fi

    if [[ -z ${__SETTINGS[CS_LOCALES_PACKAGES]:+x} ]]; then
        __init_results_add "CS_LOCALES_PACKAGES" "none"
    else
        __init_results_add "CS_LOCALES_PACKAGES" "${__SETTINGS[CS_LOCALES_PACKAGES]}"
    fi

    return 0
}
__init_function_register_always 1800 __psp_cs_locales
