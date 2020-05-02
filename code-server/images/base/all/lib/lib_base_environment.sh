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

set -o nounset

declare -gx __ENVIRONMENT_LOADED=1

#####
#
# - __environment_save
#
# Takes a list of environment variables and converts them
# into a storeable version to stdout
#
# THIS FUNCTION DOES NOT ACCEPT NAMEREF ARRAYS FOR OBVIOUS
# REASONS
#
# - Paramters:
# - #1 [IN|MANDATORY]: Variable name
#
# Returns 0 on success
# Returns >0 on failure
#
function __environment_save() {

    declare __T_VARIABLE=""

    if [[ ${#@} -lt 1 ]]; then
        return 101
    fi

    declare -a __P_ES_VARIABLES=("${@}")

    for __T_VARIABLE in "${__P_ES_VARIABLES[@]}"; do
        if __variable_exists "${__T_VARIABLE}"; then
            declare -p "${__T_VARIABLE}"
        fi
    done
    return 0
}

#####
#
# - __env_save_file
#
# Takes a list of variables and stores them into a file
#
# THIS FUNCTION DOES NOT ACCEPT NAMEREF ARRAYS FOR OBVIOUS
# REASONS
#
# - Paramters:
# - #1 [IN|MANDATORY] FILE - Full path to file where to store the variables
# - #2 [IN|MANDATORY] VARIABLE_NAME - Name/Names of variables to be saved
#
# Returns 0 on success
# Returns >0 on failure
#
function __environment_save_file() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILE="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare -a __P_ESF_VARIABLES=("${@:2}")
    fi

    if __environment_save "${__P_ESF_VARIABLES[@]}" >"${__P_FILE}"; then
        return 0
    fi
    return 1
}
