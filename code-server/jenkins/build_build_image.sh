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
declare GLOBAL_CONFIG_FILENAME="jenkins/.config"

###
# load basic functions needed.
# we always start loading from the base image when in the main tree
# and go from there....
declare __LIB_ENTRY_FILE="${__TOP_LEVEL_DIRECTORY}/../images/base/all/lib/lib_loader.sh"
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

if [[ -f "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" ]]; then
    if source "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}"; then
        true
    else
        __log e -- "Cannot source the configuration file. Exiting ($?).\n"
        exit 231
    fi
else
    __log e -- "Cannot find the configuration file. Exiting ($?).\n"
fi

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

if ! __environment_save_file "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" "${__ENVIRONMENT_SAVE[@]}"; then
    __log e -- "Could not save environment to new configuration file. Exiting.\n"
    exit 252
fi
