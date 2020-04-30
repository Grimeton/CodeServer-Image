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

#####
#
# - lib_rootlayout.sh
#
if ([[ -z ${GLOBAL_INIT_DIRECTORY+x} ]] || [[ "${GLOBAL_INIT_DIRECTORY}x" == "x" ]]); then
    if ([[ -z ${__D_INIT_DIRECTORY+z} ]] || [[ "${__D_INIT_DIRECTORY}x" == "x" ]]); then
        declare -g __ROOTLAYOUT_INIT_DIRECTORY="/usr/local/lib/init/"
    else
        declare -g __ROOTLAYOUT_INIT_DIRECTORY="${__D_INIT_DIRECTORY}"
    fi
else
    declare -g __ROOTLAYOUT_INIT_DIRECTORY="${GLOBAL_INIT_DIRECTORY}"
fi
if ([[ -z ${GLOBAL_INIT_SUBDIRECTORIES[@]+x} ]] || [[ ${#GLOBAL_INIT_SUBDIRECTORIES[@]} -lt 1 ]]); then
    if ([[ -z ${__D_INIT_SUBDIRECTORIES[@]+x} ]] || [[ ${#__D_INIT_SUBDIRECTORIES[@]} -lt 1 ]]); then
        declare -Ag __ROOTLAYOUT_INIT_SUBDIRECTORIES=([lib]="" [aliases]="aliases" [modules]="modules" [repos]="repos")
    else
        declare -Ag __ROOTLAYOUT_INIT_SUBDIRECTORIES=()
        for __T_KEY in "${!__D_INIT_SUBDIRECTORIES[@]}"; do
            __ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]="${__D_INIT_SUBDIRECTORIES[${__T_KEY}]}"
        done
    fi
else
    declare -Ag __ROOTLAYOUT_INIT_SUBDIRECTORIES=()
    for __T_KEY in "${!GLOBAL_INIT_SUBDIRECTORIES[@]}"; do
        __ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]="${GLOBAL_INIT_SUBDIRECTORIES[${__T_KEY}]}"
    done
fi
if ([[ -z ${GLOBAL_INSTALLER_DIRECTORY+x} ]] || [[ "${GLOBAL_INSTALLER_DIRECTORY}x" == "x" ]]); then
    if ([[ -z ${__D_INSTALLER_DIRECTORY+x} ]] || [[ "${__D_INSTALLER_DIRECTORY}x" == "x" ]]); then
        declare -g __ROOTLAYOUT_INSTALLER_DIRECTORY="/opt/installer"
    else
        declare -g __ROOTLAYOUT_INSTALLER_DIRECTORY="${__D_INSTALLER_DIRECTORY}"
    fi
else
    declare -g __ROOTLAYOUT_INSTALLER_DIRECTORY="${GLOBAL_INSTALLER_DIRECTORY}"
fi

if ([[ -z ${GLOBAL_INSTALLER_SUBDIRECTORIES[@]+x} ]] || [[ ${#GLOBAL_INSTALLER_SUBDIRECTORIES[@]} -lt 1 ]]); then
    if ([[ -z ${__D_INSTALLER_SUBDIRECTORIES[@]+x} ]] || [[ ${#__D_INSTALLER_SUBDIRECTORIES[@]} -lt 1 ]]); then
        declare -Ag __ROOTLAYOUT_INSTALLER_SUBDIRECTORIES=([downloads]="downloads" [repos]="repos")
    else
        declare -Ag __ROOTLAYOUT_INSTALLER_SUBDIRECTORIES=()
        for __T_KEY in "${!__D_INSTALLER_SUBDIRECTORIES[@]}"; do
            __ROOTLAYOUT_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__D_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
        done
    fi
else
    declare -Ag __ROOTLAYOUT_INSTALLER_SUBDIRECTORIES=()
    for __T_KEY in "${!GLOBAL_INSTALLER_SUBDIRECTORIES[@]}"; do
        __ROOTLAYOUT_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${GLOBAL_INSTALLER_DIRECTORIES["${__T_KEY}"]}"
    done
fi

if ([[ -z ${GLOBAL_STAGING_DIRECTORY+x} ]] || [[ "${GLOBAL_STAGING_DIRECTORY}x" == "x" ]]); then
    if ([[ -z ${__D_STAGING_DIRECTORY+x} ]] || [[ "${__D_STAGING_DIRECTORY}x" == "x" ]]); then
        declare -g __ROOTLAYOUT_STAGING_DIRECTORY="/usr/src/staging"
    else
        declare -g __ROOTLAYOUT_STAGING_DIRECTORY="${__D_STAGING_DIRECTORY}"
    fi
else
    declare -g __ROOTLAYOUT_STAGING_DIRECTORY="${GLOBAL_STAGING_DIRECTORY}"
fi

#####
#
# - __rootlayout_init
#
# - Description:
#   Called to initialize a new root layout process. Needs to be ended with "__rootlayout_destroy"
#
# - Paramters:
#   NONE.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_init() {
    if __test_variable_exists "__ROOTLAYOUT_BASEDIRECTORY"; then
        __log e -- "Current rootlayout session still runng. Layout directory: '${__ROOTLAYOUT_BASEDIRECTORY}'.\n"
        return 111
    else
        declare __T_ROOTLAYOUT_BASEDIRECTORY=""
        if __T_ROOTLAYOUT_BASEDIRECTORY="$(mktemp -d)"; then
            if declare -gx __ROOTLAYOUT_BASEDIRECTORY="${__T_ROOTLAYOUT_BASEDIRECTORY}"; then
                true
            else
                __log e -- "Could not create global '__ROOTLAYOUT_BASEDIRECTORY' setting ($?).\n"
                return 112
            fi
        else
            __log e -- "Could not get temporary directory for '__ROOTLAYOUT_BASEDIRECTORY' ($?).\n"
            return 113
        fi
    fi

    if __test_variable_exists "__ROOTLAYOUT_ROOTDIRECTORY"; then
        if unset __ROOTLAYOUT_ROOTDIRECTORY; then
            true
        else
            __log e -- "Could not get the existing '__ROOTLAYOUT_ROOTDIRECTORY' unset ($?).\n"
        fi
    fi
    if [[ -d "${__ROOTLAYOUT_BASEDIRECTORY}/system_root" ]]; then
        true
    else
        if mkdir -p "${__ROOTLAYOUT_BASEDIRECTORY}/system_root"; then
            if declare -gx __ROOTLAYOUT_ROOTDIRECTORY="${__ROOTLAYOUT_BASEDIRECTORY}/system_root"; then
                true
            else
                __log e -- "Could not declare '__ROOTLAYOUT_ROOTDIRECTORY'.\n"
            fi
        fi
    fi

}

#####
#
# - __rootlayout_copyto
#
# - Description:
#   Takes a source and a destination and copies it over to the new rootlayout by prepending the temp directory to the
#   destination file. There is no other path magic done here.
#
# - Parameters:
#   - #1 [IN|MANDATORY] FROM: The source where you want to copy from. Can either be a directory, file or symlink.
#   - #2 [IN|MANDATORY] TO: The destination you want to copy to.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#
function __rootlayout_copyto() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ -e "${@:1:1}" ]]; then
        declare __P_FROM="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_TO="${@:2:1}"
    fi

    declare __T_FROM="${__P_FROM}"
    declare __T_TO="${__ROOTLAYOUT_ROOTDIRECTORY}/${__P_TO}"

    if [[ -d "${__T_FROM}" ]]; then
        if [[ -d "${__T_TO}" ]]; then
            true
        elif [[ ! -e "${__T_TO}" ]]; then
            if mkdir -p "${__T_TO}"; then
                true
            else
                __log e -- "Problems creating new destination directory '${__T_TO}' ($?).\n"
                return 111
            fi
        else
            __log e -- "Cannot copy from a directory '${__T_FROM}' to something that is not a directory '${__T_TO}'.\n"
            return 112
        fi
        __T_FROM="${__T_FROM}/."
    elif [[ -f "${__T_FROM}" ]] || [[ -L "${__T_FROM}" ]]; then
        if [[ -d "${__T_TO}" ]]; then
            __T_TO="${__T_TO}/."
            true
        elif [[ -f "${__T_TO}" ]]; then
            true
        elif [[ -L "${__T_TO}" ]]; then
            if rm -f "${__T_TO}"; then
                true
            else
                __log e -- "Problems deleting the link '${__T_TO}' in the destination directory ($?).\n"
                return 113
            fi
        elif [[ -e "${__T_TO}" ]]; then
            __log e -- "Cannot copy from a file to something that is not a directory/file/link: '${__T_TO}'.\n"
            return 114
        elif [[ ! -d "$(dirname "${__T_TO}")" ]]; then
            if mkdir -p "$(dirname "${__T_TO}")"; then
                true
            else
                __log e -- "Problem creating destination directory of '${__T_TO}' ($?).\n"
                return 116
            fi
        fi
    else
        __log e -- "Cannot copy from something that is not a directory/file/link: '${__T_FROM}'.\n"
        return 115
    fi

    if [[ -n ${GLOBAL_DEBUG+x} ]] && [[ "${GLOBAL_DEBUG}x" != "x" ]]; then
        if cp -vLR --preserve=all "${__T_FROM}" "${__T_TO}" | __log_stdin d --; then
            return ${PIPESTATUS[0]}
        else
            return ${PIPESTATUS[0]}
        fi
    else
        if cp -LR --preserve=all "${__T_FROM}" "${__T_TO}"; then
            return 0
        fi
    fi
    return 1
}

#####
#
# - __rootlayout_concatto
#
# - Description:
#   Takes a source and a destination and concats the source file at the end of the destination file. If the file already exists
#   it will be expanded. This makes sense when overwriting functions or variables in bash.
#
# - Parameters:
#   - #1 [IN|MANDATORY] FROM: The source where you want to copy from. Can either be a directory, file or symlink.
#   - #2 [IN|MANDATORY] TO: The destination you want to copy to.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#
function __rootlayout_concatto() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ -e "${@:1:1}" ]]; then
        declare __P_FROM="${@:1:1}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_TO="${@:2:1}"
    fi

    declare __T_FROM="${__P_FROM}"
    declare __T_TO="${__ROOTLAYOUT_ROOTDIRECTORY}/${__P_TO}"

    if [[ -f "${__T_FROM}" ]]; then
        true
    else
        return 111
    fi

    if [[ -f "${__T_TO}" ]]; then
        true
    elif [[ -L "${__T_TO}" ]]; then
        if rm "${__T_TO}"; then
            true
        else
            return 112
        fi
    elif [[ -e "${__T_TO}" ]]; then
        return 113
    elif [[ -d "$(dirname "${__T_TO}")" ]]; then
        true
    elif mkdir -p "$(dirname "${__T_TO}")"; then
        true
    else
        return 114
    fi
    if echo "" >> "${__T_TO}"; then
        true
    else
        return 2
    fi
    if cat "${__T_FROM}" >>"${__T_TO}"; then
        return 0
    fi
    return 1
}

#####
#
# - __rootlayout_copy_libraries
#
# - Description:
#   Takes the parameters and generates a library layout in the destination root so that it is able to use the library there.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: DISTRIBUTION_ID - The distribution ID (ID in /etc/os-release)
#   - #2 [IN|OPTIONAL]: DISTRIBUTION_VERSION_ID - The distribution VERSION_ID from /etc/os-release
#   - #3 [IN|MANDATORY]: STAGENAME - One or more stage names that we should consider when creating the layout
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_copy_libraries() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID=""
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi

    if [[ "${@:3}x" == "x" ]]; then
        return 102
    else
        declare -a __P_STAGES=("${@:3}")
    fi

    declare -a __T_SUBDIRECTORY_PREFIXES=()
    __T_SUBDIRECTORY_PREFIXES+=("all")
    __T_SUBDIRECTORY_PREFIXES+=("${__P_DISTRIBUTION_ID}/all")
    if [[ "${__P_DISTRIBUTION_VERSION_ID}x" != "x" ]]; then
        __T_SUBDIRECTORY_PREFIXES+=("${__P_DISTRIBUTION_ID}/${__P_DISTRIBUTION_VERSION_ID}")
    fi
    for __T_STAGE in "${__P_STAGES[@]}"; do
        case "${__T_STAGE}" in
        build)
            if [[ -z ${BUILD_INIT_DIRECTORY+x} ]]; then
                declare __THIS_INIT_DIRECTORY="${__ROOTLAYOUT_INIT_DIRECTORY}"
            elif [[ "${BUILD_INIT_DIRECTORY}x" == "x" ]]; then
                declare __THIS_INIT_DIRECTORY="${__ROOTLAYOUT_INIT_DIRECTORY}"
            else
                declare __THIS_INIT_DIRECTORY="${BUILD_INIT_DIRECTORY}"
            fi
            if [[ -z ${BUILD_INIT_SUBDIRECTORIES[@]+x} ]]; then
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            elif [[ ${#BUILD_INIT_SUBDIRECTORIES[@]} -lt 1 ]]; then
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            else
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!BUILD_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${BUILD_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            fi
            ;;
        run)
            if [[ -z ${RUN_INIT_DIRECTORY+x} ]]; then
                declare __THIS_INIT_DIRECTORY="${__ROOTLAYOUT_INIT_DIRECTORY}"
            elif [[ "${RUN_INIT_DIRECTORY}x" == "x" ]]; then
                declare __THIS_INIT_DIRECTORY="${__ROOTLAYOUT_INIT_DIRECTORY}"
            else
                declare __THIS_INIT_DIRECTORY="${RUN_INIT_DIRECTORY}"
            fi
            if [[ -z ${RUN_INIT_SUBDIRECTORIES[@]+x} ]]; then
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            elif [[ ${#RUN_INIT_SUBDIRECTORIES[@]} -lt 1 ]]; then
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            else
                declare -A __THIS_INIT_SUBDIRECTORIES=()
                for __T_KEY in "${!RUN_INIT_SUBDIRECTORIES[@]}"; do
                    __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${RUN_INIT_SUBDIRECTORIES[${__T_KEY}]}"
                done
            fi
            ;;
        *)
            declare __THIS_INIT_DIRECTORY="${__ROOTLAYOUT_INIT_DIRECTORY}"
            declare -A __THIS_INIT_SUBDIRECTORIES=()
            for __T_KEY in "${!__ROOTLAYOUT_INIT_SUBDIRECTORIES[@]}"; do
                __THIS_INIT_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INIT_SUBDIRECTORIES["${__T_KEY}"]}"
            done
            ;;
        esac
        for __T_SUBDIRECTORY_PREFIX in "${__T_SUBDIRECTORY_PREFIXES[@]}"; do
            for __T_INIT_DIRECTORY in "${!__THIS_INIT_SUBDIRECTORIES[@]}"; do
                declare __T_CURRENT_DIRECTORY="${G_IMAGES_DIR}/${__T_STAGE}/${__T_SUBDIRECTORY_PREFIX}/${__T_INIT_DIRECTORY}"
                if [[ -d "${__T_CURRENT_DIRECTORY}" ]]; then
                    declare __T_OLD_PWD="${PWD}"
                    cd "${__T_CURRENT_DIRECTORY}"
                    while read __T_FILE; do
                        declare __T_FILE_SOURCE="${G_IMAGES_DIR}/${__T_STAGE}/${__T_SUBDIRECTORY_PREFIX}/${__T_INIT_DIRECTORY}/${__T_FILE}"
                        declare __T_FILE_DESTINATION="${__THIS_INIT_DIRECTORY}/${__THIS_INIT_SUBDIRECTORIES[${__T_INIT_DIRECTORY}]}/${__T_FILE}"
                        if [[ -f "${__T_FILE_SOURCE}" ]]; then
                            if __rootlayout_concatto "${__T_FILE_SOURCE}" "${__T_FILE_DESTINATION}"; then
                                continue
                            else
                                __log e -- "Problems concatting '${__T_FILE_SOURCE}' to '${__T_FILE_DESTINATION}' ($?).\n"
                            fi
                        else
                            __log de -- "'SOURCE NOT FOUND'.\n"
                        fi
                    done < <(find -L "./" -type f)
                    cd "${__T_OLD_PWD}"
                    unset __T_OLD_PWD
                fi
            done
        done
        if ([[ -n ${GLOBAL_CONFIG_FILENAME+x} ]] && [[ -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]); then
            chmod 644 "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"
            if __rootlayout_copyto "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" "${__THIS_INIT_DIRECTORY}/settings.conf"; then
                true
            else
                __log e -- "Problems copying the init file ($?).\n"
                return 131
            fi
        elif [[ -f "${G_LIB_DIR}/settings.conf" ]]; then
            if __rootlayout_copyto "${G_LIB_DIR}/settings.conf" "${__THIS_INIT_DIRECTORY}/settings.conf"; then
                true
            else
                __log e -- "Problems copying the init file ($?).\n"
                return 132
            fi
        fi

    done
}
#####
#
# - __rootlayout_copy_installer
#
# - Description:
#   Takes the parameters and generates an installer layout in the destination root so that the installer can be used.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: DISTRIBUTION_ID - The distribution ID (ID in /etc/os-release)
#   - #2 [IN|OPTIONAL]: DISTRIBUTION_VERSION_ID - The distribution VERSION_ID from /etc/os-release
#   - #3- [IN|MANDATORY]: STAGENAME - One or more stage names that we should consider when creating the layout
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_copy_installer() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID=""
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi

    if [[ "${@:3}x" == "x" ]]; then
        return 102
    else
        declare -a __P_STAGES=("${@:3}")
    fi

    declare -a __T_SUBDIRECTORY_PREFIXES=()
    __T_SUBDIRECTORY_PREFIXES+=("all")
    __T_SUBDIRECTORY_PREFIXES+=("${__P_DISTRIBUTION_ID}/all")
    if [[ "${__P_DISTRIBUTION_VERSION_ID}x" != "x" ]]; then
        __T_SUBDIRECTORY_PREFIXES+=("${__P_DISTRIBUTION_ID}/${__P_DISTRIBUTION_VERSION_ID}")
    fi
    for __T_STAGE in "${__P_STAGES[@]}"; do
        case "${__T_STAGE}" in
        build)
            if [[ -z ${BUILD_INSTALLER_DIRECTORY+x} ]]; then
                declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
            elif [[ "${BUILD_INSTALLER_DIRECTORY}x" == "x" ]]; then
                declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
            else
                declare __THIS_INSTALLER_DIRECTORY="${BUILD_INSTALLER_DIRECTORY}"
            fi
            if [[ -z ${BUILD_INSTALLER_SUBDIRECTORIES[@]+x} ]]; then
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            elif [[ ${#BUILD_INSTALLER_SUBDIRECTORIES[@]} -lt 1 ]]; then
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            else
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!BUILD_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${BUILD_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            fi
            ;;
        run)
            if [[ -z ${RUN_INSTALLER_DIRECTORY+x} ]]; then
                declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
            elif [[ "${RUN_INSTALLER_DIRECTORY}x" == "x" ]]; then
                declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
            else
                declare __THIS_INSTALLER_DIRECTORY="${RUN_INSTALLER_DIRECTORY}"
            fi
            if [[ -z ${RUN_INSTALLER_SUBDIRECTORIES[@]+x} ]]; then
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            elif [[ ${#RUN_INSTALLER_SUBDIRECTORIES[@]} -lt 1 ]]; then
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            else
                declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
                for __T_KEY in "${!RUN_INSTALLER_SUBDIRECTORIES[@]}"; do
                    __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${RUN_INSTALLER_SUBDIRECTORIES[${__T_KEY}]}"
                done
            fi
            ;;
        *)
            declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
            declare -A __THIS_INSTALLER_SUBDIRECTORIES=()
            for __T_KEY in "${!__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES[@]}"; do
                __THIS_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]="${__ROOTLAYOUT_INSTALLER_SUBDIRECTORIES["${__T_KEY}"]}"
            done
            ;;
        esac
        for __T_SUBDIRECTORY_PREFIX in "${__T_SUBDIRECTORY_PREFIXES[@]}"; do
            for __T_INSTALLER_DIRECTORY in "${!__THIS_INSTALLER_SUBDIRECTORIES[@]}"; do
                declare __T_CURRENT_DIRECTORY="${G_IMAGES_DIR}/${__T_STAGE}/${__T_SUBDIRECTORY_PREFIX}/${__T_INSTALLER_DIRECTORY}"
                if [[ -d "${__T_CURRENT_DIRECTORY}" ]]; then
                    declare __T_OLD_PWD="${PWD}"
                    cd "${__T_CURRENT_DIRECTORY}"
                    while read __T_FILE; do
                        declare __T_FILE_SOURCE="${G_IMAGES_DIR}/${__T_STAGE}/${__T_SUBDIRECTORY_PREFIX}/${__T_INSTALLER_DIRECTORY}/${__T_FILE}"
                        declare __T_FILE_DESTINATION="${__THIS_INSTALLER_DIRECTORY}/${__THIS_INSTALLER_SUBDIRECTORIES[${__T_INSTALLER_DIRECTORY}]}/${__T_FILE}"
                        if [[ -f "${__T_FILE_SOURCE}" ]]; then
                            if __rootlayout_copyto "${__T_FILE_SOURCE}" "${__T_FILE_DESTINATION}"; then
                                continue
                            else
                                __log e -- "Problems concatting '${__T_FILE_SOURCE}' to '${__T_FILE_DESTINATION}' ($?).\n"
                            fi
                        else
                            __log de -- "'SOURCE NOT FOUND'.\n"
                        fi
                    done < <(find -L "./" -type f)
                    cd "${__T_OLD_PWD}"
                    unset __T_OLD_PWD
                fi
            done
        done
    done
}
#####
#
# - __rootlayout_copy_stages
#
# - Description:
#   Takes the parameters and generates a full layout considering all the stages given to it.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: DISTRIBUTION_ID - The distribution ID (ID in /etc/os-release)
#   - #2 [IN|OPTIONAL]: DISTRIBUTION_VERSION_ID - The distribution VERSION_ID from /etc/os-release
#   - #3- [IN|MANDATORY]: STAGENAME - One or more stage names that we should consider when creating the layout
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_copy_stages() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID=""
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 102
    else
        declare -a __P_STAGES=("${@:3}")
    fi

    if __rootlayout_copy_libraries "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "${__P_STAGES[@]}"; then
        true
    else
        __log e -- "Problems copying the libraries ($?).\n"
        return 111
    fi

    if __rootlayout_copy_installer "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "${__P_STAGES[@]}"; then
        true
    else
        __log e -- "Problems copying the installer ($?).\n"
        return 112
    fi

    if __rootlayout_copy_systemroot "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "${__P_STAGES[@]}"; then
        true
    else
        __log e -- "Problems copying the system_root ($?).\n"
    fi
    for __T_STAGE in "${__P_STAGES[@]}"; do
        case "${__T_STAGE}" in
        base)
            if __rootlayout_stages_base "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}"; then
                true
            else
                __log e -- "Problems running base stage function ($?).\n"
                return 131
            fi
            ;;
        build)
            if __rootlayout_stages_build "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}"; then
                true
            else
                __log e -- "Problems running build stage function ($?).\n"
                return 131
            fi
            ;;
        run)
            if __rootlayout_stages_run "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}"; then
                true
            else
                __log e -- "Problems running run stage function ($?).\n"
                return 131
            fi
            ;;
        *)
            __log e -- "Stage '${__T_STAGE}' is unknown.\n"
            return 254
            ;;
        esac
    done
}
function __rootlayout_copy_systemroot() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID=""
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi
    if [[ "${@:3}x" == "x" ]]; then
        return 102
    else
        declare __P_STAGES=("${@:3}")
    fi

    declare -a __THIS_DIRECTORY_PREFIXES=("all" "${__P_DISTRIBUTION_ID}/all")
    if [[ "${__P_DISTRIBUTION_VERSION_ID}x" != "x" ]]; then
        __THIS_DIRECTORY_PREFIXES+=("${__P_DISTRIBUTION_ID}/${__P_DISTRIBUTION_VERSION_ID}")
    fi
    declare -A __THIS_DIRECTORY_SUFFIXES=(["system_root"]="/")
    declare -i __T_ERRORS=0
    if [[ -n ${GLOBAL_DEBUG+x} ]] && [[ "${GLOBAL_DEBUG}x" != "x" ]]; then
        __log_banner d -- "BEGIN: SYSTEM ROOT."
    fi
    for __T_STAGE in "${__P_STAGES[@]}"; do
        __log v -- __T_STAGE
        for __T_DIRECTORY_PREFIX in "${__THIS_DIRECTORY_PREFIXES[@]}"; do
            __log v -- __T_DIRECTORY_PREFIX
            for __T_DIRECTORY_SUFFIX in "${!__THIS_DIRECTORY_SUFFIXES[@]}"; do
                __log v -- __T_DIRECTORY_SUFFIX
                declare __T_CURRENT_RELATIVE_DIRECTORY="${__T_STAGE,,}/${__T_DIRECTORY_PREFIX}/${__T_DIRECTORY_SUFFIX}"
                __log v -- __T_CURRENT_RELATIVE_DIRECTORY
                declare __T_CURRENT_DIRECTORY="${G_IMAGES_DIR}/${__T_CURRENT_RELATIVE_DIRECTORY}"
                __log v -- __T_CURRENT_DIRECTORY
                if [[ -d "${__T_CURRENT_DIRECTORY}" ]]; then
                    if __rootlayout_copyto "${__T_CURRENT_DIRECTORY}" "${__THIS_DIRECTORY_SUFFIXES["${__T_DIRECTORY_SUFFIX}"]}"; then
                        true
                    else
                        __log e -- "Problems copying from '${__T_CURRENT_DIRECTORY}' to '"${__THIS_DIRECTORY_SUFFIXES["${__T_DIRECTORY_SUFFIX}"]}"' ($?)."
                        ((__T_ERRORS++)) || true
                    fi
                else
                    __log d -- "Directory '${__T_CURRENT_DIRECTORY}' does not exist ($?).\n"
                fi
            done
        done
    done
    if [[ -n ${GLOBAL_DEBUG+x} ]] && [[ "${GLOBAL_DEBUG}x" != "x" ]]; then
        __log_banner d -- "END: SYSTEM ROOT."
    fi
    return 0
}
#####
#
# - __rootlayout_stages_base
#
# - Description:
#   This function is called to do special layout things regarding to the base stage.
#
# - Paramters:
#   - #1 [IN] - DISTRIBUTION_ID
#   - #2 [IN] - DISTRIBUTION_VERSION_ID
#
function __rootlayout_stages_base() {
    return 0
}
#####
#
# - __rootlayout_stages_build
#
# - Description:
#   This function is called to do special layout things regarding to the build stage.
#
# - Paramters:
#   - #1 [IN] - DISTRIBUTION_ID
#   - #2 [IN] - DISTRIBUTION_VERSION_ID
#
function __rootlayout_stages_build() {

    if ([[ -z ${BUILD_STAGING_DIRECTORY+x} ]] || [[ "${BUILD_STAGING_DIRECTORY}x" == "x" ]]); then
        declare __THIS_STAGING_DIRECTORY="${__ROOTLAYOUT_STAGING_DIRECTORY}"
    else
        declare __THIS_STAGING_DIRECTORY="${BUILD_STAGING_DIRECTORY}"
    fi

    if __rootlayout_copy_staging_directory "${__THIS_STAGING_DIRECTORY}"; then
        true
    else
        __log e -- "Problems copying the staging directory ($?).\n"
    fi

    declare __THIS_CONFIG_FILE=""
    if [[ -n ${GLOBAL_CONFIG_FILENAME+x} ]] && [[ -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]; then
        __THIS_CONFIG_FILE="${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"
    elif [[ -f "${G_LIB_DIR}/settings.conf" ]]; then
        __THIS_CONFIG_FILE="${G_LIB_DIR}/settings.conf"
    fi

    if ([[ "${__THIS_CONFIG_FILE}x" != "x" ]] && [[ -f "${__THIS_CONFIG_FILE}" ]]); then
        if __rootlayout_copyto "${__THIS_CONFIG_FILE}" "${__THIS_STAGING_DIRECTORY}/images/base/all/lib/settings.conf"; then
            true
        else
            __log e -- "Problems copying '${__THIS_CONFIG_FILE}' to '${__THIS_STAGING_DIRECTORY}/images/base/all/lib/settings.conf' ($?).\n"
        fi
    fi

    if ([[ -n ${GLOBAL_PUSH_PASSWORD_FILE+x} ]] && [[ "${GLOBAL_PUSH_PASSWORD_FILE}" != ".pushpasswd" ]] && [[ -f "${GLOBAL_PUSH_PASSWORD_FILE}" ]]); then
        if [[ -f "${__THIS_STAGING_DIRECTORY}/.pushpasswd" ]]; then
            true
        else
            if __rootlayout_copyto "${GLOBAL_PUSH_PASSWORD_FILE}" "${__THIS_STAGING_DIRECTORY}/.pushpasswd"; then
                declare -gx GLOBAL_PUSH_PASSWORD_FILE=".pushpasswd"
            else
                __log e -- "Could not copy 'GLOBAL_PUSH_PASSWORD_FILE' ($?).\n"
            fi
        fi
    fi
    if ([[ -n ${GLOBAL_PUSH_USERNAME_FILE+x} ]] && [[ "${GLOBAL_PUSH_USERNAME_FILE}" != ".pushuser" ]] && [[ -f "${GLOBAL_PUSH_USERNAME_FILE}" ]]); then
        if [[ -f "${__THIS_STAGING_DIRECTORY}/.pushuser" ]]; then
            true
        else
            if __rootlayout_copyto "${GLOBAL_PUSH_PASSWORD_FILE}" "${__THIS_STAGING_DIRECTORY}/.pushuser"; then
                declare -gx GLOBAL_PUSH_USERNAME_FILE=".pushuser"
            else
                __log e -- "Could not copy 'GLOBAL_PUSH_USERNAME_FILE' ($?).\n"
            fi
        fi
    fi

    return 0
}
#####
#
# - __rootlayout_stages_run
#
# - Description:
#   This function is called to do special layout things regarding to the run stage.
#
# - Paramters:
#   - #1 [IN] - DISTRIBUTION_ID
#   - #2 [IN] - DISTRIBUTION_VERSION_ID
#
function __rootlayout_stages_run() {

    if ([[ -z ${RUN_INSTALLER_DIRECTORY+x} ]] || [[ "${RUN_INSTALLER_DIRECTORY}x" == "x" ]]); then
        declare __THIS_INSTALLER_DIRECTORY="${__ROOTLAYOUT_INSTALLER_DIRECTORY}"
    else
        declare __THIS_INSTALLER_DIRECTORY="${RUN_INSTALLER_DIRECTORY}"
    fi
    if [[ -f "${G_BASE_DIR}/__CODE_SERVER_TARBALL__" ]]; then
        declare __T_CODESERVER_DIRECTORY="${__ROOTLAYOUT_ROOTDIRECTORY}/opt/code-server"
        if [[ -d "${__T_CODESERVER_DIRECTORY}" ]]; then
            true
        elif mkdir -p "${__T_CODESERVER_DIRECTORY}"; then
            true
        fi

        if tar xvf "${G_BASE_DIR}/__CODE_SERVER_TARBALL__" -C "${__T_CODESERVER_DIRECTORY}"; then
            true
        else
            __log e -- "Problems extracting the code server tarball... ($?).\n"
        fi
    fi

    for __T_DOWNLOAD_FILE in "${__ROOTLAYOUT_ROOTDIRECTORY}/${__THIS_INSTALLER_DIRECTORY}/downloads/"*.sh; do
        if [[ -f "${__T_DOWNLOAD_FILE}" ]]; then
            if source "${__T_DOWNLOAD_FILE}"; then
                if [[ -n ${DOWNLOAD_DESTINATION+x} ]] && [[ "${DOWNLOAD_DESTINATION}x" != "x" ]]; then
                    if [[ -f "${DOWNLOAD_DESTINATION}" ]]; then
                        if __rootlayout_copyto "${DOWNLOAD_DESTINATION}" "${DOWNLOAD_DESTINATION}"; then
                            if rm -f "${__T_DOWNLOAD_FILE}"; then
                                true
                            else
                                __log e -- "Problems deleting '${__T_DOWNLOAD_FILE}' after successfully copying '${DOWNLOAD_DESTINATION}'.\n"
                            fi
                        else
                            __log e -- "Problems copying '${DOWNLOAD_DESTINATION}' ($?).\n"
                        fi
                    fi
                fi
            fi
        fi
    done
    

}
#####
#
# - __rootlayout_staging_directory
#
# - Description:
#   When called, creates a complete staging directory layout in the new root directory.
#
# - Paramters:
#   - #1 [IN|OPTIONAL] - STAGING_DIRECTORY
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_copy_staging_directory() {

    if [[ "${@:1:1}x" == "x" ]]; then
        if [[ -z ${BUILD_STAGING_DIRECTORY+x} ]] || [[ "${BUILD_STAGING_DIRECTORY}x" == "x" ]]; then
            declare __P_STAGING_DIRECTORY="${__ROOTLAYOUT_STAGING_DIRECTORY}"
        else
            declare __P_STAGING_DIRECTORY="${BUILD_STAGING_DIRECTORY}"
        fi
    else
        declare __P_STAGING_DIRECTORY="${@:1:1}"
    fi
    if [[ -d "${G_BASE_DIR}" ]]; then
        if __rootlayout_copyto "${G_BASE_DIR}" "${__P_STAGING_DIRECTORY}"; then
            return 0
        else
            __log e -- "Problems copying staging directory ($?).\n"
        fi
    else
        __log e -- "WHERETHEFUCKIAM?"
        return 253
    fi

}

#####
#
# - __rootlayout_destroy
#
# - Description:
#   To be called when everything with the rootlayout has been done and it can be destroyed.
#   Once called, it will all be gone....
#
# - Paramters:
#   NONE
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __rootlayout_destroy() {
    if __test_variable_exists "__ROOTLAYOUT_BASEDIRECTORY"; then
        if [[ -d "${__ROOTLAYOUT_BASEDIRECTORY}" ]]; then
            if rm -rf "${__ROOTLAYOUT_BASEDIRECTORY}"; then
                true
            else
                __log e -- "Could not delete '__ROOTLAYOUT_BASEDIRECTORY':'${__ROOTLAYOUT_BASEDIRECTORY}' ($?).\n"
                return 111
            fi
        fi
        if unset __ROOTLAYOUT_BASEDIRECTORY; then
            true
        else
            __log e -- "Could not unset '__ROOTLAYOUT_BASEDIRECTORY':'${__ROOTLAYOUT_BASEDIRECTORY}' ($?).\n"
            return 112
        fi
    fi

    if __test_variable_exists "__ROOTLAYOUT_ROOTDIRECTORY"; then
        if [[ -d "${__ROOTLAYOUT_ROOTDIRECTORY}" ]]; then
            if rm -rf "${__ROOTLAYOUT_ROOTDIRECTORY}"; then
                true
            else
                __log e -- "Problems deleting '__ROOTLAYOUT_ROOTDIRECTORY':'${__ROOTLAYOUT_ROOTDIRECTORY}' ($?).\n"
                return 113
            fi
        fi
        if unset "__ROOTLAYOUT_ROOTDIRECTORY"; then
            true
        else
            __log e -- "Could not unset '__ROOTLAYOUT_ROOTDIRECTORY':'${__ROOTLAYOUT_ROOTDIRECTORY}' ($?).\n"
            return 114
        fi
    fi

    return 0
}
