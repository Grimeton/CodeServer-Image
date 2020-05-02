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

declare -gx DEBIAN_FRONTEND="noninteractive"

# setup some basic stuff.
# Let's check if we're inside a container or not, if we are, we have to
# use relative path names... this is important when you're building from
# code-server that is running inside a container itself. ...

__T_TESTPATH="$(dirname "$(realpath "${0}")")"
if [[ -d "${__T_TESTPATH}" ]]; then
    __T_TESTPATH="${__T_TESTPATH%%/images/build}"
fi

__T_LOADERFILE="${__T_TESTPATH}/images/base/all/lib/lib_loader.sh"
if [[ -f "${__T_LOADERFILE}" ]]; then
    if ! source "${__T_LOADERFILE}"; then
        echo " - ERROR: CANNOT SOURCE '${__T_LOADERFILE}'. EXITING."
        exit 253
    fi
else
    echo " - ERROR: Cannot find '${__T_LOADERFILE}'. Exiting..."
    exit 253
fi

unset __T_TESTPATH __T_LOADERFILE

if [[ -f "${G_LIB_DIR}/settings.conf" ]]; then
    if source "${G_LIB_DIR}/settings.conf"; then
        true
    else
        __T_ERROR=$?
        __log e -- "Could not source settings... (${__T_ERROR}).\n"
        __log e -- "'G_LIB_DIR': '${G_LIB_DIR}'.\n"
        exit 123
    fi
else
    __log e -- "Could not find settings...($?).\n"
    __log e -- "'G_LIB_DIR': '${G_LIB_DIR}'.\n"
    exit 124
fi

declare -A __THIS_DISTRIBUTION=()
if __config_distribution_get "" "" "" "" "" "" __THIS_DISTRIBUTION; then
    true
else
    __log e -- "Problems getting the distribution information...($?).\n"
    return 111
fi
__log v -- __THIS_DISTRIBUTION

# the stage we're in
declare -g __THIS_STAGE="build"
declare -g __B_STAGE="${__THIS_STAGE}"
declare -g __B_RELEASE=""
declare -g __B_RELEASE_VERSION=""

if [[ -z ${BUILD_BUILDVERSION_RELEASE+x} ]]; then
    true
elif [[ "${BUILD_BUILDVERSION_RELEASE}x" == "x" ]]; then
    true
else
    __B_RELEASE="${BUILD_BUILDVERSION_RELEASE}"
fi

# the date to be used with this build
declare -g __B_DATE="$(date "+%F_%H_%M_%S")"
# the folder we're cloning into
declare -g __B_BUILD_DIR="${__CONFIG[BUILD_BUILD_DIRECTORY]%%/}/code-server"
# the compression type we're going to use
declare -g __B_TARBALL_COMPRESSION_TYPE="${__THIS_DISTRIBUTION[COMPRESSION]}"
# the name of the tarball we put the build into
declare -g __B_TARBALL_FILENAME="code-server-${__CONFIG[BUILD_DISTRIBUTION_ID]}-${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}-${__B_DATE}.tar.${__B_TARBALL_COMPRESSION_TYPE,,}"
# the name of the latest link that will point to our build
declare -g __B_TARBALL_LINKNAME=""
if [[ -z ${__CONFIG[BUILD_BUILDVERSION_RELEASE]+x} ]]; then
    __B_TARBALL_LINKNAME="code-server-latest.tar.${__B_TARBALL_COMPRESSION_TYPE,,}"
elif [[ "${__CONFIG[BUILD_BUILDVERSION_RELEASE]}x" == "x" ]]; then
    __B_TARBALL_LINKNAME="code-server-latest.tar.${__B_TARBALL_COMPRESSION_TYPE,,}"
else
    __B_TARBALL_LINKNAME="code-server-latest-${__CONFIG[BUILD_BUILDVERSION_RELEASE]}.tar.${__B_TARBALL_COMPRESSION_TYPE,,}"
fi

# the name of the info file we put the info into...
declare -g __B_INFO_FILENAME="code-server-${__CONFIG[BUILD_DISTRIBUTION_ID]}-${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}-${__B_DATE}.info"
# the name of the latest link that will point to the info file
declare -g __B_INFO_LINKNAME=""
if [[ -z ${__CONFIG[BUILD_BUILDVERSION_RELEASE]+x} ]]; then
    __B_INFO_LINKNAME="code-server-latest.info"
