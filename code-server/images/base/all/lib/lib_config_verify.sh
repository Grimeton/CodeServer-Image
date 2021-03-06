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
    echo "THIS IS A CONFIGURATION FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}")'"
    exit 254
fi

set -o nounset

function __logw() {

    if [[ -z ${GLOBAL_DEBUG+x} ]]; then
        return 0
    elif [[ "${GLOBAL_DEBUG}x" == "x" ]]; then
        return 0
    fi

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    else
        declare __P_INDENT="${@:1:1}"
    fi
    if [[ "${@:2:1}x" == "x" ]]; then
        return 3
    else
        declare __P_VARNAME="${@:2:1}"
    fi

    if __array_exists "${__P_VARNAME}" || __aarray_exists "${__P_VARNAME}"; then
        __log w "${__P_INDENT}" "(${__P_VARNAME}) is not set. Using default: '${!__P_VARNAME[@]}'.\n"
    else
        __log w "${__P_INDENT}" "(${__P_VARNAME}) is not set. Using default: '${!__P_VARNAME}'.\n"
    fi
}
#####
#
# - Preset file
#
# - Description
#   The main build settings for the whole build process.
#   Variables that need a default value inherit from GLOBAL_. All the inheritance is done while the configuration
#   is checked. Once that is done, there won't be any changes to the GLOBAL_ BUILD_ and RUN_ variables anymore.
#
#   Usually each variable is available in three versions:
#
#   - GLOBAL_
#       The global version of the variable. It will be used as the default in case the same variable in the
#       BUILD_ or RUN_ section is not set and needs a value.
#
#   - BUILD_
#       The build version of the variable. When the process of creating a working container image is in the
#       stage "build", then these variables are used.
#
#   - RUN_
#       The run version of the variable. When the process of creating a working container image is in the
#       the stage "run", these variables are in effect.
#
#
#   As long as possible, the variables are in alphabetical order, starting with the GLOBAL_ then the BUILD_
#   and finally the RUN_ variables.
#
####
# Global settings required for the build
#
# the build version to be used globally
#

# The global array of variables. The variables in here will later
# be stored in the settings.conf file and moved from stage to stage.
if [[ -z ${__REGISTERED_VARIABLES[@]+x} ]]; then
    declare -agx __REGISTERED_VARIABLES=()
fi

__log i - "(CONFIGURATION) Beginning configuration check...\n"

# global value for the future build directory inside the image.
if [[ -z ${GLOBAL_BUILD_DIRECTORY+x} ]]; then
    GLOBAL_BUILD_DIRECTORY="/usr/src/build"
    __logw -- GLOBAL_BUILD_DIRECTORY
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILD_DIRECTORY)

# global value to enforce a rebuild of an already existing CodeServer version.
if [[ -z ${GLOBAL_BUILD_FORCE+x} ]]; then
    GLOBAL_BUILD_FORCE=""
elif [[ "${GLOBAL_BUILD_FORCE}x" != "x" ]]; then
    __log i -- "(GLOBAL_BUILD_FORCE) Rebuild is forced!\n"
else
    GLOBAL_BUILD_FORCE=""
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILD_FORCE)

# The global build version. Internal number.
if [[ -z ${GLOBAL_BUILDVERSION+x} ]]; then
    GLOBAL_BUILDVERSION="0.01"
    __logw -- GLOBAL_BUILDVERSION
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILDVERSION)

# String that can be set that is part of the release marker.
# When not set or empty, not used.
if [[ -z ${GLOBAL_BUILDVERSION_RELEASE+x} ]]; then
    GLOBAL_BUILDVERSION_RELEASE=""
    __logw -- GLOBAL_BUILDVERSION_RELEASE
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILDVERSION_RELEASE)

if [[ -z ${GLOBAL_BUILDVERSION_SUFFIX+x} ]]; then
    GLOBAL_BUILDVERSION_SUFFIX=""
    __logw -- GLOBAL_BUILDVERSION_SUFFIX
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILDVERSION_SUFFIX)

if [[ -z ${GLOBAL_BUILDVERSION_FINAL+x} ]]; then
    if [[ "${GLOBAL_BUILDVERSION_RELEASE}x" == "x" ]]; then
        GLOBAL_BUILDVERSION_FINAL="${GLOBAL_BUILDVERSION}"
    else
        GLOBAL_BUILDVERSION_FINAL="${GLOBAL_BUILDVERSION}-${GLOBAL_BUILDVERSION_RELEASE}"
    fi
    if [[ "${GLOBAL_BUILDVERSION_SUFFIX}x" == "x" ]]; then
        GLOBAL_BUILDVERSION_FINAL="${GLOBAL_BUILDVERSION_FINAL}"
    else
        GLOBAL_BUILDVERSION_FINAL="${GLOBAL_BUILDVERSION_FINAL}-${GLOBAL_BUILDVERSION_SUFFIX}"
    fi

    __logw -- GLOBAL_BUILDVERSION_FINAL
fi
__REGISTERED_VARIABLES+=(GLOBAL_BUILDVERSION_FINAL)

if ! __variable_exists GLOBAL_CONFIG_FILENAME || __variable_empty GLOBAL_CONFIG_FILENAME; then
    __log e -- "GLOBAL_CONFIG_FILENAME IS EMPTY.\n"
    exit 199
fi

if [[ -z ${GLOBAL_CONFIG_VERIFY_PUBLIC+x} ]]; then
    GLOBAL_CONFIG_VERIFY_PUBLIC=1
    __logw -- GLOBAL_CONFIG_VERIFY_PUBLIC
fi
__REGISTERED_VARIABLES+=(GLOBAL_CONFIG_VERIFY_PUBLIC)

# debug?
if [[ -z ${GLOBAL_DEBUG+x} || "${GLOBAL_DEBUG}x" == "x" ]]; then
    declare -gx GLOBAL_DEBUG=""
else
    __log i -- "(GLOBAL_DEBUG) Debug enabled...\n"
fi
__REGISTERED_VARIABLES+=(GLOBAL_DEBUG)
# CentOS - centos
# Debian - debian
# Ubuntu - ubuntu
# the distribution ID to be used everywhere
if [[ -z ${GLOBAL_DISTRIBUTION_ID+x} ]]; then
    GLOBAL_DISTRIBUTION_ID="ubuntu"
    __logw -- GLOBAL_DISTRIBUTION_ID
