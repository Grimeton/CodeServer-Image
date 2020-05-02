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
declare -ag __INSTALLER_PACKAGES_DOWNLOAD_INSTALL=("ca-certificates" "curl")
declare -ag __INSTALLER_PACKAGES_REPOSITORY_INSTALL=("apt-transport-https" "ca-certificates" "curl" "gnupg2")
#####
#
# - __installer_download_install
#
# - Description:
#   Takes the full path to a file and then tries to read its contents and install the download based on the information
#   inside the file. If the file is not found - ERROR.
#
# - Paramters:
#   - #1 [IN|MANDATORY] - FILE - The full path to the file that contains the information on how/what to install.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __installer_download_install() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ -f "${@:1:1}" ]]; then
        declare __P_DOWNLOAD_FILE="${@:1:1}"
    else
        return 102
    fi

    if [[ ${#__INSTALLER_PACKAGES_DOWNLOAD_INSTALL[@]} -gt 0 ]]; then
        if __pm_package_install "${__INSTALLER_PACKAGES_DOWNLOAD_INSTALL[@]}"; then
            __INSTALLER_PACKAGES_DOWNLOAD_INSTALL=()
        else
            __T_ERROR=$?
            __log e -- "Need packages '${__INSTALLER_PACKAGES_DOWNLOAD_INSTALL[@]}'. Cannot continue. (${__T_ERROR}).\n"
            return ${__T_ERROR}
        fi
    fi

    declare __T_REGEX_PERMISSIONS='^([0-9])?[0-7][0-7][0-7]$'
    declare __T_CURL_COMMAND=""
    declare __T_CURL_IGNORE_CERTIFICATE=""
    declare -i __T_ERROR=0
    declare __T_TEMP_FILE=""

    declare DOWNLOAD_DESTINATION=""
    declare DOWNLOAD_FILE_PERMISSIONS=""
    declare DOWNLOAD_FILE_OWNER=""
    declare DOWNLOAD_FILE_GROUP=""
    declare DOWNLOAD_IGNORE_CERTIFICATE=""
    declare DOWNLOAD_PACKAGE_NAME=""
    declare DOWNLOAD_SOURCE=""

    if __T_CURL_COMMAND="$(which curl)"; then
        true
    else
        __T_ERROR=$?
        __log e -- "Could not find 'curl'. Returning. (${__T_ERROR}).\n"
        return ${__T_ERROR}
    fi

    if source "${__P_DOWNLOAD_FILE}"; then
        true
    else
        __T_ERROR=$?
        __log e -- "Could not source the download file '${__P_DOWNLOAD_FILE}'. Returning. (${__T_ERROR}).\n"
        return ${__T_ERROR}
    fi

    if [[ "${DOWNLOAD_PACKAGE_NAME}x" == "x" ]]; then
        DOWNLOAD_PACKAGE_NAME="$(basename ${__P_DOWNLOAD_FILE} .sh)"
    fi

    if [[ "${DOWNLOAD_DESTINATION}x" == "x" ]]; then
        __log e -- "'${DOWNLOAD_PACKAGE_NAME}': The download destination is empty: '${DOWNLOAD_DESTINATION}'. Returning.\n"
        return 11
    fi

    if [[ "${DOWNLOAD_SOURCE}x" == "x" ]]; then
        __log e -- "'${DOWNLOAD_PACKAGE_NAME}': The download source is empty: '${DOWNLOAD_SOURCE}'. Returning.\n"
        return 12
    fi

    if [[ "${DOWNLOAD_IGNORE_CERTIFICATE}x" == "x" ]]; then
        __T_CURL_IGNORE_CERTIFICATE=""
    else
        __T_CURL_IGNORE_CERTIFICATE="--insecure"
    fi
    __T_TEMP_FILE="$(mktemp)"

    if ${__T_CURL_COMMAND} -fsSL ${__T_CURL_IGNORE_CERTIFICATE} -o "${__T_TEMP_FILE}" "${DOWNLOAD_SOURCE}"; then
        __log i -- "Downloading of '${DOWNLOAD_SOURCE}' successful.\n"
        __log i -- "Starting install....\n"
        if [[ ! -d "$(dirname "${DOWNLOAD_DESTINATION}")" ]]; then
            __log i -- "Directory '$(dirname "${DOWNLOAD_DESTINATION}")' does not exist. Creating...\n"
            if mkdir -p "$(dirname "${DOWNLOAD_DESTINATION}")"; then
                __log i -- "Directory created successfully.\n"
            else
                __log e -- "Could not create directory. Returning.\n"
                __T_ERROR=1
            fi
        fi
        if [[ ${__T_ERROR} -lt 1 ]]; then
            if [[ -f "${__T_TEMP_FILE}" ]]; then
                if cp "${__T_TEMP_FILE}" "${DOWNLOAD_DESTINATION}"; then
                    __log i -- "Copying download to destination '${DOWNLOAD_DESTINATION}' successful.\n"
                else
                    __T_ERROR=$?
                    __log e -- "Could not copy download to destination '${DOWNLOAD_DESTINATION}'. Returning.\n"
                fi
            else
                __T_ERROR=$?
                __log e -- "Cannot find '${__T_TEMP_FILE}'. Returning...\n"
            fi
        fi

        if [[ ${__T_ERROR} -lt 1 ]]; then
            if [[ "${DOWNLOAD_FILE_PERMISSIONS}x" != "x" ]]; then
                __log i -- "Found permissions...\n"
                if [[ "${DOWNLOAD_FILE_PERMISSIONS}" =~ ${__T_REGEX_PERMISSIONS} ]]; then
                    __log i -- "Permissions valid. Applying '${DOWNLOAD_FILE_PERMISSIONS}' to '${DOWNLOAD_DESTINATION}'.\n"
                    if chmod ${DOWNLOAD_FILE_PERMISSIONS} "${DOWNLOAD_DESTINATION}"; then
                        __log i -- "Permissions applied successfully.\n"
                    else
                        __log e -- "Could not apply permissions. Returning.\n"
                    fi
                else
                    __log i -- "Permissions '${DOWNLOAD_FILE_PERMISSIONS}' are not valid. Not applying.\n"
                fi
            fi

            if [[ "${DOWNLOAD_FILE_OWNER}x" != "x" ]]; then
                __log i -- "Found file owner '${DOWNLOAD_FILE_OWNER}'.\n"
                if chown "${DOWNLOAD_FILE_OWNER}" "${DOWNLOAD_DESTINATION}"; then
                    __log i -- "Applying owner '${DOWNLOAD_FILE_OWNER}' to '${DOWNLOAD_DESTINATION}' successful.\n"
                else
                    __log e -- "Applying owner '${DOWNLOAD_FILE_OWNER}' to '${DOWNLOAD_DESTINATION}' not successfull.\n"
                fi
            fi

            if [[ "${DOWNLOAD_FILE_GROUP}x" != "x" ]]; then
                __log i -- "Found file group '${DOWNLOAD_FILE_GROUP}'.\n"
                if chgrp "${DOWNLOAD_FILE_GROUP}" "${DOWNLOAD_DESTINATION}"; then
                    __log i -- "Applying group '${DOWNLOAD_FILE_GROUP}' to '${DOWNLOAD_DESTINATION}' successful.\n"
                else
                    __log e -- "Applying group '${DOWNLOAD_FILE_GROUP}' to '${DOWNLOAD_DESTINATION}' not successful.\n"
                fi
            fi
        fi
    else
        __log e -- "Could not download '${DOWNLOAD_SOURCE}'. Returning.\n"
    fi

    if [[ -f "${__T_TEMP_FILE}" ]]; then
        rm -f "${__T_TEMP_FILE}"
    fi

    return ${__T_ERROR}

}
function __installer_repository_install() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_REPO_FILE="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_FORCE=""
    else
        declare __P_FORCE="${@:2:1}"
    fi
    declare __T_ERROR=0

    if [[ ${#__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]} -gt 0 ]]; then
        if __pm_package_install "${__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]}"; then
            __INSTALLER_PACKAGES_REPOSITORY_INSTALL=()
        else
            __T_ERROR=$?
            __log e -- "Need packages '"${__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]}"' cannot continue.\n"
            return ${__T_ERROR}
        fi
    fi
    if __T_CURL_COMMAND="$(which curl)"; then
        true
    else
        __T_ERROR=$?
        __log e -- "Cannot find 'curl'. Exiting. (${__T_ERROR}).\n"
        return ${__T_ERROR}
    fi
    __T_ERROR=0

    if [[ -f "${__P_REPO_FILE}" ]]; then
        declare REPO_IGNORE_CERTIFICATE=""
        declare -a REPO_KEYS=()
        declare -a REPO_LIST_ENTRIES=()
        declare REPO_LIST_FILENAME=""
        declare __T_CURL_IGNORE_CERTIFICATE=""
        declare __T_REPO_KEY=""
        declare __T_REPO_FILE_MKTEMP=""
        declare __T_REPO_FILE=""

        if source "${__P_REPO_FILE}"; then
            true
        else
            __T_ERROR=$?
            __log e -- "Could not load the repository file '${__P_REPO_FILE}'. Exiting (${__T_ERROR}).\n"
            return ${__T_ERROR}
        fi

        if __variable_exists REPO_LIST_FILENAME; then
            if __variable_empty REPO_LIST_FILENAME; then
                __log e -- "'REPO_LIST_FILENAME' is empty. Not good...\n"
                return 1
            else
                if [[ -f "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}" ]]; then
                    if __variable_empty __P_FORCE; then
                        __log w -- "Repository already exists. '${__P_REPO_FILE}'. Aborting.\n"
                        return 0
                    else
                        if rm -r "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}"; then
                            return 0
                        else
                            __T_ERROR=$?
                            __log w -- "Could not delete '/etc/apt/sources.list.d/${REPO_LIST_FILENAME}'.\n"
                            return ${__T_ERROR}
                        fi
                    fi
                fi
            fi
        else
            __log e -- "'REPO_LIST_FILENAME' is missing. Not good...\n"
            return 2
        fi

        if __variable_exists "REPO_KEYS"; then
            if __array_exists "REPO_KEYS"; then
                if [[ ${#REPO_KEYS[@]} -gt 0 ]]; then
                    for __T_REPO_KEY in "${REPO_KEYS[@]}"; do
                        if __installer_repository_install_key "${__T_REPO_KEY}" "${REPO_IGNORE_CERTIFICATE}"; then
                            __log i -- "Key '${__T_REPO_KEY}' installed successfully.\n"
                        else
                            __log e -- "Problems installing '${__T_REPO_KEY}'. Skipping.\n"
                            __T_ERROR=1
                            continue
                        fi
                    done
                else
                    __log w -- "This repository comes without keys.\n"
                fi
            else
                if [[ "${REPO_KEYS}x" == "x" ]]; then
                    __log w -- "This repository comes without keys.\n"
                else
                    if __installer_repository_install_key "${REPO_KEYS}" "${REPO_IGNORE_CERTIFICATE}"; then
                        __log i -- "Installed key '${REPO_KEYS}' successfully.\n"
                    else
                        __log e -- "Could not install '${REPO_KEYS}'. Returning.\n"
                        __T_ERROR=1
                    fi
                fi
            fi
        else
            __log w -- "This repository comes without keys... Suspicious...\n"
        fi

        if [[ ${__T_ERROR} != 0 ]]; then
            return ${__T_ERROR}
        fi

        if __variable_exists "REPO_LIST_ENTRIES"; then
            if __array_exists "REPO_LIST_ENTRIES"; then
                if [[ ${#REPO_LIST_ENTRIES[@]} -gt 0 ]]; then
                    if [[ -f "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}" ]]; then
                        __log w -- "Repository '${REPO_LIST_FILENAME}' already exists. Deleting...\n"
                        if rm -f "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}"; then
                            __log i -- "Deleted '/etc/apt/sources.list.d/${REPO_LIST_FILENAME}' successfully.\n"
                        else
                            __log w -- "Problems deleting '/etc/apt/sources.list.d/${REPO_LIST_FILENAME}'. Returning.\n"
                            return 10
                        fi
                    fi
                    __log i -- "Adding repository entries to list..."
                    for __T_REPO_LIST_ENTRY in "${REPO_LIST_ENTRIES[@]}"; do
                        if ! echo "${__T_REPO_LIST_ENTRY}" >>"/etc/apt/sources.list.d/${REPO_LIST_FILENAME}"; then
                            __T_ERROR=11
                        fi
                    done
                    __log i -- "Done.\n"
                else
                    __log w -- "No list entries for this repo. Supsicious....\n"
                fi
            else
                if [[ "${REPO_LIST_ENTRIES}x" == "x" ]]; then
                    __log w -- "No list entries for this repo. Suspicious....\n"
                else
                    if [[ -f "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}" ]]; then
                        __log w -- "Repository '${REPO_LIST_FILENAME}' already exists. Deleting...\n"
                        if rm -f "/etc/apt/sources.list.d/${REPO_LIST_FILENAME}"; then
                            __log i -- "Deleted '/etc/apt/sources.list.d/${REPO_LIST_FILENAME}' successfully.\n"
                        else
                            __log w -- "Problems deleting '/etc/apt/sources.list.d/${REPO_LIST_FILENAME}'. Returning.\n"
                            __T_ERROR=12
                        fi
                    fi
                    if [[ "${__T_ERROR}" != "100" ]]; then
                        return ${__T_ERROR}
                    fi

                    if ! echo "${REPO_LIST_ENTRIES}" >"/etc/apt/sources.list.d/${REPO_LIST_FILENAME}"; then
                        return 13
                    fi
                fi
            fi
        else
            __log w -- "Repository comes without list entries...\n"
        fi
        if [[ "${__T_ERROR}" != "0" ]]; then
            return ${__T_ERROR}
        fi
    else
        __log e -- "Repository file '${__P_REPO_FILE}' does not exist.\n"
    fi
    return ${__T_ERROR}
}
function __installer_repository_install_key() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_KEY="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_CURL_IGNORE_CERTIFICATE=""
    else
        declare __P_CURL_IGNORE_CERTIFICATE="${@:2:1}"
    fi

    if [[ ${#__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]} -gt 0 ]]; then
        if __pm_package_install "${__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]}"; then
            __INSTALLER_PACKAGES_REPOSITORY_INSTALL=()
        else
            __log e -- "Need packages '"${__INSTALLER_PACKAGES_REPOSITORY_INSTALL[@]}"' cannot continue.\n"
            return 104
        fi
    fi
    declare __T_CURL_COMMAND=
    declare __T_CURL_IGNORE_CERTIFICATE=
    declare __T_ERR=100
    declare __T_KEY_MKTEMP=

    if ! __T_CURL_COMMAND="$(which curl)"; then
        __log e -- "Cannot find 'curl'. Exiting.\n"
        return 3
    fi

    if [[ -f "${__P_KEY}" ]]; then
        if apt-key add "${__P_KEY}" >/dev/null 2>&1; then
            __log i -- "Key '${__P_KEY}' installed successfully.\n"
            __T_ERR=0
        else
            __log i -- "Key '${__P_KEY}' could not be installed. Returning.\n"
            __T_ERR=1
        fi
    else
        if [[ "${__P_CURL_IGNORE_CERTIFICATE}x" == "x" ]]; then
            __T_CURL_IGNORE_CERTIFICATE=""
        else
            __T_CURL_IGNORE_CERTIFICATE="--insecure"
        fi

        __T_KEY_MKTEMP="$(mktemp)"
        __log i -- "Attempting to download '${__P_KEY}'.\n"

        if "${__T_CURL_COMMAND}" -sSL -o "${__T_KEY_MKTEMP}" ${__T_CURL_IGNORE_CERTIFICATE} "${__P_KEY}"; then

            __log i -- "Downloading '${__P_KEY}' succeeded.\n"

            if apt-key add "${__T_KEY_MKTEMP}" >/dev/null 2>&1; then
                __log i -- "Adding key '${__P_KEY}' sucessful.\n"
                __T_ERR=0
            else
                __log e -- "Could not add key '${__P_KEY}'. Returning.\n"
                __T_ERR=2
            fi
        else
            __log e -- "Could not download '${__P_KEY}'. Returning.\n"
            __T_ERR=3
        fi
    fi

    if [[ -f "${__T_KEY_MKTEMP}" ]]; then
        rm -f "${__T_KEY_MKTEMP}"
    fi

    return ${__T_ERR}

}
