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
declare -gx __AARRAY_LOADED=1
declare -gx __AARRAY_TYPE_REGEX='^declare -[^\ ]*A[^\ ]*\ .*$'

#####
#
# - __aarray_add
#
# Takes the name of an array, the key and the value and adds it if the key does NOT exist yet.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array where the value should be added to
# - #2 [IN|MANDATORY]: KEY - The name of the key to add to the array
# - #3 [IN|MANDATORY]: VALUE - The value to be added. Can be empty!
#
# Returns 0 on success
# Returns >0 on failure
#
function __aarray_add() {

    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare -a __P_KEY="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare __P_VALUE=""
    else
        declare __P_VALUE="${@:3:1}"
    fi

    if __aarray_contains_key "${!__P_ARRAY}" "${__P_KEY}"; then
        return 1
    elif __P_ARRAY+=([${__P_KEY}]="${__P_VALUE}"); then
        return 0
    fi
    return 1
}
#####
#
# - __aarray_add_always
#
# Takes the name of an array, the key and the value and adds it, even if the key already
# exists. This can be used to overwrite a value or to enforce adding a value
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array where the value should be added to.
# - #2 [IN|MANDATORY]: KEY - The name of the key to add to the array
# - #3 [IN|MANDATORY]: VALUE - The value that should be added to the array. Can be empty!
#
# Returns 0 on success
# Returns >0 on error
#
function __aarray_add_always() {

    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare -a __P_KEY="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare -a __P_VALUE=""
    else
        declare -a __P_VALUE="${@:3:1}"
    fi

    if __P_ARRAY[${__P_KEY}]="${__P_VALUE}"; then
        return 0
    fi
    return 1
}
#####
#
# - __aarray_contains_key
#
# Takes the name of an array and a possible key and checks if the key exists.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array that should be checked.
# - #2 [IN|MANDATORY]: KEY - The name of the key to test for
#
# Returns 0 when found
# Returns >0 when error
#
function __aarray_contains_key() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_KEY="${@:2:1}"
    fi

    if __aarray_empty "${!__P_ARRAY}"; then
        return 111
    fi

    for __T_KEY in "${!__P_ARRAY[@]}"; do
        if [[ "${__T_KEY}" == "${__P_KEY}" ]]; then
            return 0
        fi
    done
    return 1
}
#####
#
# - __aaray_contains_value
#
# Takes the name of an array and a value and checks if it exists in the array
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array to check
# - #2 [IN|MANDATORY]: VALUE - The value to search for
#
# Returns 0 on success/found
# Returns >0 on error/not found
function __aarray_contains_value() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_VALUE=""
    else
        declare __P_VALUE="${@:2:1}"
    fi

    if __aarray_empty "${!__P_ARRAY}"; then
        return 111
    fi

    for __T_VALUE in "${__P_ARRAY[@]}"; do
        if [[ "${__T_VALUE}" == "${__P_VALUE}" ]]; then
            return 0
        fi
    done
    return 1
}
#####
#
# - __aarray_empty
#
# Takes the name of an array and tests if it is empty.
#
# - Parameters
#
# - #1 [IN|MANDATORY]: ARRAY- The name of an array to be tested.
#
# Returns 0 when empty/success
# Returns >0 when not empty/error
#
function __aarray_empty() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ ${#__P_ARRAY[@]} -lt 1 ]]; then
        return 0
    fi
    return 1
}
#####
#
# - __aarray_exists
#
# Takes the name of a variable and tests if it is an associative array.
#
# - Parameters:
#
# - #1 [IN|MANDATORY]: ARRAYNAME - The name of the variable to test for
#
# Returns 0 when array is associative
# Returns > 0 otherwise
#
function __aarray_exists() {

    shopt -u nocasematch
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_ARRAYNAME="${@:1:1}"
    fi
    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_ARRAYNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__AARRAY_TYPE_REGEX} ]]; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __aaray_get_key
