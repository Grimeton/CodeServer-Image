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
set -o nounset
declare -gx __LOG_DEBUG=1
__INSTALLER_VERSION="0.01"
declare -a __INSTALLER_PACKAGES=()
declare -a __INSTALLER_REPO_REQUIRED_PACKAGES=()
declare -a __INSTALLER_REPO_PACKAGES=()
declare -i __INSTALLER_BUILD_PACKAGES_INSTALLED=0
declare -i __INSTALLER_RUN_PACKAGES_INSTALLED=0
declare -i __INSTALLER_INSTALLER_PACKAGES_INSTALLED=0

if [[ -d /tmp ]]; then
    chmod 1777 /tmp
fi
function __install_packages() {
    declare -a __T_PACKAGES_TO_INSTALL=()
    declare -i __T_ERROR=0

    if __pm_ready; then
        true
    else
        __T_ERROR=$?
        __log e -- "Cannot get package manager. Returning (${__T_ERROR}).\n"
        return ${__T_ERROR}
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        if [[ "${__INSTALLER_STAGE}" == "build" ]] && [[ ${__INSTALLER_BUILD_PACKAGES_INSTALLED} -lt 1 ]]; then
            if [[ -z ${__CONFIG[BUILD_PACKAGES_INSTALL]+x} ]]; then
                true
            elif [[ "${__CONFIG[BUILD_PACKAGES_INSTALL]}x" == "x" ]]; then
                true
            else
                __T_PACKAGES_TO_INSTALL=(${__CONFIG[BUILD_PACKAGES_INSTALL]})
            fi
        elif [[ "${__INSTALLER_STAGE}" == "run" ]] && [[ ${__INSTALLER_RUN_PACKAGES_INSTALLED} -lt 1 ]]; then
            if [[ -z ${__CONFIG[RUN_PACKAGES_INSTALL]+x} ]]; then
                true
            elif [[ "${__CONFIG[RUN_PACKAGES_INSTALL]}x" == "x" ]]; then
                true
            else
                __T_PACKAGES_TO_INSTALL=(${__CONFIG[RUN_PACKAGES_INSTALL]})
            fi
        fi

        if [[ ${#__T_PACKAGES_TO_INSTALL[@]} -gt 0 ]]; then
            declare -a __T_AAA_REPOS=()
            if __pm_package_aliases_check __T_PACKAGES_TO_INSTALL __T_AAA_REPOS; then
                if [[ ${#__T_AAA_REPOS[@]} -gt 0 ]]; then
                    if __install_repos "${__T_AAA_REPOS[@]}"; then
                        true
                    else
                        __T_ERROR=$?
                        __log e -- "Cannot install additional repositories (${__T_ERROR}).\n"
                        return ${__T_ERROR}
                    fi
                fi
            fi
            if __pm_package_install "${__T_PACKAGES_TO_INSTALL[@]}"; then
                if [[ "${__INSTALLER_STAGE}" == "build" ]]; then
                    __INSTALLER_BUILD_PACKAGES_INSTALLED=1
                elif [[ "${__INSTALLER_STAGE}" == "run" ]]; then
                    __INSTALLER_RUN_PACKAGES_INSTALLED=1
                fi
                declare -a __T_PACKAGES_TO_INSTALL=()
            fi
        fi
    else
        __T_PACKAGES_TO_INSTALL=("${@:1}")
    fi

    if [[ ${#__INSTALLER_PACKAGES[@]} -gt 0 ]] && [[ ${__INSTALLER_INSTALLER_PACKAGES_INSTALLED} -lt 1 ]]; then
        declare -a __T_BBB_REPOS=()
        declare -a __T_INSTALLER_PACKAGES=("${__INSTALLER_PACKAGES[@]}")
        if __pm_package_aliases_check __T_INSTALLER_PACKAGES __T_BBB_REPOS; then
            if [[ ${#__T_BBB_REPOS[@]} -gt 0 ]]; then
                if __install_repos "${__T_BBB_REPOS[@]}"; then
                    true
                else
                    __T_ERROR=$?
                    __log e -- "Couldn't install additional repositories... (${__T_ERROR}).\n"
                    return ${__T_ERROR}
                fi
            fi
        fi

        if __pm_package_install "${__T_INSTALLER_PACKAGES[@]}"; then
            __INSTALLER_INSTALLER_PACKAGES_INSTALLED=1
        fi
    fi

    if [[ ${#__T_PACKAGES_TO_INSTALL[@]} -gt 0 ]]; then
        __log i -- "Checking for aliases..."
        declare -a __T_ABC_REPOS_ARRAY=()
        if __pm_package_aliases_check __T_PACKAGES_TO_INSTALL __T_ABC_REPOS_ARRAY; then
            if [[ ${#__T_ABC_REPOS_ARRAY[@]} -gt 0 ]]; then
                if __install_repos "${__T_ABC_REPOS_ARRAY[@]}"; then
                    true
                else
                    __T_ERROR=$?
                    __log e -- "Could not install additional repositories (${__T_ERROR}).\n"
                    return ${__T_ERROR}
                fi
            fi
        fi

        __log i -- "Beginning to install '${__T_PACKAGES_TO_INSTALL[@]}'.\n"
        if __pm_package_install "${__T_PACKAGES_TO_INSTALL[@]}"; then
            __T_PACKAGES_TO_INSTALL=()
        else
            __log e -- "Could not install packages..\n"
            __T_ERROR=3
        fi
    fi

    return ${__T_ERROR}

}
function __install_repos() {

    __log i --- "Entering repository installation...(${#}).\n"

    local -r __T_INSTALLER_REPO_DIR="${__INSTALLER_DIR}/repos"
    declare -a __T_INSTALLER_REPO_FILES=()
    local __T_ERROR=0

    if [[ "${@:1:1}x" == "x" ]]; then
        for __T_INSTALLER_REPO_FILE in "${__T_INSTALLER_REPO_DIR}"/*.sh; do
            if [[ -f "${__T_INSTALLER_REPO_FILE}" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_FILE}")
            fi
        done
    else
        for __T_INSTALLER_REPO_FILE in "${@:1}"; do
            if [[ -f "${__T_INSTALLER_REPO_FILE}" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_FILE}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_FILE,,}" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_FILE,,}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE}" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE,,}" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE,,}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE}.sh" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE}.sh")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE,,}.sh" ]]; then
                __T_INSTALLER_REPO_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_REPO_FILE,,}.sh")
                continue
            else
                __log e -- "Could not find repository '${__T_INSTALLER_REPO_FILE}'. Giving up.\n"
                __T_ERROR=1
                continue
            fi
        done
    fi

    if [[ ${#__T_INSTALLER_REPO_FILES[@]} -lt 1 ]]; then
        __log e -- "Could not find any repo file. Exiting.\n"
        __T_ERROR=101
    else
        for __T_INSTALLER_REPO_FILE in "${__T_INSTALLER_REPO_FILES[@]}"; do
            __log i -- "Working on: '${__T_INSTALLER_REPO_FILE}'.\n"
            if __installer_repository_install "${__T_INSTALLER_REPO_FILE}"; then
                if ! __pm_cache_update; then
                    __log e -- "Could not update the cache after repo installation...\n"
                fi
                __log i -- "Installing '${__T_INSTALLER_REPO_FILE}' successful.\n"
            else
                __T_ERROR=$?
                __log e -- "Problem installing '${__T_INSTALLER_REPO_FILE}' (${__T_ERROR}).\n"
            fi
        done
    fi
    return ${__T_ERROR}
}
function __install_downloads() {

    local -r __T_INSTALLER_DOWNLOAD_DIR="${__INSTALLER_DIR}/downloads"
    local __T_INSTALLER_DOWNLOAD_FILES=()
    local __T_ERROR=0

    if [[ "${@:1:1}x" == "x" ]]; then
        for __T_INSTALLER_DOWNLOAD_FILE in "${__T_INSTALLER_DOWNLOAD_DIR}"/*.sh; do
            if [[ -f "${__T_INSTALLER_DOWNLOAD_FILE}" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_DOWNLOAD_FILE}")
            fi
        done
    else
        for __T_INSTALLER_DOWNLOAD_FILE in "${@:1}"; do
            if [[ -f "${__T_INSTALLER_DOWNLOAD_FILE}" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_DOWNLOAD_FILE}")
                continue
            elif [[ -f "${__T_INSTALLER_DOWNLOAD_FILE,,}" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_DOWNLOAD_FILE,,}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE}" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE,,}" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE,,}")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE}.sh" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE}.sh")
                continue
            elif [[ -f "${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE,,}.sh" ]]; then
                __T_INSTALLER_DOWNLOAD_FILES+=("${__T_INSTALLER_REPO_DIR}/${__T_INSTALLER_DOWNLOAD_FILE,,}.sh")
                continue
            else
                __log e -- "Could not find download '${__T_INSTALLER_DOWNLOAD_FILE}'. Giving up.\n"
                __T_ERROR=1
                continue
            fi
        done
    fi

    if [[ ${#__T_INSTALLER_DOWNLOAD_FILES} -lt 1 ]]; then
        __log e -- "Could not find any download file. Exiting.\n"
        __T_ERROR=101
    else
        for __T_INSTALLER_DOWNLOAD_FILE in "${__T_INSTALLER_DOWNLOAD_FILES[@]}"; do
            __log i -- "Working on: '${__T_INSTALLER_DOWNLOAD_FILE}'.\n"
            if __installer_download_install "${__T_INSTALLER_DOWNLOAD_FILE}"; then
                __log i -- "Installing '${__T_INSTALLER_DOWNLOAD_FILE}' successful.\n"
            else
                __log e -- "Problem installing '${__T_INSTALLER_DOWNLOAD_FILE}'.\n"
                __T_ERROR=102
            fi
        done
    fi
    return ${__T_ERROR}
}
function __do_cleanup() {
    return 0
    if ! __pm_ready; then
        __log e -- "Need package manager for this...\n"
    fi
    __pm_cache_clean

}
function __install_all_build() {
    for __T_FN in "__install_downloads" "__install_packages"; do
        if "${__T_FN}"; then
            __log i -- "Ran '${__T_FN}' successful.\n"
        else
            __log e -- "Problems running '${__T_FN}' ($?).\n"
        fi
    done
}
function __install_all_run() {
    for __T_FN in "__install_packages" "__do_cleanup"; do
        if "${__T_FN}"; then
            __log i -- "Running '${__T_FN}' success.\n"
        else
            __log e -- "Running '${__T_FN}' error ($?).\n"
        fi
    done
    
    if [[ -d /var/cache/apt ]]; then
        rm -rf /var/cache/apt/
    fi
    if [[ -d /var/lib/apt/lists ]]; then
        rm -rf /var/lib/apt/lists/
    fi

}
function __install_all() {
    if [[ "${__INSTALLER_STAGE}" == "build" ]]; then
        __install_all_build
    elif [[ "${__INSTALLER_STAGE}" == "run" ]]; then
        __install_all_run
    fi
    return
}
function __show_usage() {
    echo ""
    echo " To use the installer, please use the following options:"
    echo ""
    echo " '${0}' install [repo|repository|repositories] [repository|repositories|<none>]"
    echo " '${0}' install download [name|names|<none>]"
    echo " '${0}' install stage [name|names|<none>]"
    echo ""
    echo " When an option has the word '<none>' in its description it means that the command will install everything it finds."
    echo ""
}
if ! source /usr/local/lib/init/lib_loader.sh; then
    echo "ERROR: Cannot find libraries. Exiting."
    exit 199
fi

__log i -- "Installer starting up..\n"

for __T_PACKAGE in "installer" "package_manager" "rootlayout"; do
    if ! __lib_package_load "${__T_PACKAGE}"; then
        __log e - "Could not load package '${__T_PACKAGE}'. Exiting.\n"
        exit 198
    fi
done

if [[ -f "${G_LIB_DIR}/settings.conf" ]]; then
    if ! source "${G_LIB_DIR}/settings.conf"; then
        __log e - "Could not load settings...\n"
        exit 199
    fi
else
    __log e -- "Could not load settings...\n"
    exit 200
fi

if [[ "${THIS_STAGE}" == "build" ]]; then
    __INSTALLER_STAGE="build"
    __INSTALLER_DIR="${__CONFIG[BUILD_INSTALLER_DIRECTORY]}"
elif [[ "${THIS_STAGE}" == "run" ]]; then
    __INSTALLER_STAGE="run"
    __INSTALLER_DIR="${__CONFIG[RUN_INSTALLER_DIRECTORY]}"
else
    __log e -- "Don't know the stage I'm in.\n"
    exit 99
fi

if [[ "${@:1:1}x" == "x" ]]; then
    __P_COMMAND=""
else
    __P_COMMAND="${@:1:1}"
fi

if [[ "${@:2:1}x" == "x" ]]; then
    __P_SUBCOMMANDS=()
else
    __P_SUBCOMMANDS=("${@:2}")
fi
if [[ "${__P_COMMAND,,}" == "destroy" ]]; then
    __log i -- "Going to destroy myself. Goodbye.\n"
    if [[ -d "${__INSTALLER_DIR}" ]]; then
        rm -rf "${__INSTALLER_DIR}"
    fi
    if [[ -f "${0}" ]]; then
        rm -f "${0}"
    fi
elif [[ "${__P_COMMAND}" == "install" ]]; then
    if [[ ${#__P_SUBCOMMANDS} -gt 0 ]]; then
        if [[ "${__P_SUBCOMMANDS[0],,}" == "download" ]] ||
            [[ "${__P_SUBCOMMANDS[0],,}" == "downloads" ]]; then
            if __install_downloads "${__P_SUBCOMMANDS[@]:1}"; then
                __log i -- "Installing downloads successfull.\n"
            else
                __log i -- "Installing downloads failed.\n"
                exit 102
            fi
        elif [[ "${__P_SUBCOMMANDS[0],,}" == "package" ]] ||
            [[ "${__P_SUBCOMMANDS[0],,}" == "packages" ]]; then
            if __install_packages "${__P_SUBCOMMANDS[@]}"; then
                __log i -- "Installing packages successful.\n"
            else
                __log e -- "Installing packages unsuccessful.\n"
            fi
        elif [[ "${__P_SUBCOMMANDS[0],,}" == "repositories" ]] ||
            [[ "${__P_SUBCOMMANDS[0],,}" == "repo" ]] ||
            [[ "${__P_SUBCOMMANDS[0],,}" == "repository" ]]; then
            __log i -- "Starting repository installation...\n"
            if ! __install_repos "${__P_SUBCOMMANDS[@]:1}"; then
                __log e -- "Installing repositories failed.\n"
                exit 101
            else
                __log i -- "Installing repositories successful.\n"
            fi
        elif [[ "${__P_SUBCOMMANDS[0],,}" == "all" ]]; then
            if __install_all; then
                __log i -- "Running installation for all options successful.\n"
            else
                __log e -- "Running installation for all options not successful.\n"
                exit 103
            fi
        else
            __log w -- "Sub command '${__P_SUBCOMMANDS[0]}' is unknown.\n"
            __show_usage
            exit 104
        fi
    else
        __log w -- "Command '${__P_COMMAND}' needs a subcommand.\n"
        __show_usage
        exit 105
    fi
elif [[ "${__P_COMMAND}x" == "x" ]]; then
    if __install_all; then
        exit 0
    else
        exit 2
    fi

else
    __log e -- "Command '${__P_COMMAND}' unknown. Exiting.\n"
    exit 1
fi
