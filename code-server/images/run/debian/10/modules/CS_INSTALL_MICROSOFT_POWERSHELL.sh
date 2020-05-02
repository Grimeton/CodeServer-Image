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

function __isenabled_install_microsoft_powershell() {

    declare __IMP_DEFAULT=""
    declare __IMP_DEFAULT_PACKAGENAME="powershell"
    declare __IMP_REGEX_PACKAGENAME='^powershell.*$'

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX}x" == "x" ]]; then
        true
    else
        declare __IMP_REGEX_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL}x" == "x" ]]; then
        declare __IMP_DEFAULT=""
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL}" =~ ${__IMPREGEX_PACKAGENAME} ]]; then
        declare __IMP_DEFAULT="${__D_C_INSTALL_MICROSOFT_POWERSHELL}"
    else
        if __variable_text __D_C_INSTALL_MICROSOFT_POWERSHELL 1; then
            declare __IMP_DEFAULT="1"
        else
            declare __IMP_DEFAULT=""
        fi
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}x" == "x" ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}" =~ ${__IMP_REGEX_PACKAGENAME} ]]; then
        declare __IMP_DEFAULT_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}"
    fi

    __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="${__IMP_DEFAULT}"
    if [[ -z ${CS_INSTALL_MICROSOFT_POWERSHELL+x} ]]; then
        true
    elif [[ "${CS_INSTALL_MICROSOFT_POWERSHELL}x" == "x" ]]; then
        true
    elif [[ "${CS_INSTALL_MICROSOFT_POWERSHELL}" =~ ${__IMP_REGEX_PACKAGENAME} ]]; then
        __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="${CS_INSTALL_MICROSOFT_POWERSHELL}"
    elif __variable_text CS_INSTALL_MICROSOFT_POWERSHELL 1; then
        if [[ "${__IMP_DEFAULT}" =~ ${__IMP_REGEX_PACKAGENAME} ]]; then
            __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="${__IMP_DEFAULT}"
        else
            __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="${__IMP_DEFAULT_PACKAGENAME}"
        fi
    elif __variable_text CS_INSTALL_MICROSOFT_POWERSHELL 0; then
        __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]=""
    fi

    if [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}x" == "x" ]]; then
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Installation disabled.\n"
        return 0
    else
        __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS]="1"
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Installation enabled.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Using package '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}'.\n"
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Enabling installation of microsoft packagelists (CS_INSTALL_MICROSOFT_PACKAGELISTS).\n"
        return 0
    fi
    return 254
}

__init_function_register_always 177 __isenabled_install_microsoft_powershell

function __package_install_microsoft_powershell() {

    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}x" == "x" ]]; then
        return 0
    elif __pm_package_install_list_add "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"; then
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Successfully added package '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}' to list.\n"
        return 0
    else
        __log e -- "(CS_INSTALL_MICROSOFOT_POWERSHELL) Problems adding package '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}' to list ($?)\n"
        return 111
    fi
    return 254
}

__init_function_register_always 317 __package_install_microsoft_powershell

function __fix_package_install_microsoft_powershell() {

    declare __IMP_DEFAULT=""
    declare __IMP_DEFAULT_PACKAGENAME="powershell"
    declare __IMP_REGEX_PACKAGENAME='^powershell.*$'

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX}x" == "x" ]]; then
        true
    else
        declare __IMP_REGEX_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}x" == "x" ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}" =~ ${__IMP_REGEX_PACKAGENAME} ]]; then
        declare __IMP_DEFAULT_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE}"
    fi

    if [[ -z ${__D_C_INSTALL_MICROSOFT_POWERSHELL+x} ]]; then
        true
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL}x" == "x" ]]; then
        declare __IMP_DEFAULT=""
    elif [[ "${__D_C_INSTALL_MICROSOFT_POWERSHELL}" =~ ${__IMPREGEX_PACKAGENAME} ]]; then
        declare __IMP_DEFAULT_PACKAGENAME="${__D_C_INSTALL_MICROSOFT_POWERSHELL}"
    fi

    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]+x} ]]; then
        return 0
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}x" == "x" ]]; then
        return 0
    elif [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]+x} ]]; then
        true
    elif [[ "${__SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_ABORT]}x" == "x" ]]; then
        true
    else
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Microsoft package list installation was aborted. Taking care of the powershell package...\n"
        if __pm_package_install_list_contains "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"; then
            if __pm_package_install_list_remove "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Successfully removed '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}' from the list.\n"
                return 0
            else
                __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Problems removing package '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}' from the list ($?).\n"
                return 111
            fi
        else
            __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Package not in the list.\n"
            return 0
        fi
    fi

    __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Checking if the package '${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}' is available for installation.\n"
    if __pm_package_available "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"; then
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Package available.\n"
        return 0
    else
        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Package not available. Reverting to default '${__IMP_DEFAULT_PACKAGENAME}'.\n"
        if __pm_package_install_list_remove "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"; then
            if __pm_package_available "${__IMP_DEFAULT_PACKAGENAME}"; then
                if __pm_package_install_list_add "${__IMP_DEFAULT_PACKAGENAME}"; then
                    __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="${__IMP_DEFAULT_PACKAGENAME}"
                    __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Successfully added '${__IMP_DEFAULT_PACKAGENAME}' to the list.\n"
                    return 0
                else
                    __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Problems adding '${__IMP_DEFAULT_PACKAGENAME}' to the list.\n"
                    return 111
                fi
            else
                __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Package '${__IMP_DEFAULT_PACKAGENAME}' is not available.\n"
                __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Reverting to last resort 'powershell'.\n"
                if __pm_package_available "powershell"; then
                    if __pm_package_install_list_add "powershell"; then
                        __SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]="powershell"
                        __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Successfully added last resort 'powershell' to the list.\n"
                        return 0
                    else
                        __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Problems adding last resort 'powershell' to the list ($?).\n"
                        return 121
                    fi
                else
                    __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Last resort 'powershell' is not available either. Giving up ($?).\n"
                    return 122
                fi
            fi
        else
            __log e -- "(CS_INSTALL_MICROSOFT_POWERSHELL) Problems removing package '${__SETTINGS[CS_INSTALL_POWERSHELL]}' from the list ($?).\n"
            return 123
        fi
    fi
    return 254

}
__init_function_register_always 457 __fix_package_install_microsoft_powershell
function __psp_cs_install_microsoft_powershell() {
    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]:+x} ]]; then
        __init_results_add "CS_INSTALL_MICROSOFT_POWERSHELL" "Disabled"
    else
        __init_results_add "CS_INSTALL_MICROSOFT_POWERSHELL" "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_install_microsoft_powershell
