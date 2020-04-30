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

function __group_id_get() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_GROUPNAME="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __test_variable_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
    else
        declare __T_RETURN_VALUE=""
    fi
    __T_RETURN_VALUE=""
    declare -a __GINFO=()
    declare __T_RES=""
    if __T_RES="$(getent group "${__P_GROUPNAME}")"; then
        IFS=":" read -ra __GINFO <<<"${__T_RES}"
        if [[ -R __T_RETURN_VALUE ]]; then
            __T_RETURN_VALUE="${__GINFO[2]}"
        else
            echo "${__GINFO[2]}"
        fi
        return 0
    fi
    return 1
}
function __group_add() {

    if [[ "${@}x" == "x" ]]; then
        return 101
    fi
    declare -a __GA_PARAMETERS=()
    OPTIND=1
    while getopts :fg:K:op:rR: __OPTION; do
        case "${__OPTION}" in
        g | K | p | R)
            __GA_PARAMETERS+=("-${__OPTION}" "${OPTARG}")
            ;;
        f | p | r)
            __GA_PARAMETERS+=("-${__OPTION}")
            ;;
        *)
            __log e -- "Option '${OPTARG}' is unknown.\n"
            return 249
            ;;
        esac
    done
    shift $((${OPTIND} - 1))
    if [[ ${#} -lt 1 ]]; then
        __log e -- "Missing group name.\n"
        return 241
    elif [[ ${#} -gt 1 ]]; then
        __log e -- "Too many parameters.\n"
        return 242
    fi
    __GA_PARAMETERS+=("${@:1:1}")
    groupadd "${__GA_PARAMETERS[@]}"

}
function __group_exists() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        getent group "${@:1:1}" >/dev/null 2>&1
    fi
}
function __group_id_exists() {
    __group_exists "${@}"
}
function __group_id_next() {
    declare __GIN_REGEX_GID='^[0-9]{4,5}$'
    declare -i __GIN_GID_DEFAULT=1000
    declare -i __GIN_GID_MIN=1000
    declare -i __GIN_GID_MAX=50000

    if [[ -z ${__D_C_USER_GROUP_ID_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID_REGEX}x" == "x" ]]; then
        true
    else
        declare __GIN_REGEX_NUMBER="${__D_C_USER_GROUP_ID_REGEX}"
    fi

    if [[ -z ${__D_C_USER_GROUP_ID_MIN+x} ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID_MIN}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID_MIN}" =~ ${__GIN_REGEX_GID} ]]; then
        declare -i __GIN_GID_MIN=${__D_C_USER_GROUP_ID_MIN}
    fi

    if [[ -z ${__D_C_USER_GROUP_ID_MAX+x} ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID_MAX}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID_MAX}" =~ ${__GUN_REGEX_GID} ]]; then
        declare -i __GIN_GID_MAX=${__D_C_USER_GROUP_ID_MAX}
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare -i __T_RETURN_VALUE=0
    elif __test_variable_exists "${@:1:1}"; then
        declare -n __T_RETURN_VALUE="${@:1:1}"
    else
        declare -i __T_RETURN_VALUE=0
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        true
    elif [[ "${@:1:1}" =~ ${__GIN_REGEX_GID} ]]; then
        declare -i __GIN_GID_MIN=${@:1:1}
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        true
    elif [[ "${@:2:1}" =~ ${__GIN_REGEX_GID} ]]; then
        declare -i __GIN_GID_MAX=${@:2:1}
    fi

    if [[ -z ${__D_C_USER_GROUP_ID+x} ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_GROUP_ID}" =~ ${__GIN_REGEX_GID} ]]; then
        declare -i __GIN_GID_DEFAULT=${__D_C_USER_GROUP_ID}
    fi

    if [[ ${__GIN_GID_MIN} -gt ${__GIN_GID_MAX} ]]; then
        declare -i __GIN_GID_MIN=${__GIN_GID_MAX}
    fi

    if [[ ${__GIN_GID_MAX} -lt ${__GIN_GID_MIN} ]]; then
        declare -i __GIN_GID_MAX=${__GIN_GID_MIN}
    fi

    if [[ ${__GIN_GID_DEFAULT} -lt ${__GIN_GID_MIN} ]] || [[ ${__GIN_GID_DEFAULT} -gt ${__GIN_GID_MAX} ]]; then
        declare -i __GIN_GID_DEFAULT=$(((${__GIN_GID_MIN} + ${__GIN_GID_MAX}) / 2))
    fi

    declare -i __GIN_GID_NEXT=${__GIN_GID_DEFAULT}

    while read line; do
        if [[ "${line}" =~ ${__GIN_REGEX_GID} ]]; then
            declare -i __T_GID=${line}
            if [[ ${__T_GID} -lt ${__GIN_GID_MIN} ]] || [[ ${__T_GID} -gt ${__GIN_GID_MAX} ]]; then
                continue
            elif [[ ${__T_GID} -gt ${__GIN_GID_NEXT} ]]; then
                __GIN_GID_NEXT=${__T_GID}
            fi
        fi
    done < <(getent group | awk -F ':' '{print $3}' | sort -n)

    while __group_exists ${__GIN_GID_NEXT}; do
        ((__GIN_GID_NEXT++)) || true
    done

    if [[ ${__GIN_GID_NEXT} -ge ${__GIN_GID_MIN} ]] && [[ ${__GIN_GID_NEXT} -le ${__GIN_GID_MAX} ]]; then
        if [[ -R __T_RETURN_VALUE ]]; then
            __T_RETURN_VALUE=${__GIN_GID_NEXT}
        else
            echo "${__GIN_GID_NEXT}"
        fi
        return 0
    else
        return 1
    fi
    return 254

}
function __group_name_exists() {
    __group_exists "${@}"
}
function __group_name_get() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_GROUPID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __test_variable_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
    else
        declare __T_RETURN_VALUE=""
    fi
    __T_RETURN_VALUE=""
    declare __T_RES=""
    declare -a __GINFO=()
    if __T_RES="$(getent group "${__P_GROUPID}")"; then
        IFS=":" read -ra __GINFO <<<"${__T_RES}"
        unset IFS
        if [[ -R __T_RETURN_VALUE ]]; then
            __T_RETURN_VALUE="${__GINFO[0]}"
        else
            echo "${__GINFO[0]}"
        fi
        return 0
    fi

    return 1

}
function __user_add() {

    if [[ "${@}x" == "x" ]]; then
        return 101
    fi
    declare -a __UA_PARAMETERS=()
    OPTIND=1
    while getopts :b:c:d:De:f:g:G:k:K:lmMNop:rR:s:u:UZ: __OPTION; do
        case "${__OPTION}" in
        b | c | d | e | f | g | G | k | K | p | R | s | u | Z)
            __UA_PARAMETERS+=("-${__OPTION}" "${OPTARG}")
            ;;
        D | l | m | M | N | o | r | U)
            __UA_PARAMETERS+=("-${__OPTION}")
            ;;
        "?")
            __log e -- "Option '${OPTARG}' is unknown.\n"
            return 249
            ;;
        esac
    done
    shift $((${OPTIND} - 1))

    if [[ ${#} -lt 1 ]]; then
        __log e -- "Missing username.\n"
        return 241
    elif [[ ${#} -gt 1 ]]; then
        __log e -- "Too many parameters.\n"
        return 242
    fi
    __UA_PARAMETERS+=("${@:1:1}")

    useradd "${__UA_PARAMETERS[@]}"

}
function __user_exists() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        getent passwd "${@:1:1}" >/dev/null 2>&1
    fi

}
function __user_id_exists() {
    __user_exists "${@}"
}
function __user_id_next() {
    declare __UIN_REGEX_UID='^[0-9]{4,5}$'
    declare -i __UIN_UID_DEFAULT=1000
    declare -i __UIN_UID_MIN=1000
    declare -i __UIN_UID_MAX=50000

    if [[ -z ${__D_C_USER_ID_REGEX+x} ]]; then
        true
    elif [[ "${__D_C_USER_ID_REGEX}x" == "x" ]]; then
        true
    else
        declare __UIN_REGEX_NUMBER="${__D_USER_ID_REGEX}"
    fi

    if [[ -z ${__D_C_USER_ID_MIN+x} ]]; then
        true
    elif [[ "${__D_C_USER_ID_MIN}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_ID_MIN}" =~ ${__UIN_REGEX_UID} ]]; then
        declare -i __UIN_UID_MIN=${__D_C_USER_ID_MIN}
    fi

    if [[ -z ${__D_C_USER_ID_MAX+x} ]]; then
        true
    elif [[ "${__D_C_USER_ID_MAX}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_ID_MAX}" =~ ${__GUN_REGEX_UID} ]]; then
        declare -i __UIN_UID_MAX=${__D_C_USER_ID_MAX}
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        declare -i __T_RETURN_VALUE=0
    elif __test_variable_exists "${@:1:1}"; then
        declare -n __T_RETURN_VALUE="${@:1:1}"
    else
        declare -i __T_RETURN_VALUE=0
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        true
    elif [[ "${@:1:1}" =~ ${__UIN_REGEX_UID} ]]; then
        declare -i __UIN_UID_MIN=${@:1:1}
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        true
    elif [[ "${@:2:1}" =~ ${__UIN_REGEX_UID} ]]; then
        declare -i __UIN_UID_MAX=${@:2:1}
    fi

    if [[ -z ${__D_C_USER_ID+x} ]]; then
        true
    elif [[ "${__D_C_USER_ID}x" == "x" ]]; then
        true
    elif [[ "${__D_C_USER_ID}" =~ ${__UIN_REGEX_UID} ]]; then
        declare -i __UIN_UID_DEFAULT=${__D_C_USER_ID}
    fi

    if [[ ${__UIN_UID_MIN} -gt ${__UIN_UID_MAX} ]]; then
        declare -i __UIN_UID_MIN=${__UIN_UID_MAX}
    fi

    if [[ ${__UIN_UID_MAX} -lt ${__UIN_UID_MIN} ]]; then
        declare -i __UIN_UID_MAX=${__UIN_UID_MIN}
    fi

    if [[ ${__UIN_UID_DEFAULT} -lt ${__UIN_UID_MIN} ]] || [[ ${__UIN_UID_DEFAULT} -gt ${__UIN_UID_MAX} ]]; then
        declare -i __UIN_UID_DEFAULT=$(((${__UIN_UID_MIN} + ${__UIN_UID_MAX}) / 2))
    fi

    declare -i __UIN_UID_NEXT=${__UIN_UID_DEFAULT}

    while read line; do
        if [[ "${line}" =~ ${__UIN_REGEX_UID} ]]; then
            declare -i __T_UID=${line}
            if [[ ${__T_UID} -lt ${__UIN_UID_MIN} ]] || [[ ${__T_UID} -gt ${__UIN_UID_MAX} ]]; then
                continue
            elif [[ ${__T_UID} -gt ${__UIN_UID_NEXT} ]]; then
                __UIN_UID_NEXT=${__T_UID}
            fi
        fi
    done < <(getent passwd | awk -F ':' '{print $3}' | sort -n)

    while __user_exists ${__UIN_UID_NEXT}; do
        ((__UIN_UID_NEXT++)) || true
    done

    if [[ ${__UIN_UID_NEXT} -ge ${__UIN_UID_MIN} ]] && [[ ${__UIN_UID_NEXT} -le ${__UIN_UID_MAX} ]]; then
        if [[ -R __T_RETURN_VALUE ]]; then
            __T_RETURN_VALUE=${__UIN_UID_NEXT}
        else
            echo "${__UIN_UID_NEXT}"
        fi
        return 0
    else
        return 1
    fi
    return 254

}
function __user_mod() {
    if [[ "${@}x" == "x" ]]; then
        return 101
    fi

    declare -a __UM_PARAMETERS=()
    OPTIND=1
    while getopts :c:d:e:f:g:G:al:Lmop:R:s:u:Uv:V:w:W:Z: __OPTION; do
        case "${__OPTION}" in
        c | d | e | f | g | G | l | P | R | s | u | v | V | w | W | Z)
            __UM_PARAMETERS+=("-${__OPTION}" "${OPTARG}")
            ;;
        a | L | m | o | U)
            __UM_PARAMETERS+=("-${__OPTION}")
            ;;
        *)
            __log e -- "Option '${OPTARG}' is unknown.\n"
            return 249
            ;;
        esac
    done
    shift $((${OPTIND} - 1))

    if [[ ${#} -lt 1 ]]; then
        __log e -- "Missing username."
        return 241
    elif [[ ${#} -gt 1 ]]; then
        __log e -- "Too many parameters.\n"
        return 242
    fi
    __UM_PARAMETERS+=("${@:1:1}")

    usermod "${__UM_PARAMETERS[@]}"

}
function __user_name_exists() {
    __user_exists "${@}"
}