else
    GLOBAL_DISTRIBUTION_ID="${GLOBAL_DISTRIBUTION_ID,,}"
fi
__REGISTERED_VARIABLES+=(GLOBAL_DISTRIBUTION_ID)

# CentOS - Centos
# Debian - Debian
# Ubuntu - Ubuntu
# the distribution name to be used globally...
if [[ -z ${GLOBAL_DISTRIBUTION_NAME+x} ]]; then
    GLOBAL_DISTRIBUTION_NAME="Ubuntu"
    __logw -- GLOBAL_DISTRIBUTION_NAME
fi
__REGISTERED_VARIABLES+=(GLOBAL_DISTRIBUTION_NAME)

# CentOS
# Debian
# Ubuntu
# - 16.04 - xenial
# - 18.04 - bionic
# - 19.04 - disco
# - 19.10 - eoan
# the codename to be used globally
if [[ -z ${GLOBAL_DISTRIBUTION_VERSION_CODENAME+x} ]]; then
    GLOBAL_DISTRIBUTION_VERSION_CODENAME="bionic"
    __logw -- GLOBAL_DISTRIBUTION_VERSION_CODENAME
else
    GLOBAL_DISTRIBUTION_VERSION_CODENAME="${GLOBAL_DISTRIBUTION_VERSION_CODENAME,,}"
fi
__REGISTERED_VARIABLES+=(GLOBAL_DISTRIBUTION_VERSION_CODENAME)

# Whatever distribution ids the distribution offers to get images
if ! __variable_exists GLOBAL_DISTRIBUTION_VERSION_ID || __variable_empty GLOBAL_DISTRIBUTION_VERSION_ID; then
    declare GLOBAL_DISTRIBUTION_VERSION_ID="18.04"
    __logw -- GLOBAL_DISTRIBUTION_VERSION_ID
fi
__REGISTERED_VARIABLES+=(GLOBAL_DISTRIBUTION_VERSION_ID)

__log_banner_start i -- ""
__log_banner_content i -- "" "" ""
__ERROR=101

if __config_distribution_verify "${GLOBAL_DISTRIBUTION_ID}" "${GLOBAL_DISTRIBUTION_NAME}" "${GLOBAL_DISTRIBUTION_VERSION_ID}" "${GLOBAL_DISTRIBUTION_VERSION_CODENAME}"; then
    __log_banner_content i -- "" "" "Distribution settings supported."
    __ERROR=
else
    __log_banner_content e -- "" "" "Distribution settings NOT supported. Exiting."
fi

__log_banner_content i -- "" "" ""
__log_banner_content i -- "" "" "GLOBAL_DISTRIBUTION_ID: '${GLOBAL_DISTRIBUTION_ID}'"
__log_banner_content i -- "" "" "GLOBAL_DISTRIBUTION_NAME: '${GLOBAL_DISTRIBUTION_NAME}'"
__log_banner_content i -- "" "" "GLOBAL_DISTRIBUTION_VERSION_ID: '${GLOBAL_DISTRIBUTION_VERSION_ID}'"
__log_banner_content i -- "" "" "GLOBAL_DISTRIBUTION_VERSION_CODENAME: '${GLOBAL_DISTRIBUTION_VERSION_CODENAME}'"
__log_banner_content i -- "" "" ""
__log_banner_end i -- ""

[[ "${__ERROR}x" != "x" ]] && exit "${__ERROR}"
unset __ERROR

# suffix for images, like the debian "-slim" ones.
if [[ ! -z ${GLOBAL_DOCKER_ARG_FROM_SUFFIX+x} ]] && [[ "${GLOBAL_DOCKER_ARG_FROM_SUFFIX}x" != "x" ]]; then
    __log i -- "(GLOBAL_DOCKER_ARG_FROM_SUFFIX) activated: '${GLOBAL_DOCKER_ARG_FROM_SUFFIX}'.\n"
else
    GLOBAL_DOCKER_ARG_FROM_SUFFIX=""
fi
__REGISTERED_VARIABLES+=(GLOBAL_DOCKER_ARG_FROM_SUFFIX)

# the argument that is used for the "FROM" arg inside a Dockerfile
if [[ -z ${GLOBAL_DOCKER_ARG_FROM+x} ]]; then

    GLOBAL_DOCKER_ARG_FROM="${GLOBAL_DISTRIBUTION_ID}:${GLOBAL_DISTRIBUTION_VERSION_ID}${GLOBAL_DOCKER_ARG_FROM_SUFFIX}"
    __logw -- GLOBAL_DOCKER_ARG_FROM
fi
__REGISTERED_VARIABLES+=(GLOBAL_DOCKER_ARG_FROM)

# the build mode, basically the sub directory name in the
# docker folders
if [[ -z ${GLOBAL_DOCKER_BUILDMODE+x} ]]; then
    GLOBAL_DOCKER_BUILDMODE="default"
    __logw -- GLOBAL_DOCKER_BUILDMODE
fi
__REGISTERED_VARIABLES+=(GLOBAL_DOCKER_BUILDMODE)

# The filename to use for Docker. The path will be
# adjusted automatically.
if [[ -z ${GLOBAL_DOCKER_FILENAME+x} ]]; then
    GLOBAL_DOCKER_FILENAME="Dockerfile"
    __logw -- GLOBAL_DOCKER_FILENAME
fi
__REGISTERED_VARIABLES+=(GLOBAL_DOCKER_FILENAME)

# the global variable holding the installer's default directory
#
if [[ -z ${GLOBAL_INSTALLER_DIRECTORY+x} ]]; then
    if [[ -z ${__D_INSTALLER_DIRECTORY+x} ]]; then
        GLOBAL_INSTALLER_DIRECTORY="/opt/installer"
    else
        GLOBAL_INSTALLER_DIRECTORY="${__D_INSTALLER_DIRECTORY}"
    fi
    __logw -- GLOBAL_INSTALLER_DIRECTORY
fi
__REGISTERED_VARIABLES+=(GLOBAL_INSTALLER_DIRECTORY)

#
# the init command that will be used to start the container
if [[ -z ${GLOBAL_INIT_COMMAND+x} ]] || [[ "${GLOBAL_INIT_COMMAND}x" == "x" ]]; then
    GLOBAL_INIT_COMMAND="/usr/local/bin/dumb-init"
    __logw -- GLOBAL_INIT_COMMAND
