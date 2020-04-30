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
        echo "THIS IS A CONFIGURATION FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
        exit 254;
fi
#####
# The build settings for a system.
# 
# All of these settings will be in alphabetical order as long as feasible.
#
####
# Global settings required for the build
#

#####
#
# - GLOBAL_BUILDVERSION
#
# The global version number that should be used for the build. This is the
# version number of the created images and NOT of code-server. It is used
# to set the version tag on the images.
#
# Default: 0.01
# Mandatory: YES
#
GLOBAL_BUILDVERSION="0.01"

#####
#
# - GLOBAL_DISTRIBUTION_ID,GLOBAL_DISTRIBUTION_NAME,GLOBAL_DISTRIBUTION_VERSION_CODENAME,GLOBAL_DISTRIBUTION_VERSION_ID
#
# The four variables mentioned before, are modeled after their corresponding versions in /etc/os-release
# They're used to check that we're on the right distribution version, to pull the images for docker and so on
#
# The three variables ID, NAME and VERSION_ID are usually set in all /etc/os-release files. The CODENAME is a speciality
# that is not used everywhere, so be a bit careful with this. The supported distributions are visible in 
# "lib/defaults.sh" in __D_SUPPORTED_DISTRIBUTION_IDS variable.
#

#####
#
# - GLOBAL_DISTRIBUTION_ID
#
# The following values are available at the time of writing:
# DISTRIBUTION - ID
# CentOS - centos
# Debian - debian
# Ubuntu - ubuntu
#
# Default: "ubuntu"
# Mandatory: Yes
#
GLOBAL_DISTRIBUTION_ID="debian"

#####
#
# - GLOBAL_DISTRIBUTION_NAME
#
# While this variable is basically a fancy version of the ID, on some distributions
# like Debian, they can become much more than just a name. So check beforehand what
# you need.
#
# Default: "Ubuntu"
# Mandatory: Yes
#
GLOBAL_DISTRIBUTION_NAME="Debian GNU/Linux"

#####
#
# - GLOBAL_DISTRIBUTION_VERSION_CODENAME
#
# This seems to be special to debian based distributions. It is used to 
# automagically create the build image names. So if you pick something
# non-debian, make sure you adjust the other variables.
#
# Default: "bionic"
# Mandatory: Yes
#
GLOBAL_DISTRIBUTION_VERSION_CODENAME="jessie"

#####
#
# - GLOBAL_DISTRIBUTION_VERSION_ID
#
# This represents the version of the distribution and the image that
# is pulled from the docker registry when the image names are auto generated.
#
# Default: '18.04'
# Mandatory: Yes
#
GLOBAL_DISTRIBUTION_VERSION_ID="8"

#####
#
# - GLOBAL_PACKAGES_PATH_{INSIDE,OUTSIDE}
#
# These two values are used to provide a persistent storage to the containers
# so that the build product will be available permanent and not just for the
# runtime of the containers.
# 
# The variables will be put together this way when a container is started
# via docker run:
#
# --volume "/srv/containers/build/codeserver/packages":"/packages"
#
# The build process uses GLOBAL_PACKAGES_PATH_INSIDE as base directory for
# storing build packages.
#
# The basic packages that you need in both images:
GLOBAL_PACKAGES_INSTALL=( "__ADD__" "apt-transport-https" "apt-utils" "ca-certificates" "curl" "git" "gnupg2" "python" "sudo" )

# Now the ADDITIONAL packages you need in the build image:
#
BUILD_PACKAGES_INSTALL=( "docker" "fakeroot" "gcc" "g++" "git" "jq" "libsecret-1-dev" "libterm-readline-gnu-perl" "libx11-dev" "libxkbfile-dev" "make" "nodejs" "pkg-config" "yarn" )

# And now the ADDITIONAL packages you might need in the run image:
#
RUN_PACKAGES_INSTALL=()

#####
#
# - GLOBAL_PACKAGES_PATH_INSIDE
#
# The inside path to the main packages directory
#
# Default: "/packages"
# Mandatory: No
#
GLOBAL_PACKAGES_PATH_INSIDE="/packages"

#####
#
# - GLOBAL_PACKAGES_PATH_OUTSIDE
#
# The outside part of the packages path. This is the path to a writeable directory
# on the host.
#
# Default: ""
# Mandatory: No
#
GLOBAL_PACKAGES_PATH_OUTSIDE="/srv/containers/build/codeserver/packages"
GLOBAL_PUSH_USERNAME="grimages"
GLOBAL_PUSH_PASSWORD_FILE="/data/.dockerpass"

