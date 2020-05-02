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
__lib_require "base_variable"

function __isenabled_install_microsoft_powershell() {
    
    if __variable_exists CS_INSTALL_MICROSOFT_POWERSHELL; then
        if __variable_empty CS_INSTALL_MICROSOFT_POWERSHELL; then
            true
        elif __variable_text CS_INSTALL_MICROSOFT_POWERSHELL 1; then
            __log i -- "(CS_INSTALL_MICROSOFT_POWERSHELL) This feature is not available on this Ubuntu version."
        fi
    fi
    return 0
}

__init_function_register_always 177 __isenabled_install_microsoft_powershell

function __psp_cs_install_microsoft_powershell() {
    if [[ -z ${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]:+x} ]]; then
        __init_results_add "CS_INSTALL_MICROSOFT_POWERSHELL" "Disabled"
    else
        __init_results_add "CS_INSTALL_MICROSOFT_POWERSHELL" "${__SETTINGS[CS_INSTALL_MICROSOFT_POWERSHELL]}"
    fi
    return 0
}
__init_function_register_always 1800 __psp_cs_install_microsoft_powershell