fi
__REGISTERED_VARIABLES+=(GLOBAL_INIT_COMMAND)
#
# Global locales settings
if [[ -z ${GLOBAL_LOCALES+x} ]]; then
    GLOBAL_LOCALES="de_DE.UTF-8 en_US.UTF-8"
    __logw -- GLOBAL_LOCALES
fi
__REGISTERED_VARIABLES+=(GLOBAL_LOCALES)

if [[ -z ${GLOBAL_MULTISTAGE+x} ]]; then
    GLOBAL_MULTISTAGE=""
elif [[ "${GLOBAL_MULTISTAGE}x" == "x" ]]; then
    GLOBAL_MULTISTAGE=""
else
    GLOBAL_MULTISTAGE="${GLOBAL_MULTISTAGE}"
fi
__REGISTERED_VARIABLES+=(GLOBAL_MULTISTAGE)

# this is an array of packages that should be installed.
#
# If the other variables {BUILD,RUN}_PACKAGES_INSTALL
# contain variables then you can tell the system
# to add the global packages to those variables:
#
# if first value (0) is "__ADD__"
# then the packages will be added to all other variables
# BUILD_PACKAGES_INSTALL and RUN_PACKAGES_INSTALL
#
# if first value (0) is "__ADD_BUILD__" then they're added
# to BUILD_PACKAGES_INSTALL but not to RUN_PACKAGES_INSTALL
# not even if the variable is empty
#
# if first value (0) is "__ADD_RUN__" then they're added
# to RUN_PACKAGES_INSTALL but not to BUILD_PACKAGES_INSTALL
# not even if the variable is empty
if [[ -z ${GLOBAL_PACKAGES_INSTALL+x} ]]; then
    GLOBAL_PACKAGES_INSTALL=("__ADD__")
    __logw -- GLOBAL_PACKAGES_INSTALL
fi
# __REGISTERED_VARIABLES+=(GLOBAL_PACKAGES_INSTALL)
# This is the volume we use to share the build packages between containers.
# The inside path
if [[ -z ${GLOBAL_PACKAGES_PATH_INSIDE+x} ]]; then
    GLOBAL_PACKAGES_PATH_INSIDE="/packages"
    __logw -- GLOBAL_PACKAGES_PATH_INSIDE
fi
__REGISTERED_VARIABLES+=(GLOBAL_PACKAGES_PATH_INSIDE)

# the outside path
if [[ -z ${GLOBAL_PACKAGES_PATH_OUTSIDE+x} ]]; then
    GLOBAL_PACKAGES_PATH_OUTSIDE="/srv/containers/build/codeserver/packages"
    __logw -- GLOBAL_PACKAGES_PATH_OUTSIDE
fi
__REGISTERED_VARIABLES+=(GLOBAL_PACKAGES_PATH_OUTSIDE)
if [[ -z ${GLOBAL_PUSH_OVERRIDE+x} ]]; then
    GLOBAL_PUSH_OVERRIDE=""
    __logw -- GLOBAL_PUSH_OVERRIDE
fi
__REGISTERED_VARIABLES+=(GLOBAL_PUSH_OVERRIDE)

if [[ -z ${GLOBAL_PUSH_USERNAME+x} ]]; then
    GLOBAL_PUSH_USERNAME=""
    __logw -- GLOBAL_PUSH_USERNAME
fi
__REGISTERED_VARIABLES+=(GLOBAL_PUSH_USERNAME)

if [[ -z ${GLOBAL_PUSH_PASSWORD_FILE+x} ]]; then
    GLOBAL_PUSH_PASSWORD_FILE=""
    __logw -- GLOBAL_PUSH_PASSWORD_FILE
fi
__REGISTERED_VARIABLES+=(GLOBAL_PUSH_PASSWORD_FILE)

# the path where to put the script collection
if [[ -z ${GLOBAL_STAGING_DIRECTORY+x} ]]; then
    if __variable_exists __D_STAGING_DIRECTORY; then
        if [[ "${__D_STAGING_DIRECTORY}x" != "x" ]]; then
            GLOBAL_STAGING_DIRECTORY="${__D_STAGING_DIRECTORY}"
        else
            GLOBAL_STAGING_DIRECTORY="/usr/src/staging"
        fi
    else
        GLOBAL_STAGING_DIRECTORY="/usr/src/staging"
    fi
    __logw -- GLOBAL_STAGING_DIRECTORY
fi
__REGISTERED_VARIABLES+=(GLOBAL_STAGING_DIRECTORY)

if [[ -z ${GLOBAL_VERBOSE+x} ]] || [[ "${GLOBAL_VERBOSE}x" == "x" ]]; then
    if [[ "${GLOBAL_DEBUG}x" != "x" ]]; then
        GLOBAL_VERBOSE=1
        __log i -- "Enabeling GLOBAL_VERBOSE because GLOBAL_DEBUG is enabled.\n"
    else
        GLOBAL_VERBOSE=""
        __logw -- GLOBAL_VERBOSE
    fi
else
    if [[ "${GLOBAL_DEBUG}x" != "x" ]]; then
        GLOBAL_VERBOSE=1
        __log i -- "Enabeling GLOBAL_VERRBOSE because GLOBAL_DEBUG is enabled.\n"
    fi
fi
__REGISTERED_VARIABLES+=(GLOBAL_VERBOSE)

####
# Build image settings
#
# - These settings are to *CREATE* the image
# - AGAIN: the build image settings will be used to CREATE the build image
#   and NOT inside it...
# - Settings for the build image
# - The name of some of the variables are modeled after /etc/os-release
#

if [[ -z ${BUILD_BUILD_DIRECTORY+x} ]]; then
    BUILD_BUILD_DIRECTORY="${GLOBAL_BUILD_DIRECTORY}"
    __logw -- BUILD_BUILD_DIRECTORY
fi
__REGISTERED_VARIABLES+=(BUILD_BUILD_DIRECTORY)

if [[ -z ${BUILD_BUILD_FORCE+x} ]]; then
    BUILD_BUILD_FORCE="${GLOBAL_BUILD_FORCE}"
    __logw -- BUILD_BUILD_FORCE