#
# Takes the name of an array and the value to search for and returns the keys (!) that match the value.
#
# - Parameters
# - #1 [IN|MANDATORY]: ARRAY - The name of the array that should be searched
# - #2 [IN|MANDATORY]: VALUE - The value to search for
# - #3 [OUT|OPTIONAL]: RETURN_ARRAY - The name of an existing array (normal, not associative) that should
#                                     be filled with the keys found. If not set, keys will be printed to stdout.
#
# Returns 0 on success
# Returns >0 on failure.
#
function __aarray_get_key() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_VALUE="${@:2:1}"
    fi

    if __array_exists "${@:3:1}"; then
        declare -n __T_RETURN_ARRAY="${@:3:1}"
    else
        declare -a __T_RETURN_ARRAY=()
    fi

    if [[ ${#__P_ARRAY[@]} -lt 1 ]]; then
        return 111
    else
        for __T_KEY in "${!__P_ARRAY[@]}"; do
            if [[ "${__P_ARRAY[${__T_KEY}]}" == "${__P_VALUE}" ]]; then
                __T_RETURN_ARRAY+=("${__T_KEY}")
            fi
        done
    fi

    if [[ ${#__T_RETURN_ARRAY[@]} -gt 0 ]]; then
        if [[ ! -R __T_RETURN_ARRAY ]]; then
            echo "${__T_RETURN_ARRAY[@]}"
        fi
        return 0
    fi
    return 1
}
#####
#
# - __aaray_get_value
#
# Takes the name of an array and a key and returns the value when found.
#
# - Parameters
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array to search in...
# - #2 [IN|MANDATORY]: KEY - The key to search for
# - #3 [OUT|OPTIONAL]: RETURN_RESULT - The name of an existing variable that should be filled with the result
#                                      If not set, will be printed to stdout.
#
# Returns 0 when found/success
# Returns >0 when not found/problem
#
function __aarray_get_value() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_KEY="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare __T_RETURN_RESULT=""
    elif __variable_exists "${@:3:1}"; then
        declare -n __T_RETURN_RESULT="${@:3:1}"
        __T_RETURN_RESULT=""
    else
        declare __T_RETURN_RESULT=""
    fi
    if __aarray_empty "${!__P_ARRAY}"; then
        return 111
    fi

    if __aarray_contains_key "${!__P_ARRAY}" "${__P_KEY}"; then
        __T_RETURN_RESULT="${__P_ARRAY[${__P_KEY}]}"
    fi

    if [[ "${__T_RETURN_RESULT}x" != "x" ]]; then
        if [[ ! -R __T_RETURN_RESULT ]]; then
            echo "${__T_RETURN_RESULT}"
        fi
        return 0
    fi
    return 1
}
#####
#
# - __aarray_remove_key
#
# Takes the name of an array and a key and removes it if found.
#
# - Parameters
#
# - #1 [IN|MANDATORY] - ARRAY - The name of the array to work on.
# - #2 [IN|MANDATORY] - KEY - The key to be removed.
# - #3 [OUT|OPTIONAL] - RETURN_RESULT - The name of an existing variable to be filled with the removed value.
#                                       If not set, nothing happens.
#
# Returns 0 on success/remove
# Returns >0 on error/failure
#
function __aarray_remove_key() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_KEY="${@:2:1}"
    fi

    if __aarray_empty "${!__P_ARRAY}"; then
        return 111
    fi

    if __aarray_contains_key "${!__P_ARRAY}" "${__P_KEY}"; then
        if unset __P_ARRAY[${__P_KEY}]; then
            return 0
        else
            return 121
        fi
    else
        return 122
    fi
    return 199
}
#####
#
# - __aarray_remove_value
#
# Takes the name of an array and a value and removes all the keys that contain said value.
#
# - Parameters
#
# - #1 [IN|MANDATORY]: ARRAY - The name of an array to be worked on
# - #2 [IN|MANDATORY]: VALUE - The name of the value to be searched for
# - #3 [OUT|OPTIONAL]: RETURN_ARRAY - The name of an existing array to be filled with the keys
#                                     that have been removed. If not set, nothing happens.
#
# Returns 0 when success/remove
# Returns >0 when failure/no removal
#
function __aarray_remove_value() {
    if __aarray_exists "${@:1:1}"; then
        declare -n __P_ARRAY="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_VALUE=""
    else
        declare __P_VALUE="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare -a __T_RETURN_ARRAY=()
    elif __array_exists "${@:3:1}"; then
        declare -n __T_RETURN_ARRAY="${@:3:1}"
    else
        declare -a __T_RETURN_ARRAY=()
    fi

    if __aarray_empty "${!__P_ARRAY}"; then
        return 111
    else
        for __T_KEY in "${!__P_ARRAY[@]}"; do
            if [[ "${__P_ARRAY[${__T_KEY}]}" == "${__P_VALUE}" ]]; then
                if unset __P_ARRAY[${__T_KEY}]; then
                    __T_RETURN_ARRAY+=("${__T_KEY}")
                    true
                else
                    return 1
                fi
            fi
        done
        return 0
    fi
    return 199

}