elif [[ "${__CONFIG[BUILD_BUILDVERSION_RELEASE]}x" == "x" ]]; then
    __B_INFO_LINKNAME="code-server-latest.info"
else
    __B_INFO_LINKNAME="code-server-latest-${__CONFIG[BUILD_BUILDVERSION_RELEASE]}.info"
fi
# the base path where of where to store packages
declare -g __B_TARBALL_PATH="${__CONFIG[BUILD_PACKAGES_PATH_INSIDE]}/${__CONFIG[BUILD_DISTRIBUTION_ID]}/${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}"
# the filename of the tarball including the path
declare -g __B_TARBALL_FILE="${__B_TARBALL_PATH%%/}/${__B_TARBALL_FILENAME}"
# the filename of the info file including the path
declare -g __B_INFO_FILE="${__B_TARBALL_PATH%%/}/${__B_INFO_FILENAME}"
# the name of the link including the path
declare -g __B_TARBALL_LINK="${__B_TARBALL_PATH%%/}/${__B_TARBALL_LINKNAME}"
# the name of the info link including full path.
declare -g __B_INFO_LINK="${__B_TARBALL_PATH%%/}/${__B_INFO_LINKNAME}"

if [[ ! -d "${__B_TARBALL_PATH}" ]]; then
    if mkdir -p "${__B_TARBALL_PATH}"; then
        true
    else
        __log e -- "Problems creating '${__B_TARBALL_PATH}' ($?).\n"
        return 249
    fi
fi

__log_banner i -- "BEGIN: Loading build packages...\n"
declare -i __T_ERROR=0
for __T_PKG in "build" "rootlayout"; do
    if __lib_package_load "${__T_PKG}" "${__CONFIG[BUILD_DISTRIBUTION_ID]}" "${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}" "base,build"; then
        __log i -- "Package '${__T_PKG}' loaded successfully.\n"
    else
        __log e -- "Could not load package '${__T_PKG}'. Aborting.\n"
        __T_ERROR=101
        break
    fi
done
__log_banner i -- "END: Loading of build packages....\n"
if [[ ${__T_ERROR} -ne 0 ]]; then
    return ${__T_ERROR}
fi
unset __T_ERROR

__log_banner i -- "BEGIN: STARTING BUILD!"
declare -i __T_ERROR=0
for __T_FUNC in "__build_before_before" "__build_before" "__build_prepare" "__build" "__build_after" "__build_package" "__build_after_after"; do
    if __variable_type_function "${__T_FUNC}"; then
        __log_banner i -- "START: '${__T_FUNC}'"
        __log i -- "Running function '${__T_FUNC}'.\n"
        if ${__T_FUNC}; then
            __log i -- "Running function '${__T_FUNC}' successful.\n"
        else
            __T_ERROR=$?
            __log e -- "Could not run '${__T_FUNC}'. Error: '${__T_ERROR}'. Exiting.\n"
            break
        fi
    fi
done
__log_banner i -- "END: BUILD"
if [[ ${__T_ERROR} -ne 0 ]]; then
    exit ${__T_ERROR}
fi
unset __T_ERROR

__log_banner i -- "BEGIN: ROOTFS Layout."
declare -i __T_ERROR=0
if __rootlayout_init; then
    __log i -- "Rootlayout successfully initialized...\n"
else
    __log e -- "Problems initializing the rootlayout system...($?).\n"
    __T_ERROR=131
fi

if [[ ${__T_ERROR} -ne 0 ]]; then
    __log_banner i -- "END: ROOTFS Layout."
    exit ${__T_ERROR}
fi
unset __T_ERROR
declare __T_ERROR=0

if __rootlayout_copy_stages "${__CONFIG[RUN_DISTRIBUTION_ID]}" "${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}" "base" "run"; then
    __log i -- "Copying stages 'base' and 'run' to root layout successful.\n"
else
    __log e -- "Problem copying stages 'base' and 'run' to rootlayout ($?).\n"
    __T_ERROR=132
fi
__log_banner i -- "END: ROOTFS Layout."

if [[ ${__T_ERROR} -ne 0 ]]; then
    exit ${__T_ERROR}
fi
unset __T_ERROR

###
#
# most significant matches wins..
#
declare __RUN_DOCKER_FILE=""
if __config_distribution_get_dockerfile "${__CONFIG[RUN_DISTRIBUTION_ID]}" "${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}" "run" "${__CONFIG[RUN_DOCKER_FILENAME]}" __RUN_DOCKER_FILE; then
    true
