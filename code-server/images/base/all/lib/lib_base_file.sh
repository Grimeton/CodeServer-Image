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

__lib_require "system"
declare -gx __FILE_LOADED=1
declare -gx __FILE_REGEX_PERMISSIONS_DIGIT='^([0-7])$'
declare -gx __FILE_REGEX_PERMISSIONS_POSITION='^[1-4]$'
declare -gx __FILE_REGEX_TEXT_NUMBER='^[0-9]+$'

#####
#
# - __FILE_REGEX_PERMISSIONS_BLOCK
#
# - Description
#   Can be used to match against permissions in octal form. Either three of four digits are supported.
#   Check the BASH_REMATCH explanation.
#
# - BASH_REMATCH
#   - #0 - The whole block
#   - #1 - Special bits, or empty if the mode has only three digits
#   - #2 - Always the mode of the user
#   - #3 - Always the mode of the group
#   - #4 - Always the mode of world
#
declare -gx __FILE_REGEX_PERMISSIONS_BLOCK='^([0-7])?([0-7])([0-7])([0-7])$'

#####
#
# - __file_access
#
# - Description
#   Takes the name of a user, a mode and a file and tests if given file can be accessed in
#   given mode by given user...
#
# - Parameters
#   - #1 [IN|MANDATORY]: USER - The user name or ID of said user. The user MUST exist in the system.
#   - #2 [IN|MANDATORY]: MODE - The mode in which the user should be able to access the file.
#   - #3 [IN|MANDATORY]: FILE - The full path to the file that should be tested.
#
#   - #1 [IN|MANDATORY] USER
#       The name or the UID of the user to be tested with. As this tool runs "su", the user must exist
#       independent if it is given the name or the UID.
#
#   - #2 [IN|MANDATORY]: MODE
#       The mode to test for. One can use the following characters/words to represent certain modes:
#       - READ: 1,r,read
#       - WRITE: 2,w,write
#       - EXECUTE: 4,x,execute
#
#   - # [IN|MANDATORY]: FILE
#       The full path to the file to test for. If the path does NOT start with a slash, the function
#       checks if there is a file available from the current directory and gets its realpath and then
#       tests against that.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#   - >1 on problems.
#
function __file_access() {

    declare __P_USER=""

    if [[ "${@:1:1}x" == "x" ]]; then
        __P_USER="$(id -un)"
    elif __user_name_get "${@:1:1}" __P_USER; then
        true
    else
        return 101
    fi

    if [[ "${@:2:1}" =~ ${__FILE_REGEX_PERMISSIONS_DIGIT} ]]; then
        declare -i __P_MODE=${@:2:1}
    else

        case "${@:2:1}" in
        1 | -r | r | read)
            declare __P_MODE="1"
            ;;
        2 | -w | w | write)
            declare __P_MODE="2"
            ;;
        4 | -x | x | execute)
            declare __P_MODE="4"
            ;;
        *)
            return 111
            ;;
        esac
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 121
    else
        declare __P_FILE="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        declare -i __P_RECURSIVE=0
    elif [[ "${@:4:1}" =~ ${__FILE_REGEX_TEXT_NUMBER} ]]; then

        declare -i __P_RECURSIVE=${@:4:1}
        ((__P_RECURSIVE++)) || true
    else
        declare -i __P_RECURSIVE=1
    fi
    declare -i __T_LOOP_ERROR=0

    if [[ ${__P_RECURSIVE} -eq 0 ]]; then
        declare __F_DIRECTORY=""
        declare -a __F_SUBDIRECTORIES=()
        declare -i __T_DIRECTORY_MODE=0
        declare -A __T_DM=([r]=0 [w]=0 [x]=0)
        declare -i __T_M=${__P_MODE}

        if [[ ${__T_M} -gt 3 ]]; then
            __T_DM[x]=4
            __T_M=$((${__T_M} - 4))
        fi

        if [[ ${__T_M} -gt 1 ]]; then
            __T_DM[w]=2
            __T_M=$((${__T_M} - 2))
        fi

        if [[ ${__T_M} -gt 0 ]]; then
            __T_DM[x]=4
        fi

        for i in r w x; do
            __T_DIRECTORY_MODE=$((${__T_DIRECTORY_MODE} + ${__T_DM[${i}]}))
        done

        unset __T_M __T_DM

        if __F_DIRECTORY="$(dirname "${__P_FILE}")"; then
            IFS="/" read -ra __F_SUBDIRECTORIES <<<"${__F_DIRECTORY}"
            unset IFS

            if [[ "${__F_SUBDIRECTORIES[0]}x" == "x" ]]; then
                declare __T_CURRENT_DIRECTORY="/"
                declare -i __T_CTR=1
            else
                declare __T_CURRENT_DIRECTORY="/"
                declare -i __T_CTR=0
            fi

            while [[ ${__T_CTR} -lt ${#__F_SUBDIRECTORIES[@]} ]]; do
                if __file_access "${__P_USER}" "${__P_MODE}" "${__T_CURRENT_DIRECTORY}" ${__P_RECURSIVE}; then
                    declare __T_OLD_DIRECTORY="${__T_CURRENT_DIRECTORY}"
                    if __T_CURRENT_DIRECTORY="$(realpath -e "${__T_CURRENT_DIRECTORY}/${__F_SUBDIRECTORIES[${__T_CTR}]}" 2>/dev/null)"; then
                        ((__T_CTR++)) || true
                        continue
                    else
                        __T_LOOP_ERROR=$?
                        break
                    fi
                else
                    __T_LOOP_ERROR=$?
                    break
                fi
            done
        else
            declare -i __T_ERROR=$?
            return ${__T_ERROR}
        fi
    fi

    declare __F_UID=""
    declare __F_GID=""
    declare __F_PERM=""
    declare __T_UID=""
    declare __T_GID=""

    if [[ ${__T_LOOP_ERROR} -gt 0 ]]; then
        if [[ "${__P_USER}" == "$(id -un)" ]]; then
            return 1
        else
            if __file_access_su "${__P_USER}" "${__P_PERM}" "${__P_FILE}"; then
                return 0
            else
                return 1
            fi
        fi
    fi

    if __F_UID="$(stat --printf='%u' "${__P_FILE}")"; then
        true
    else
        return 131
    fi

    if __F_GID="$(stat --printf='%g' "${__P_FILE}")"; then
        true
    else
        return 132
    fi

    if __F_PERM="$(stat --printf='%a' "${__P_FILE}")"; then
        true
    else
        return 133
    fi

    if __user_id_get "${__P_USER}" __T_UID; then
        true
    else
        return 141
    fi

    if __user_group_id_get "${__P_USER}" __T_GID; then
        true
    else
        return 142
    fi

    if __file_permissions_allow ${__P_MODE} ${__F_PERM} w; then
        return 0
    fi

    if [[ "${__F_UID}" == "${__T_UID}" ]]; then
        if __file_permissions_allow ${__P_MODE} ${__F_PERM}; then
            return 0
        fi
    fi

    if __user_group_member "${__T_UID}" "${__F_GID}"; then
        if __file_permissions_allow ${__P_MODE} ${__F_PERM} g; then
            return 0
        fi
    fi
    return 1
}
#####
#
# - __file_access_su
#
# - Description
#   Takes the name of a user, a mode and a file and tests if given file can be accessed in
#   given mode by given user by using su. So the script need to run as root, to actually do it.
#
# - Parameters
#   - #1 [IN|MANDATORY]: USER - The user name or ID of said user. The user MUST exist in the system.
#   - #2 [IN|MANDATORY]: MODE - The mode in which the user should be able to access the file.
#   - #3 [IN|MANDATORY]: FILE - The full path to the file that should be tested.
#
#   - #1 [IN|MANDATORY] USER
#       The name or the UID of the user to be tested with. As this tool runs "su", the user must exist
#       independent if it is given the name or the UID.
#
#   - #2 [IN|MANDATORY]: MODE
#       The mode to test for. One can use the following characters/words to represent certain modes:
#       - READ: 1,r,read
#       - WRITE: 2,w,write
#       - EXECUTE: 4,x,execute
#
#   - # [IN|MANDATORY]: FILE
#       The full path to the file to test for. If the path does NOT start with a slash, the function
#       checks if there is a file available from the current directory and gets its realpath and then
#       tests against that.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#   - >1 on problems.
#
function __file_access_su() {

    if __user_exists "${@:1:1}"; then
        declare -p __P_USER="${@:1:1}"
    else
        return 101
    fi

    case "${@:2:1}" in
    1 | -r | r | read)
        declare __P_MODE="-r"
        ;;
    2 | -w | w | write)
        declare __P_MODE="-w"
        ;;
    4 | -x | x | execute)
        declare __P_MODE="-x"
        ;;
    *)
        return 111
        ;;
    esac

    if [[ "${@:3:1}x" == "x" ]]; then
        return 121
    else
        declare __P_FILE="${@:3:1}"
    fi

    if su - "${__P_USER}" -s /bin/bash -c "[[ ${__P_MODE} "${__P_FILE}" ]]" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
    return 254

}

