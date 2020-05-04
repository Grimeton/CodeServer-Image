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

__CONFIG[__BUILD_ROOTLAYOUT_BASEDIRECTORY]="${__ROOTLAYOUT_BASEDIRECTORY}"
__CONFIG[__BUILD_ROOTLAYOUT_ROOTDIRECTORY]="${__ROOTLAYOUT_ROOTDIRECTORY}"

if ! __environment_save_file "${G_BASE_DIR}/${GLOBAL_CONFIG_FILENAME}" "${__ENVIRONMENT_SAVE[@]}"; then
    __log e -- "Could not save environment to new configuration file. Exiting.\n"
    exit 252
fi