else
    __log e -- "Could not find a Dockerfile. Aborting.\n"
    exit 199
fi

###
#
# Get the settings for tagging together
#
if [[ "${__CONFIG[RUN_TAG_IMAGE_NAME]}x" != "x" ]]; then
    __RUN_TAG_IMAGE_NAME="--tag ${__CONFIG[RUN_TAG_IMAGE_NAME]}"
fi
if [[ "${__CONFIG[RUN_TAG_IMAGE_LATEST]}x" != "x" ]]; then
    __RUN_TAG_IMAGE_LATEST="--tag ${__CONFIG[RUN_TAG_IMAGE_LATEST]}"
fi
if [[ -f "${__B_INFO_FILE}" ]]; then
    __T_BUILD_INFO_FILE="${__B_INFO_FILE}"
elif [[ -L "${__B_INFO_LINK}" ]]; then
    __T_BUILD_INFO_FILE="${__B_INFO_LINK}"
else
    __T_BUILD_INFO_FILE=""
fi

if [[ -e "${__T_BUILD_INFO_FILE}" ]]; then
    if source "${__T_BUILD_INFO_FILE}"; then
        __log i -- "Build information loaded successfully.\n"
    else
        __log e -- "Could not load build information.\n"
    fi
else
    __log w -- "Build information is not available.\n"
fi

