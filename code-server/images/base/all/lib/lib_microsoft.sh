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
set -o nounset

function __microsoft_generate_repository_location() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 3
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi

    if [[ "${@:3:1}"x == "x" ]]; then
        return 4
    else
        declare __P_LOCATION_BASE="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        return 5
    else
        declare __P_REPOSITORY_BRANCH="${@:4:1}"
    fi

    if [[ "${@:5:1}x" == "x" ]]; then
        return 6
    else
        declare __P_REPOSITORY_TYPE="${@:5:1}"
    fi

    if [[ "${@:6:1}x" == "x" ]]; then
        declare __P_LOCATION_FILENAME=""
    else
        declare __P_LOCATION_FILENAME="${@:6:1}"
    fi

    if [[ "${@:7:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __variable_exists "${@:7:1}"; then
        declare -n __T_RETURN_VALUE="${@:7:1}"
        __T_RETURN_VALUE=""
    else
        declare __T_RETURN_VALUE=""
    fi
    declare __T_LOCATION_BASE="${__P_LOCATION_BASE}"
    declare __T_REPOSITORY_BRANCH="${__P_REPOSITORY_BRANCH}"
    declare __T_REPOSITORY_TYPE="${__P_REPOSITORY_TYPE}"
    declare __T_DISTRIBUTION_ID="${__P_DISTRIBUTION_ID}"
    declare __T_DISTRIBUTION_VERSION_ID="${__P_DISTRIBUTION_VERSION_ID}"
    declare __T_LOCATION_FILENAME=""

    if [[ "${__P_LOCATION_FILENAME}x" == "x" ]]; then
        if __microsoft_repository_to_filename "${__T_REPOSITORY_BRANCH}" "${__T_REPOSITORY_TYPE}" "${__T_DISTRIBUTION_ID}" __T_LOCATION_FILENAME; then
            true
        else
            return 11
        fi
    else
        __T_LOCATION_FILENAME="${__P_LOCATION_FILENAME}"
    fi
    __T_RETURN_VALUE="${__T_LOCATION_BASE}/${__T_DISTRIBUTION_ID}/${__T_DISTRIBUTION_VERSION_ID}/${__T_LOCATION_FILENAME}"
    if [[ ! -R __T_RETURN_VALUE ]]; then
        echo "${__T_RETURN_VALUE}"
    fi
    return 0

}
function __microsoft_install_microsoft_packagelists() {

    declare __T_MICROSOFT_PACKAGELISTS_FILENAME=""
    declare __T_MICROSOFT_PACKAGELISTS_LOCATION=""
    declare __T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH=""
    declare __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE=""
    declare -a __T_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS=("https://packages.microsoft.com/keys/microsoft.asc" "https://packages.microsoft.com/keys/msopentech.asc")
    declare __T_CURL_IGNORE_CERTIFICATE=""
    declare __T_W_FILE=""

    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Installing Microsoft Package Lists...\n"

    # let's get everything together
    # we need this and the _INSTALLTYPE pre defined and can generate everything else from it
    if [[ -z ${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]+x} ]]; then
        return 101
    elif [[ "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]}x" == "x" ]]; then
        return 102
    else
        __T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH="${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH]}"
    fi

    if [[ -z ${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]+x} ]]; then
        return 103
    elif [[ "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]}x" == "x" ]]; then
        return 104
    else
        __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE="${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE]}"
    fi

    if [[ -z ${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS[@]+x} ]]; then
        true
    elif [[ ${#__D_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS[@]} -lt 1 ]]; then
        true
    else
        __T_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS=("${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS[@]}")
    fi

    if [[ -z ${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]+x} ]] || [[ "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]}x" == "x" ]]; then
        if __microsoft_repository_to_filename \
            "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}" \
            "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" \
            "${ID}" \
            __T_MICROSOFT_PACKAGELISTS_FILENAME; then
            __SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]="${__T_MICROSOFT_PACKAGELISTS_FILENAME}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Filename set to: '${__T_MICROSOFT_PACKAGELISTS_FILENAME}'.\n"
        else
            __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not determine the filename ($?).\n"
            return 15
        fi
    else
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Filename preset to: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]}'.\n"
        __T_MICROSOFT_PACKAGELISTS_FILENAME="${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_FILENAME]}"
    fi

    if [[ -z ${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]+x} ]] || [[ "${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]}x" == "x" ]]; then
        if __microsoft_generate_repository_location \
            "${ID}" \
            "${VERSION_ID}" \
            "${__D_MICROSOFT_PACKAGELISTS_LOCATION_BASE}" \
            "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}" \
            "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" \
            "${__T_MICROSOFT_PACKAGELISTS_FILENAME}" \
            __T_MICROSOFT_PACKAGELISTS_LOCATION; then
            __SETTINGS[CS_INSTALL_MICROSOFT_PACKAGELISTS_LOCATION]="${__T_MICROSOFT_PACKAGELISTS_LOCATION}"
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Location set to: '${__T_MICROSOFT_PACKAGELISTS_LOCATION}'.\n"
        else
            __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not determine the repository location ($?).\n"
            return 41
        fi
    else
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Location was preset to: '${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]}'.\n"
        __T_MICROSOFT_PACKAGELISTS_LOCATION="${__SETTINGS[CS_MICROSOFT_PACKAGELISTS_LOCATION]}"
        __T_CURL_IGNORE_CERTIFICATE=1
    fi

    __T_W_FILE="/tmp/${__T_MICROSOFT_PACKAGELISTS_FILENAME}"

    declare -i __T_RUNS_LEFT=2
    while [[ ${__T_RUNS_LEFT} -gt 0 ]]; do

        if [[ -f "${__T_W_FILE}" ]]; then
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) '${__T_W_FILE}' already exists. Trying to delete...\n"
            if rm -f "${__T_W_FILE}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Success!\n"
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not delete existing '${__T_W_FILE}'.\n"
                return 71
            fi
        fi

        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Beginning installation of Microsoft's package lists...\n"

        if [[ -f "${__T_MICROSOFT_PACKAGELISTS_LOCATION}" ]]; then
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Location seems to be a file.\n"

            if cp "${__T_MICROSOFT_PACKAGELISTS_LOCATION}" "${__T_W_FILE}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File copied.\n"
                unset __T_RUNS_LEFT
                break
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not copy the file ($?).\n"
                return 51
            fi
        else
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Location might be an URL.\n"

            if [[ "${__T_CURL_IGNORE_CERTIFICATE}x" == "x" ]]; then
                __T_CURL_INSECURE=""
            else
                __T_CURL_INSECURE="--insecure"
            fi

            if curl -fsSLo "${__T_W_FILE}" ${__T_CURL_INSECURE} "${__T_MICROSOFT_PACKAGELISTS_LOCATION}" >/dev/null 2>&1; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Sucessfully downloaded '${__T_MICROSOFT_PACKAGELISTS_LOCATION}'.\n"
                unset __T_RUNS_LEFT
                break
            else
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not download from '${__T_MICROSOFT_PACKAGELISTS_LOCATION}'.\n"
                if [[ "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" != "source" ]] &&
                    [[ "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" != "fpkg" ]] &&
                    [[ ${__T_RUNS_LEFT} -gt 1 ]]; then

                    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) The last run was a '${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}' run, which allows us to try again, with the 'source' version.\n"
                    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Changing the repository type to 'source'.\n"
                    __T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE="source"

                    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Generating a new filename...\n"
                    if __microsoft_repository_to_filename \
                        "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}" \
                        "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" \
                        "${ID}" \
                        __T_MICROSOFT_PACKAGELISTS_FILENAME; then
                        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Filename set to: '${__T_MICROSOFT_PACKAGELISTS_FILENAME}'.\n"
                        __T_W_FILE="/tmp/${__T_MICROSOFT_PACKAGELISTS_FILENAME}"
                    else
                        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not determine the filename.\n"
                        return 61
                    fi
                    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Regenerating PACKAGELISTS_LOCATION...\n"
                    if __microsoft_generate_repository_location \
                        "${ID}" \
                        "${VERSION_ID}" \
                        "${__D_MICROSOFT_PACKAGELISTS_LOCATION_BASE}" \
                        "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}" \
                        "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" \
                        "${__T_MICROSOFT_PACKAGELISTS_FILENAME}" \
                        __T_MICROSOFT_PACKAGELISTS_LOCATION; then

                        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Location set to: '${__T_MICROSOFT_PACKAGELISTS_LOCATION}'.\n"
                        ((__T_RUNS_LEFT--)) || true
                        continue
                    else
                        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not create the repository location.\n"
                        unset __T_RUNS_LEFT
                        return 62
                    fi
                else
                    __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) The last run was a '${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}' run. We cannot go again or use the source version.\n"
                    unset __T_RUNS_LEFT
                    return 63
                fi
            fi
        fi
    done

    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Beginning file installation...\n"
    # we're still here, seems like we got a file...
    if [[ "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" =~ ^(pkg|fpkg)$ ]]; then
        # let's try to install it.
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File is a distribution package...\n"
        if [[ "${__T_W_FILE##*.}" == "deb" ]]; then
            if __pm_package_file_install "${__T_W_FILE}"; then

                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File successfully installed.\n"
                rm -r "${__T_W_FILE}"

            else
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Problems installing the file. Exiting.\n"
                return 71
            fi
        else
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File extension is unknown... Exiting.\n"
            return 72
        fi
    elif [[ "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_INSTALLTYPE}" == "source" ]]; then
        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File is a source list...\n"
        if [[ "${__T_W_FILE##*.}" == "list" ]]; then
            # we got a list, we move it over to /etc/apt/sources.list.d
            # and name it after the repo
            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Installing...\n"
            declare __T_DESTINATION_FILE="/etc/apt/sources.list.d/microsoft-${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_BRANCH}.list"

            if [[ ! -d "$(dirname "${__T_DESTINATION_FILE}")" ]]; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Directory '$(dirname "${__T_DESTINATION_FILE}")' does not exists. Attempting to create it...\n"
                if mkdir -p "$(dirname "${__T_DESTINATION_FILE}")"; then
                    __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Success!\n"
                else
                    __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Error ($?)!\n"
                    return 111
                fi
            fi

            if cp "${__T_W_FILE}" "${__T_DESTINATION_FILE}"; then
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) File successfully moved to '${__T_DESTINATION_FILE}'.\n"
                if [[ -f "${__T_W_FILE}" ]]; then
                    rm -f "${__T_W_FILE}" >/dev/null 2>&1
                fi
                chmod 0644 "${__T_DESTINATION_FILE}" >/dev/null 2>&1
            else
                __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not copy the file. Giving up.\n"
                if [[ -f "${__T_W_FILE}" ]]; then
                    rm -f "${__T_W_FILE}" >/dev/null 2>&1
                fi
                return 73
            fi

            # we have a list installed, but the key is still missing.
            # microsoft has two repository keys, we'll install both, just in case..

            __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Installing repository keys.\n"

            for __T_MSKEY_URL in "${__T_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS[@]}"; do
                declare __T_MSKEY_FILE="$(mktemp)"
                __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Installing '${__T_MSKEY_URL}'...\n"
                if curl -fsSLo "${__T_MSKEY_FILE}" "${__T_MSKEY_URL}" >/dev/null 2>&1; then
                    if apt-key add "${__T_MSKEY_FILE}" >/dev/null 2>&1; then
                        __log i -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Key '${__T_MSKEY_URL}' installed.\n"
                    else
                        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Key '${__T_MSKEY_URL}' could not be installed.\n"
                    fi
                else
                    __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Could not download key '${__T_MSKEY_URL}'.\n"
                fi
                if [[ -f "${__T_MSKEY_FILE}" ]]; then
                    rm -f "${__T_MSKEY_FILE}" >/dev/null 2>&1
                fi
            done
        else
            __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Don't know the file extension... Exiting...\n"
            return 74
        fi
    else
        __log e -- "(CS_INSTALL_MICROSOFT_PACKAGELISTS) Where the fuck I am?\n"
        return 75
    fi
}
function __microsoft_packagelists_repository_branch_get() {

    shopt -s nocasematch

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __TP_REPO="${@:1:1}"
        declare __P_REPO="${__TP_REPO,,}"
        unset __TP_REPO
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __variable_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
        __T_RETURN_VALUE=""
    else
        declare __T_RETURN_VALUE=""
    fi

    if [[ "${__P_REPO}" =~ ${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX} ]]; then
        __TP_REPO_N="${__P_REPO//[^:]/}"
        if [[ ${#__TP_REPO_N} -lt 2 ]]; then
            __T_REPO="${__P_REPO}:"
        else
            __T_REPO="${__P_REPO}"
        fi

        IFS=":" read -ra __T_R <<<"${__T_REPO}"
        if [[ ${#__T_R} -lt 2 ]]; then
            return 3
        fi
        if [[ -R __T_RETURN_VALUE ]]; then
            __T_RETURN_VALUE="${__T_R[0]}"
        else
            echo "${__T_R[0]}"
        fi
        return 0
    fi

    return 1
}
function __microsoft_packagelists_repository_installtype_get() {

    shopt -s nocasematch

    if [[ "${@:1:1}x" == "x" ]]; then
        return 1
    else
        declare __TP_REPO="${@:1:1}"
        declare __P_REPO="${__TP_REPO,,}"
        unset __TP_REPO
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __variable_exists "${@:2:1}"; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
    else
        declare __T_RETURN_VALUE=""
    fi

    if [[ ${__P_REPO,,} =~ ${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX} ]]; then
        __T_REPO_N="${__P_REPO//[^:]/}"
        if [[ ${#__T_REPO_N} -lt 1 ]]; then
            __T_REPO="${__P_REPO}::"
        elif [[ ${#__T_REPO_N} -lt 2 ]]; then
            __T_REPO="${__P_REPO}:"
        else
            __T_REPO="${__P_REPO}"
        fi
        IFS=":" read -ra __T_R <<<"${__T_REPO}"

        if [[ ${#__T_R[@]} -lt 2 ]]; then
            return 3
        elif [[ "${__T_R[1]}x" == "x" ]]; then
            declare __T_MPRIG_RETURN_VALUE=""
            if __microsoft_packagelists_get_repotype "${__D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT}" __T_MPRIG_RETURN_VALUE; then
                if [[ -R __T_RETURN_VALUE ]]; then
                    __T_RETURN_VALUE="${__T_MPRIG_RETURN_VALUE}"
                else
                    echo "${__T_MPRIG_RETURN_VALUE}"
                fi
                return 0
            else
                return 111
            fi
        else
            if [[ -R __T_RETURN_VALUE ]]; then
                __T_RETURN_VALUE="${__T_R[1]}"
            else
                echo "${__T_R[1]}"
            fi
            return 0
        fi
    fi
    return 1
}
function __microsoft_repository_to_filename() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_BRANCH="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 3
    else
        declare __P_TYPE="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 4
    else
        declare __P_DISTRIBUTION_ID="${@:3:1}"
    fi
    if [[ "${@:4:1}x" == "x" ]]; then
        declare __T_RETURN_VALUE=""
    elif __variable_exists "${@:4:1}"; then
        declare -n __T_RETURN_VALUE="${@:4:1}"
    else
        declare __T_RETURN_VALUE="${@:4:1}"
    fi

    declare __T_DISTRIBUTION_ID="${__P_DISTRIBUTION_ID}"
    declare __T_ERROR=0
    declare __T_FILENAME_PREFIX=""
    declare __T_FILENAME_BRANCH=""
    declare __T_FILENAME_SUFFIX=""
    declare __T_TYPE="${__P_TYPE}"
    declare __T_FILENAME=""

    if [[ "${__P_BRANCH,,}" == "islow" ]]; then
        __T_FILENAME_BRANCH="insiders-slow"
    elif [[ "${__P_BRANCH,,}" == "ifast" ]]; then
        __T_FILENAME_BRANCH="insiders-fast"
    elif [[ "${__P_BRANCH,,}" == "prod" ]]; then
        __T_FILENAME_BRANCH="prod"
    else
        __log e -- "Unknown branch: '${__P_BRANCH}'.\n"
        return 11
    fi

    if [[ "${__T_DISTRIBUTION_ID,,}" == "debian" ]] ||
        [[ "${__T_DISTRIBUTION_ID,,}" == "ubuntu" ]]; then
        if [[ "${__T_TYPE,,}" == "source" ]]; then
            __T_FILENAME_SUFFIX=".list"
        elif [[ "${__T_TYPE,,}" =~ ^(pkg|fpkg)$ ]]; then
            __T_FILENAME_SUFFIX=".deb"
            __T_FILENAME_PREFIX="packages-microsoft-"
        else
            __T_ERROR=11
        fi
    elif [[ "${__T_DISTRIBUTION_ID,,}" == "centos" ]] ||
        [[ "${__T_DISTRIBUTION_ID,,}" == "fedora" ]] ||
        [[ "${__T_DISTRIBUTION_ID,,}" == "opensuse" ]] ||
        [[ "${__T_DISTRIBUTION_ID,,}" == "opensuse-leap" ]] ||
        [[ "${__T_DISTRIBUTION_ID,,}" == "suse" ]]; then
        if [[ "${__T_TYPE,,}" == "source" ]]; then
            __T_FILENAME_SUFFIX=".repo"
        elif [[ "${__T_TYPE,,}" =~ ^(pkg|fpkg)$ ]]; then
            __T_FILENAME_SUFFIX=".rpm"
            __T_FILENAME_PREFIX="packages-microsoft-"
        else
            __T_ERROR=12
        fi
    else
        __T_ERROR=13
    fi

    if [[ ${__T_ERROR} -gt 0 ]]; then
        return ${__T_ERROR}
    fi

    __T_FILENAME="${__T_FILENAME_PREFIX}${__T_FILENAME_BRANCH}${__T_FILENAME_SUFFIX}"
    if [[ -R __T_RETURN_VALUE ]]; then
        __T_RETURN_VALUE="${__T_FILENAME}"
    else
        echo "${__T_FILENAME}"
    fi
    return 0
}
