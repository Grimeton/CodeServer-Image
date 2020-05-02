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
declare -gx __LOG_LOADED=1

if [[ -z ${__LOG_DEBUG:+x} ]]; then
    declare -gx __LOG_DEBUG=""
else
    declare -gx __LOG_DEBUG
fi

if [[ -z ${__LOG_VERBOSE:+x} ]]; then
    declare -gx __LOG_VERBOSE=""
else
    declare -gx __LOG_VERBOSE
fi

if [[ -n ${__D_TEXT_REGEX_NUMBER+x} ]] && [[ "${__D_TEXT_REGEX_NUMBER}x" != "x" ]]; then
    declare -gx __LOG_TEXT_REGEX_NUMBER="${__D_TEXT_REGEX_NUMBER}"
else
    declare -gx __LOG_TEXT_REGEX_NUMBER='^[0-9]+$'
fi

if [[ -n ${__D__LOG_BANNER_PREFIX+x} ]]; then
    declare -gx __LOG_BANNER_PREFIX="${__D__LOG_BANNER_PREFIX}"
else
    declare -gx __LOG_BANNER_PREFIX="*"
fi

if [[ -n ${__D__LOG_BANNER_CONTENT+x} ]]; then
    declare -gx __LOG_BANNER_CONTENT="${__D__LOG_BANNER_CONTENT}"
else
    declare -gx __LOG_BANNER_CONTENT="*"
fi

if [[ -n ${__D__LOG_BANNER_SUFFIX+x} ]]; then
    declare -gx __LOG_BANNER_SUFFIX="${__D__LOG_BANNER_SUFFIX}"
else
    declare -gx __LOG_BANNER_SUFFIX="*"
fi

if [[ -n ${__D__LOG_BANNER_WIDTH_MAX+x} ]]; then
    if [[ "${__D__LOG_BANNER_WIDTH_MAX}" =~ ${__LOG_TEXT_REGEX_NUMBER} ]]; then
        declare -gix __LOG_BANNER_WIDTH_MAX=${__D__LOG_BANNER_WIDTH_MAX}
    else
        declare -gix __LOG_BANNER_WIDTH_MAX=40
    fi
else
    declare -gix __LOG_BANNER_WIDTH_MAX=40
fi

declare -a __LOG_IMPORT_TERMINAL_COLOURS=(NONE BLACK BLUE BROWN CYAN DARK_GRAY GREEN LIGHT_BLUE LIGHT_CYAN LIGHT_GRAY LIGHT_GREEN LIGHT_PURPLE LIGHT_RED PURPLE RED WHITE YELLOW)
for __T_LOG_COLOUR in "${__LOG_IMPORT_TERMINAL_COLOURS[@]}"; do
    declare __THIS_VARNAME="__LOG_TERMINAL_COLOURS_${__T_LOG_COLOUR}"
    declare __TEST_VARNAME_ANSI="__D_TERMINAL_COLOURS_ANSI_${__T_LOG_COLOUR}"
    declare __TEST_VARNAME_OTHER="__D_TERMINAL_COLOURS_${__T_LOG_COLOUR}"

    # prefer ansi over other
    if __variable_exists "${__TEST_VARNAME_ANSI}"; then
        declare -gx ""${__THIS_VARNAME}"="${!__TEST_VARNAME_ANSI}""
    elif __variable_exists "${__TEST_VARNAME_OTHER}"; then
        declare -gx ""${__THIS_VARNAME}"="${!__TEST_VARNAME_OTHER}""
    else
        declare -gx ""${__THIS_VARNAME}"="""
    fi
