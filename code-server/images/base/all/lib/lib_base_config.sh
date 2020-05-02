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

# DO NOT MESS WITH THIS.
# REALLY I MEAN IT.
set -o nounset
__lib_require "base_aarray"
# export library specific for all scripts.
declare -gx __CONFIG_LOADED=1
declare -agx __CONFIG_DISTRIBUTIONS_SUPPORTED_IDS=()

if ([[ -z ${GLOBAL_DISTRIBUTIONS_SUPPORTED_IDS[@]+x} ]] || [[ ${GLOBAL_DISTRIBUTIONS_SUPPORTED_IDS[@]} -lt 1 ]]); then
    if ([[ -z ${__D_DISTRIBUTIONS_SUPPORTED_IDS[@]+x} ]] || [[ ${#__D_DISTRIBUTIONS_SUPPORTED_IDS[@]} -lt 1 ]]); then
        true
    else
        for __T_AARRAYNAME in "${__D_DISTRIBUTIONS_SUPPORTED_IDS[@]}"; do
            if __aarray_exists "${__T_AARRAYNAME}"; then
                __CONFIG_DISTRIBUTIONS_SUPPORTED_IDS+=("${__T_AARRAYNAME}")
            fi
        done
    fi
else
    for __T_AARRAYNAME in "${GLOBAL_DISTRIBUTIONS_SUPPORTED_IDS[@]}"; do
        if __aarray_exists "${__T_AARRAYNAME}"; then
            __CONFIG_DISTRIBUTIONS_SUPPORTED_IDS+=("${__T_AARRAYNAME}")
        fi
    done
fi

#####
#
# - __config_distribution_find
#
# - Description:
#   Takes a number of arguments and searches for distributions that match said
#   arguments in __D_SUPPORTED_DISTRIBUTION_IDS
#
#   Will either return all found distributions to stdout, or when given a
#   nameref to an array, fill the array
#
# !!! PARAMETERS ARE POSITIONAL - OPTIONAL MEANS THEY CAN BE EMPTY -> ""
#
# - Parameters:
#   - #1 [IN|MANDATORY]: DISTRIBUTION_ID (ID in /etc/os-release)
#   - #2 [IN|OPTIONAL]: DISTRIBUTION_NAME (NAME in /etc/os-release)
#   - #3 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID (VERSION_ID in /etc/os-release)
#   - #4 [IN|OPTIONAL]: DISTRIBUTION_VERSION_CODENAME (VERSION_CODENAME in /etc/os-release)
#   - #5 [IN|OPTIONAL]: DISTRIBUTION_COMPRESSION - the compression type you want to search for
#   - #6 [IN|OPTIONAL]: DISTRIBUTION_COMMENT - the comment that was added to the distribution entry
#   - #7 [OUT|OPTIONAL]: RETURN_ARRAY - Name of an array that should be filled with the found distributions
#
# - Return values:
#   - 0 when distributions were found (>0).
#   - 1 when no distributions were found.
#   - >1 on error.
#
function __config_distribution_find() {

    declare __T_DINFO=""
    declare __T_VERSION_DOTS=""
    # bitmask, yeah right ...
    declare -ai __T_BITMASK_MATCH=()
    declare -ai __T_BITMASK_MATCHES=()

    if [[ "${@:1:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_ID="${@:1:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_ID=""
        __T_BITMASK_MATH+=(0)
    fi
    if [[ "${@:2:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_NAME="${@:2:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_NAME=""
        __T_BITMASK_MATCH+=(0)
    fi
    if [[ "${@:3:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_VERSION_ID=""
        __T_BITMASK_MATH+=(0)
    fi
    if [[ "${@:4:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_CODENAME="${@:4:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_VERSION_CODENAME=""
        __T_BITMASK_MATCH+=(0)
    fi
    if [[ "${@:5:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMPRESSION="${@:5:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_COMPRESSION=""
        __T_BITMASK_MATCH+=(0)
    fi
    if [[ "${@:6:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMMENT="${@:6:1}"
        __T_BITMASK_MATCH+=(1)
    else
        declare __P_DISTRIBUTION_COMMENT=""
        __T_BITMASK_MATCH+=(0)
    fi

    if __array_exists "${@:7:1}"; then
        declare -n __T_CONFIG_DF_RETURN_ARRAY="${@:7:1}"
    else
        declare -a __T_CONFIG_DF_DUMMY_ARRAY=()
        declare -n __T_CONFIG_DF_RETURN_ARRAY="__T_CONFIG_DF_DUMMY_ARRAY"
    fi
    declare __T_BITMASK_MATCH

    for __T_DINFO in "${__CONFIG_DISTRIBUTIONS_SUPPORTED_IDS[@]}"; do

        if __aarray_exists "${__T_DINFO}"; then
            unset __T_BITMASK_MATCHES
            declare -a __T_BITMASK_MATCHES=()
            unset -n __TRA
            declare -n __TRA="${__T_DINFO}"

            if [[ -n ${__TRA[ID]+x} ]]; then

                if [[ "${__TRA[ID]}x" == "${__P_DISTRIBUTION_ID}x" ]]; then
                    __T_BITMASK_MATCHES+=(1)
                else
                    __T_BITMASK_MATCHES+=(0)
                fi
            else
                __T_BITMASK_MATCHES+=(0)
            fi
            if [[ -n ${__TRA[NAME]+x} ]]; then
                if [[ "${__TRA[NAME]}x" != "x" ]] && [[ "${__P_DISTRIBUTION_NAME}x" != "x" ]]; then
                    if [[ "${__TRA[NAME]}x" == "${__P_DISTRIBUTION_NAME}x" ]]; then
                        __T_BITMASK_MATCHES+=(1)
                    else
                        __T_BITMASK_MATCHES+=(0)
                    fi
                else
                    __T_BITMASK_MATCHES+=(2)
                fi
            else
                __T_BITMASK_MATCHES+=(2)
            fi

            if [[ -n ${__TRA[VERSION_ID]+x} ]]; then
                __T_VERSION_DOTS="${__P_DISTRIBUTION_VERSION_ID//[^\.]/}"
                if [[ "${__TRA[ID],,}" == "alpine" ]] && [[ ${#__T_VERSION_DOTS} -gt 1 ]]; then
                    if [[ "${__TRA[VERSION_ID]}x" == "${__P_DISTRIBUTION_VERSION_ID%.*}x" ]]; then
                        __T_BITMASK_MATCHES+=(1)
                    else
                        __T_BITMASK_MATCHES+=(0)
                    fi
                else
                    if [[ "${__TRA[VERSION_ID]}x" == "${__P_DISTRIBUTION_VERSION_ID}x" ]]; then
                        __T_BITMASK_MATCHES+=(1)
                    else
                        __T_BITMASK_MATCHES+=(0)
                    fi
                fi
            else
                __T_BITMASK_MATCHES+=(0)
            fi
            if [[ -n ${__TRA[VERSION_CODENAME]+x} ]]; then

                if [[ "${__TRA[VERSION_CODENAME]}x" == "${__P_DISTRIBUTION_VERSION_CODENAME}x" ]]; then
                    __T_BITMASK_MATCHES+=(1)
                else
                    __T_BITMASK_MATCHES+=(0)
                fi
            else
                __T_BITMASK_MATCHES+=(0)
            fi
            if [[ -n ${__TRA[COMPRESSION]+x} ]]; then
                if [[ "${__TRA[COMPRESSION]}x" != "x" ]] && [[ "${__P_DISTRIBUTION_COMPRESSION}x" != "x" ]]; then
                    if [[ "${__TRA[COMPRESSION]}x" == "${__P_DISTRIBUTION_COMPRESSION}x" ]] && [[ "${__P_DISTRIBUTION_COMPRESSION}x" != "x" ]]; then
                        __T_BITMASK_MATCHES+=(1)
                    else
                        __T_BITMASK_MATCHES+=(0)
                    fi
                else
                    __T_BITMASK_MATCHES+=(2)
                fi
            else
                __T_BITMASK_MATCHES+=(2)
            fi
            if [[ -n ${__TRA[COMMENT]+x} ]]; then
                if [[ "${__TRA[COMMENT]}x" != "x" ]] && [[ "${__P_DISTRIBUTION_COMMENT}x" != "x" ]]; then
                    if [[ "${__TRA[COMMENT]}x" == "${__P_DISTRIBUTION_COMMENT}x" ]]; then
                        __T_BITMASK_MATCHES+=(1)
                    else
                        __T_BITMASK_MATCHES+=(0)
                    fi
                else
                    __T_BITMASK_MATCHES+=(2)
                fi
            else
                __T_BITMASK_MATCHES+=(2)
            fi

            declare -i __T_CTR=0

            while [[ ${__T_CTR} -lt ${#__T_BITMASK_MATCH[@]} ]]; do
                if [[ ${__T_BITMASK_MATCH[${__T_CTR}]} -gt ${__T_BITMASK_MATCHES[${__T_CTR}]} ]]; then
                    continue 2
                fi
                ((__T_CTR++)) || true
            done
            __T_CONFIG_DF_RETURN_ARRAY+=("${__T_DINFO}")
        fi
    done

    if [[ ${#__T_CONFIG_DF_RETURN_ARRAY[@]} -gt 0 ]]; then
        if [[ ! -R __T_CONFIG_DF_RETURN_ARRAY ]]; then
            echo "${__T_CONFIG_DF_RETURN_ARRAY[@]}"
        fi
        return 0
    else
        return 1
    fi
    return 254

}
#####
#
# - __config_distribution_get
#
# - Description:
#   Takes the parameters and checks if they're valid against
#   __D_DISTRIBUTIONS_SUPPORTED_IDS in "lib_defaults.sh"
#
#   The tests for "NAME","CODENAME",COMPRESSION and COMMENT are only done
#   if both sides hold a value, meaning that the value you handed to the function
#   and the value that comes from the array are NOT empty.
#
#   CODENAME and COMPRESSION are always matched case insensitive.
#
#   THIS FUNCTION TESTS FOR "${ID}" "${NAME}" AND SO ON IF DISTRIBUTION_ID DISTRIBUTION_NAME
#   FIELDS ARE EMPTY AND USES THEM IF FOUND!!!!
#
# !!! PARAMETERS ARE POSITIONAL - OPTIONAL MEANS THEY CAN BE EMPTY -> ""
#
# - Parameters:
#   - #1: [IN|OPTIONAL]: DISTRIBUTION_ID - "ID" in /etc/os-release
#   - #2: [IN|OPTIONAL]: DISTRIBUTION_NAME - "NAME" in /etc/os-release (can be empty)
#   - #3: [IN|OPTIONAL]: DISTRIBUTION_VERSION_ID - "VERSION_ID" in /etc/os-release
#   - #4: [IN|OPTIONAL]: DISTRIBUTION_VERSION_CODENAME - "VERSION_CODENAME" in /etc/os-release (can be empty)
#   - #5: [IN|OPTIONAL]: DISTRIBUTION_COMPRESSION - The compression type of the distribution (can be empty)
#   - #6: [IN|OPTIONAL]: DISTRIBUTION_COMMENT - A comment that can be added to the definintion (can be empty)
#   - #7: [OUT|OPTIONAL]: RETURN_ARRAY - A name of an existing array that should be filled with the found information
#
# - Return values:
#   - 0 when distribution found.
#   - 1 when no distribution found.
#   - >1 when invalid/failure.
#
function __config_distribution_get() {

    if [[ "${@:1:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    elif ([[ -n ${ID+x} ]] && [[ "${ID}x" != "x" ]]); then
        declare __P_DISTRIBUTION_ID="${ID}"
    else
        declare __P_DISTRIBUTION_ID=""
    fi
    if [[ "${@:2:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_NAME="${@:2:1}"
    elif ([[ -n ${NAME+x} ]] && [[ "${NAME}x" != "x" ]]); then
        declare __P_DISTRIBUTION_NAME="${NAME}"
    else
        declare __P_DISTRIBUTION_NAME=""
    fi
    if [[ "${@:3:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    elif ([[ -n ${VERSION_ID+x} ]] && [[ "${VERSION_ID}x" != "x" ]]); then
        declare __P_DISTRIBUTION_VERSION_ID="${VERSION_ID}"
    else
        declare __P_DISTRIBUTION_VERSION_ID=""
    fi
    if [[ "${@:4:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_CODENAME="${@:4:1}"
    elif ([[ -n ${VERSION_CODENAME+x} ]] && [[ "${VERSION_CODENAME}x" != "x" ]]); then
        declare __P_DISTRIBUTION_VERSION_CODENAME="${@:4:1}"
    else
        declare __P_DISTRIBUTION_VERSION_CODENAME=""
    fi
    if [[ "${@:5:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMPRESSION="${@:5:1}"
    elif ([[ -n ${COMPRESSION+x} ]] && [[ "${COMPRESSION}x" != "x" ]]); then
        declare __P_DISTRIBUTION_COMPRESSION="${@:5:1}"
    else
        declare __P_DISTRIBUTION_COMPRESSION=""
    fi
    if [[ "${@:6:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMMENT="${@:6:1}"
    elif ([[ -n ${COMMENT+x} ]] && [[ "${COMMENT}x" != "x" ]]); then
        declare __P_DISTRIBUTION_COMMENT="${COMMENT}"
    else
        declare __P_DISTRIBUTION_COMMENT=""
    fi

    if __aarray_exists "${@:7:1}"; then
        declare -n __T_RET_AA="${@:7:1}"
    else
        declare -A __T_RET_AA=()
    fi

    declare -a __T_CONFIG_DG_RETURN_ARRAY=()

    if __config_distribution_find \
        "${__P_DISTRIBUTION_ID}" \
        "${__P_DISTRIBUTION_NAME}" \
        "${__P_DISTRIBUTION_VERSION_ID}" \
        "${__P_DISTRIBUTION_VERSION_CODENAME}" \
        "${__P_DISTRIBUTION_COMPRESSION}" \
        "${__P_DISTRIBUTION_COMMENT}" \
        "__T_CONFIG_DG_RETURN_ARRAY"; then
        if [[ ${#__T_CONFIG_DG_RETURN_ARRAY[@]} -eq 1 ]]; then
            if __aarray_exists "${__T_CONFIG_DG_RETURN_ARRAY[0]}"; then
                declare -n __T_CA="${__T_CONFIG_DG_RETURN_ARRAY[0]}"
                for __T_KEY in "${!__T_CA[@]}"; do
                    __T_RET_AA["${__T_KEY}"]="${__T_CA["${__T_KEY}"]}"
                done
            fi

            if [[ ! -R "__T_RET_AA" ]]; then
                # yes, this is not __T_RET_AA
                echo "${__T_CONFIG_DG_RETURN_ARRAY[@]}"
            fi
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
    return 254
}
#####
#
# - __config_distribution_get_dockerfile()
#
# - Description:
#   Takes the parameters and prints a valid Dockerfile to stdout if found.
#
# - Parameters
#   - #1: DISTRIBUTION_ID - (ID in /etc/os-release)
#   - #2: DISTRIBUTION_VERSION_ID - (VERSION_ID in /etc/os-release)
#   - #3: STAGE - The stage you need the Dockerfile for. (base, build, run, ....)
#   - #4: DOCKERFILE_FILENAME - The name of the Dockerfile. If this isn't found, the default is used.
#   - #5: RETURN_VALUE - The name of an existing variable that should be filled with the Dockerfile filename.
#
# - Return values:
#   - 0 when file is found/success.
#   - 1 when no file was found.
#   - >1 on error.
#
function __config_distribution_get_dockerfile() {

    declare __T_DOCKERFILE_FILENAME=
    declare __T_DOCKERFILE_FILENAMES=
    declare __T_FOLDER_TO_SEARCH=
    declare __T_FOLDERS_TO_SEARCH=()
    declare __T_LAST_FOUND_FILE=

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 103
    else
        declare __P_STAGE="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        __T_DOCKERFILE_FILENAMES=("Dockerfile")
    elif [[ "${@:4:1}" == "Dockerfile" ]]; then
        __T_DOCKERFILE_FILENAMES=("${@:4:1}")
    else
        __T_DOCKERFILE_FILENAMES=("${@:4:1}")
        __T_DOCKERFILE_FILENAMES+=("Dockerfile")
    fi

    if [[ "${@:5:1}x" == "x" ]]; then
        declare __T_LAST_FOUND_FILE=""
    elif __variable_exists "${@:5:1}"; then
        declare -n __T_LAST_FOUND_FILE="${@:5:1}"
        __T_LAST_FOUND_FILE=""
    else
        declare __T_LAST_FOUND_FILE=""
    fi

    __T_FOLDERS_TO_SEARCH+=("${G_IMAGES_DIR}/${__P_STAGE,,}/${__P_DISTRIBUTION_ID}/all/docker")

    if [[ "${__P_DISTRIBUTION_VERSION_ID}x" != "x" ]]; then
        __T_FOLDERS_TO_SEARCH+=("${G_IMAGES_DIR}/${__P_STAGE,,}/${__P_DISTRIBUTION_ID}/${__P_DISTRIBUTION_VERSION_ID}/docker")
    fi
    for __T_FOLDER_TO_SEARCH in "${__T_FOLDERS_TO_SEARCH[@]}"; do
        for __T_DOCKERFILE_FILENAME in "${__T_DOCKERFILE_FILENAMES[@]}"; do
            if [[ -f "${__T_FOLDER_TO_SEARCH}/${__T_DOCKERFILE_FILENAME}" ]]; then
                __T_LAST_FOUND_FILE="${__T_FOLDER_TO_SEARCH%%/}/${__T_DOCKERFILE_FILENAME}"
            fi
        done
    done

    if [[ "${__T_LAST_FOUND_FILE}x" != "x" ]]; then
        if [[ ! -R __T_LAST_FOUND_FILE ]]; then
            echo "${__T_LAST_FOUND_FILE}"
        fi
        return 0
    else
        return 1
    fi
    return 254

}
#####
#
# - __config_distribution_verify
#
# - Description:
#   Takes the parameters and checks if they're valid against
#   __D_DISTRIBUTIONS_SUPPORTED_IDS in "lib_defaults.sh"
#
#   The tests for "NAME","CODENAME",COMPRESSION and COMMENT are only done
#   if both sides hold a value, meaning that the value you handed to the function
#   and the value that comes from the array are NOT empty.
#
#   CODENAME and COMPRESSION are always matched case insensitive.
#
# !!! PARAMETERS ARE POSITIONAL - OPTIONAL MEANS THEY CAN BE EMPTY -> ""
#
# - Parameters:
#   - #1: [IN|MANDATORY]: DISTRIBUTION_ID - "ID" in /etc/os-release
#   - #2: [IN|OPTIONAL]: DISTRIBUTION_NAME - "NAME" in /etc/os-release (can be empty)
#   - #3: [IN|MANDATORY]: DISTRIBUTION_VERSION_ID - "VERSION_ID" in /etc/os-release
#   - #4: [IN|OPTIONAL]: DISTRIBUTION_VERSION_CODENAME - "VERSION_CODENAME" in /etc/os-release (can be empty)
#   - #5: [IN|OPTIONAL]: DISTRIBUTION_COMPRESSION - The compression type of the distribution (can be empty)
#   - #6: [IN|OPTIONAL]: DISTRIBUTION_COMMENT - A comment that can be added to the definintion (can be empty)
#
# - Return values:
#   - 0 when verified.
#   - 1 when not verified.
#   - >1 when invalid/problems.
#
function __config_distribution_verify() {

    if [[ "${@:1:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_ID="${@:1:1}"
    else
        declare __P_DISTRIBUTION_ID=""
    fi
    if [[ "${@:2:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_NAME="${@:2:1}"
    else
        declare __P_DISTRIBUTION_NAME=""
    fi
    if [[ "${@:3:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    else
        declare __P_DISTRIBUTION_VERSION_ID=""
    fi
    if [[ "${@:4:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_CODENAME="${@:4:1}"
    else
        declare __P_DISTRIBUTION_VERSION_CODENAME=""
    fi
    if [[ "${@:5:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMPRESSION="${@:5:1}"
    else
        declare __P_DISTRIBUTION_COMPRESSION=""
    fi
    if [[ "${@:6:1}x" != "x" ]]; then
        declare __P_DISTRIBUTION_COMMENT="${@:6:1}"
    else
        declare __P_DISTRIBUTION_COMMENT=""
    fi

    if __array_exists "${@:7:1}"; then
        declare -n __T_CONFIG_DV_RETURN_ARRAY="${@:7:1}"
    else
        declare -a __T_CONFIG_DV_DUMMY_ARRAY=()
        declare -n __T_CONFIG_DV_RETURN_ARRAY="__T_CONFIG_DV_DUMMY_ARRAY"
    fi

    if __config_distribution_find \
        "${__P_DISTRIBUTION_ID}" \
        "${__P_DISTRIBUTION_NAME}" \
        "${__P_DISTRIBUTION_VERSION_ID}" \
        "${__P_DISTRIBUTION_VERSION_CODENAME}" \
        "${__P_DISTRIBUTION_COMPRESSION}" \
        "${__P_DISTRIBUTION_COMMENT}" \
        "${!__T_CONFIG_DV_RETURN_ARRAY}"; then

        if [[ ${#__T_CONFIG_DV_RETURN_ARRAY[@]} -ne 1 ]]; then
            __T_CONFIG_DV_RETURN_ARRAY=()
            return 1
        fi
        return 0
    fi
    return 1

}