fi
__REGISTERED_VARIABLES+=(BUILD_BUILD_FORCE)

# the version number of this build
if [[ -z ${BUILD_BUILDVERSION+x} ]]; then
    BUILD_BUILDVERSION="${GLOBAL_BUILDVERSION}"
    __logw -- BUILD_BUILDVERSION
fi
__REGISTERED_VARIABLES+=(BUILD_BUILDVERSION)

if [[ -z ${BUILD_BUILDVERSION_RELEASE+x} ]]; then
    BUILD_BUILDVERSION_RELEASE="${GLOBAL_BUILDVERSION_RELEASE}"
    __logw -- BUILD_BUILDVERSION_RELEASE
fi
__REGISTERED_VARIABLES+=(BUILD_BUILDVERSION_RELEASE)

if [[ -z ${BUILD_BUILDVERSION_SUFFIX+x} ]]; then
    BUILD_BUILDVERSION_SUFFIX="${GLOBAL_BUILDVERSION_SUFFIX}"
    __logw -- BUILD_BUILDVERSION_SUFFIX
fi
__REGISTERED_VARIABLES+=(BUILD_BUILDVERSION_SUFFIX)

if [[ -z ${BUILD_BUILDVERSION_FINAL+x} ]]; then

    if [[ "${BUILD_BUILDVERSION_RELEASE}x" == "x" ]]; then
        BUILD_BUILDVERSION_FINAL="${BUILD_BUILDVERSION}"
    else
        BUILD_BUILDVERSION_FINAL="${BUILD_BUILDVERSION}-${BUILD_BUILDVERSION_RELEASE}"
    fi

    if [[ "${BUILD_BUILDVERSION_SUFFIX}x" == "x" ]]; then
        BUILD_BUILDVERSION_FINAL="${BUILD_BUILDVERSION_FINAL}"
    else
        BUILD_BUILDVERSION_FINAL="${BUILD_BUILDVERSION_FINAL}-${BUILD_BUILDVERSION_SUFFIX}"
    fi
    __logw -- BUILD_BUILDVERSION_FINAL
fi
__REGISTERED_VARIABLES+=(BUILD_BUILDVERSION_FINAL)

###
# Enable debug output
#
if [[ -z ${BUILD_DEBUG+x} ]]; then
    BUILD_DEBUG="${GLOBAL_DEBUG}"
    __logw -- BUILD_DEBUG
fi
__REGISTERED_VARIABLES+=(BUILD_DEBUG)

###
# The distribution ID, set by all distributions so far.
# Will be used to create the image to pull from the docker repo if
# BUILD_IMAGE_FROM is not set.
if [[ -z ${BUILD_DISTRIBUTION_ID+x} ]]; then
    BUILD_DISTRIBUTION_ID="${GLOBAL_DISTRIBUTION_ID}"
    __logw -- BUILD_DISTRIBUTION_ID
fi
__REGISTERED_VARIABLES+=(BUILD_DISTRIBUTION_ID)

###
# The name of the distribution. mostly set, not really used for this so far...
if [[ -z ${BUILD_DISTRIBUTION_NAME+x} ]]; then
    BUILD_DISTRIBUTION_NAME="${GLOBAL_DISTRIBUTION_NAME}"
    __logw -- BUILD_DISTRIBUTION_NAME
fi
__REGISTERED_VARIABLES+=(BUILD_DISTRIBUTION_NAME)

###
# The codename of a distribution. Not all distributions set this, e.g. fedora or alpine.
# We use this to create the image's name later.
if [[ -z ${BUILD_DISTRIBUTION_VERSION_CODENAME+x} ]]; then
    BUILD_DISTRIBUTION_VERSION_CODENAME="${GLOBAL_DISTRIBUTION_VERSION_CODENAME}"
    __logw -- BUILD_DISTRIBUTION_VERSION_CODENAME
fi
__REGISTERED_VARIABLES+=(BUILD_DISTRIBUTION_VERSION_CODENAME)

###
# The distribution version id. Set by all distributions so far and used in various places
# during the main build of all images. We need this, e.g. to download the package lists
# from microsoft later
if [[ -z ${BUILD_DISTRIBUTION_VERSION_ID+x} ]]; then
    BUILD_DISTRIBUTION_VERSION_ID="${GLOBAL_DISTRIBUTION_VERSION_ID}"
    __logw -- BUILD_DISTRIBUTION_VERSION_ID
fi
__REGISTERED_VARIABLES+=(BUILD_DISTRIBUTION_VERSION_ID)

# the parameter for the Dockerfile "FROM" argument.
if [[ -z ${BUILD_DOCKER_ARG_FROM+x} ]]; then
    BUILD_DOCKER_ARG_FROM="${GLOBAL_DOCKER_ARG_FROM}"
    __logw -- BUILD_DOCKER_ARG_FROM
fi
__REGISTERED_VARIABLES+=(BUILD_DOCKER_ARG_FROM)

if [[ -z ${BUILD_DOCKER_ARG_FROM_SUFFIX+x} ]]; then
    BUILD_DOCKER_ARG_FROM_SUFFIX="${GLOBAL_DOCKER_ARG_FROM_SUFFIX}"
    __logw -- BUILD_DOCKER_ARG_FROM_SUFFIX
fi
__REGISTERED_VARIABLES+=(BUILD_DOCKER_ARG_FROM_SUFFIX)

if [[ -z ${BUILD_DOCKER_BUILDMODE+x} ]]; then
    BUILD_DOCKER_BUILDMODE="${GLOBAL_DOCKER_BUILDMODE}"
    __logw -- BUILD_DOCKER_BUILDMODE
fi
__REGISTERED_VARIABLES+=(BUILD_DOCKER_BUILDMODE)

# The filename used to build the image. Path will be adjusted automatically
if [[ -z ${BUILD_DOCKER_FILENAME+x} ]]; then
    BUILD_DOCKER_FILENAME="${GLOBAL_DOCKER_FILENAME}"
    __logw -- BUILD_DOCKER_FILENAME
fi
__REGISTERED_VARIABLES+=(BUILD_DOCKER_FILENAME)
#
# the init command that will be used to start the container
if [[ -z ${BUILD_INIT_COMMAND+x} ]]; then
    BUILD_INIT_COMMAND="/usr/local/bin/dumb-init"
    __logw -- BUILD_INIT_COMMAND
