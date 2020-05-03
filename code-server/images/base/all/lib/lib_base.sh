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
declare -gx __LIB_LOADED=1
declare -Agx __LIB_PACKAGES_LOADED=()
declare -agx __LIB_PACKAGES_INIT=()

if [[ -n ${__D_LIB_PACKAGES_INIT[@]:+x} ]]; then
    __LIB_PACKAGES_INIT=("${__D_LIB_PACKAGES_INIT[@]}")
fi

###
#
# - Base functionality of the library.
#

#####
#
# - __lib_file_get_full_path
#
# - Description
#   Takes a library name and returns the full filename including
#   the path to it.
#
#   When the library is in "install" or "init" mode, there is only
#   one file to be returned. In "build" mode however the
#   most significant file gets returned.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: NAME - Name of the library to be searched for.
#   - #2 [OUT|OPTIONAL]: RETURN_VALUE - Name of an existing variable that should be filled with the information.
#
#   The following parameters are only needed then the library is in build mode.
#
#   - #3 [IN|MANDATORY]: DISTRIBUTION_ID - ID from /etc/os-release.
#   - #4 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID - VERSION_ID from /etc/os-release.
#   - #5+ [IN|MANDATORY]: STAGE - One or more image stages to be searched for the library.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_file_get_full_path() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_LIBNAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        declare __T_LIB_FGFP_RETURN_VALUE=""
    elif __variable_exists "${@:2:1}"; then
        declare -n __T_LIB_FGFP_RETURN_VALUE="${@:2:1}"
    else
        declare __T_LIB_FGFP_RETURN_VALUE=""
    fi
    __T_LIB_FGFP_RETURN_VALUE=""

    declare -a __T_STAGES=()
    declare __T_FILENAME=""
    declare __T_RETURN_FILENAME=""

    if [[ "${G_LIB_STAGE}" != "build" ]]; then
        if __lib_filename_from_libname "${__P_LIBNAME}" __T_FILENAME; then
            __T_FILE="${G_LIB_DIR%%/}/${__T_FILENAME}"
            if [[ -f "${__T_FILE}" ]]; then
                __T_LIB_FGFP_RETURN_VALUE="${__T_FILE}"
                if [[ ! -R __T_LIB_FGFP_RETURN_VALUE ]]; then
                    echo "${__T_LIB_FGFP_RETURN_VALUE}"
                fi
                return 0
            else
                return 2
            fi
        fi
        return 1
    fi

    if [[ "${G_LIB_STAGE}" == "build" ]]; then
        if [[ "${@:3:1}x" == "x" ]]; then
            return 102
        else
            declare __P_DISTRIBUTION_ID="${@:3:1}"
        fi
        if [[ "${@:4:1}x" == "x" ]]; then
            return 103
        else
            declare __P_DISTRIBUTION_VERSION_ID="${@:4:1}"
        fi

        if [[ "${@:5}x" == "x" ]]; then
            return 104
        else
            declare -a __P_STAGES=("${@:5}")
        fi

        if __lib_filename_from_libname "${__P_LIBNAME}" "__T_FILENAME"; then
            true
        else
            __log e -- "Could not get the filename from library name ($?)."
        fi

        if __lib_file_get_most_significant "${__T_FILENAME}" "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "__T_LIB_FGFP_RETURN_VALUE" "${__P_STAGES[@]}"; then
            if [[ ! -R __T_LIB_FGFP_RETURN_VALUE ]]; then
                echo "${__T_LIB_FGFP_RETURN_VALUE}"
            fi
            return 0
        else
            __log d -- "__lib_file_get_most_significant: '$?'.\n"
        fi
        return 1
    fi
    echo "WHERE THE FUCK I AM?" >&2
    return 99
}
#####
#
# - __lib_file_get_all()
#
# - Description
#   Searches through all combinations of distribution/version/stage and returns the files
#   found for the filename it gets handed.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: FILENAME - Filename to search for
#   - #2 [IN|MANDATORY]: DISTRIBUTION_ID - ID from /etc/os-release.
#   - #3 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID - VERSION_ID from /etc/os-release.
#   - #4 [OUT|OPTIONAL]: RETURN_ARRAY - Name of an existing, empty array that should be filled with the results.
#   - #5+ [IN|MANDATORY]:  STAGENAME - One or more names of stages to be searched in.
#
# - Return values
#   - 0 on success
#   - 1 on failure
#   - >1 on error.
#
function __lib_file_get_all() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILENAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_DISTRIBUTION_ID="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 103
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    fi
    if __array_exists "${@:4:1}"; then
        declare -n __T_RETURN_ARRAY="${@:4:1}"
    else
        declare -a __T_RETURN_ARRAY=()
    fi

    if [[ "${@:5}x" == "x" ]]; then
        return 104
    else
        declare __P_STAGES=("${@:5}")
    fi

    declare -a __T_TEST_DIRECTORIES=()

    for __T_STAGE in "${__P_STAGES[@]}"; do
        __T_W_DIR1="${G_BASE_DIR%%/}/images/${__T_STAGE,,}"

        for __T_DISTRO in all ${__P_DISTRIBUTION_ID,,}; do
            __T_W_DIR2="${__T_W_DIR1%%/}/${__T_DISTRO,,}"
            if [[ "${__T_DISTRO}" == "all" ]]; then
                __T_TEST_DIRECTORIES+=("${__T_W_DIR2}/lib")
                continue
            fi

            for __T_DISTRO_VERSION_ID in all ${__P_DISTRIBUTION_VERSION_ID}; do
                __T_W_DIR3="${__T_W_DIR2%%/}/${__T_DISTRO_VERSION_ID,,}/lib"
                __T_TEST_DIRECTORIES+=("${__T_W_DIR3}")
            done
        done
    done

    for __T_TEST_DIRECTORY in "${__T_TEST_DIRECTORIES[@]}"; do
        if [[ -f "${__T_TEST_DIRECTORY%%/}/${__P_FILENAME}" ]]; then
            __T_RETURN_ARRAY+=("${__T_TEST_DIRECTORY%%/}/${__P_FILENAME}")
        fi
    done

    if [[ ${#__T_RETURN_ARRAY[@]} -gt 0 ]]; then
        if [[ ! -R __T_RETURN_ARRAY ]]; then
            echo "${__T_RETURN_ARRAY[@]}"
        fi
        return 0
    else
        return 1
    fi
    return 254
}

#####
#
# - __lib_file_get_most_significant
#
# - Description
#   Takes a filename and returns only the most significant file that has been found
#   for this distribution/version/build stage combination.
#
# - Paramters:
#   - #1: [IN|MANDATORY]: FILENAME - Filename to search for.
#   - #2: [IN|MANDATORY]: DISTRIBUTION_ID - ID from /etc/os-release.
#   - #3: [IN|MANDATORY]: DISTRIBUTION_VERSION_ID - VERSION_ID from /etc/os-release.
#   - #4: [OUT|OPTIONAL]: RETURN_VALUE - Name of an existing, empty variable.
#   - #5+ [IN|MANDATORY]: STAGE_NAME - One ore more names of stages to be searched for the file.
#
# - Return values
#   - 0 when file is found.
#   - 1 when no file is found.
#   - >1 on error.
#
function __lib_file_get_most_significant() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILENAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_DISTRIBUTION_ID="${@:2:1}"
    fi
    if [[ "${@:3:1}x" == "x" ]]; then
        return 103
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    fi
    if __variable_exists "${@:4:1}"; then
        declare -n __T_RETURN_VALUE="${@:4:1}"
    else
        declare __T_RETURN_VALUE=""
    fi

    __T_RETURN_VALUE=""

    if [[ "${@:5}x" == "x" ]]; then
        return 104
    else
        declare -a __P_STAGES=("${@:5}")
    fi

    declare __T_GFMS_FILES_RETURN=()
    declare __T_FILES_MAX=0

    if __lib_file_get_all "${__P_FILENAME}" "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "__T_GFMS_FILES_RETURN" "${__P_STAGES[@]}"; then
        __T_FILES_MAX=$((${#__T_GFMS_FILES_RETURN[@]} - 1))
        __T_RETURN_VALUE="${__T_GFMS_FILES_RETURN[${__T_FILES_MAX}]}"
        if [[ ! -R __T_RETURN_VALUE ]]; then
            echo "${__T_RETURN_VALUE}"
        fi
        return 0
    else
        return 1
    fi
    return 254
}

#####
#
# - __lib_filename_from_libname
#
# - Description
#   Takes the name of a library and returns the corresponding filename.
#   This function exists mainly as the single point of configuration for
#   the filenames of the library, in case it ever needs to be changed.
#
#   Works withe filenames only, no paths involved.
#
# - Paramters:
#   - #1: [IN|MANDATORY]: LIBRARY_NAME - The name of the library...
#   - #2: [OUT|OPTIONAL]: RETURN_VALUE - The name of an existing variable to be filled with the result.
#
# - Return value
#   - 0 on success.
#   - 1 on failure.
#   - >1 on error.
#
function __lib_filename_from_libname() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_LIBNAME="${@:1:1}"
    fi

    if declare -p "${@:2:1}" >/dev/null 2>&1; then
        declare -n __T_RETURN_VALUE="${@:2:1}"
    else
        declare __T_RETURN_VALUE=""
    fi

    __T_RETURN_VALUE="lib_${__P_LIBNAME}.sh"
    if [[ ! -R __T_RETURN_VALUE ]]; then
        echo "${__T_RETURN_VALUE}"
    fi
    return 0

}

#####
#
# - __lib_init
#
# - Description
#   This is where the fun begins. Main function to initialize the library.
#   SHOULD NOT BE USED DIRECTLY. USE __lib_init_defaults !
#
# - Parameters:
#   - NONE
#
# - Return values
#   - 0 on success
#   - >0 on failure.
#
function __lib_init() {

    declare __T_LIB_DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    declare __T_LIB_REGEX_IMAGES_BASE='^.*/images/base/all/lib'

    if declare -p "BASH_SOURCE" >/dev/null 2>&1; then
        if (declare -p "__INIT_VERSION" >/dev/null 2>&1 && [[ "${__INIT_VERSION}x" != "x" ]]) || [[ "${0##*/}" == "init" ]]; then

            if ! declare -p __INIT_VERSION >/dev/null 2>&1; then
                declare -gx __INIT_VERSION="0.00"
            elif [[ "${__INIT_VERSION}x" == "x" ]]; then
                unset __INIT_VERSION
                declare -gx __INIT_VERSION="0.00"
            fi

            # we're running in init, at least we're assuming we do
            declare -gx G_LIB_DIR="${__T_LIB_DIRECTORY}"
            declare -gx G_LIB_LOADED="true"
            declare -gx G_LIB_STAGE="init"
            return 0
        fi

        if (declare -p __INSTALLER_VERSION >/dev/null 2>&1 && [[ "${__INSTALLER_VERSION}x" != "x" ]]) || [[ "${0##*/}" == "installer.sh" ]]; then

            if ! declare -p __INSTALLER_VERSION >/dev/null 2>&1; then
                declare -gx __INSTALLER_VERSION="0.00"
            elif [[ "${__INSTALLER_VERSION}x" == "x" ]]; then
                unset __INSTALLER_VERSION
                declare -gx __INSTALLER_VERSION="0.00"
            fi

            # looks like we're doing the installer.
            declare -gx G_LIB_DIR="${__T_LIB_DIRECTORY}"
            declare -gx G_LIB_LOADED="true"
            declare -gx G_LIB_STAGE="installer"
            return 0
        fi

        # this is what happens when you don't know wtf is going on
        # guess we're still in the build stage, let's check
        if [[ "${__T_LIB_DIRECTORY}" =~ ${__T_LIB_REGEX_IMAGES_BASE} ]]; then

            declare __TEST_PATHS=("${__T_LIB_DIRECTORY%%/images/base/all/lib}/images/base"
                "${__T_LIB_DIRECTORY%%/images/base/all/lib}/images/build"
                "${__T_LIB_DIRECTORY%%/images/base/all/lib}/images/run"
            )

            declare __TEST_PATH=""

            for __TEST_PATH in "${__TEST_PATHS[@]}"; do
                if [[ ! -d "${__TEST_PATH}" ]]; then
                    echo "This is not a build environment. Exiting." >&2
                    exit 254
                fi
            done

            declare -gx G_BASE_DIR="${__T_LIB_DIRECTORY%%/images/base/all/lib}"

            if [[ "${G_BASE_DIR}x" == "x" ]]; then
                echo "ERROR: RUNNING IN ROOT DIRECTORY. NOT GOOD."
                exit 210
            fi

            declare -gx G_IMAGES_DIR="${G_BASE_DIR%%/}/images"
            declare -gx G_IMAGES_BASE_DIR="${G_IMAGES_DIR%%/}/base"
            declare -gx G_IMAGES_BUILD_DIR="${G_IMAGES_DIR%%/}/build"
            declare -gx G_IMAGES_MULTISTAGE_DIR="${G_IMAGES_DIR%%/}/multistage"
            declare -gx G_IMAGES_RUN_DIR="${G_IMAGES_DIR%%/}/run"
            declare -gx G_LIB_DIR="${__T_LIB_DIRECTORY%%/}"
            declare -gx G_LIB_LOADED=1
            declare -gx G_LIB_STAGE="build"
        fi
    else
        # this should never happen.
        # Let's honour the god of reddit.
        echo "WHERE THE FUCK I AM?" >&2
        exit 254
    fi
}

#####
#
# - __lib_init_defaults
#
# - Description
#   This function will load the library via __lib_init if necessary and then load the defaults
#   as well as set the OS information to the environment.
#
# - Parameters
#   - NONE
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_init_defaults() {

    if declare -p G_LIB_LOADED >/dev/null 2>&1 && ([[ "${G_LIB_LOADED,,}" == "true" ]] || [[ "${G_LIB_LOADED}" == "1" ]]); then
        echo "LIBRARY ALREADY LOADED: G_LIB_LOADED: '${G_LIB_LOADED}'."
        exit 254
    elif __lib_init; then
        true
    else
        echo "COULD NOT LOAD THE LIBRARY ($?). EXITING."
        return 254
    fi

    if [[ -f "${G_LIB_DIR%%/}/lib_defaults.sh" ]]; then
        if source "${G_LIB_DIR%%/}/lib_defaults.sh"; then
            true
        else
            echo "COULD NOT LOAD DEFAULTS ($?). EXITING."
            return 253
        fi
    else
        return 102
    fi
    if ! __lib_init_os_information; then
        echo "DON'T KNOW WHICH OS I'M ON. EXITING."
        return 252
    fi

    if declare -p __D_LIB_PACKAGES_INIT >/dev/null 2>&1; then
        if [[ ${#__D_LIB_PACKAGES_INIT[@]} -gt 0 ]]; then
            __LIB_PACKAGES_INIT=("${__D_LIB_PACKAGES_INIT[@]}")
        fi
    fi

    if [[ ${#__LIB_PACKAGES_INIT[@]} -gt 0 ]]; then
        for __T_PI in "${__LIB_PACKAGES_INIT[@]}"; do
            if __lib_package_load "${__T_PI}"; then
                true
            else
                echo "COULD NOT LOAD PACKAGE: '${__T_PI}' ($?)."
                return 254
            fi
        done
    fi
    return 0
}

#####
#
# - __lib_init_os_information()
#
# - Description
#   Checks if /etc/os-release exists. If so, sources it into the environment.
#
#   If not, checks for the os version by other means. if successfull, it exports
#   at least ID and VERSION_ID
#
# - Parameters
#   - NONE.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_init_os_information() {

    declare __T_REGEX_CENTOS6='^CentOS\ release\ 6\..*$'
    declare __T_TEST_VAL=""

    if [[ -f /etc/os-release ]]; then
        if source /etc/os-release; then
            return 0
        else
            return 1
        fi
    elif [[ -f /etc/centos-release ]]; then
        __T_TEST_VAL="$(cat /etc/centos-release)"
        if [[ ${__T_TEST_VAL} =~ ${__T_REGEX_CENTOS6} ]]; then
            declare -gx ID="centos"
            declare -gx NAME="CentOS"
            declare -gx VERSION_ID="6"
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
# - __lib_loaded
#
# - Description
#   Checks if the library has been loaded and returns the status.
#
# - Parameters
#   - NONE.
#
# - Return values
#   - 0 when loaded.
#   - 1 when not loaded.
#
function __lib_loaded() {
    if [[ -n ${G_LIB_LOADED:+x} ]]; then
        return 0
    else
        return 1
    fi
}
#####
#
# - __lib_package_create_all
#
# - Description
#   Searches for all available versions of a file in the combination
#   of DISTRIBUTION_ID,DISTRIBUTION_VERSION_ID and STAGE and returns
#   a concatenation of said files to stdout based on their order
#   of significance. The more significant the later the output.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: FILENAME - The filename to search for.
#   - #2 [IN|MANDATORY]: DISTRIBUTION_ID - ID from /etc/os-release.
#   - #3 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID - VERSION_ID from /etc/os-release.
#   - #4+ [IN|MANDATORY]: STAGE_NAME - One or more names of library stages to be searched in.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_package_create_all() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILENAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_DISTRIBUTION_ID="${@:2:1}"
    fi
    if [[ "${@:3:1}x" == "x" ]]; then
        return 103
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        return 104
    else
        declare -a __P_STAGES=("${@:4}")
    fi

    declare -a __T_FILES=()
    declare -a __T_TEST_DIRECTORIES=()

    for __T_STAGE in "${__P_STAGES[@]}"; do
        __T_W_DIR1="${G_IMAGES_DIR%%/}/${__T_STAGE,,}"

        for __T_DISTRO in all ${__P_DISTRIBUTION_ID,,}; do
            __T_W_DIR2="${__T_W_DIR1%%/}/${__T_DISTRO,,}"
            if [[ "${__T_DISTRO}" == "all" ]]; then
                __T_TEST_DIRECTORIES+=("${__T_W_DIR2}/lib")
                continue
            fi

            for __T_DISTRO_VERSION_ID in all ${__P_DISTRIBUTION_VERSION_ID}; do
                __T_W_DIR3="${__T_W_DIR2%%/}/${__T_DISTRO_VERSION_ID,,}/lib"
                __T_TEST_DIRECTORIES+=("${__T_W_DIR3}")
            done
        done
    done

    for __T_TEST_DIRECTORY in "${__T_TEST_DIRECTORIES[@]}"; do

        if [[ -f "${__T_TEST_DIRECTORY%%/}/${__P_FILENAME}" ]]; then
            __T_FILES+=("${__T_TEST_DIRECTORY%%/}/${__P_FILENAME}")
        fi
    done
    if [[ ${#__T_FILES[@]} -gt 0 ]]; then
        echo "${__D_LIB_DEFAULT_HEADER}"
        for __T_FILE in "${__T_FILES[@]}"; do
            echo "#####"
            echo "#"
            echo "# - '${__T_FILE}'"
            echo "#"
            echo ""
            if [[ -f "${__T_FILE}" ]]; then
                cat "${__T_FILE}"
            else
                echo "#### FILE NOT FOUND '${__T_FILE}'"
            fi

            echo ""
            echo "#"
            echo "#####"
        done
        return 0
    fi
    return 1
}

#####
#
# - __lib_packages_create_all_file
#
# - Description
#   Uses __lib_package_create_all to get all the files and store their content in a file.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: FILENAME - Filename including path where the results should be stored.
#   - #2 [IN|MANDATORY]: NEEDLE - Filename to search for.
#   - #3 [IN|MANDATORY]: DISTRIBUTION_ID: The distribution id to use (from /etc/os-release).
#   - #4 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID: The distribution version id to use (from /etc/os-release).
#   - #5+ [IN|MANDATORY]: STAGE_NAME: One ore more names of library stages to be searched for the files.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_package_create_all_file() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FILENAME="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_NEEDLE_FILENAME="${@:2:1}"
    fi
    if [[ "${@:3:1}x" == "x" ]]; then
        return 103
    else
        declare __P_DISTRIBUTION_ID="${@:3:1}"
    fi
    if [[ "${@:4:1}x" == "x" ]]; then
        return 104
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:4:1}"
    fi
    if [[ "${@:5:1}x" == "x" ]]; then
        return 105
    else
        declare -a __P_STAGES=("${@:5}")
    fi

    if __lib_package_create_all "${__P_NEEDLE_FILENAME}" "${__P_DISTRIBUTION_ID}" "${__P_DISTRIBUTION_VERSION_ID}" "${__P_STAGES[@]}" >"${__P_FILENAME}"; then
        return 0
    else
        return 1
    fi
    return 254

}
#####
#
# - __lib_package_load
#
# - Description
#   Takes the packagename and loads the file if found.
#
#   - When in run or install mode, it only needs the package name.
#   - When in build mode it also needs the other paramters.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: PACKAGENAME - The name of the package to be loaded.
#
#   The following parameters are only needed when the library is in build stage.
#   If not provided, the library will use ID, VERSION_ID from the environment and
#   the stage names "base" and "build".
#
#   - #2 [IN|MANDATORY]: DISTRIBUTION_ID: The distribution id from /etc/os-release.
#   - #3 [IN|MANDATORY]: DISTRIBUTION_VERSION_ID: The version ID of the distribution from /etc/os-release.
#   - #4+ [IN|MANDATORY]: STAGE_NAME - One ore more names of the library stages to be searched.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __lib_package_load() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_PACKAGENAME="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_ID="${ID}"
    else
        declare __P_DISTRIBUTION_ID="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare __P_DISTRIBUTION_VERSION_ID="${VERSION_ID}"
    else
        declare __P_DISTRIBUTION_VERSION_ID="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        declare -a __P_STAGES=("base" "build")
    else
        declare -a __P_STAGES=("${@:4}")
    fi

    if [[ -n ${__LIB_PACKAGES_LOADED["${__P_PACKAGENAME,,}"]:+x} ]]; then
        return 0
    fi

    declare __T_DISTRIBUTION_ID="${__P_DISTRIBUTION_ID}"
    declare __T_DISTRIBUTION_VERSION_ID="${__P_DISTRIBUTION_VERSION_ID}"
    declare -a __T_STAGES=("${__P_STAGES[@]}")
    declare __T_PACKAGE_FILENAME=""

    if __lib_filename_from_libname "${__P_PACKAGENAME}" __T_PACKAGE_FILENAME; then
        true
    else
        return 111
    fi

    if [[ "${G_LIB_STAGE}" == "init" || "${G_LIB_STAGE}" == "installer" ]]; then
        if [[ -f "${G_LIB_DIR}/${__T_PACKAGE_FILENAME}" ]]; then
            if source "${G_LIB_DIR}/${__T_PACKAGE_FILENAME}"; then
                __LIB_PACKAGES_LOADED["${__P_PACKAGENAME,,}"]=1
                return 0
            fi
        fi
        return 1
    elif [[ "${G_LIB_STAGE}" == "build" ]]; then
        if ! declare -p GLOBAL_DEBUG >/dev/null 2>&1 || [[ "${GLOBAL_DEBUG}x" == "x" ]]; then
            if source <(__lib_package_create_all "${__T_PACKAGE_FILENAME}" "${__T_DISTRIBUTION_ID}" "${__T_DISTRIBUTION_VERSION_ID}" "${__T_STAGES[@]}"); then
                __LIB_PACKAGES_LOADED["${__P_PACKAGENAME,,}"]=1
                return 0
            fi
        else
            declare __T_MKTEMP="$(mktemp)"
            __LIB_DEBUG_FILES+=("${__T_MKTEMP}")
            if __lib_package_create_all_file "${__T_MKTEMP}" "${__T_PACKAGE_FILENAME}" "${__T_DISTRIBUTION_ID}" "${__T_DISTRIBUTION_VERSION_ID}" "${__T_STAGES[@]}"; then
                if source "${__T_MKTEMP}"; then
                    __LIB_PACKAGES_LOADED["${__P_PACKAGENAME,,}"]=1
                    return 0
                fi
            fi
        fi
        return 1
    else
        __log e -- "WHERE THE FUCK I AM?"
        return 254
    fi
    return 1
}

#####
#
# - __lib_require
#
# - Description
#   Takes the name of one or more packages to be loaded.
#
# - Parameters
#   - #1+ [IN|MANDATORY]: PACKAGENAMES - The name(s) of the packages to be loaded.
#
# - Return values
#   - 0 on success
#   - >0 on failure
#
function __lib_require() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_PACKAGENAMES=("${@}")
    fi

    # if the library has already loaded packages, try to filter out
    # the ones loaded here instead of calling __lib_package_load for
    # each package
    if [[ -n ${__LIB_PACKAGES_LOADED[@]:+x} ]]; then
        declare -a __T_PACKAGES_MISSING=()
        for __T_PACKAGE in "${__P_PACKAGENAMES[@]}"; do
            if [[ -z ${__LIB_PACKAGES_LOADED["${__T_PACKAGE,,}"]:+x} ]]; then
                __T_PACKAGES_MISSING+=("${__T_PACKAGE}")
            fi
        done
    else
        declare -a __T_PACKAGES_MISSING=("${__P_PACKAGENAMES[@]}")
    fi

    if [[ ${#__T_PACKAGES_MISSING[@]} -lt 1 ]]; then
        return 0
    fi

    declare -a __T_LOAD_OPTIONS=()
    if [[ "${G_LIB_STAGE}" == "build" ]]; then
        __T_LOAD_OPTIONS+=("${ID}" "${VERSION_ID}" "base" "build")
    fi

    for __T_PACKAGE in "${__P_PACKAGENAMES[@]}"; do
        if __lib_package_load "${__T_PACKAGE}" "${__T_LOAD_OPTIONS[@]}"; then
            continue
        else
            return $?
        fi
    done

    return 0

}


