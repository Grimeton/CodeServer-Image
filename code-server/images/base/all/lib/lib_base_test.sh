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

function __test_array_associative() {
    __aarray_exists "${@}"
}
#####
#
# - __test_array_contains
#
# Takes a NEEDLE and searches for it in HAYSTACK.
#
# If found, returns 0
# returns 1 otherwise
#
function __test_array_contains() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_NEEDLE="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    elif __array_exists "${@:2:1}"; then
        declare -n __P_ARRAY="${@:2:1}"
    else
        declare -a __P_TAC_ARRAY=("${@:2}")
        declare -n __P_ARRAY="__P_TAC_ARRAY"
    fi
    __array_contains "${!__P_ARRAY}" "${__P_NEEDLE}"
}

#####
#
# - __test_array_exists
#
# Takes the name of a variable and tests if it is an array.
#
# - Paramters
#
# - #1 [MANDATORY]: ARRAYNAME - The name of the possible array to test for
#
# Returns 0 on success > 0 on failure.
#
function __test_array_exists() {
    __array_exists "${@}"
}
#####
#
# - __test_arrayref_associative
#
# Takes the name of a variable and tests if it is a nameref to an existing, associative array.
#
# - Paramters
#
# - #1 [MANDATORY]: ARRAYREFNAME - The name of the possible arrayref to test for
#
# Returns 0 on success > 0 on failure.
#
function __test_arrayref_associative() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_nameref_exists "${@:1:1}"; then
        declare -n __P_ARRAYREF="${@:1:1}"
    else
        return 102
    fi

    if __aarray_exists "${!__P_ARRAYREF}"; then
        return 0
    fi
    return 1

}

#####
#
# - __test_arrayref_exists
#
# Takes the name of a variable and tests if it is a nameref to an existing array.
#
# - Paramters
#
# - #1 [MANDATORY]: ARRAYREFNAME - The name of the possible arrayref to test for
#
# Returns 0 on success > 0 on failure.
#
function __test_arrayref_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_nameref_exists "${@:1:1}"; then
        declare -n __P_NAMEREF="${@:1:1}"
        if __array_exists "${!__P_NAMEREF}"; then
            return 0
        fi
    fi
    return 1

}
#####
#
# - __test_function_exists
#
# Takes the name of a function and
#
# return 0 when found and function
# return 1 otherwise
# return 3 when "functionname" is empty
#
# - Parameters
#
# - #1: "FUNCTIONNAME" - "name of the function..."
#
function __test_function_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FUNCTIONNAME="${@:1:1}"
    fi
    declare __T_RESULT=""

    if __T_RESULT="$(type -t "${__P_FUNCTIONNAME}")"; then
        if [[ "${__T_RESULT,,}" == "function" ]]; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __test_nameref_exists
#
# Takes the name of a variable and tests if it is a named reference.
#
# - Paramters
#
# - #1 [MANDATORY]: NAMEREF - The name of the possible named reference to test for
#
# Returns 0 on success > 0 on failure.
#
function __test_nameref_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_STRING="${@:1:1}"
    fi

    declare __T_TEXT_REGEX_NAMEREF='^declare -([^\ ]*n[^\ ]*)\ .*'
    declare __T_RESULT=""
    # yes, we could just do [[ -R ${__P_STRING} ]] here...
    if __T_RESULT="$(declare -p "${__P_STRING}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_TEXT_REGEX_NAMEREF} ]]; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __test_regex_valid
#
# - Description:
#   Takes a string and tests if the regex is valid.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: REGEX - The string to be tested.
#
# - Return values:
#   - 0 if it is a valid regex.
#   - 1 if it is not a valid regex.
#
function __test_regex_valid() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_REGEX="${@:1:1}"
    fi

    if [[ "" =~ ${__P_REGEX} ]]; then
        return 0
    else
        declare -i __T_ERROR=$?
        if [[ ${__T_ERROR} -eq 1 ]]; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __test_variable_empty
#
# Takes the name of a variable and...
#
# return 0 if empty
# return 1 otherwise
#
# IF THE VARIABLE IS NOT SET, IT IS NOT EMPTY!!!
#
# - Paramters
#
# - #1: VARNAME - The name of the variable
#
function __test_variable_empty() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    if __test_variable_exists "${__P_VARNAME}"; then
        if [[ "${!__P_VARNAME}x" == "x" ]]; then
            return 0
        fi
    else
        return 111
    fi
    return 1
}