fi
__REGISTERED_VARIABLES+=(BUILD_INIT_COMMAND)
# the global variable holding the installer's default directory
#
if [[ -z ${BUILD_INSTALLER_DIRECTORY+x} ]]; then
    BUILD_INSTALLER_DIRECTORY="${GLOBAL_INSTALLER_DIRECTORY}"
    __logw -- BUILD_INSTALLER_DIRECTORY
fi
__REGISTERED_VARIABLES+=(BUILD_INSTALLER_DIRECTORY)

# locales that should be used
if [[ -z ${BUILD_LOCALES+x} ]]; then
    BUILD_LOCALES="${GLOBAL_LOCALES}"
    __logw -- BUILD_LOCALES
fi
__REGISTERED_VARIABLES+=(BUILD_LOCALES)

if [[ -z ${BUILD_PACKAGES_INSTALL+x} ]]; then
    __T_REGEX='^__ADD(_BUILD|_RUN)?__$'
    if [[ "${GLOBAL_PACKAGES_INSTALL[0]}" =~ ${__T_REGEX} ]]; then
        BUILD_PACKAGES_INSTALL=("${GLOBAL_PACKAGES_INSTALL[@]:1}")
    else
        BUILD_PACKAGES_INSTALL=("${GLOBAL_PACKAGES_INSTALL[@]}")
    fi
    __logw -- BUILD_PACKAGES_INSTALL
    unset __T_REGEX
else
    __T_REGEX='^__ADD(_BUILD)?__$'
    if [[ "${GLOBAL_PACKAGES_INSTALL[0]}" =~ ${__T_REGEX} ]]; then
        BUILD_PACKAGES_INSTALL+=("${GLOBAL_PACKAGES_INSTALL[@]:1}")
    fi
    unset __T_REGEX
fi
# __REGISTERED_VARIABLES+=(BUILD_PACKAGES_INSTALL)
set +x

# the container path to the package sharing directory.
if [[ -z ${BUILD_PACKAGES_PATH_INSIDE+x} ]]; then
    BUILD_PACKAGES_PATH_INSIDE="${GLOBAL_PACKAGES_PATH_INSIDE}"
    __logw -- BUILD_PACKAGES_PATH_INSIDE
fi
__REGISTERED_VARIABLES+=(BUILD_PACKAGES_PATH_INSIDE)

# the outside path to the package sharing directory (on the host)
if [[ -z ${BUILD_PACKAGES_PATH_OUTSIDE+x} ]]; then
    BUILD_PACKAGES_PATH_OUTSIDE="${GLOBAL_PACKAGES_PATH_OUTSIDE}"
    __logw -- BUILD_PACKAGES_PATH_OUTSIDE
fi
__REGISTERED_VARIABLES+=(BUILD_PACKAGES_PATH_OUTSIDE)

# the staging directory, where to build everything
# this is inside the container.
if [[ -z ${BUILD_STAGING_DIRECTORY+x} ]]; then
    BUILD_STAGING_DIRECTORY="${GLOBAL_STAGING_DIRECTORY}"
    __logw -- BUILD_STAGING_DIRECTORY
fi
__REGISTERED_VARIABLES+=(BUILD_STAGING_DIRECTORY)

# the basename for the tags used to tag the build image.
if [[ -z ${BUILD_TAG_IMAGE_BASENAME+x} ]]; then
    BUILD_TAG_IMAGE_BASENAME="codeserver"

    for _VAR in BUILD_DISTRIBUTION_ID BUILD_DISTRIBUTION_VERSION_ID BUILD_DISTRIBUTION_VERSION_CODENAME; do
        if [[ "${!_VAR}x" != "x" ]]; then
            BUILD_TAG_IMAGE_BASENAME+="-${!_VAR}"
        fi
    done
    BUILD_TAG_IMAGE_BASENAME+="-build"
    __logw -- BUILD_TAG_IMAGE_BASENAME
fi
__REGISTERED_VARIABLES+=(BUILD_TAG_IMAGE_BASENAME)

# the name of the image's tag
if [[ -z ${BUILD_TAG_IMAGE_NAME+x} ]]; then
    BUILD_TAG_IMAGE_NAME="${BUILD_TAG_IMAGE_BASENAME}:${BUILD_BUILDVERSION_FINAL}"
    __logw -- BUILD_TAG_IMAGE_NAME
fi
__REGISTERED_VARIABLES+=(BUILD_TAG_IMAGE_NAME)

# should the image be tagged as latest
if [[ -z ${BUILD_TAG_IMAGE_LATEST+x} ]]; then
    if [[ "${BUILD_BUILDVERSION_SUFFIX}x" == "x" ]]; then
        BUILD_TAG_IMAGE_LATEST="${BUILD_TAG_IMAGE_BASENAME}:latest"
    else
        BUILD_TAG_IMAGE_LATEST="${BUILD_TAG_IMAGE_BASENAME}:${BUILD_BUILDVERSION_SUFFIX}-latest"
    fi
    if [[ "${BUILD_BUILDVERSION_RELEASE}x" == "x" ]]; then
        BUILD_TAG_IMAGE_LATEST="${BUILD_TAG_IMAGE_LATEST}"
    else
        BUILD_TAG_IMAGE_LATEST="${BUILD_TAG_IMAGE_LATEST}-${BUILD_BUILDVERSION_RELEASE}"
    fi

    __logw -- BUILD_TAG_IMAGE_LATEST
fi
__REGISTERED_VARIABLES+=(BUILD_TAG_IMAGE_LATEST)

if [[ -z ${BUILD_VSCODE_GIT_BRANCH+x} ]]; then
    BUILD_VSCODE_GIT_BRANCH=""
else
    __log i -- "(BUILD_VSCODE_GIT_BRANCH) is set to '${BUILD_VSCODE_GIT_BRANCH}'.\n"
fi
__REGISTERED_VARIABLES+=(BUILD_VSCODE_GIT_BRANCH)

if [[ -z ${BUILD_VSCODE_GIT_TAG+x} ]]; then
    BUILD_VSCODE_GIT_TAG=""
else
    __log i -- "(BUILD_VSCODE_GIT_TAG) is set to '${BUILD_VSCODE_GIT_TAG}'.\n"
fi
__REGISTERED_VARIABLES+=(BUILD_VSCODE_GIT_TAG)