#####
#
# - __file_permissions_allow
#
# - Description
#   Helper function for __file_access. Takes a digit as needle, a digit or a permissions block as haystack and the position in the 
#   permissions block to test against.
#
# - Parameter
#   - #1 [IN|MANDATORY]: NEEDLE
#       The digit of the modes that you want to test for. This digit is composed out of 4,2 and 1. Read chmod's manual to learn more.
#
#   - #2 [IN|MANDATORY]: HAYSTACK
#       The digit of the modes that you want to test in. This can either be a simple digit, like in NEEDLE, or you can hand it a 3 or 4 digit
#       permission block like "755" or "0755".
#
#   - #3 [IN|OPTIONAL]: POSITION
#       This option is only active if HAYSTACK is actually a block of 3 or 4 digits. You can either use the positions 1 to 3 or 1 to 4,
#       or you can use the following characters for the position in the permissions block:
#       - u - User permissions.
#       - g - Group permissions.
#       - w - World/other permissions.
#
#       The function automatically adjusts to 3 or 4 digit blocks. Also, when using a 4 digit block, you can check against the special bits via position 1 in the block.
#
# - Return values
#   - 0 when the permissions allow access.
#   - 1 when the permissions do NOT allow access.
#   - >1 when there was an error along the way.
#
function __file_permissions_allow() {
    if [[ "${@:1:1}" =~ ${__FILE_REGEX_PERMISSIONS_DIGIT} ]]; then
        declare -i __P_NEEDLE=${@:1:1}
    else
        return 101
    fi

    if [[ "${@:2:1}" =~ ${__FILE_REGEX_PERMISSIONS_DIGIT} ]]; then
        declare __PT_HAYSTACK="${@:2:1}"
    elif [[ "${@:2:1}" =~ ${__FILE_REGEX_PERMISSIONS_BLOCK} ]]; then
        declare __PT_HAYSTACK="${@:2:1}"
    else
        return 102
    fi

    if [[ "${@:3:1}" =~ ${__FILE_REGEX_PERMISSIONS_POSITION} ]]; then
        declare -i __P_POSITION=${@:3:1}
        if [[ ${#__PT_HAYSTACK} -eq 3 ]]; then
            if [[ ${__P_POSITION} -lt 4 ]]; then
                __P_POSITION=$((__P_POSITION + 1))
            fi
        fi
    elif [[ "${@:3:1}x" == "x" ]]; then
        declare -i __P_POSITION=2
    else
        case "${@:3:1}" in
        u | user)
            declare -i __P_POSITION=2
            ;;
        g | group)
            declare -i __P_POSITION=3
            ;;
        w | world)
            declare -i __P_POSITION=4
            ;;
        *)
            return 249
            ;;
        esac
    fi

    if [[ "${__PT_HAYSTACK}" =~ ${__FILE_REGEX_PERMISSIONS_DIGIT} ]]; then
        declare -i __P_HAYSTACK=${@:2:1}
        unset __PT_HAYSTACK
    elif [[ "${__PT_HAYSTACK}" =~ ${__FILE_REGEX_PERMISSIONS_BLOCK} ]]; then
        declare -i __P_HAYSTACK=${BASH_REMATCH[${__P_POSITION}]}
        unset __PT_HAYSTACK
    else
        return 103
    fi

    declare -A __T_NEEDLE_ARRAY=()
    declare -A __T_HAYSTACK_ARRAY=()

    if __file_permissions_array ${__P_NEEDLE} __T_NEEDLE_ARRAY; then
        true
    else
        return 111
    fi

    if __file_permissions_array ${__P_HAYSTACK} __T_HAYSTACK_ARRAY; then
        true
    else
        return 112
    fi

    for __T_KEY in "r" "w" "x"; do
        if [[ ${__T_NEEDLE_ARRAY[${__T_KEY}]} -gt ${__T_HAYSTACK_ARRAY[${__T_KEY}]} ]]; then
            return 1
        fi
    done
    return 0
}
#####
#
# - __file_permissions_array
#
# - Description
#   Takes a permission digit, composed of 4,2 and 1 and returns an associative array that contains either
#   the corresponding value of the digit if set, or 0 if not set. This way, you can either iterate over
#   the array and add all the values to get the full permission digit again, or check each digit if it
#   is set or not.
#
#   When you have two of those arrays, one with the permissions you need and one with the permissions
#   you actually got and you find a value in the required array that is bigger than the one in the
#   existing array, you cannot access the file/directory with the permissions you require.
#
# - Parameters
#   - #1 [IN|MANDATORY] - The permission digit to be stripped apart.
#   - #2 [OUT|MANDATORY] - The name of an associative array that should be filled with the results.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __file_permissions_array() {
    if [[ "${@:1:1}" =~ ${__FILE_REGEX_PERMISSIONS_DIGIT} ]]; then
        declare -i __T_PERM=${@:1:1}
    else
        return 101
    fi

    if __aarray_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
    else
        return 102
    fi

    __T_RETURN_VALUE=([r]=0 [w]=0 [x]=0)

    if [[ ${__T_PERM} -gt 3 ]]; then
        __T_RETURN_VALUE[r]=4
        __T_PERM=$((${__T_PERM} - 4))
    fi

    if [[ ${__T_PERM} -gt 1 ]]; then
        __T_RETURN_VALUE[w]=2
        __T_PERM=$((${__T_PERM} - 2))
    fi

    if [[ ${__T_PERM} -gt 0 ]]; then
        __T_RETURN_VALUE[x]=1
    fi
    return 0

}
