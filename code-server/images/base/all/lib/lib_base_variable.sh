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
declare -gx __VARIABLE_LOADED=1
declare -gix __VARIABLE_NAME_RANDOM_LENGTH_DEFAULT=10
declare -gx __VARIABLE_REGEX_CHARACTERS_VALID='^[a-zA-Z0-9_]+$'
declare -gx __VARIABLE_REGEX_MODE_EXPORT='^declare -([^\ ]*x[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_MODE_LOWERCASE='^declare -([^\ ]*l[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_MODE_READONLY='^declare -([^\ ]*r[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_MODE_TRACE='^declare -([^\ ]*t[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_MODE_UPPERCASE='^declare -([^\ ]*u[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_NUMBER='^[0-9]+$'
declare -gx __VARIABLE_REGEX_TYPE_ARRAY='^declare -([^\ ]*a[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_TYPE_AARRAY='^declare -([^\ ]*A[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_TYPE_INTEGER='^declare -([^\ ]*i[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_TYPE_NAMEREF='^declare -([^\ ]*n[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_TYPE_STRING='^declare -([^\ ]*\-[^\ ]*)\ .*'
declare -gx __VARIABLE_REGEX_TYPES='^declare\ -([lrtux]+)?([aAin\-])([lrtux]+)?\ .*'
declare -gx __VARIABLE_REGEX_TEXT_TRUE='^(1|any|enable|enabled|true|yes)$'
declare -gx __VARIABLE_REGEX_TEXT_FALSE='^(0|disable|disabled|false|no|none)$'

if [[ -n ${__D_TEXT_REGEX_TRUE:+x} ]]; then
    __VARIABLE_REGEX_TEXT_TRUE="${__D_TEXT_REGEX_TRUE}"
fi

if [[ -n ${__D_TEXT_REGEX_FALSE:+x} ]]; then
    __VARIABLE_REGEX_TEXT_FALSE="${__D_TEXT_REGEX_FALSE}"
fi

#####
#
# - __variable_aarray
#
# - Description
#   Alias to __variable_type_aarray
#
function __variable_aarray() {
    __variable_type_aarray "${@}"
}
#####
#
# - __variable_array
#
# - Description
#   Alias to __variable_type_array
#
function __variable_array() {
    __variable_type_array "${@}"
}
#####
#
# - __variable_empty
#
# - Description
#   Takes the name of a variable and tests if it is empty. A not existing variable is NOT empty.
#   Accepts arrays, associative arrays, integers, namerefs and "normal|string" variables.
#   Namerefs and integers CANNOT be empty. A nameref would be invalid, an integer would be "0".
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test
#
# - Return values
#   - 0 when empty.
#   - 1 when not empty.
#   - >1 when error.
#
function __variable_empty() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_VAR_TYPE=""
    if __variable_type "${__P_VARNAME}" __T_VAR_TYPE; then
        case "${__T_VAR_TYPE}" in
        a)
            declare -n __T_DUMMY="${__P_VARNAME}"
            if [[ ${#__T_DUMMY[@]} -lt 1 ]]; then
                return 0
            else
                return 1
            fi
            ;;
        A)
            declare -n __T_DUMMY="${__P_VARNAME}"
            if [[ ${#__T_DUMMY[@]} -lt 1 ]]; then
                return 0
            else
                return 1
            fi
            ;;
        f)
            return 1
            ;;
        i)
            return 1
            ;;

        n)
            return 1
            ;;

        s)
            if [[ "${!__P_VARNAME}x" == "x" ]]; then
                return 0
            else
                return 1
            fi
            ;;
        esac
    fi
    return 254
}
#####
#
# - __variable_exists
#
# - Description
#   Takes the name of a variable and tests if exists.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test
#
# - Return values
#   - 0 when exists.
#   - 1 when doesn't exist.
#   - >1 on error.
#
function __variable_exists() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    if declare -p "${__P_VARNAME}" >/dev/null 2>&1; then
        return 0
    else
        declare __T_RESULT=""
        if __T_RESULT="$(type -t "${__P_VARNAME}" 2>/dev/null)"; then
            if [[ "${__T_RESULT}" == "function" ]]; then
                return 0
            else
                return 1
            fi
        else
            return 1
        fi
    fi
    return 254

}
#####
#
# - __variable_export
#
# - Description
#   Alias of __variable_mode_export
#
function __variable_export() {
    __variable_mode_export "${@}"
}
#####
#
# - __variable_function
#
# - Description
#   Alias of __variable_type_function
#
function __variable_function() {
    __variable_type_function "${@}"
}
#####
#
# - __variable_integer
#
# - Description
#   Alias of __variable_type_integer
#
function __variable_integer() {
    __variable_type_integer "${@}"
}
#####
#
# - __variable_lowercase
#
# - Description
#   Alias of __variable_mode_lowercase
#
function __variable_lowercase() {
    __variable_mode_lowercase "${@}"
}
#####
#
# - __variable_mode_export
#
# - Description
#   Takes the name of a variable and checks if it is exported via the "-x" flag of declare.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_mode_export() {

    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_MODE_EXPORT} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi

    return 254

}
#####
#
# - __variable_mode_lowercase
#
# - Description
#   Takes the name of a variable and checks if it is in lower case mode via the "-l" flag of declare.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_mode_lowercase() {

    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_MODE_LOWERCASE} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254

}
#####
#
# - __variable_mode_readonly
#
# - Description
#   Takes the name of a variable and checks if it is set to readonly via "-r" option of declare.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_mode_readonly() {

    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_MODE_READONLY} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254

}
#####
#
# - __variable_mode_trace
#
# - Description
#   Takes the name of a variable and checks if it is set to trace mode via "-t" option of declare.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_mode_trace() {

    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_MODE_TRACE} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254

}
#####
#
# - __variable_mode_uppercase
#
# - Description
#   Takes the name of a variable and checks if it is set to uppercase mode via "-u" option of declare.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_mode_uppercase() {

    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_MODE_UPPERCASE} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254

}
#####
#
# - __variable_name_random
#
# - Description
#   Takes a prefix and a wanted length and generates a random variable name.
#
# - Parameters
#   - #1 [IN|OPTIONAL]: PREFIX - The wanted prefix of the variable.
#   - #2 [IN|OPTIONAL]: LENGTH - The total length of the new variable.
#   - #3 [OUT|OPTIONAL]: RETURN_VALUE - The name of an existing variable to be filled with the result.
#
# - Return values
#   - 0 on success
#   - >0 on failure.
#
function __variable_name_random() {

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_PREFIX=""
    elif [[ "${@:1:1}" =~ ${__VARIABLE_REGEX_CHARACTERS_VALID} ]]; then
        declare __P_PREFIX="${@:1:1}"
    else
        return 101
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare -i __P_LENGTH=${__VARIABLE_NAME_RANDOM_LENGTH_DEFAULT}
    elif [[ "${@:2:1}x" =~ ${__VARIABLE_REGEX_NUMBER} ]]; then
        declare -i __P_LENGTH=${@:2:1}
    else
        declare -i __P_LENGTH=${__VARIABLE_NAME_RANDOM_LENGTH_DEFAULT}
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE_DUMMY=""
        declare -n __T_RETURN_VALUE="__T_RETURN_VALUE_DUMMY"
    elif __variable_exists "${@:3:1}"; then
        declare -n __T_RETURN_VALUE="${@:3:1}"
    else
        declare __T_RETURN_VALUE_DUMMY=""
        declare -n __T_RETURN_VALUE="__T_RETURN_VALUE_DUMMY"
    fi
    __T_RETURN_VALUE=""

    declare -i __T_LENGTH_RANDOM=$(($__P_LENGTH - ${#__P_PREFIX}))

    if [[ ${__T_LENGTH_RANDOM} -lt 1 ]]; then
        return 111
    fi

    __T_RETURN_VALUE="${__P_PREFIX}"
    __T_RETURN_VALUE+="$(cat /dev/urandom | tr -dc 'A-Z0-9_' | fold -w "${__T_LENGTH_RANDOM}" | head -n 1)"

    while __variable_exists "${__T_RETURN_VALUE}"; do
        __variable_name_random "${__P_PREFIX}" "${__P_LENGTH}" "${!__T_RETURN_VALUE}"
    done

    if [[ "${!__T_RETURN_VALUE}" == "__T_RETURN_VALUE_DUMMY" ]]; then
        echo "${__T_RETURN_VALUE}"
    fi
    return 0
}
#####
#
# - __variable_nameref
#
# - Description
#   Alias to __variable_type_nameref
#
function __variable_nameref() {
    __variable_type_nameref "${@}"
}
#####
#
# - __variable_readonly
#
# - Description
#   Alias to __variable_mode_readonly
#
function __variable_readonly() {
    __variable_mode_readonly "${@}"
}
#####
#
# - __variable_string
#
# - Description
#   Alias to __variable_type_string
#
function __variable_string() {
    __variable_type_string "${@}"
}
#####
#
# - __variable_text
#
# - Description
#   Takes the name of a variable, the test condition and tests for it.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#   - #2 [IN|OPTIONAL|DEFAULT:1]: TESTCONDITION - Is tested against __VARIABLE_REGEX_TEXT_TRUE
#                                   and __VARIABLE_REGEX_TEXT_FALSE. The one it matches against
#                                   will be used.
#
# - Return values
#   - 0 when match.
#   - 1 when no match.
#   - >1 when error.
#
function __variable_text() {
    if ! __variable_type_string "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi
    declare __P_TESTREGEX="${__VARIABLE_REGEX_TEXT_TRUE}"

    if [[ "${@:2:1}x" == "x" ]]; then
        true
    else
        declare -a __T_REGEXES=()
        IFS=$'\n' __T_REGEXES=($(set | grep -E '^__VARIABLE_REGEX_TEXT.*=.*' | awk -F '=' '{print $1}'))
        unset IFS

        if [[ ${#__T_REGEXES[@]} -lt 1 ]]; then
            return 253
        fi
        for __T_REGEX in "${__T_REGEXES[@]}"; do
            if [[ "${@:2:1}" =~ ${!__T_REGEX} ]]; then
                __P_TESTREGEX="${!__T_REGEX}"
            fi
        done
    fi

    shopt -s nocasematch

    if [[ "${!__P_VARNAME}" =~ ${__P_TESTREGEX} ]]; then
        return 0
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_trace
#
# - Description
#   Alias to __variable_mode_trace
#
function __variable_trace() {
    __variable_mode_trace "${@}"
}
#####
#
# - __variable_type_aarray
#
# - Description
#   Takes the name of a variable and checks if it is an associative array.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_aarray() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPE_AARRAY} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_type_array
#
# - Description
#   Takes the name of a variable and checks if it is an array.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_array() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPE_ARRAY} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_type_function
#
# - Description
#   Takes the name of a variable and checks if it is a function. This may seem odd in here, but
#   bash's declare has the "-f" option, which brings the function stuff into this space.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_function() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    if declare -fp "${__P_VARNAME}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi

    return 254
}
#####
#
# - __variable_type_integer
#
# - Description
#   Takes the name of a variable and checks if it is an integer.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_integer() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPE_INTEGER} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_type_nameref
#
# - Description
#   Takes the name of a variable and checks if it is a nameref.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_nameref() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPE_NAMEREF} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_type_string
#
# - Description
#   Takes the name of a variable and checks if it is just a variable.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#
# - Result values
#   - 0 when true
#   - 1 when false
#   - >1 when error.
#
function __variable_type_string() {
    if ! __variable_exists "${@:1:1}"; then
        return 101
    else
        declare __P_VARNAME="${@:1:1}"
    fi

    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPE_STRING} ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __variable_type
#
# - Description
#   Takes the name of a variable and returns it's type in form of a character that matches declare's option.
#
# - Parameters
#   - #1 [IN|MANDATORY]: VARNAME - The name of the variable to test.
#   - #2 [OUT|OPTIONAL]: RETURN_VALUE - The name of an existing variable to be filled with the type information.
#
# - Result values
#   - 0 on success.
#   - >0 on failure.
#
function __variable_type() {
    if __variable_exists "${@:1:1}"; then
        declare __P_VARNAME="${@:1:1}"
    else
        return 101
    fi

    if __variable_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
        __T_RETURN_VALUE=""
    else
        declare __T_RETURN_VALUE=""
    fi
    declare __T_RESULT=""
    if __T_RESULT="$(declare -p "${__P_VARNAME}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__VARIABLE_REGEX_TYPES} ]]; then
            __T_RETURN_VALUE="${BASH_REMATCH[2]}"
        fi
    elif declare -fp "${__P_VARNAME}" >/dev/null 2>&1; then
        __T_RETURN_VALUE="f"
    fi

    if [[ "${__T_RETURN_VALUE}x" != "x" ]]; then
        if [[ "${__T_RETURN_VALUE}" == "-" ]]; then
            __T_RETURN_VALUE="s"
        fi
        if [[ ! -R __T_RETURN_VALUE ]]; then
            echo "${__T_RETURN_VALUE}"
        fi
        return 0
    else
        return 1
    fi

    return 254
}
####
#
# - __variable_uppercase
#
# - Description
#   Alias to __variable_mode_uppercase
#
function __variable_uppercase() {
    __variable_mode_uppercase "${@}"
}