if [[ -z ${BUILD_VSCODE_SOURCE_TARBALL+x} ]]; then
    BUILD_VSCODE_SOURCE_TARBALL=""
else
    __log i -- "(BUILD_VSCODE_SOURCE_TARBALL) is set to: '${BUILD_VSCODE_SOURCE_TARBALL}'.\n"
fi
__REGISTERED_VARIABLES+=(BUILD_VSCODE_SOURCE_TARBALL)

__log_banner_start i -- ""
__log_banner_content i -- "" "" ""
__ERROR=102

if __config_distribution_verify "${BUILD_DISTRIBUTION_ID}" "${BUILD_DISTRIBUTION_NAME}" "${BUILD_DISTRIBUTION_VERSION_ID}" "${BUILD_DISTRIBUTION_VERSION_CODENAME}"; then
    __log_banner_content i -- "" "" "Build distribution settings supported."
    __ERROR=
else
    __log_banner_content e -- "" "" "Build distribution settings NOT supported. Exiting."
fi

__log_banner_content i -- "" "" ""
__log_banner_content i -- "" "" "BUILD_DISTRIBUTION_ID: '${BUILD_DISTRIBUTION_ID}'"
__log_banner_content i -- "" "" "BUILD_DISTRIBUTION_NAME: '${BUILD_DISTRIBUTION_NAME}'"
__log_banner_content i -- "" "" "BUILD_DISTRIBUTION_VERSION_ID: '${BUILD_DISTRIBUTION_VERSION_ID}'"
__log_banner_content i -- "" "" "BUILD_DISTRIBUTION_VERSION_CODENAME: '${BUILD_DISTRIBUTION_VERSION_CODENAME}'"
__log_banner_content i -- "" "" ""
__log_banner_end i -- ""

[[ "${__ERROR}x" != "x" ]] && exit "${__ERROR}"
unset __ERROR

####
# Run image settings
#
# - These settings are to *CREATE* the image
# - AGAIN: the run image settings will be used to CREATE the run image
#   and NOT to run it.
# - Settings for the run image
# - The name of some of the variables are modeled after /etc/os-release
#

if [[ -z ${RUN_BUILD_DIRECTORY+x} ]]; then
    RUN_BUILD_DIRECTORY="${GLOBAL_BUILD_DIRECTORY}"
    __logw -- RUN_BUILD_DIRECTORY
fi
__REGISTERED_VARIABLES+=(RUN_BUILD_DIRECTORY)

if [[ -z ${RUN_BUILD_FORCE+x} ]]; then
    RUN_BUILD_FORCE="${GLOBAL_BUILD_FORCE}"
    __logw -- RUN_BUILD_FORCE
fi
__REGISTERED_VARIABLES+=(RUN_BUILD_FORCE)

# the version number of this build
if [[ -z ${RUN_BUILDVERSION+x} ]]; then
    RUN_BUILDVERSION="${GLOBAL_BUILDVERSION}"
    __logw -- RUN_BUILDVERSION
fi
__REGISTERED_VARIABLES+=(RUN_BUILDVERSION)

if [[ -z ${RUN_BUILDVERSION_RELEASE+x} ]]; then
    RUN_BUILDVERSION_RELEASE="${GLOBAL_BUILDVERSION_RELEASE}"
    __logw -- RUN_BUILDVERSION_RELEASE
fi
__REGISTERED_VARIABLES+=(RUN_BUILDVERSION_RELEASE)

if [[ -z ${RUN_BUILDVERSION_SUFFIX+x} ]]; then
    RUN_BUILDVERSION_SUFFIX="${GLOBAL_BUILDVERSION_SUFFIX}"
    __logw -- RUN_BUILDVERSION_SUFFIX
fi
__REGISTERED_VARIABLES+=(RUN_BUILDVERSION_SUFFIX)

if [[ -z ${RUN_BUILDVERSION_FINAL+x} ]]; then

    if [[ "${RUN_BUILDVERSION_RELEASE}x" == "x" ]]; then
        RUN_BUILDVERSION_FINAL="${RUN_BUILDVERSION}"
    else
        RUN_BUILDVERSION_FINAL="${RUN_BUILDVERSION}-${RUN_BUILDVERSION_RELEASE}"
    fi

    if [[ "${RUN_BUILDVERSION_SUFFIX}x" == "x" ]]; then
        RUN_BUILDVERSION_FINAL="${RUN_BUILDVERSION_FINAL}"
    else
        RUN_BUILDVERSION_FINAL="${RUN_BUILDVERSION_FINAL}-${RUN_BUILDVERSION_SUFFIX}"
    fi
    __logw -- RUN_BUILDVERSION_FINAL
fi
__REGISTERED_VARIABLES+=(RUN_BUILDVERSION_FINAL)

###
# Enable debug output
#
if [[ -z ${RUN_DEBUG+x} ]]; then
    RUN_DEBUG="${GLOBAL_DEBUG}"
    __logw -- RUN_DEBUG
fi
__REGISTERED_VARIABLES+=(RUN_DEBUG)

###
# The distribution ID, set by all distributions so far.
# Will be used to create the image to pull from the docker repo if
# RUN_IMAGE_FROM is not set.
if [[ -z ${RUN_DISTRIBUTION_ID+x} ]]; then
    RUN_DISTRIBUTION_ID="${GLOBAL_DISTRIBUTION_ID}"
    __logw -- RUN_DISTRIBUTION_ID
fi
__REGISTERED_VARIABLES+=(RUN_DISTRIBUTION_ID)

###
# The name of the distribution. mostly set, not really used for this so far...
if [[ -z ${RUN_DISTRIBUTION_NAME+x} ]]; then
    RUN_DISTRIBUTION_NAME="${GLOBAL_DISTRIBUTION_NAME}"
    __logw -- RUN_DISTRIBUTION_NAME
fi
__REGISTERED_VARIABLES+=(RUN_DISTRIBUTION_NAME)

###
# The codename of a distribution. Not all distributions set this, e.g. fedora or alpine.
# We use this to create the image's name later.
if [[ -z ${RUN_DISTRIBUTION_VERSION_CODENAME+x} ]]; then
    RUN_DISTRIBUTION_VERSION_CODENAME="${GLOBAL_DISTRIBUTION_VERSION_CODENAME}"
    __logw -- RUN_DISTRIBUTION_VERSION_CODENAME
