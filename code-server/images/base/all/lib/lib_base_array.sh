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

# DO NOT MESS WITH THIS.
# REALLY I MEAN IT.
set -o nounset

# export lib specific things
declare -gx __ARRAY_TYPE_REGEX='^declare -([^\ ]*a[^\ ]*)\ .*'
declare -gx __ARRAY_LOADED=1

#####
#
# - __array_add
#
# Takes the name of an ARRAY and adds the VALUE to it if it DOES NOT exist.
#
# - Parameters:
#
# - #1: [IN|MANDATORY]: ARRAY - The name of the array to work on.
# - #2: [IN|OPTIONAL]: VALUE - The value to add to the array (can be empty)
#
# Returns 0 on success
# Returns >0 on error
#
function __array_add() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare -a __P_VALUE=""
    else
        declare -a __P_VALUE="${@:2:1}"
    fi

    if __array_contains "${!__P_ARRAY}" "${__P_VALUE}"; then
        return 111
    elif __P_ARRAY+=("${__P_VALUE}"); then
        return 0
    fi
    return 1

}
#####
#
# - __array_add_always
#
# Takes the name of an array and ALWAYS adds the value to it.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of the array to work on
# - #2 [IN|MANDATORY]: VALUE - The value to add to the array (can be empty)
#
# Returns 0 on success
# Returns >0 only on failures
#
function __array_add_always() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_VALUE=""
    else
        declare __P_VALUE="${@:2:1}"
    fi
    if __P_ARRAY+=("${__P_VALUE}"); then
        return 0
    fi
    return 1
}

#####
#
# - __array_contains
#
# Takes a NEEDLE and searches for it in HAYSTACK.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: HAYSTACK - The name of the array to search in
# - #2 [IN|MANDATORY]: NEEDLE - The value to search for in HAYSTACK (Can be empty)
#
# Returns 0 when found/success
# Returns >0 when not found/problem
#
function __array_contains() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __P_HAYSTACK="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_NEEDLE=""
    else
        declare __P_NEEDLE="${@:2:1}"
    fi

    if __array_empty "${!__P_HAYSTACK}"; then
        return 111
    else
        for __P_HAY in "${__P_HAYSTACK[@]}"; do
            if [[ "${__P_HAY}" == "${__P_NEEDLE}" ]]; then
                return 0
            fi
        done
    fi
    return 1
}

#####
#
# - __array_empty
#
# Takes an ARRAYNAME and checks if it is empty.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of the array to test
#
# Returns 0 on success
# Returns >0 otherwise
#
function __array_empty() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 102
    fi

    if [[ ${#__P_ARRAY[@]} -lt 1 ]]; then
        return 0
    fi
    return 1

}
#####
#
# - __array_exists
#
# Takes the name of a variable and tests if it exists/is an array.
#
# - Paramters
#
# - #1 [IN|MANDATORY]: ARRAYNAME - The name of the possible array to test for
#
# Returns 0 on success
# Returns >0 on failure.
#
function __array_exists() {

    shopt -u nocasematch
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_ARRAYNAME="${@:1:1}"
    fi
    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_ARRAYNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__ARRAY_TYPE_REGEX} ]]; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __array_remove
#
# Takes the name of an array and a value that will be removed when found.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of the array to work on.
# - #2 [IN|MANDATORY]: VALUE - The value to be deleted (can be empty)
#
# Returns 0 on success/deletion
# Returns >0 on failure/value not found
#
function __array_remove() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_VALUE=""
    else
        declare __P_VALUE="${@:2:1}"
    fi

    if __array_empty "${!__P_ARRAY}"; then
        return 111
    else
        declare -a __T_ARRAY_NEW=()
        declare -i __T_DELETED=0
        for __T_VALUE in "${__P_ARRAY[@]}"; do
            if [[ "${__P_VALUE}x" == "${__T_VALUE}x" ]]; then
                ((__T_DELETED++)) || true
                continue
            fi
            __T_ARRAY_NEW+=("${__T_VALUE}")
        done
        if [[ ${#__T_ARRAY_NEW[@]} -gt 0 ]]; then
            __P_ARRAY=("${__T_ARRAY_NEW[@]}")
        else
            __P_ARRAY=()
        fi
        
        if [[ ${__T_DELETED} -gt 0 ]]; then
            return 0
        fi
    fi
    return 1

}
