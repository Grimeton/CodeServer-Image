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
declare __TOP_LEVEL_DIRECTORY="$(dirname "$(realpath "${0}")")"
declare GLOBAL_CONFIG_FILENAME="$(basename "$(mktemp -p "${__TOP_LEVEL_DIRECTORY}")")"

###
# load basic functions needed.
# we always start loading from the base image when in the main tree
# and go from there....
declare __LIB_ENTRY_FILE="${__TOP_LEVEL_DIRECTORY}/images/base/all/lib/lib_loader.sh"
if [[ -f "${__LIB_ENTRY_FILE}" ]]; then
    if ! source "${__LIB_ENTRY_FILE}"; then
        echo " - ERROR: CANNOT SOURCE '${__LIB_ENTRY_FILE}'. Exiting."
        exit 253
    fi
else
    echo " - ERROR: Cannot find '${__LIB_ENTRY_FILE}'. Exiting."
    exit 253
fi

unset __LIB_ENTRY_FILE __TOP_LEVEL_DIRECTORY

###
#
# load additional packages
for __T_PACKAGE in "base_trap" "rootlayout"; do
    if ! __lib_package_load "${__T_PACKAGE}"; then
        __log e -- "Could not load '${__T_PACKAGE}'."
        exit 253
    fi
done

# function to cleanup the config file if this thing exits at any point
# is registered via EXIT trap.
function __cleanup_config_file() {
    declare -i __T_LAST_ERROR=$?

    if [[ -z ${GLOBAL_CONFIG_FILENAME:+x} ]]; then
        true
    elif [[ -f "${GLOBAL_CONFIG_FILENAME}" ]]; then
        rm -f "${GLOBAL_CONFIG_FILENAME}"
    fi

}
__trap_signal_register EXIT
__trap_function_register EXIT __cleanup_config_file

declare __T_CONFIG_FILE=
###
#
# check if we have a parameter handed to us.
# If the parameter turns into a file, we use it for configuration
#
if [[ "${@:1:1}x" != "x" ]]; then
    if [[ -f "${@:1:1}" ]]; then
        __log i - "Using '${@:1:1}'.\n"
        declare __PARAM_FILE="$(realpath "${@:1:1}")"
    else
        __log e - "'${@:1:1}' is not a file. Exiting.\n"
        exit 99
    fi
fi

# setup some basic stuff.
# let's see what config files we have....
declare -a GLOBAL_CONFIG_FILES=()
for __T_CF in "/config/config.sh" "${G_BASE_DIR%%/}/config.sh" "${__PARAM_FILE}" "${__T_CONFIG_FILE}"; do
    if [[ -f "${__T_CF}" ]]; then
        GLOBAL_CONFIG_FILES+=("${__T_CF}")
    fi
done

# check if we have a configuration....
#
(for __T_CF in "${GLOBAL_CONFIG_FILES[@]}"; do

    if [[ -f "${__T_CF}" ]]; then
        echo ""
        echo "####"
        echo "# START: "${__T_CF}""
        cat "${__T_CF}"
        echo ""
        echo "# END: "${__T_CF}""
        echo "####"
    fi
done) >"${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"

