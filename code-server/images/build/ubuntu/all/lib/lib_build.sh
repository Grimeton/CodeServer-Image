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

function __vscode_gather_information() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILENAME="${@:1:1}"
    fi
    declare -a __T_VARIABLES_TO_SAVE=()

    declare __T_OLDPWD="${PWD}"
    cd "${__B_BUILD_DIR}" || return 101

    if __BUILD_GIT_HASH="$(git show -s --pretty='format:%h')"; then
        __T_VARIABLES_TO_SAVE+=(__BUILD_GIT_HASH)
    fi
    if __BUILD_GIT_TAG="$(git describe --tags)"; then
        __T_VARIABLES_TO_SAVE+=(__BUILD_GIT_TAG_DESCRIPTION)
    fi

    if which jq >/dev/null 2>&1; then
        if __BUILD_CODESERVER_VERSION=$(cat package.json | jq -r .version); then
            __T_VARIABLES_TO_SAVE+=(__BUILD_CODESERVER_VERSION)
        fi
    else
        if __BUILD_CODESERVER_VERSION="$(cat package.json | grep version | sed -E 's/^.*:\ "([0-9|\.]+).*$/\1/g')"; then
            __T_VARIABLES_TO_SAVE+=(__BUILD_CODESERVER_VERSION)
        fi
    fi

    if [[ ${#__T_VARIABLES_TO_SAVE[@]} -gt 0 ]]; then
        __environment_save_file "${__P_FILENAME}" "${__T_VARIABLES_TO_SAVE[@]}"
    fi
    cd "${__T_OLDPWD}" || return 102
    return 0

}
function __vscode_prepare_build() {

    declare __T_OLD_PWD="${PWD}"

    if [[ ! -d "${__CONFIG[BUILD_BUILD_DIRECTORY]%%/}" ]]; then
        if ! mkdir -p "${__CONFIG[BUILD_BUILD_DIRECTORY]%%/}"; then
            return 101
        fi
    fi

    cd "${__CONFIG[BUILD_BUILD_DIRECTORY]%%/}" || return 102

    git clone https://github.com/cdr/code-server.git "${__B_BUILD_DIR}" || return 103
    cd "${__B_BUILD_DIR%%/}" || return 104

    if [[ "${__CONFIG[BUILD_VSCODE_GIT_BRANCH]}x" != "x" ]]; then
        git checkout "${__CONFIG[BUILD_VSCODE_GIT_BRANCH]}" | __log_stdin d --
        for __T_PS in ${PIPESTATUS[@]}; do
            if [[ ${__T_PS} -ne 0 ]]; then
                __log e -- "COULD NOT CHECKOUT GIT BRANCH: '${__CONFIG[BUILD_VSCODE_GIT_BRANCH]}'. Exiting (${__T_PS}).\n"
                return ${__T_PS}
            fi
        done
    fi

    if [[ "${__CONFIG[BUILD_VSCODE_GIT_TAG]}x" == "x" ]]; then
        true
    elif [[ "${__CONFIG[BUILD_VSCODE_GIT_TAG]}" == "__LATEST__" ]]; then
        declare __T_GIT_TAG=""
        if __T_GIT_TAG="$(git tag | tail -1)"; then
            true
        else
            __log e -- "Problems getting the latest git tag... ($?).\n"
            return 231
        fi
    else
        declare __T_GIT_TAG=""
        if __T_GIT_TAG="$(git tag | grep -E "^${__CONFIG[BUILD_VSCODE_GIT_TAG]}\$")"; then
            if [[ "${__T_GIT_TAG}" == "${__CONFIG[BUILD_VSCODE_GIT_TAG]}" ]]; then
                true
            else
                __log e -- "Problems verifying the tag '${__CONFIG[BUILD_VSCODE_GIT_TAG]}', result: '${__T_GIT_TAG}' ($?).\n"
                return 233
            fi
        else
            __log e -- "Problems verifying the tag '${__CONFIG[BUILD_VSCODE_GIT_TAG]}' ($?).\n"
        fi
    fi

    if [[ -z ${__T_GIT_TAG+x} ]]; then
        true
    elif [[ "${__T_GIT_TAG}x" == "x" ]]; then
        true
    else
        if git checkout "tags/${__T_GIT_TAG}"; then
            __log i -- "Switched to tag 'tags/${__T_GIT_TAG}' (${__CONFIG[BUILD_VSCODE_GIT_TAG]}) as requested.\n"
            if [[ -z ${__CONFIG[BUILD_BUILDVERSION_RELEASE]+x} ]]; then
                true
            elif [[ "${__CONFIG[BUILD_BUILDVERSION_RELEASE]}x" == "x" ]]; then
                true
            else
                declare __T_GIT_HASH=""
                if __T_GIT_HASH="$(git show -s --pretty='format:%h')"; then
                    true
                else
                    __log e -- "Problems getting the git hash ($?).\n"
                    return 235
                fi
                __B_TARBALL_FILENAME="codeserver-${__CONFIG[BUILD_BUILDVERSION_RELEASE]}-${__T_GIT_TAG}-${__T_GIT_HASH}-${__CONFIG[BUILD_DISTRIBUTION_ID]}-${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}-${__B_DATE}.tar.${__B_TARBALL_COMPRESSION_TYPE,,}"
                __B_INFO_FILENAME="codeserver-${__CONFIG[BUILD_BUILDVERSION_RELEASE]}-${__T_GIT_TAG}-${__T_GIT_HASH}-${__CONFIG[BUILD_DISTRIBUTION_ID]}-${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}-${__B_DATE}.info"
                __B_TARBALL_FILE="${__B_TARBALL_PATH%%/}/${__B_TARBALL_FILENAME}"
                __B_INFO_FILE="${__B_TARBALL_PATH%%/}/${__B_INFO_FILENAME}"
                __B_TARBALL_LINK="${__B_TARBALL_PATH%%/}/${__B_TARBALL_LINKNAME}"
                __B_INFO_LINK="${__B_TARBALL_PATH%%/}/${__B_INFO_LINKNAME}"
            fi
        else
            __log e -- "Problems checking out git tag 'tags/${__T_GIT_TAG}' ($?).\n"
            return 234
        fi
    fi

    if yarn; then
        __log i -- "Running 'yarn' successful.\n"
    else
        __log e -- "Problem running 'yarn' ($?).\n"
        return 106
    fi

    if yarn vscode; then
        __log i -- "Running 'yarn vscode' successful.\n"
    else
        __log e -- "Problem running 'yarn' ($?).\n"
        return 107
    fi

    cd "${__T_OLD_PWD}" || return 108

}
function __vscode_build() {

    declare __T_OLD_PWD="${PWD}"
    cd "${__B_BUILD_DIR}" || return 101
    export MINIFY="true"
    yarn build || return 102
    cd "${__T_OLD_PWD}"

}

function __vscode_create_package() {

    declare __T_OLD_PWD="${PWD}"
    declare __T_FILES_TO_COPY=("README.md" "LICENSE.txt" "lib/vscode/ThirdPartyNotices.txt" "ci/code-server.sh")
    declare __T_NODE=

    # not needed, we come with our own version
    if __T_NODE="$(which node)"; then
        __T_FILES_TO_COPY+=("${__T_NODE}")
    fi

    if [[ ! -d "${__B_TARBALL_PATH}" ]]; then
        mkdir -p "${__B_TARBALL_PATH}" || return 101
    fi

    cd "${__B_BUILD_DIR%%}"

    __log i -- "Copying files...\n"

    declare __T_FILE=""

    for __T_FILE in "${__T_FILES_TO_COPY[@]}"; do
        if [[ -f "${__T_FILE}" ]]; then
            cp -LR --preserve=all "${__T_FILE}" ./build || return 102
        fi
    done

    unset __T_FILE

    cd "${__B_BUILD_DIR%%/}/build" || return 103

    __COMPRESS_COMMAND="bzip2 -9"
    if [[ "${__B_TARBALL_COMPRESSION_TYPE,,}" == "gz" ]]; then
        __COMPRESS_COMMAND="gzip -9"
    fi

    if tar cvf - ./ | ${__COMPRESS_COMMAND} >"${__B_TARBALL_FILE}"; then
        __log i -- "Tarball '${__B_TARBALL_FILE}' successfully created.\n"
    else
        __log e -- "Couldn't create the tarball. Exiting.\n"
        return 104
    fi

    if __vscode_gather_information "${__B_INFO_FILE}"; then
        __log i -- "'__vscode_gather_information' ran successfully.\n"
    else
        declare -i __T_ERROR=$?
        __log e -- "Problems running '__vscode_gather_information'. Returning (${__T_ERROR}).\n"
        return ${__T_ERROR}
    fi

    if [[ -e "${__B_TARBALL_LINK}" ]]; then
        if [[ -L "${__B_TARBALL_LINK}" ]]; then
            rm "${__B_TARBALL_LINK}" || return 108
            ln -rs "${__B_TARBALL_FILE}" "${__B_TARBALL_LINK}" || return 109
        else
            __log w -- "'${__B_TARBALL_LINK}' is not a link. Will not attempt to link to '${__B_TARBALL_FILE}'.\n"
        fi
    else
        ln -rs "${__B_TARBALL_FILE}" "${__B_TARBALL_LINK}" || return 110
    fi

    if [[ -e "${__B_INFO_LINK}" ]]; then
        if [[ -L "${__B_INFO_LINK}" ]]; then
            rm "${__B_INFO_LINK}" || return 111
            if [[ -f "${__B_INFO_FILE}" ]]; then
                ln -rs "${__B_INFO_FILE}" "${__B_INFO_LINK}" || return 112
            fi
        else
            __log w -- "'${__B_INFO_LINK}' is not a link. Will not attempt to link to '${__B_INFO_FILE}'.\n"
        fi
    else
        if [[ -f "${__B_INFO_FILE}" ]]; then
            ln -rs "${__B_INFO_FILE}" "${__B_INFO_LINK}"
        fi

    fi

    cd "${__T_OLD_PWD}" || return 113
}
function __vscode_after_build() {

    # this is necessary to create the image without building!
    if [[ -L "${__B_TARBALL_LINK}" ]]; then
        __log i -- "Found '${__B_TARBALL_LINK}'. Going to use it...\n"
        cp "${__B_TARBALL_LINK}" "${G_BASE_DIR%%/}/__CODE_SERVER_TARBALL__" || return 101
    elif [[ -f "${__B_TARBALL_FILE}" ]]; then
        __log i -- "Found '${__B_TARBALL_FILE}'. Going to use it...\n"
        cp "${__B_TARBALL_FILE}" "${G_BASE_DIR%%/}/__CODE_SERVER_TARBALL__" || return 102
    else
        __log e -- "Cannot locate "${__B_TARBALL_LINK}" nor "${__B_TARBALL_FILE}"".
        return 103
    fi

    if [[ -L "${__B_INFO_LINK}" ]]; then
        __log i -- "Found ${__B_INFO_LINK}. Going to use it...\n"
        cp "${__B_INFO_LINK}" "${G_BASE_DIR%%/}/__CODE_SERVER_INFO__" || return 104
    elif [[ -f "${__B_INFO_FILE}" ]]; then
        __log i -- "Found ${__B_INFO_FILE}. Going to use it...\n"
        cp "${__B_INFO_FILE}" "${G_BASE_DIR%%/}/__CODE_SERVER_INFO__" || return 105
    fi

}
function __build_before() {

    if [[ ! -e "${__B_TARBALL_LINK}" ]] || [[ "${__CONFIG[BUILD_BUILD_FORCE]}x" != "x" ]]; then
        __vscode_prepare_build
        return
    fi

    return 0
}
function __build() {

    if [[ ! -e "${__B_TARBALL_LINK}" ]] || [[ "${__CONFIG[BUILD_BUILD_FORCE]}x" != "x" ]]; then

        __vscode_build
        return
    fi

    return 0

}
function __build_package() {

    if [[ ! -e "${__B_TARBALL_LINK}" ]] || [[ -n ${__CONFIG[BUILD_BUILD_FORCE]} ]]; then

        if __vscode_create_package; then
            if [[ "${__CONFIG[BUILD_VSCODE_SOURCE_TARBALL]}x" != "x" ]] && [[ "${__B_BUILD_DIR%%/}" ]]; then
                cd "${__B_BUILD_DIR%%/}" || return 101

                declare __COMPRESS_COMMAND="bzip2 -9"
                if [[ "${__B_TARBALL_COMPRESSION_TYPE}" == "gz" ]]; then
                    __COMPRESS_COMMAND="gzip -9"
                fi
                if [[ "${GLOBAL_DEBUG}x" == "x" ]]; then
                    declare __T_TAR_PARAMETERS="cf"
                else
                    declare __T_TAR_PARAMETERS="cvf"
                fi

                tar ${__T_TAR_PARAMETERS} - ./ | ${__COMPRESS_COMMAND} >"${__B_TARBALL_PATH}/source-${__B_TARBALL_FILENAME}" || return 102

                unset __T_TAR_PARAMETERS __COMPRESS_COMMAND
            fi
        else
            return $?
        fi
    fi
    return 0
}
function __build_after_after() {

    __vscode_after_build
    return

}