declare -ga __GLOBAL_PUBLIC_TAGS=()
if __variable_text GLOBAL_CONFIG_VERIFY_PUBLIC 1; then

    declare __T_CONFIG_VERIFY_PUBLIC_FILE=""
    if __lib_file_get_full_path "config_verify_public" "__T_CONFIG_VERIFY_PUBLIC_FILE" "${ID}" "${VERSION_ID}" "base" "run"; then
        true
    else
        __log e -- "Problems getting the full file path of 'config_verify_public'...($?).\n"
        exit 141
    fi

    if [[ -f "${__T_CONFIG_VERIFY_PUBLIC_FILE}" ]]; then
        if [[ -f "${G_BASE_DIR}/configs/${__CONFIG[RUN_DISTRIBUTION_ID]}/${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}-${__CONFIG[RUN_BUILDVERSION_SUFFIX]}/public_tags.sh" ]]; then
            __T_PUBLIC_TAGS_FILE="${G_BASE_DIR}/configs/${__CONFIG[RUN_DISTRIBUTION_ID]}/${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}-${__CONFIG[RUN_BUILDVERSION_SUFFIX]}/public_tags.sh"
        elif [[ -f "${G_BASE_DIR}/configs/${__CONFIG[RUN_DISTRIBUTION_ID]}/${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}/public_tags.sh" ]]; then
            __T_PUBLIC_TAGS_FILE="${G_BASE_DIR}/configs/${__CONFIG[RUN_DISTRIBUTION_ID]}/${__CONFIG[RUN_DISTRIBUTION_VERSION_ID]}/public_tags.sh"
        else
            __T_PUBLIC_TAGS_FILE=""
        fi
        if [[ -f "${__T_PUBLIC_TAGS_FILE}" ]]; then
            if source "${__T_PUBLIC_TAGS_FILE}"; then
                if source "${__T_CONFIG_VERIFY_PUBLIC_FILE}"; then
                    __log i -- "Loaded and verified the public tags configuration.\n"
                    if [[ ${#GLOBAL_PUBLIC_TAGS[@]} -gt 0 ]]; then
                        for __T_GPT in "${GLOBAL_PUBLIC_TAGS[@]}"; do
                            __GLOBAL_PUBLIC_TAGS+=("${__T_GPT}")
                        done
                    fi
                else
                    __log e -- "Problems loading the public tags verifier.\n"
                fi
            else
                __log e -- "Problems loading the public tags definition.\n"
            fi
        fi
    else
        __log e -- "Cannot find config verifier for public tags...\n"
    fi
fi

###
#
# Let's dance...
#
declare -a __T_DOCKER_ARGS=()
declare __T_RUNFS_STAGING_DIRECTORY="${__ROOTLAYOUT_BASEDIRECTORY}"
__T_DOCKER_ARGS+=("--build-arg" "THIS_DOCKER_ARG_FROM="${__CONFIG[RUN_DOCKER_ARG_FROM]}"")
__T_DOCKER_ARGS+=("--build-arg" "THIS_STAGE="run"")
__T_DOCKER_ARGS+=("--file" "${__RUN_DOCKER_FILE}")
__T_DOCKER_ARGS+=("--network" "host")
__T_DOCKER_ARGS+=("${__RUN_TAG_IMAGE_NAME}")
__T_DOCKER_ARGS+=("${__RUN_TAG_IMAGE_LATEST}")
if __array_exists __GLOBAL_PUBLIC_TAGS; then
    if [[ ${#__GLOBAL_PUBLIC_TAGS[@]} -gt 0 ]]; then
        for __GLOBAL_PUBLIC_TAG in "${__GLOBAL_PUBLIC_TAGS[@]}"; do
            __T_DOCKER_ARGS+=("--tag ${__GLOBAL_PUBLIC_TAG}")
        done
    fi
fi

if [[ -f "${__RUN_DOCKER_FILE}" ]]; then
    if env -i docker build \
        ${__T_DOCKER_ARGS[@]} \
        "${__T_RUNFS_STAGING_DIRECTORY}"; then
        __log i -- "Successfully build the runtime image!\n"
        if [[ -z ${__CONFIG[GLOBAL_PUSH_OVERRIDE]+x} ]]; then
            true
        elif [[ "${__CONFIG[GLOBAL_PUSH_OVERRIDE]}x" == "x" ]]; then
            true
        else
            __log i -- "Global push was overriden via configuration option '-x' on command line.\n"
            exit 0
        fi

        if ! __variable_exists GLOBAL_PUBLIC_PUSH || __variable_empty GLOBAL_PUBLIC_PUSH; then
            __log i -- "GLOBAL_PUBLIC_PUSH"
            exit 0
        fi

        if ! __variable_exists GLOBAL_PUSH_PASSWORD_FILE; then
            __log i -- "GLOBAL_PUSH_PASSWORD_FILE - 1\n"
            exit 0
        elif __variable_empty GLOBAL_PUSH_PASSWORD_FILE; then
            __log i -- "GLOBAL_PUSH_PASSWORD_FILE - 2\n"
            exit 0
        elif [[ ! -f "${G_BASE_DIR}/.pushpasswd" ]]; then
            __log i -- "GLOBAL_PUSH_PASSWORD_FILE - 3\n"
            exit 0
        fi

        if [[ -z ${__CONFIG[GLOBAL_PUSH_USERNAME]+x} ]]; then
            __log i -- "'GLOBAL_PUSH_USERNAME' does not exist.\n"
            exit 0
        elif [[ "${__CONFIG[GLOBAL_PUSH_USERNAME]}x" == "x" ]]; then
            __log i -- "'GLOBAL_PUSH_USERNAME' is empty.\n"
            exit 0
        fi

        if [[ -z ${__GLOBAL_PUBLIC_TAGS[@]+x} ]]; then
            __log i -- "'__GLOBAL_PUBLIC_TAGS[@]' does not exist.\n"
            exit 0
        elif [[ ${#__GLOBAL_PUBLIC_TAGS[@]} -lt 1 ]]; then
            __log i -- "'__GLOBAL_PUBLIC_TAGS[@]' is empty.\n"
            exit 0
        fi

        if cat "${G_BASE_DIR}/.pushpasswd" | docker login -u "${__CONFIG[GLOBAL_PUSH_USERNAME]}" --password-stdin; then
            true
        else
            __T_ERROR=$?
            __log e -- "Could not login to dockerhub (${__T_ERROR})."
            exit ${__T_ERROR}
        fi
        __T_ERROR=0

        for __T_GLOBAL_PUBLIC_TAG in "${__GLOBAL_PUBLIC_TAGS[@]}"; do
            if docker push "${__T_GLOBAL_PUBLIC_TAG}"; then
                __log i -- "Successfully pushed '${__T_GLOBAL_PUBLIC_TAG}' to dockerhub."
            else
                __T_ERROR=$?
                __log e -- "Problems pushing '${__T_GLOBAL_PUBLIC_TAG}' to dockerhub (${__T_ERROR})."
            fi
        done

        exit ${__T_ERROR}
    else
        __log e - "COULD NOT BUILD THE RUNTIME IMAGE. EXITING."
        exit 199
    fi
else
    echo "Cannot find Dockerfile: '${_RUN_DOCKER_FILE}'. Exiting."
    exit 111
fi
