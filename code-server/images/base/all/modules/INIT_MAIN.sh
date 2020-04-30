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
# 0
#
if ! (return 0 2>/dev/null); then
    echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
    exit 254
fi

function __main_pm_repositories_install() {
    __log i -- "(INIT) Checking if there are repositories to be installed...\n"
    declare -a __T_INIT_REPOSITORIES=()
    if __pm_repository_install_list_get __T_INIT_REPOSITORIES; then
        if [[ ${#__T_INIT_REPOSITORIES[@]} -gt 0 ]]; then
            __log i -- "(INIT) There are '${#__T_INIT_REPOSITORIES[@]}' to be installed. Starting...\n"
            for __T_INIT_REPOSITORY in "${__T_INIT_REPOSITORIES[@]}"; do
                __log i -- "(INIT) Working on repository '${__T_INIT_REPOSITORY}'.\n"
                declare __T_REPO_FILE="${G_LIB_DIR}/repos/${__T_INIT_REPOSITORY}"
                if [[ -f "${__T_REPO_FILE}" ]]; then
                    __log i -- "(INIT) Working on '${__T_REPO_FILE}'.\n"
                    if __installer_repo_install "${__T_REPO_FILE}"; then
                        __log i -- "(INIT) Repository '${__T_INIT_REPOSITORY}' installed successfully.\n"
                        __array_remove __T_INIT_REPOSITORIES "${__T_INIT_REPOSITORY}"
                    else
                        __log e -- "(INIT) Problems installing '${__T_INIT_REPOSITORY}' ($?).\n"
                        return 111
                    fi
                else
                    __log i -- "(INIT) The file '${__T_REPO_FILE}' of repository '${__T_INIT_REPOSITORY}' does not exist.\n"
                fi
            done
        else
            __log i -- "(INIT) There are not repositories to be installed.\n"
        fi
    else
        __log i -- "(INIT) The list of repositories is empty.\n"
    fi
    if __pm_repository_install_list_flush; then
        if [[ -z ${__T_INIT_REPOSITORIES[@]:+x} ]]; then
            return 0
        fi
        if __pm_repository_install_list_add "${__T_INIT_REPOSITORIES[@]}"; then
            return 0
        else
            return 1
        fi
    fi
    return 254

}
__init_function_register_always 200 __main_install_repositories

function __main_pm_cache_update() {
    __log i -- "(INIT) Checking if there are packages to be installed...\n"
    declare -a __T_INIT_PACKAGES=()
    if __pm_package_install_list_get __T_INIT_PACKAGES; then
        if [[ ${#__T_INIT_PACKAGES[@]} -gt 0 ]]; then
            __log i -- "(INIT) There are '${#__T_INIT_PACKAGES[@]}' in the list. Going to update the package manager's cache...\n"
            if __pm_ready; then
                if __pm_cache_update; then
                    __log i -- "(INIT) Package manager cache update successful.\n"
                else
                    __log e -- "(INIT) Problems updating the package manager's cache ($?).\n"
                    return 201
                fi
            else
                __log e -- "(INIT) Package manager not ready ($?).\n"
                return 202
            fi
        else
            __log i -- "(INIT) No packages to be installed.\n"
        fi
    else
        __log i -- "(INIT) Package list is empty.\n"
    fi
    return 0
}
__init_function_register_always 400 __main_pm_cache_update

function __main_pm_aliases_check() {
    declare -a __T_INIT_PACKAGES=()
    declare -a __T_INIT_REPOS=()
    __log i -- "(INIT) Doing the alias check...\n"
    if __pm_package_install_list_get __T_INIT_PACKAGES; then
        if __pm_package_aliases_check __T_INIT_PACKAGES __T_INIT_REPOS; then
            if [[ -z ${__T_INIT_PACKAGES[@]:+x} ]]; then
                __log i -- "(INIT) No packages to be installed.\n"
            elif __pm_package_install_list_flush; then
                if __pm_package_install_list_add "${__T_INIT_PACKAGES[@]}"; then
                    __log i -- "(INIT) Alias check done. Packages converted.\n"
                else
                    __log e -- "(INIT) Problems converting the package names ($?).\n"
                fi
            fi

            __log i -- "(INIT) Checking if new repositories need to be installed...\n"
            if [[ -z ${__T_INIT_REPOS[@]:+x} ]]; then
                __log i -- "(INIT) No additional repositories to be installed.\n"
            elif __pm_repository_install_list_add "${__T_INIT_REPOS[@]}"; then
                __log i -- "(INIT) Added '${#__T_INIT_REPOS[@]}' repositories to the install list.\n"
            else
                __log e -- "(INIT) Problems adding '${#__T_INIT_REPOS[@]}' to the install list ($?).\n"
            fi
        fi
    fi
    return 0

}
__init_function_register_always 601 __main_pm_aliases_check
__init_function_register_always 602 __main_pm_repositories_install
__init_function_register_always 603 __main_pm_cache_update

function __main_pm_packages_install() {
    __log i -- "(INIT) Checking for packages to be installed...\n"
    declare -a __T_INIT_PACKAGES=()
    if __pm_package_install_list_get __T_INIT_PACKAGES; then
        if [[ -z ${__T_INIT_PACKAGES[@]:+x} ]]; then
            __log i -- "(INIT) There are no packages to be installed.\n"
            return 0
        else
            __log i -- "(INIT) There are '${#__T_INIT_PACKAGES[@]}' to be installed.\n"
            if __pm_package_install "${__T_INIT_PACKAGES[@]}"; then
                __pm_package_install_list_flush
                __log i -- "(INIT) Packages installed successfully.\n"
                return 0
            else
                __log e -- "(INIT) Problems installing packages ($?).\n"
                return 1
            fi
        fi
    else
        __log i -- "(INIT) No additional packages to be installed.\n"
    fi
    return 0
}
__init_function_register_always 604 __main_pm_packages_install

function __main_environment_save() {
    if [[ -z ${__T_REGISTERED_VARIABLES_TO_SAVE[@]:+x} ]]; then
        declare -a __T_REGISTERED_VARIABLES_TO_SAVE=()
    fi
    __T_REGISTERED_VARIABLES_TO_SAVE+=("__SETTINGS")

    declare -a __T_SORTED=()
    IFS=$'\n' __T_SORTED=($(sort -u <<<"${__T_REGISTERED_VARIABLES_TO_SAVE[*]}"))
    unset IFS

    if [[ -f "/.initenv" ]]; then
        if rm -f "/.initenv"; then
            true
        else
            __log e -- "(INIT) Problems deleting '/.initenv' ($?).\n"
            return 134
        fi
    fi

    if __environment_save_file "/.initenv" "${__T_SORTED[@]}"; then
        if chown root:root "/.initenv"; then
            if chmod 0600 "/.initenv"; then
                return 0
            else
                __log e -- "(INIT) Problems changing mode to '0600' on '/.initenv' ($?).\n"
                return 111
            fi
        else
            __log e -- "(INIT) Problems changing owner to 'root:root' on '/.initenv' ($?).\n"
            return 112
        fi
    else
        __log e -- "(INIT) Problems saving environment to '/.initenv' ($?).\n"
        return 113
    fi
    return 254
}
__init_function_register_always 1000 __main_environment_save