fi
__REGISTERED_VARIABLES+=(RUN_DISTRIBUTION_VERSION_CODENAME)

###
# The distribution version id. Set by all distributions so far and used in various places
# during the main build of all images. We need this, e.g. to download the package lists
# from microsoft later
if [[ -z ${RUN_DISTRIBUTION_VERSION_ID+x} ]]; then
    RUN_DISTRIBUTION_VERSION_ID="${GLOBAL_DISTRIBUTION_VERSION_ID}"
    __logw -- RUN_DISTRIBUTION_VERSION_ID
fi
__REGISTERED_VARIABLES+=(RUN_DISTRIBUTION_VERSION_ID)

# the parameter for the Dockerfile "FROM" argument.
if [[ -z ${RUN_DOCKER_ARG_FROM+x} ]]; then
    RUN_DOCKER_ARG_FROM="${GLOBAL_DOCKER_ARG_FROM}"
    __logw -- RUN_DOCKER_ARG_FROM
fi
__REGISTERED_VARIABLES+=(RUN_DOCKER_ARG_FROM)

# the parameter for the Dockerfile "FROM" argument - SUFFIX
if [[ -z ${RUN_DOCKER_ARG_FROM_SUFFIX+x} ]]; then
    RUN_DOCKER_ARG_FROM_SUFFIX="${GLOBAL_DOCKER_ARG_FROM_SUFFIX}"
    __logw -- RUN_DOCKER_ARG_FROM_SUFFIX
fi
__REGISTERED_VARIABLES+=(RUN_DOCKER_ARG_FROM_SUFFIX)

if [[ -z ${RUN_DOCKER_BUILDMODE+x} ]]; then
    RUN_DOCKER_BUILDMODE="${GLOBAL_DOCKER_BUILDMODE}"
    __logw -- RUN_DOCKER_BUILDMODE
fi
__REGISTERED_VARIABLES+=(RUN_DOCKER_BUILDMODE)

# The filename used to build the image. Path will be adjusted automatically
if [[ -z ${RUN_DOCKER_FILENAME+x} ]]; then
    RUN_DOCKER_FILENAME="${GLOBAL_DOCKER_FILENAME}"
    __logw -- RUN_DOCKER_FILENAME
fi
__REGISTERED_VARIABLES+=(RUN_DOCKER_FILENAME)
#
# the init command that will be used to start the container
if [[ -z ${RUN_INIT_COMMAND+x} ]]; then
    RUN_INIT_COMMAND="/usr/local/bin/dumb-init"
    __logw -- RUN_INIT_COMMAND
fi
__REGISTERED_VARIABLES+=(RUN_INIT_COMMAND)
# the run variable holding the installer's default directory
#
if [[ -z ${RUN_INSTALLER_DIRECTORY+x} ]]; then
    RUN_INSTALLER_DIRECTORY="${GLOBAL_INSTALLER_DIRECTORY}"
    __logw -- RUN_INSTALLER_DIRECTORY
fi
__REGISTERED_VARIABLES+=(RUN_INSTALLER_DIRECTORY)

# locales that should be used
if [[ -z ${RUN_LOCALES+x} ]]; then
    RUN_LOCALES="${GLOBAL_LOCALES}"
    __logw -- RUN_LOCALES
fi
__REGISTERED_VARIABLES+=(RUN_LOCALES)

# Packages to install for runtime
if [[ -z ${RUN_PACKAGES_INSTALL+x} ]]; then
    __T_REGEX='^__ADD(_BUILD|_RUN)?__$'
    if [[ "${GLOBAL_PACKAGES_INSTALL[0]}" =~ ${__T_REGEX} ]]; then
        RUN_PACKAGES_INSTALL=("${GLOBAL_PACKAGES_INSTALL[@]:1}")
    else
        RUN_PACKAGES_INSTALL=("${GLOBAL_PACKAGES_INSTALL[@]}")
    fi
    __logw -- RUN_PACKAGES_INSTALL
    unset __T_REGEX
else
    __T_REGEX='^__ADD(_RUN)?__$'
    if [[ "${GLOBAL_PACKAGES_INSTALL[0]}" =~ ${__T_REGEX} ]]; then
        RUN_PACKAGES_INSTALL+=("${GLOBAL_PACKAGES_INSTALL[@]:1}")
    fi
    unset __T_REGEX
fi
# __REGISTERED_VARIABLES+=(RUN_PACKAGES_INSTALL)

# the container path to the package sharing directory.
if [[ -z ${RUN_PACKAGES_PATH_INSIDE+x} ]]; then
    RUN_PACKAGES_PATH_INSIDE="${GLOBAL_PACKAGES_PATH_INSIDE}"
    __logw -- RUN_PACKAGES_PATH_INSIDE
fi
__REGISTERED_VARIABLES+=(RUN_PACKAGES_PATH_INSIDE)

# the outside path to the package sharing directory (on the host)
if [[ -z ${RUN_PACKAGES_PATH_OUTSIDE+x} ]]; then
    RUN_PACKAGES_PATH_OUTSIDE="${GLOBAL_PACKAGES_PATH_OUTSIDE}"
    __logw -- RUN_PACKAGES_PATH_OUTSIDE
fi
__REGISTERED_VARIABLES+=(RUN_PACKAGES_PATH_OUTSIDE)

# the staging directory, where to build everything
# this is inside the container.
if [[ -z ${RUN_STAGING_DIRECTORY+x} ]]; then
    RUN_STAGING_DIRECTORY="${GLOBAL_STAGING_DIRECTORY}"
    __logw -- RUN_STAGING_DIRECTORY
fi
__REGISTERED_VARIABLES+=(RUN_STAGING_DIRECTORY)

# the basename for the tags used to tag the build image.
if [[ -z ${RUN_TAG_IMAGE_BASENAME+x} ]]; then

    RUN_TAG_IMAGE_BASENAME="codeserver"

    for _VAR in RUN_DISTRIBUTION_ID RUN_DISTRIBUTION_VERSION_ID RUN_DISTRIBUTION_VERSION_CODENAME BUILD_VSCODE_GIT_BRANCH; do
        if [[ "${!_VAR}x" != "x" ]]; then
            RUN_TAG_IMAGE_BASENAME+="-${!_VAR}"
        fi
    done
    RUN_TAG_IMAGE_BASENAME+="-runtime"
    __logw -- RUN_TAG_IMAGE_BASENAME