#####
#
# - __test_variable_exists
#
# Takes the name of a variable and...
#
# return 0 if exists
# return 1 otherwise
#
# - Paramters
#
# - #1: VARNAME - The name of the variable
#
function __test_variable_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare -p "${__P_VARNAME}" >/dev/null 2>&1

}

#####
#
# - __test_variable_readonly
#
# Takes the name of a variable and...
#
# return 0 if it is readonly
# return 1 otherwise
#
# - Paramters
#
# - #1: VARNAME - The name of the variable
#
function __test_variable_readonly() {

    declare __T_TEXT_REGEX_READONLY='^declare -([^\ ]*r[^\ ]*)\ .*'
    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_VARNAME="${@:1:1}"
    fi
    declare __T_RESULT=""
    if __test_variable_exists "${__P_VARNAME}"; then
        if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
            if [[ "${__T_RESULT}" =~ ${__T_TEXT_REGEX_READONLY} ]]; then
                return 0
            fi
        fi
    fi
    return 1
}

#####
#
# - __test_variable_text
#
# Takes __P_VARIABLENAME and tests if it matches the __T_REGEX_TEST regex.
#
# - Paramters
#
# - #1 [MANDATORY]: VARIABLENAME - The name of the variable we test
# - #2 [MANDATORY]: TEST_FOR - What we test for. E.g. 1,true,0,false ...
# - #3: RESULT - If the test is true, then the result will be printed.
#
# Returns 0 on success, >0 on failure.
# Prints RESULT to stdout if given.
#
function __test_variable_text() {

    shopt -s nocasematch

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        local -r __P_VARIABLENAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        local -r __P_TEST_FOR="${@:2:1}"
    fi
    if [[ "${@:3:1}x" == "x" ]]; then
        local -r __P_RESULT=""
    else
        local -r __P_RESULT="${@:3:1}"
    fi

    if __test_variable_exists "${__P_VARIABLENAME}"; then
        true
    else
        return
    fi

    declare __T_REGEX_TEST="${__D_TEXT_REGEX_FALSE}"

    if [[ "${__P_TEST_FOR}" =~ ${__D_TEXT_REGEX_TRUE} ]]; then
        __T_REGEX_TEST="${__D_TEXT_REGEX_TRUE}"
    fi

    if [[ "${!__P_VARIABLENAME}" =~ ${__T_REGEX_TEST} ]]; then
        if [[ "${__P_RESULT}x" != "x" ]]; then
            echo "${__P_RESULT}"
        fi
        return 0
    fi
    return 1
}

#####
#
# - __test_variable_text_true
#
# Takes the name of a variable and tests if its content is true.
#
# This function does NOT test if the content matches the true regex, instead it
# tests if the content DOES NOT match the false regex and then returns 0 (!!!!!!)
#
function __test_variable_text_true() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_variable_exists "${@:1:1}"; then
        declare __P_VARIABLENAME="${@:1:1}"
    else
        declare __P_TEST_VTT_VARIABLECONTENT="${@:1:1}"
        declare __P_VARIABLENAME="__P_TEST_VTT_VARIABLECONTENT"
    fi

    if ! __test_variable_text "${__P_VARIABLENAME}" 0; then
        return 0
    fi
    return 1
}

#####
#
# - __test_variable_text_false
#
# Takes the name of a variable and tests if its content is false.
#
# This function does NOT test if the content matches the false regex, instead it
# tests if the content DOES NOT match the true regex and then returns 0 (!!!!!!)
#
function __test_variable_text_false() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_variable_exists "${@:1:1}"; then
        declare __P_VARIABLENAME="${@:1:1}"
    else
        declare __P_TEST_VTF_VARIABLECONTENT="${@:1:1}"
        declare __P_VARIABLENAME="__P_TEST_VTF_VARIABLECONTENT"
    fi

    if __test_variable_text "${__P_VARIABLENAME}" 0; then
        return 0
    fi
    return 1
}

#####
#
# -- __test_file_access_read_by_user
#
# Takes a USERNAME and FILE and then tests if the file
# can be read by the user. If so return 0, 1 otherwise
#
# - Paramters
#
# - #1: USERNAME - username to test
# - #2: FILE - full path to file to test
#
function __test_file_access_read_by_user() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        local __P_USERNAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        local __P_FILENAME="${@:2:1}"
    fi

    if su - "${__P_USERNAME}" -s /bin/bash -c "[[ -r "${__P_FILENAME}" ]]" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}
