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
function __pm_cache_clean() {

    rm -rvf /var/cache/apk/*
}
function __pm_cache_update() {

    __log_banner i -- "BEGIN: Update Cache..."
    if apk update; then
        __log_banner i -- "END: Update Cache..."
    else
        declare -i __T_ERROR=$?
        __log_banner e -- "END: Update Cache (${__T_ERROR})..."
        return ${__T_ERROR}
    fi
}
function __pm_exists() {

    if [[ -z ${__PM_INIT_ERROR+x} ]]; then
        true
    elif [[ "${__PM_INIT_ERROR}x" == "x" ]]; then
        true
    else
        return 101
    fi

    if [[ -z ${PM_INIT+x} ]]; then
        return 102
    elif [[ "${PM_INIT}x" == "x" ]]; then
        return 103
    else
        return 0
    fi
    return 254
}
function __pm_init() {

    declare -a __T_COMMANDS=(apk)

    for __T_COMMAND in "${__T_COMMANDS[@]}"; do
        if which "${__T_COMMAND}" >/dev/null 2>&1; then
            true
        else
            __T_ERROR=$?
            __log e -- "(PM) Cannot find '${__T__COMMAND}'"
            exit ${__T_ERROR}
        fi
    done
    if __pm_package_aliases_load; then
        true
    fi
    declare -gx __PM_INIT=1
    return 0
}
function __pm_package_file_install() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ -f "${@:1:1}" ]]; then
        declare __P_FILE="${@:1:1}"
    fi

    apk add --allow-untrusted "${__P_FILE}" 2>&1 | __log_stdin d --

    for __T_PS in ${PIPESTATUS[@]}; do
        if [[ ${__T_PS} -ne 0 ]]; then
            return ${__T_PS}
        fi
    done

    return 0

}
function __pm_package_available() {

    if __array_exists "${@:1:1}"; then
        declare -n __T_PMPIA_RETURN_ARRAY="${@:1:1}"
        declare -a __P_PACKAGES=("${@:2}")
    else
        declare -a __T_PMPIA_RETURN_ARRAY=()
        declare -a __P_PACKAGES=("${@:1}")
    fi

    if [[ ${#__P_PACKAGES[@]} -gt 0 ]]; then
        for __T_PACKAGE in "${__P_PACKAGES[@]}"; do
            unset __T_RESULT
            declare __T_RESULT=""
            if __T_RESULT="$(apk search -x "${__T_PACKAGE}" | wc -l)"; then
                if [[ "${__T_RESULT}" == "1" ]]; then
                    __T_PMPIA_RETURN_ARRAY+=("${__T_PACKAGE}")
                fi
            fi
        done
        unset __T_RESULT
    fi

    if [[ ${#__T_PMPIA_RETURN_ARRAY[@]} -gt 0 ]]; then
        if [[ ! -R __T_PMPIA_RETURN_ARRAY ]]; then
            echo "${__T_PMPIA_RETURN_ARRAY[@]}"
        fi
        return 0
    fi

    return 1

}
function __pm_package_install() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_PACKAGES=("${@}")
    fi
    if __pm_ready; then
        true
    else
        __log e -- "COULD NOT INITIALIZE PACKAGE MANAGER. NEEDED. RETURNING ($?).\n"
        return 231
    fi
    declare -a __T_PACKAGES=()
    IFS=$'\n' __T_PACKAGES=($(sort -u <<<"${__P_PACKAGES[*]}"))
    unset IFS
    declare -a __T_PI_PACKAGES_TO_INSTALL=()
    declare -i __T_RETURN_VALUE=1
    if __pm_package_install_needed __T_PI_PACKAGES_TO_INSTALL "${__T_PACKAGES[@]}"; then
        __log_banner i -- "BEGIN: apk add --no-cache"
        __log d -- "Command: apk add --no-cache "${__T_PI_PACKAGES_TO_INSTALL[@]}"\n"
        __log i -- "Generating package list...\n"
        if apk add --no-cache "${__T_PI_PACKAGES_TO_INSTALL[@]}"; then
            __T_RETURN_VALUE=0
        else
            __T_RETURN_VALUE=2
        fi
        __log_banner i -- "END: apk add --no-cache"
    else
        __T_RETURN_VALUE=0
    fi
    return ${__T_RETURN_VALUE}
}
function __pm_package_aliases_alias_add() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_PACKAGENAME="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_PACKAGEALIAS="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare __P_PACKAGEREPO=":"
    else
        declare __P_PACKAGEREPO="${@:3:1}"
    fi

    __T_ALIAS="${__P_PACKAGENAME}:${__P_PACKAGEALIAS}:${__P_PACKAGEREPO}"

    __pm_package_aliases_add "${__T_ALIAS}"
    return
}
function __pm_package_aliases_alias_get() {

    if __array_exists "${@:1:1}"; then
        declare -n __T_W_ARRAY="${@:1:1}"
    else
        declare -a __T_W_ARRAY=()
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_PACKAGENAME="${@:2:1}"
    fi

    if [[ -z ${__PM_ALIAS_PACKAGENAMES[@]+x} ]]; then
        return 111
    fi

    if ! __array_contains __PM_ALIAS_PACKAGENAMES "${__P_PACKAGENAME}"; then
        return 121
    fi

    if [[ -z ${__PM_ALIAS_DEFINITIONS[@]+x} ]]; then
        return 112
    fi

    for __T_ALIAS_DEFINITION in "${__PM_ALIAS_DEFINITIONS[@]}"; do
        IFS=":" read -ra __T_AD <<<"${__T_ALIAS_DEFINITION}"
        if [[ ${#__T_AD[@]} -ne 3 ]]; then
            return 131
        fi

        if [[ "${__T_AD[0]}" == "${__P_PACKAGENAME}" ]]; then
            __T_W_ARRAY=("${__T_AD[@]}")

            if [[ ! -R __T_W_ARRAY ]]; then
                echo "${__T_W_ARRAY[@]}"
            fi
            return 0
        fi
    done
}
function __pm_package_aliases_check() {

    if __array_exists "${@:1:1}"; then
        declare -n __T_PACKAGES="${@:1:1}"
    else
        return 101
    fi
    if __array_exists "${@:2:1}"; then
        declare -n __T_REPOS_INSTALL="${@:2:1}"
    else
        return 102
    fi

    if __array_exists __PM_ALIAS_PACKAGENAMES; then
        true
    else
        return 11
    fi

    if [[ ${#__T_PACKAGES[@]} -lt 1 ]]; then
        return 0
    fi
    declare -a __T_PMPAC_ARRAY=()
    declare -a __T_TEMP_ARRAY=()
    declare -a __T_WW_P_ARRAY=()

    # we have to work around the fact that we're going to change __T_PACKAGES
    # and that cannot be done while iterating it...

    for __T_PACKAGE in "${__T_PACKAGES[@]}"; do
        if __array_contains __PM_ALIAS_PACKAGENAMES "${__T_PACKAGE}"; then
            __T_WW_P_ARRAY+=("${__T_PACKAGE}")
        fi
    done

    if [[ ${#__T_WW_P_ARRAY[@]} -gt 0 ]]; then
        for __T_W_P in "${__T_WW_P_ARRAY[@]}"; do
            declare -a __T_W_P_ALIAS=()
            if __pm_package_aliases_alias_get __T_W_P_ALIAS "${__T_W_P}"; then
                for __T_PACKAGE in "${__T_PACKAGES[@]}"; do
                    if [[ "${__T_W_P}" == "${__T_PACKAGE}" ]]; then
                        __T_TEMP_ARRAY+=("${__T_W_P_ALIAS[1]}")
                        __T_REPOS_INSTALL+=("${__T_W_P_ALIAS[2]}")
                    else
                        __T_TEMP_ARRAY+=("${__T_PACKAGE}")
                    fi
                done
                __T_PACKAGES=("${__T_TEMP_ARRAY[@]}")
            else
                __log e -- "Could not get an alias definition for '${__T_W_P}' but it exists in the alias package names...\n"
            fi
        done
    fi
    return 0
}
function __pm_package_aliases_load() {

    declare -a __T_PMPAL_FILES=()

    if [[ "${G_LIB_STAGE}" == "installer" ]]; then
        if [[ -f "${G_LIB_DIR}/modules/package_aliases.sh" ]]; then
            if source "${G_LIB_DIR}/modules/package_aliases.sh"; then
                true
            else
                __T_ERROR=$?
                __log e -- "Problem loading package.aliases...\n"
                return ${__T_ERROR}
            fi
        else
            __log w -- "No package_aliases.sh found\n"
        fi
        return 0
    else
        return 1
    fi

}
function __pm_package_aliases_add() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare -a __P_ALIASES=("${@:1}")
    fi

    if ! __array_exists __PM_ALIAS_DEFINITIONS; then
        declare -agx __PM_ALIAS_DEFINITIONS
        unset __PM_ALIAS_PACKAGENAMES
    fi

    if ! __array_exists __PM_ALIAS_PACKAGENAMES; then
        declare -agx __PM_ALIAS_PACKAGENAMES=()
    fi

    for __T_ALIAS in "${__P_ALIASES[@]}"; do
        __T_ALIAS_N="${__T_ALIAS//[^\:]/}"

        if [[ ${#__T_ALIAS_N} -lt 3 ]]; then
            __T_ALIAS="${__T_ALIAS}:"
        fi

        IFS=":" read -ra __T_A <<<"${__T_ALIAS}"

        if [[ ${#__T_A[@]} -ne 3 ]]; then
            __log e -- "Alias '${__T_ALIAS}' is wrong.\n"
            continue
        fi

        __PM_ALIAS_PACKAGENAMES+=("${__T_A[0]}")
        __PM_ALIAS_DEFINITIONS+=("${__T_ALIAS}")
    done
    return 0
}
function __pm_package_install_list_add() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_PACKAGES=("${@:1}")
    fi

    if __array_exists __PM_PACKAGE_INSTALL_LIST; then
        true
    else
        declare -ga __PM_PACKAGE_INSTALL_LIST=()
    fi

    for __T_PKG in "${__P_PACKAGES[@]}"; do
        if __array_contains __PM_PACKAGE_INSTALL_LIST "${__T_PKG}"; then
            continue
        else
            __PM_PACKAGE_INSTALL_LIST+=("${__T_PKG}")
        fi

    done

}
function __pm_package_install_list_contains() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_PACKAGENAME="${@:1:1}"
    fi

    if [[ -z ${__PM_PACKAGE_INSTALL_LIST[@]+x} ]]; then
        return 102
    elif [[ ${#__PM_PACKAGE_INSTALL_LIST[@]} -lt 1 ]]; then
        return 103
    fi

    if __array_contains __PM_PACKAGE_INSTALL_LIST "${__P_PACKAGENAME}"; then
        return 0
    fi
    return 1
}
function __pm_package_install_list_flush() {
    unset __PM_PACKAGE_INSTALL_LIST
    return 0
}
function __pm_package_install_list_get() {

    if [[ "${@:1:1}x" == "x" ]]; then
        declare -a __T_PILG_RETURN_ARRAY=()
    elif __array_exists "${@:1:1}"; then
        declare -n __T_PILG_RETURN_ARRAY="${@:1:1}"
        __T_PILG_RETURN_ARRAY=()
    else
        declare -a __T_PILG_RETURN_ARRAY=()
    fi

    if [[ -z ${__PM_PACKAGE_INSTALL_LIST[@]+x} ]]; then
        return 0
    elif [[ ${__PM_PACKAGE_INSTALL_LIST[@]} -gt 0 ]]; then
        if [[ -R __T_PILG_RETURN_ARRAY ]]; then
            __T_PILG_RETURN_ARRAY=("${__PM_PACKAGE_INSTALL_LIST[@]}")
        else
            echo "${__PM_PACKAGE_INSTALL_LIST[@]}"
        fi
    fi
    return 0
}
function __pm_package_install_list_remove() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_PACKAGES=("${@:1}")
    fi
    declare -a __T_ARRAY=()

    if [[ -z ${__PM_PACKAGE_INSTALL_LIST[@]+x} ]]; then
        return 0
    elif [[ ${#__PM_PACKAGE_INSTALL_LIST[@]} -lt 1 ]]; then
        return 0
    fi

    for __T_PKG in "${__P_PACKAGES[@]}"; do
        if __array_contains "__PM_PACKAGE_INSTALL_LIST" "${__T_PKG}"; then
            declare -a __T_ARRAY=()
            for __T_LPKG in "${__PM_PACKAGE_INSTALL_LIST[@]}"; do
                if [[ "${__T_PKG}" == "${__T_LPKG,,}" ]]; then
                    continue
                fi
                __T_ARRAY+=("${__T_LPKG}")
            done
            __PM_PACKAGE_INSTALL_LIST=("${__T_ARRAY[@]}")
        fi
    done

    if [[ ${#__PM_PACKAGE_INSTALL_LIST[@]} -lt 1 ]]; then
        unset __PM_PACKAGE_INSTALL_LIST
    fi
    return 0
}
function __pm_package_install_needed() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_array_exists "${@:1:1}"; then
        declare -n __T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE="${@:1:1}"
        declare -a __T_PPNEI_PACKAGES_TO_INSTALL=("${@:2}")
    else
        declare -a __T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE_DUMMY=()
        declare -n __T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE="__T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE_DUMMY"
        declare -a __T_PPNEI_PACKAGES_TO_INSTALL=("${@:1}")
    fi
    if [[ ${#__T_PPNEI_PACKAGES_TO_INSTALL[@]} -lt 1 ]]; then
        return 102
    fi
    if __pm_ready; then
        true
    else
        return 103
    fi
    declare -a __T_PPNEI_PACKAGES_NOT_INSTALLED=()

    if __pm_package_installed_not __T_PPNEI_PACKAGES_NOT_INSTALLED "${__T_PPNEI_PACKAGES_TO_INSTALL[@]}"; then
        if __pm_package_available "${!__T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE}" "${__T_PPNEI_PACKAGES_NOT_INSTALLED[@]}"; then
            if [[ ${#__T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE[@]} -gt 0 ]]; then
                if [[ ! -R __T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE ]]; then
                    echo "${__T_PPNEI_PACKAGES_NOT_INSTALLED_AVAILABLE[@]}"
                fi
                return 0
            fi
        fi
    fi
    return 1
}
function __pm_package_installed() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __array_exists "${@:1:1}"; then
        declare -n __T_PPII_PACKAGES_INSTALLED="${@:1:1}"
        declare -a __P_PACKAGES=("${@:2}")
    else
        declare -a __T_PPII_PACKAGES_INSTALLED=()
        declare -a __P_PACKAGES=("${@:2}")
    fi

    if [[ ${#__P_PACKAGES[@]} -gt 0 ]]; then
        for __T_PACKAGE in "${__P_PACKAGES[@]}"; do
            if apk info -e "${__T_PACKAGE}" >/dev/null 2>&1; then
                __T_PPI_PACKAGES_INSTALLED+=("${__T_PACKAGE}")
            fi
        done
    fi

    if [[ ${#__T_PPII_PACKAGES_INSTALLED[@]} -gt 0 ]]; then
        if [[ ! -R __T_PPII_PACKAGES_INSTALLED ]]; then
            echo "${__T_PPII_PACKAGES_INSTALLED[@]}"
        fi
        return 0
    fi

    return 1
}
function __pm_package_installed_not() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __test_array_exists "${@:1:1}"; then
        declare -n __T_PPNI_PACKAGES_NOT_INSTALLED="${@:1:1}"
        declare -a __P_PACKAGES=("${@:2}")
    else
        declare -a __T_PPNI_PACKAGES_NOT_INSTALLED=()
        declare -a __P_PACKAGES=("${@:1}")
    fi
    if [[ ${#__P_PACKAGES[@]} -lt 1 ]]; then
        return 102
    fi

    for __T_PACKAGE in "${__P_PACKAGES[@]}"; do
        if apk info -e "${__T_PACKAGE}" >/dev/null 2>&1; then
            continue
        fi
        __T_PPNI_PACKAGES_NOT_INSTALLED+=("${__T_PACKAGE}")
    done

    if [[ ${#__T_PPNI_PACKAGES_NOT_INSTALLED[@]} -gt 0 ]]; then
        if [[ ! -R __T_PPNI_PACKAGES_NOT_INSTALLED ]]; then
            echo "${__T_PPNI_PACKAGES_NOT_INSTALLED[@]}"
        fi
        return 0
    fi
    return 1
}
function __pm_ready() {

    if [[ -z ${__PM_INIT_ERROR+x} ]]; then
        true
    else
        return 101
    fi
    if [[ -z ${__PM_INIT+x} ]] || [[ "${__PM_INIT}x" == "x" ]]; then
        if __pm_init; then
            true
        else
            return 102
        fi
    fi

    if [[ -z ${__PM_CACHE_UPDATE+x} ]] || [[ "${__PM_CACHE_UPDATE}x" == "x" ]]; then
        if __pm_cache_update; then
            true
        else
            return 103
        fi
    fi
    return 0
}
function __pm_repository_install_list_add() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_REPOSITORIES=("${@:1}")
    fi

    if [[ -z ${__PM_REPOSITORY_INSTALL_LIST[@]+x} ]]; then
        declare -ga __PM_REPOSITORY_INSTALL_LIST=()
    fi

    for __T_REPOSITORY in "${__P_REPOSITORIES[@]}"; do
        if __array_contains __PM_REPOSITORY_INSTALL_LIST "${__T_REPOSITORY}"; then
            continue
        else
            __PM_REPOSITORY_INSTALL_LIST+=("${__T_REPOSITORY}")
        fi
    done

    return 0
}
function __pm_repository_install_list_contains() {

    if [[ -z ${__PM_REPOSITORY_INSTALL_LIST[@]+x} ]]; then
        return 101
    elif [[ ${#__PM_REPOSITORY_INSTALL_LIST[@]} -lt 1 ]]; then
        return 102
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        return 103
    else
        declare __P_NEEDLE="${@:1:1}"
    fi

    if __array_contains __PM_REPOSITORY_INSTALL_LIST "${__P_NEEDLE}"; then
        return 0
    fi
    return 1
}
function __pm_repository_install_list_flush() {
    unset __PM_REPOSITORY_INSTALL_LIST
    return 0
}
function __pm_repository_install_list_get() {

    if [[ "${@:1:1}x" == "x" ]]; then
        declare -a __T_RILG_RETURN_ARRAY=()
    elif __array_exists "${@:1:1}"; then
        declare -n __T_RILG_RETURN_ARRAY="${@:1:1}"
        __T_RILG_RETURN_ARRAY=()
    else
        declare -a __T_RILG_RETURN_ARRAY=()
    fi

    if [[ -z ${__PM_REPOSITORY_INSTALL_LIST[@]+x} ]]; then
        return 0
    elif [[ ${#__PM_REPOSITORY_INSTALL_LIST[@]} -lt 1 ]]; then
        return 0
    fi

    if [[ -R __T_RILG_RETURN_ARRAY ]]; then
        __T_RILG_RETURN_ARRAY=("${__PM_REPOSITORY_INSTALL_LIST[@]}")
    else
        echo "${__PM_REPOSITORY_INSTALL_LIST[@]}"
    fi
    return 0
}
function __pm_repository_install_list_remove() {

    if [[ -z ${__PM_REPOSITORY_INSTALL_LIST[@]+x} ]]; then
        return 0
    elif [[ ${#__PM_REPOSITORY_INSTALL_LIST[@]} -lt 1 ]]; then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_REPOSITORYNAME="${@:1:1}"
    fi

    if __array_contains __PM_REPOSITORY_INSTALL_LIST "${__P_REPOSITORYNAME}"; then
        declare -a __T_ARRAY=()
        for __T_REPO in "${__PM_REPOSITORY_INSTALL_LIST[@]}"; do
            if [[ "${__T_REPO}" == "${__P_REPOSITORYNAME}" ]]; then
                continue
            fi
            __T_ARRAY+=("${__T_REPO}")
        done
        __PM_REPOSITORY_INSTALL_LIST=("${__T_ARRAY[@]}")
    fi
    return 0
}