fi
__REGISTERED_VARIABLES+=(RUN_TAG_IMAGE_BASENAME)

# the name of the image's tag
if [[ -z ${RUN_TAG_IMAGE_NAME+x} ]]; then
    RUN_TAG_IMAGE_NAME="${RUN_TAG_IMAGE_BASENAME}:${RUN_BUILDVERSION_FINAL}"
    __logw -- RUN_TAG_IMAGE_NAME
fi
__REGISTERED_VARIABLES+=(RUN_TAG_IMAGE_NAME)

# should the image be tagged as latest
if [[ -z ${RUN_TAG_IMAGE_LATEST+x} ]]; then

    if [[ "${RUN_BUILDVERSION_SUFFIX}x" == "x" ]]; then
        RUN_TAG_IMAGE_LATEST="${RUN_TAG_IMAGE_BASENAME}:latest"
    else
        RUN_TAG_IMAGE_LATEST="${RUN_TAG_IMAGE_BASENAME}:${RUN_BUILDVERSION_SUFFIX}-latest"
    fi
    if [[ "${RUN_BUILDVERSION_RELEASE}x" == "x" ]]; then
        RUN_TAG_IMAGE_LATEST="${RUN_TAG_IMAGE_LATEST}"
    else
        RUN_TAG_IMAGE_LATEST="${RUN_TAG_IMAGE_LATEST}-${RUN_BUILDVERSION_RELEASE}"
    fi
    __logw -- RUN_TAG_IMAGE_LATEST
fi
__REGISTERED_VARIABLES+=(RUN_TAG_IMAGE_LATEST)

__log_banner_start i -- ""
__log_banner_content i -- ""
__ERROR=103

if __config_distribution_verify "${RUN_DISTRIBUTION_ID}" "${RUN_DISTRIBUTION_NAME}" "${RUN_DISTRIBUTION_VERSION_ID}" "${RUN_DISTRIBUTION_VERSION_CODENAME}"; then
    __log_banner_content i -- "" "" "Runtime distribution settings supported."
    __ERROR=
else
    __log_banner_content e -- "" "" "Runtime distribution settings NOT supported. Exiting."
fi

__log_banner_content i -- "" "" "" ""
__log_banner_content i -- "" "" "RUN_DISTRIBUTION_ID: '${RUN_DISTRIBUTION_ID}'"
__log_banner_content i -- "" "" "RUN_DISTRIBUTION_NAME: '${RUN_DISTRIBUTION_NAME}'"
__log_banner_content i -- "" "" "RUN_DISTRIBUTION_VERSION_ID: '${RUN_DISTRIBUTION_VERSION_ID}'"
__log_banner_content i -- "" "" "RUN_DISTRIBUTION_VERSION_CODENAME: '${RUN_DISTRIBUTION_VERSION_CODENAME}'"
__log_banner_content i -- "" "" ""
__log_banner_end i -- ""

declare -Agx __CONFIG=()
for __T_REGISTERED_VARIABLE in "${__REGISTERED_VARIABLES[@]}"; do
    if [[ -z ${!__T_REGISTERED_VARIABLE+x} ]]; then
        echo "Z" >&2
        continue
    else
        __CONFIG["${__T_REGISTERED_VARIABLE}"]="${!__T_REGISTERED_VARIABLE}"
        if unset "${__T_REGISTERED_VARIABLE}"; then
            true
        else
            return 253
        fi
    fi
done

if [[ -z ${GLOBAL_PACKAGES_INSTALL[@]+x} ]]; then
    __CONFIG[GLOBAL_PACKAGES_INSTALL]=""
elif [[ ${#GLOBAL_PACKAGES_INSTALL[@]} -lt 1 ]]; then
    unset GLOBAL_PACKAGES_INSTALL
    __CONFIG[GLOBAL_PACKAGES_INSTALL]=""
else
    __CONFIG[GLOBAL_PACKAGES_INSTALL]=""
    for __T_PACKAGE in "${GLOBAL_PACKAGES_INSTALL[@]}"; do
        if [[ "${__T_PACKAGE}" == "__ADD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_BUILD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_RUN__" ]]; then
            continue
        fi

        __CONFIG[GLOBAL_PACKAGES_INSTALL]+=" ${__T_PACKAGE}"
    done
fi

if [[ -z ${BUILD_PACKAGES_INSTALL[@]+x} ]]; then
    __CONFIG[BUILD_PACKAGES_INSTALL]=""
elif [[ ${#BUILD_PACKAGES_INSTALL[@]} -lt 1 ]]; then
    __CONFIG[BUILD_PACKAGES_INSTALL]=""
    unset BUILD_PACKAGES_INSTALL
else
    __CONFIG[BUILD_PACKAGES_INSTALL]=""
    for __T_PACKAGE in "${BUILD_PACKAGES_INSTALL[@]}"; do
        if [[ "${__T_PACKAGE}" == "__ADD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_BUILD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_RUN__" ]]; then
            continue
        fi

        __CONFIG[BUILD_PACKAGES_INSTALL]+=" ${__T_PACKAGE}"
    done
fi

if [[ -z ${RUN_PACKAGES_INSTALL[@]+x} ]]; then
    __CONFIG[RUN_PACKAGES_INSTALL]=""
elif [[ ${#RUN_PACKAGES_INSTALL[@]} -lt 1 ]]; then
    __CONFIG[RUN_PACKAGES_INSTALL]=""
    unset RUN_PACKAGES_INSTALL
else
    __CONFIG[RUN_PACKAGES_INSTALL]=""
    for __T_PACKAGE in "${RUN_PACKAGES_INSTALL[@]}"; do
        if [[ "${__T_PACKAGE}" == "__ADD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_BUILD__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}" == "__ADD_RUN__" ]]; then
            continue
        elif [[ "${__T_PACKAGE}x" == "x" ]]; then
            continue
        fi

        __CONFIG[RUN_PACKAGES_INSTALL]+=" ${__T_PACKAGE}"
    done
fi

if [[ "${__ERROR}x" != "x" ]]; then
    exit ${__ERROR}
fi

unset __ERROR
unset -f __logw
unset __T_DEBUG