done
unset __LOG_IMPORT_TERMINAL_COLOURS
#####
#
# - __log()
#
# Takes a list of paramteres and then logs the output
#
# - Available log levels:
#
# - d | deb | debu | debug - Goes to debug
#   (C_DEBUG or GLOBAL_DEBUG is set, default output: stderr)
#
# - de | derror | debug_error | debug-error - Goes to debug_error
#   (C_DEBUG or GLOBAL_DEBUG is set, default output: stderr)
#
# - e | er | err | erro | error - Goes to error
#   (default output: stderr)
#
# - i | in | inf |info - Goes to info
#   (default output: stdout)
#
# - v | var | variable - Goes to the variable out.
#   This is a special one. It takes a variable's name as the second name and then creates a debug output
#   of the variable and its contents.
#   (C_DEBUG or GLOBAL_DEBUG is set, default output: stderr)
#
# - ver | verb | verbose - Goes to the verbose output
#   (C_VERBOSE or GLOBAL_VERBOSE is set, default output: stdout)
#
# - w | warn | warning  - Goes to the warning output.
#   (default output: stdout)
#
# - Paramters
#
# - #1 [IN|MANDATORY]: LOG_LEVEL - One of the above
# - #2 [IN|MANDATORY]: LOG_INDENT - This is used for indentation. Use "-" for on level, "--" for two level and so on...
# - #3 [IN|MANDATORY]: LOG_MESSAGE - The message to log.
#
# returns 0 on success
# Returns > 0 on failure
#
function __log() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_LOG_LEVEL="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:2:1}"
    fi
    if [[ "${@:3:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:3}"
    fi

    case "${__P_LOG_LEVEL,,}" in
    d | deb | debu | debug)
        __log_debug "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    de | derror | debug_error | debug-error)
        __log_debug_error "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    dw | dwarn | dwarning | debug-w | debug-warn | debug-warning | debug_w | debug_warn | debug_warning)
        __log_debug_warning "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    e | er | err | erro | errror)
        __log_error "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    i | in | inf | info)
        __log_info "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    v | var | variable)
        __log_variable "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    ver | verb | verbose)
        __log_verbose "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    w | warn | warning)
        __log_warning "${__P_LOG_INDENT}" "${__P_LOG_MESSAGE}"
        ;;
    *)
        return 254
        ;;
    esac
}
#####
#
# - __log_banner
#
# - Description
#   Wrapper around __log_banner_start, __log_banner_content, __log_banner_end to create a banner
#   with a single line.
#
# - Parameters
#   - #1 [IN|MANDATORY] LOGLEVEL - One of the log levels described at "__log".
#   - #2 [IN|MANDATORY] INDENT - Indentation level as described at "__log".
#   - #3 [IN|MANDATORY] MESSAGE - The message to be logged.
#
# - Return values
#   - 0 on success.
#   - >0 on failure/problems.
#
function __log_banner() {
    __log_banner_start "${@:1:1}" "${@:2:1}"
    __log_banner_content "${@:1:1}" "${@:2:1}" "" "" "${@:3}"
    __log_banner_end "${@:1:1}" "${@:2:1}"
}
#####
#
# - __log_banner_content
#
# - Description
#   Takes a bunch of parameters and a log message and logs the message as part of a banner to screen.
#
# - Parameters
#   - #1 [IN|MANDATORY]: LOGLEVEL - A log level as described at "__log".
#   - #2 [IN|OPTIONAL]: INDENT - An indentation as described at "__log".
#   - #3 [IN|OPTIONAL]: PREFIX - The character shown at the beginning of the line. Default is "*".
#   - #4 [IN|OPTIONAL]: SUFFIX - The character show at the end of the line. Default is "*".
#   - #5 [IN|OPTIONAL]: LOG_MESSAGE - The message to be logged.
#
# - Return values
#   - 0 on success.
#   - >0 on error.
#
function __log_banner_content() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_C_LOG_LEVEL="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_C_LOG_INDENT=""
    else
        declare __P_C_LOG_INDENT="${@:2:1}"
    fi

    if [[ "${@:3:1}x" != "x" ]]; then
        declare __P_C_PREFIX="${@:3:1}"
    else
        declare __P_C_PREFIX="${__LOG_BANNER_PREFIX}"
    fi

    if [[ "${@:4:1}x" != "x" ]]; then
        declare __P_C_SUFFIX="${@:4:1}"
    else
        declare __P_C_SUFFIX="${__LOG_BANNER_SUFFIX}"
    fi

    if [[ "${@:5}x" == "x" ]]; then
        declare __P_C_LOG_MESSAGE=""
    else
        declare __P_C_LOG_MESSAGE="${@:5}"
    fi

    if [[ -n ${COLUMNS+x} ]]; then
        if [[ "${COLUMNS}" =~ ${__LOG_TEXT_REGEX_NUMBER} ]]; then
            declare -i __T_C_MAX_WIDTH=${COLUMNS}
        else
            declare -i __T_C_MAX_WIDTH=${__LOG_BANNER_WIDTH_MAX}
        fi
    else
        declare -i __T_C_MAX_WIDTH=${__LOG_BANNER_WIDTH_MAX}
    fi

    declare __T_C_INDENT=""
    while [[ ${#__T_C_INDENT} -lt ${#__P_C_LOG_INDENT} ]]; do
        __T_C_INDENT+=" "
    done

    declare __T_C_CONTENT="${__P_C_LOG_MESSAGE}"
    declare __T_C_PREFIX="${__P_C_PREFIX}"
    declare __T_C_SUFFIX="${__P_C_SUFFIX}"
    # PREFIX - SPACE - [CONTENT] - SPACE - SUFFIX
    declare -i __T_C_CONTENT_SIZE_MAX=$((${__T_C_MAX_WIDTH} - ${#__T_C_INDENT} - ${#__T_C_PREFIX} - 1 - 1 - ${#__T_C_SUFFIX}))
    declare __T_C_LAST_SPACE=""
    declare __T_C_T_LAST_SPACE=""
    declare __T_C_C_MSG=""
    declare __T_C_W_MSG="${__P_C_LOG_MESSAGE}"
    # echo "_T_C_W_MSG: ${#__T_C_W_MSG}"
    while [[ ${#__T_C_W_MSG} -gt 0 ]]; do
        __T_C_C_MSG="${__T_C_W_MSG:0:${__T_C_CONTENT_SIZE_MAX}}"
        if [[ ${#__T_C_C_MSG} == ${#__T_C_W_MSG} ]]; then
            __T_C_W_MSG=""
        elif [[ ${#__T_C_C_MSG} -le ${__T_C_CONTENT_SIZE_MAX} ]]; then
            __T_C_W_MSG=""
        else
            if [[ "${__T_C_C_MSG: -1}x" == " x" ]] || [[ "${__T_C_W_MSG:${#__T_C_C_MSG}:1}x" == " x" ]]; then
                __T_C_W_MSG="${__T_C_W_MSG:${#__T_C_C_MSG}}"
            else
                # this is a workaround so that bash is not erroring out
                __T_C_T_LAST_SPACE="${__T_C_C_MSG##* }"
                __T_C_LAST_SPACE=$((${#__T_C_C_MSG} - ${#__T_C_T_LAST_SPACE}))
                if [[ ${#__T_C_C_MSG} -eq ${#__T_C_LAST_SPACE} ]]; then
                    __T_C_W_MSG="${__T_C_W_MSG:${#__T_C_C_MSG}}"
                else
                    __T_C_C_MSG="${__T_C_C_MSG:0:${__T_C_LAST_SPACE}}"
                    __T_C_W_MSG="${__T_C_W_MSG:${#__T_C_C_MSG}}"
                fi
            fi
        fi
        while [[ ${#__T_C_C_MSG} -lt ${__T_C_CONTENT_SIZE_MAX} ]]; do
            __T_C_C_MSG+=" "
        done
        __log "${__P_C_LOG_LEVEL}" "${__P_C_LOG_INDENT}" "${__T_C_PREFIX} ${__T_C_C_MSG} ${__T_C_SUFFIX}\n"
        # echo "__T_C_W_MSG: '${__T_C_W_MSG}' LENGTH: '${#__T_C_W_MSG}'."
    done
}
#####
#
# - __log_banner_end
#
# - Description
#   Simple wrapper around __log_banner_outer to create the footer of the banner. If you want the full
#   blown possibilities, you have to use __log_banner_outer directly.
#
# - Parameters
#   - #1 [IN|MANDATORY] - LOGLEVEL - One of the log levels described at "__log".
#   - #2 [IN|OPTIONAL] - INDENT - The indentation level as described at "__log"
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __log_banner_end() {
    __log_banner_outer "${@:1:1}" "${@:2:1}"
}
#####
#
# - __log_banner_outer
#
# - Description
#   Used to create the header or footer of a banner.
#
# - Parameters
#   - #1 [IN|MANDATORY] - LOGLEVEL - One of the log levels described at "__log".
#   - #2 [IN|OPTIONAL] - INDENT - The indentation level as described at "__log"
#   - #3 [IN|OPTIONAL] - PREFIX - The character that is shown at the left of the printed line. Default is "*".
#   - #4 [IN|OPTIONAL] - CONTENT - The character(s) that is/are used to create the printed line. Default is "*".
#   - #5 [IN|OPTIONAL] - SUFFIX - The character that is show at the right of the printed line. Default is "*".
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __log_banner_outer() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_B_LOG_LEVEL="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_B_LOG_INDENT=""
    else
        declare __P_B_LOG_INDENT="${@:2:1}"
    fi

    if [[ "${@:3:1}x" != "x" ]]; then
        declare __P_B_PREFIX="${@:3:1}"
    else
        declare __P_B_PREFIX="${__LOG_BANNER_PREFIX}"
    fi

    if [[ "${@:4:1}x" != "x" ]]; then
        declare __P_B_CONTENT="${@:4:1}"
    else
        declare __P_B_CONTENT="${__LOG_BANNER_CONTENT}"
    fi

    if [[ "${@:5:1}x" != "x" ]]; then
        declare __P_B_SUFFIX="${@:5:1}"
    else
        declare __P_B_SUFFIX="${__LOG_BANNER_SUFFIX}"
    fi

    if [[ -n ${COLUMNS+x} ]]; then
        if [[ "${COLUMNS}" =~ ${__LOG_TEXT_REGEX_NUMBER} ]]; then
            declare -i __T_BB_MAX_WIDTH=${COLUMNS}
        else
            declare -i __T_BB_MAX_WIDTH=${__LOG_BANNER_WIDTH_MAX}
        fi
    else
        declare -i __T_BB_MAX_WIDTH=${__LOG_BANNER_WIDTH_MAX}
    fi

    declare __T_BB_INDENT=""
    while [[ ${#__T_BB_INDENT} -lt ${#__P_B_LOG_INDENT} ]]; do
        __T_BB_INDENT+=" "
    done
    declare __T_BB_CONTENT="${__P_B_CONTENT}"
    declare __T_BB_PREFIX="${__P_B_PREFIX}"
    declare __T_BB_SUFFIX="${__P_B_SUFFIX}"
    declare -i __T_BB_CONTENT_MAX_LENGTH="$((${__T_BB_MAX_WIDTH} - ${#__T_BB_INDENT} - ${#__T_BB_PREFIX} - ${#__T_BB_SUFFIX}))"
    declare -i __T_BB_CONTENT_MAX_LENGTH_ZERO="$((${__T_BB_CONTENT_MAX_LENGTH} - 1))"

    # in perl: $_T_BANNER_CONTENT="$_T_D_BANNER_BORDER_CONTENT"x"$_T_D_BANNER_CONTENT_LENGTH";
    # in bash:
    while [[ ${#__T_BB_CONTENT} -lt ${__T_BB_CONTENT_MAX_LENGTH} ]]; do
        __T_BB_CONTENT+="${__P_B_CONTENT}"
    done

    if [[ ${#__T_BB_CONTENT} -gt ${__T_BB_CONTENT_MAX_LENGTH} ]]; then
        __T_BB_CONTENT="${__T_BB_CONTENT:0:${__T_BB_CONTENT_MAX_LENGTH_ZERO}}"
    fi
    __log "${__P_B_LOG_LEVEL}" "${__P_B_LOG_INDENT}" "${__T_BB_PREFIX}${__T_BB_CONTENT}${__T_BB_SUFFIX}\n"
}
#####
#
# - __log_banner_start
#
# - Description
#   Simple wrapper around __log_banner_outer to create the header of the banner. If you want the
#   full blown possibilities, you have to use __log_banner_outer directly.
#
# - Parameters
#   - #1 [IN|MANDATORY] - LOGLEVEL - One of the log levels described at "__log".
#   - #2 [IN|OPTIONAL] - INDENT - The indentation level as described at "__log"
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __log_banner_start() {
    __log_banner_outer "${@:1:1}" "${@:2:1}"
}
#####
#
# - __log_debug
#
# - Takes the parameters and prints them to wherever debug output goes.
# - C_DEBUG or GLOBAL_DEBUG must be set and contain a value!
# - Default output: STDERR
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_debug() {

    if ([[ -z ${__LOG_DEBUG+x} ]] || [[ "${__LOG_DEBUG}x" == "x" ]]); then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi

    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    declare __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__P_LOG_MESSAGE}"
    declare __TP_LOG_MESSAGE="${__P_LOG_MESSAGE}"
    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __TP_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__TP_LOG_MESSAGE}"
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "DEBUG" "${__P_LOG_INDENT}" "${__TP_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_LIGHT_PURPLE} ${__P_LOG_INDENT} DEBUG: ${__T_LOG_MESSAGE}"

}
#####
#
# - __log_debug_error
#
# - Takes the parameters and prints them to wherever debug-error output goes.
# - C_DEBUG or GLOBAL_DEBUG must be set and contain a value!
# - Default output: STDERR
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_debug_error() {

    if ([[ -z ${__LOG_DEBUG+x} ]] || [[ "${__LOG_DEBUG}x" == "x" ]]); then
        return 0
    fi
    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi
    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    declare __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__P_LOG_MESSAGE}"

    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "DEBUG_ERROR" "${__P_LOG_INDENT}" "${__T_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_PURPLE} ${__P_LOG_INDENT} DEBUG-ERROR: ${__T_LOG_MESSAGE}"

}
#####
#
# - __log_debug_warning
#
# - Takes the parameters and prints them to wherever debug-error output goes.
# - C_DEBUG or GLOBAL_DEBUG must be set and contain a value!
# - Default output: STDERR
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_debug_warning() {

    if ([[ -z ${__LOG_DEBUG+x} ]] || [[ "${__LOG_DEBUG}x" == "x" ]]); then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi
    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    declare __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__P_LOG_MESSAGE}"

    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "DEBUG_WARNING" "${__P_LOG_INDENT}" "${__T_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_YELLOW} ${__P_LOG_INDENT} DEBUG-WARN: ${__T_LOG_MESSAGE}"

}
#####
#
# - __log_error
#
# - Takes the parameters and prints them to wherever error output goes
# - Default output: STDERR
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_error() {

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi

    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    declare __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__P_LOG_MESSAGE}"
    declare __TP_LOG_MESSAGE="${__P_LOG_MESSAGE}"
    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __TP_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__TP_LOG_MESSAGE}"
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "ERROR" "${__P_LOG_INDENT}" "${__TP_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_LIGHT_RED} ${__P_LOG_INDENT} ERROR: ${__T_LOG_MESSAGE}"

}
#####
#
# - __log_info
#
# - Takes the parameters and prints the them to wherever info output goes
# - Default output: STDOUT
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_info() {

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi
    declare __TP_LOG_MESSAGE="${__P_LOG_MESSAGE}"
    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __TP_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__TP_LOG_MESSAGE}"
    fi

    __log__write "INFO" "${__P_LOG_INDENT}" "${__TP_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE} ${__P_LOG_INDENT} INFO: ${__TP_LOG_MESSAGE}"
}
#####
#
# - __log_stdin
#
# - Description
#   Function that reads from stdin and prints it to the log level it got handed when called.
#
# - Example
#   Let's say you run tar and want it's output only to be visible when debug is enabled.
#
#   # tar cvf /some/file /some/directory  2>&1 | __log_stdin d --
#
#   Tar will create a tarball and print its information to stderr. By redirecting stderr to stdout and then
#   piping it to the function, the information will only be printed/shown on the screen/in log files, if debugging is enabled.
#
# - Parameters
#   - #1 [IN|MANDATORY]: LOG_LEVEL - On of the log levels described at "__log".
#   - #2 [IN|OPTIONAL]: LOG_INDENT - An indentation level as described at "__log".
#
# - Return values
#   - 0 on succcess.
#   - >0 on error.
#
function __log_stdin() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_LOG_LEVEL="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:2:1}"
    fi

    while IFS= read line; do
        __log "${__P_LOG_LEVEL}" "${__P_LOG_INDENT}" "${line}\n"
    done

}
#####
#
# - __log_variable
#
# - Takes the parameters below, and prints debug output of the variable to wherever you think that should go
# - C_DEBUG or GLOBAL_DEBUG must be set and contain a value!
# - Default output: STDERR
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|MANDATORY]: VARIABLE - THIS IS THE NAME OF THE VARIABLE TO BE DEBUGGED !!!!!!
#
# Returns 0 on success
# Returns >0 on error
#
function __log_variable() {

    if ([[ -z ${__LOG_DEBUG+x} ]] || [[ "${__LOG_DEBUG}x" == "x" ]]); then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    elif __variable_exists "${@:2:1}"; then
        declare __P_VARNAME="${@:2:1}"
    else
        return 104
    fi

    if [[ -R "${__P_VARNAME}" ]]; then
        declare __T_TEST_VARNAME="$(declare -p "${__P_VARNAME}" | sed -E 's/^declare[^\"]+"([^\"]+).*$/\1/g')"
        declare __T_VARIABLE_NAME="('${__P_VARNAME}':('${__T_TEST_VARNAME}'))"
        declare __T_VARIABLE_TYPE="('n':"
    else
        declare __T_TEST_VARNAME="${__P_VARNAME}"
        declare __T_VARIABLE_NAME="('${__P_VARNAME}')"
        declare __T_VARIABLE_TYPE="("
    fi

    declare __T_VARIABLE_TYPE_DECLARE="$(declare -p "${__T_TEST_VARNAME}" 2>/dev/null)"
    declare __T_REGEX_VARIABLE_TYPE='^declare\ -([-|a-z|A-Z]+).*$'

    if [[ "${__T_VARIABLE_TYPE_DECLARE}" =~ ${__T_REGEX_VARIABLE_TYPE} ]]; then
        __T_VARIABLE_TYPE+="('${BASH_REMATCH[1]}'))"
    else
        return 103
    fi

    declare __T_VARIABLE_VALUE=""
    if __array_exists "${__T_TEST_VARNAME}"; then
        __T_VARIABLE_VALUE="$(declare -p "${__T_TEST_VARNAME}" | sed -E 's/^([^=]+)=(.*)$/\2/g')"
    elif __aarray_exists "${__T_TEST_VARNAME}"; then
        __T_VARIABLE_VALUE="$(declare -p "${__T_TEST_VARNAME}" | sed -E 's/^([^=]+)=(.*)$/\2/g')"
    elif __variable_exists "${__T_TEST_VARNAME}"; then
        __T_VARIABLE_VALUE="${!__T_TEST_VARNAME}"
    else
        return 11
    fi
    declare __T_LOG_MESSAGE="Name: '${__T_VARIABLE_NAME}' Type: '${__T_VARIABLE_TYPE}' - Value: '${__T_VARIABLE_VALUE}'"
    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__T_LOG_MESSAGE}"
    __T_LOG_MESSAGE+="\n"

    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "VARIABLE_DEBUG" "${__P_LOG_INDENT}" "${__T_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_LIGHT_CYAN} ${__P_LOG_INDENT} VARIABLE-DEBUG: ${__T_LOG_MESSAGE}"

}
#####
#
# - __log_verbose
#
# - Takes the parameters and prints them to wherever you think verbosity should go
# - C_VERBOSE or GLOBAL_VERBOSE must be set and contain a value!
# - Default output: STDOUT
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_verbose() {

    if ([[ -z ${__LOG_VERBOSE+x} ]] || [[ "${__LOG_VERBOSE}x" == "x" ]]); then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi

    declare __T_F_CTR=1
    declare __T_F_REGEX='^__log.*$'
    while [[ "${FUNCNAME[${__T_F_CTR}]}" =~ ${__T_F_REGEX} ]]; do
        ((__T_F_CTR++))
    done
    declare __T_FUNCNAME="${FUNCNAME[${__T_F_CTR}]}"
    declare __T_LOG_MESSAGE="'${__T_FUNCNAME}': ${__P_LOG_MESSAGE}"

    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __T_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__T_LOG_MESSAGE}"
    fi

    __log__write "VERBOSE" "${__P_LOG_INDENT}" "${__T_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_LIGHT_BLUE} ${__P_LOG_INDENT} VERBOSE: ${__T_LOG_MESSAGE}"
}
#####
#
# - __log_warning
#
# - Takes the parameters and prints them to wherever warning output goes
#
# - Default output: STDOUT
#
# - Parameters
#
# - #1 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #2 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log_warning() {
    if [[ "${@:1:1}x" == "x" ]]; then
        declare __P_LOG_INDENT=""
    else
        declare __P_LOG_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_LOG_MESSAGE=""
    else
        declare __P_LOG_MESSAGE="${@:2}"
    fi

    declare __TP_LOG_MESSAGE="${__P_LOG_MESSAGE}"
    if [[ -z ${__LOG_STAGE_CURRENT+x} ]]; then
        true
    elif [[ "${__LOG_STAGE_CURRENT}x" == "x" ]]; then
        true
    else
        __TP_LOG_MESSAGE="(STAGE:${__LOG_STAGE_CURRENT}) ${__TP_LOG_MESSAGE}"
    fi

    __log__write "WARNING" "${__P_LOG_INDENT}" "${__TP_LOG_MESSAGE}"
    __log__print "${__LOG_TERMINAL_COLOURS_NONE}${__LOG_TERMINAL_COLOURS_YELLOW} ${__P_LOG_INDENT} WARNING: ${__TP_LOG_MESSAGE}"
}
#####
#
# - __log__print (two underscores)
#
# - This function takes the parameters and then prints the data to wherever you think it should go.
#   It is basically the output switch. It checks for the functionname it was called from and then
#   decides where data should go.
#
# - If you do not want log output on the terminal, just overwrite this function to something
#   else. The most simple way would be:
#
#   function __log__print() { return 0; }
#
# - The setup so far:
#
# - STDERR: __log_debug __log_debug_error __log_error __log_variable
# - STDOUT: __log_info __log_verbose __log_warnig
#
# - Parameters
#
# - #1 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log__print() {

    declare __P_MESSAGE="${@}${__LOG_TERMINAL_COLOURS_NONE}"
    declare __T_CALLER="${FUNCNAME[1]}"

    case "${__T_CALLER}" in
    __log_info | __log_verbose | __log_warning)
        printf '%b' "${__P_MESSAGE}${__LOG_TERMINAL_COLOURS_NONE}" >&1
        ;;
    __log_debug | __log_debug_error | __log_error | __log_variable)
        printf '%b' "${__P_MESSAGE}${__LOG_TERMINAL_COLOURS_NONE}" >&2
        ;;
    *)
        return 254
        ;;
    esac
}
#####
#
# - __log__write (two underscores)
#
# - Takes the parameters and writes them to wherever you see fit. So far this function
#   only returns 0. If you want to write to a file, overwrite this function and use it
#   to store the log information in whatever format you like.
#
# - Parameters
#
# - #1 [IN|MANDATORY]: LEVEL - The log level in upper case letters and dashes replaced by underscores.
# - #2 [IN|MANDATORY]: INDENT - The level of indentation like "-" for one, "--" for two and so on...
# - #3 [IN|OPTIONAL]: MESSAGE - The message to be logged.
#
# Returns 0 on success
# Returns >0 on error
#
function __log__write() {
    return 0
}