##
# if the file doesn't exist....
if [[ ! -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]; then
    __log e -- "Could not find build config. exiting.\n"
    exit 251
fi

# load the config
if ! source "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"; then
    __log e -- "Could not source the configuration. Exiting.\n"
    exit 252
fi

# i love it...
declare __T_CONFIG_VERIFY_FILE=

###
#
# get the full file to verify the configuration.
declare __T_CONFIG_VERIFY_FILE=""
if __lib_file_get_full_path "config_verify" __T_CONFIG_VERIFY_FILE "${ID}" "${VERSION_ID}" base build; then
    __log i -- "Got config verificiation file '${__T_CONFIG_VERIFY_FILE}'.\n"
else
    __log e - "COULD NOT LOAD CONFIGURATION VERIFIER. EXITING. (200)\n"
    exit 200
fi

# verify the config and create non existing variable with their default value.
if source "${__T_CONFIG_VERIFY_FILE}"; then
    __log i -- "Configuration verifier loaded successfully.\n"
else
    __log e - "COULD NOT LOAD CONFIGURATION VERIFIER. EXITING. (199)\n"
    exit 199
fi

# i really do
unset __PARAM_FILE __T_CF __T_CONFIG_FILE __T_CONFIG_VERIFY_FILE GLOBAL_CONFIG_FILES

# let's create a clean configuration.
if ! __environment_save_file "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" "__CONFIG" "__LOG_DEBUG" "DOCKER_HOST" "JENKINS_HOME"; then
    __log e -- "Could not save environment to new configuration file. Exiting.\n"
    exit 252
fi

###
# create necessary directory and file definitions
#
# Staging directory for the BUILDFS
#
if __rootlayout_init; then
    true
else
    __log e -- "Could not init the rootlayout system ($?).\n"
    exit 123
fi

if __rootlayout_copy_stages "${__CONFIG[BUILD_DISTRIBUTION_ID]}" "${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}" "base" "build"; then
    declare __T_BUILDFS_STAGING_DIRECTORY="${__ROOTLAYOUT_BASEDIRECTORY}"
    true
else
    __log e -- "Could not copy the stages ($?).\n"
    exit 124
fi

#if [[ -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]; then
#    rm "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"
#fi

# Most significant one wins
#
declare __BUILD_DOCKER_FILE=""
if __config_distribution_get_dockerfile "${__CONFIG[BUILD_DISTRIBUTION_ID]}" "${__CONFIG[BUILD_DISTRIBUTION_VERSION_ID]}" "build" "${__CONFIG[BUILD_DOCKER_FILENAME]}" __BUILD_DOCKER_FILE; then
    true
else
    __log e -- "Problems getting the Dockerfile for the build stage ($?)."
    exit 125
fi

###
#
# get the parameters together to start the build
#
# The name tag with the version number of the image
#
if [[ "${__CONFIG[BUILD_TAG_IMAGE_NAME]}x" != "x" ]]; then
    declare __BUILD_TAG_IMAGE_NAME="--tag ${__CONFIG[BUILD_TAG_IMAGE_NAME]}"
fi

###
#
# The latest tag of the image
#
if [[ "${__CONFIG[BUILD_TAG_IMAGE_LATEST]}x" != "x" ]]; then
    declare __BUILD_TAG_IMAGE_LATEST="--tag ${__CONFIG[BUILD_TAG_IMAGE_LATEST]}"
fi

__log_banner_start i -- ""
__log_banner_content i -- "" "" "Starting build. Configuration as follows:"
declare -a __CONFIG_KEYS_SORTED=()
IFS=$'\n' __CONFIG_KEYS_SORTED=($(sort <<<"${!__CONFIG[*]}"))
unset IFS
for __T_KEY in "${__CONFIG_KEYS_SORTED[@]}"; do
    __log_banner_content i -- "" "" "${__T_KEY}=\"${__CONFIG[${__T_KEY}]}\""
done
unset __CONFIG_KEYS_SORTED
__log_banner_end i -- ""

if [[ "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]; then
    rm -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"
    unset GLOBAL_CONFIG_FILENAME
fi

###
#
# Let's dance
#
if [[ -f "${__BUILD_DOCKER_FILE}" ]]; then
    if env -i docker build \
        --build-arg THIS_DOCKER_ARG_FROM="${__CONFIG[BUILD_DOCKER_ARG_FROM]}" \
        --build-arg THIS_STAGE="build" \
        --file "${__BUILD_DOCKER_FILE}" \
        --network host \
        --no-cache \
        ${__BUILD_TAG_IMAGE_NAME} \
        ${__BUILD_TAG_IMAGE_LATEST} \
        "${__T_BUILDFS_STAGING_DIRECTORY}"; then

        if [[ -d "${__T_BUILDFS_STAGING_DIRECTORY}" ]]; then
            rm -rf "${__T_BUILDFS_STAGING_DIRECTORY}"
        fi
        __log i -- "Build successful.\n"
    else
        __log e -- "UH OH, BUILDING THE IMAGE WENT WRONG...\n"
        exit 99
    fi
else
    __log e -- "Cannot find Dockerfile...\n"
    exit 99
fi

unset __BUILD_TAG_NAME __BUILD_TAG_IMAGE_LATEST __BUILD_DOCKER_FILE

__log_banner "BEGINNING TO CREATE THE RUNTIME.\n"

declare __START_IMAGE_TAG="${__CONFIG[BUILD_TAG_IMAGE_NAME]}"

###
#
# Check if we have an outside and inside path for the package volume mount. if so, use it.
#
if [[ "${__CONFIG[BUILD_PACKAGES_PATH_INSIDE]}x" != "x" ]] && [[ "${__CONFIG[BUILD_PACKAGES_PATH_OUTSIDE]}x" != "x" ]]; then
    declare __START_IMAGE_PACKAGES_PATH="--volume "${__CONFIG[BUILD_PACKAGES_PATH_OUTSIDE]}:${__CONFIG[BUILD_PACKAGES_PATH_INSIDE]}""
fi

###
#
# Let's dance
#
if [[ -z ${JENKINS_HOME:+x} ]]; then
    if env -i docker run \
        --interactive \
        --network host \
        --tty \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        ${__START_IMAGE_PACKAGES_PATH} \
        "${__START_IMAGE_TAG}" \
        "${__CONFIG[BUILD_STAGING_DIRECTORY]%%/}/images/build/build.sh"; then
        __log i -- "Building the runtime successful.\n"
        exit 0
    else
        __T_ERROR=$?
        __log e -- "Could not run build stage. Exiting (${__T_ERROR}).\n"
        exit ${__T_ERROR}
    fi
else
    if env -i docker run \
        --network host \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        ${__START_IMAGE_PACKAGES_PATH} \
        "${__START_IMAGE_TAG}" \
        "${__CONFIG[BUILD_STAGING_DIRECTORY]%%/}/images/build/build.sh"; then
        __log i -- "Building the runtime successful.\n"
        exit 0
    else
        __T_ERROR=$?
        __log e -- "Could not run build stage. Exiting (${__T_ERROR}).\n"
        exit ${__T_ERROR}
    fi
fi
unset __START_IMAGE_PACKAGES_PATH __START_IMAGE_TAG
