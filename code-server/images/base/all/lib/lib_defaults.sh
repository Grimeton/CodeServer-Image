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
##########
#
# - Default values for all kinds of settings. Just scroll down and see...
#

#####
#
# - Distribution related settings
#

#####
#
# - Supported Distributions
#
# - Description:
#   These are the supported distributions so far. They are known to create a working
#   build and runtime image.
#
#   - Debian 8,9 and 10 are supported as well as their SLIM variants.
#   - The slim variants are identifying the same and are only called in via
#     a different DOCKER_FROM_ARG in the configuration.
#
#   - Ubuntu < 16.04 is not supported because it lacks nodejs 12 support
#   - Ubuntu Releases 16.10 17.04 17.10 18.10 19.04 are not supported. They are
#     EOL: https://wiki.ubuntu.com/Releases
#
#   The basic array just holds the names of the associative arrays that contain the final values.
#   It's a bit of a hack but surprisingly it works quite well ;-P
#
declare -agrx __D_DISTRIBUTIONS_SUPPORTED_IDS=(
    "__D_DISTRIBUTION_SUPPORTED_IDS_ALPINE_310"
    "__D_DISTRIBUTION_SUPPORTED_IDS_ALPINE_311"
    "__D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1604"
    "__D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1804"
    "__D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1910"
    "__D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_8"
    "__D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_9"
    "__D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_10"
    "__D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_SID"
)

#####
#
# - Per distribution array
#
# - Description:
#   These are the arrays that hold the per distribution data. Their name must
#   be registered in the __D_DISTRIBUTIONS_SUPPORTED_IDS array to work.
#
# - Fields:
#   Each array contains multiple key/value combinations, those are:
#
#   - [ID] - This is the "${ID}" from /etc/os-release. Usually a lowercase variant of the distribution's name like alpine,debian, ubuntu...
#   - [NAME] - The full blown "${NAME}" from /etc/os-release.
#   - [VERSION_ID] - The "${VERSION_ID}" from /etc/os-release.
#   - [VERSION_CODENAME] - The "${VERSION_CODENAME}" from /etc/os-release. This is a debian specific thing.
#   - [COMPRESSION] - The compression to be used with this distribution. This is quite usefull so that you don't need to install additional packages...
#   - [COMMENT] - Random comment chosen by me or you or whoever...
#
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_ALPINE_310=([ID]="alpine" [NAME]="Alpine Linux" [VERSION_ID]="3.10" [VERSION_CODENAME]="" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_ALPINE_311=([ID]="alpine" [NAME]="Alpine Linux" [VERSION_ID]="3.11" [VERSION_CODENAME]="" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_8=([ID]="debian" [NAME]="Debian GNU/Linux" [VERSION_ID]="8" [VERSION_CODENAME]="jessie" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_9=([ID]="debian" [NAME]="Debian GNU/Linux" [VERSION_ID]="9" [VERSION_CODENAME]="stretch" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_10=([ID]="debian" [NAME]="Debian GNU/Linux" [VERSION_ID]="10" [VERSION_CODENAME]="buster" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_DEBIAN_SID=([ID]="debian" [NAME]="Debian GNU/Linux" [VERSION_ID]="0" [VERSION_CODENAME]="sid" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1604=([ID]="ubuntu" [NAME]="Ubuntu" [VERSION_ID]="16.04" [VERSION_CODENAME]="xenial" [COMPRESSION]="gz" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1804=([ID]="ubuntu" [NAME]="Ubuntu" [VERSION_ID]="18.04" [VERSION_CODENAME]="bionic" [COMPRESSION]="bz2" [COMMENT]="")
declare -Agrx __D_DISTRIBUTION_SUPPORTED_IDS_UBUNTU_1910=([ID]="ubuntu" [NAME]="Ubuntu" [VERSION_ID]="19.10" [VERSION_CODENAME]="eoan" [COMPRESSION]="bz2" [COMMENT]="")

# the default compression algorithm to be used
declare -grx __D_DISTRIBUTIONS_COMPRESSION_DEFAULT="gz"

#####
#
# - GLOBAL settings
#

######
#
# - INIT related default settings
#

# base path of the init directory inside images
declare -grx __D_INIT_DIRECTORY="/usr/local/lib/init"

# Subdirectories that the init uses and where they are to be stored on the image later
declare -Agrx __D_INIT_SUBDIRECTORIES=([lib]="" [aliases]="aliases" [modules]="modules" [repos]="repos")

#
# - END: INIT related default settings
#
#####

#####
#
# - Installer related defaults
#

# the default directory used inside images to store the installer
declare -grx __D_INSTALLER_DIRECTORY="/opt/installer/"

# the default sub directory that the installer stores information in
declare -Agrx __D_INSTALLER_SUBDIRECTORIES=([downloads]="downloads" [repos]="repos")

#
# - END: Installer related defaults
#
#####

#####
#
# - Library defaults
#

# the default header to be used in files that are created by the lib
read -r -d '' __D_LIB_DEFAULT_HEADER <<EOF
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


EOF

declare -grx __D_LIB_DEFAULT_HEADER

# the packages library should ALWAYS load on init, no matter what.
declare -agrx __D_LIB_PACKAGES_INIT=("base_dummies" "base_array" "base_aarray" "base_trap" "base_test" "base_log" "base_environment" "base_config")

#
# - END: Library defaults
#
#####

#####
#
# - LOG settings
#

####
#
# - Banner settings.
#

# The prefix that each row that is logged inside a banner will have.
declare -grx __D__LOG_BANNER_PREFIX="*"

# The suffix that each row will have...
declare -grx __D__LOG_BANNER_SUFFIX="*"

# The character(s) that is (are) used to create the border at the top/bottom of the banner
declare -grx __D__LOG_BANNER_CONTENT="*"

# The default width of the banner in case $COLUMNS does not exist.
declare -girx __D__LOG_BANNER_WIDTH_MAX=80

#
# - END: Banner settings.
#
####

#
# - END: LOG settings.
#
#####

#####
#
# - Microsoft specific settings
#

# the default for installing microsoft's dotnet sdk
declare -grx __D_C_INSTALL_MICROSOFT_DOTNET_SDK=""
declare -grx __D_C_INSTALL_MICROSOFT_DOTNET_SDK_PACKAGE="dotnet-sdk-3.1"
declare -grx __D_C_INSTALL_MICROSOFT_DOTNET_SDK_REGEX='^dotnet-sdk.*$'

# the default for installing microsoft's powershell
declare -grx __D_C_INSTALL_MICROSOFT_POWERSHELL=""
declare -grx __D_C_INSTALL_MICROSOFT_POWERSHELL_PACKAGE="powershell"
declare -grx __D_C_INSTALL_MICROSOFT_POWERSHELL_REGEX='^powershell.*$'

# the default for installing microsfot's package lists
declare -grx __D_C_INSTALL_MICROSOFT_PACKAGELISTS=""

###
# opt out of microsoft's dotnet telemetry
declare -grx __D_C_MICROSOFT_DOTNET_TELEMETRY_OPTOUT=1

# the base url of the microsoft package repositories
declare -grx __D_MICROSOFT_PACKAGELISTS_LOCATION_BASE="https://packages.microsoft.com/config"

# the default repo, MUST CONTAIN branch and type
declare -grx __D_MICROSOFT_PACKAGELISTS_REPOSITORY_DEFAULT="prod:pkg"

# An array with the full urls to the microsoft repository keys.
# When curl downloads these keys, there is no "--insecure" and no "-L" (follow redirect) set.
declare -grx __D_MICROSOFT_PACKAGELISTS_REPOSITORY_KEYS=("https://packages.microsoft.com/keys/microsoft.asc" "https://packages.microsoft.com/keys/msopentech.asc")

# the regex to check for valid repos
declare -grx __D_MICROSOFT_PACKAGELISTS_REPOSITORY_REGEX='^(prod|islow|ifast)(|:|:source|:pkg|:fpkg)$'

#
# - END: Microsoft specific settings
#
#####

#####
#
# - Regular expressions
#
# the regex to test if a text value is false
declare -grx __D_TEXT_REGEX_FALSE='^(0|disabled|false|no|none)$'

# the regex to test if a text is a number
declare -grx __D_TEXT_REGEX_NUMBER='^[0-9]+$'

# the regex to test if it's a number and to remove leading zeroes
# The number is in BASH_REMATCH[2], the leading zeroes in BASH_REMATCH[1]
declare -grx __D_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES='^([^1-9]+)?([0-9]+)$'

# the regex to test if a text value is true
declare -grx __D_TEXT_REGEX_TRUE='^(1|enabled|true|yes)$'

#
# - END: Regular expressions
#
#####

#####
#
# - Terminal Colours
#

# some terminal colours...
declare -rgx __D_TERMINAL_COLOURS_NONE='\033[0m'
declare -rgx __D_TERMINAL_COLOURS_BLACK='\033[0;30m'
declare -rgx __D_TERMINAL_COLOURS_BLUE='\033[0;34m'
declare -rgx __D_TERMINAL_COLOURS_BROWN='\033[0;33m'
declare -rgx __D_TERMINAL_COLOURS_CYAN='\033[0;36m'
declare -rgx __D_TERMINAL_COLOURS_DARK_GRAY='\033[1;30m'
declare -rgx __D_TERMINAL_COLOURS_GREEN='\033[0;32m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_BLUE='\033[1;34m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_CYAN='\033[1;36m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_GRAY='\033[0;37m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_GREEN='\033[1;32m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_PURPLE='\033[1;35m'
declare -rgx __D_TERMINAL_COLOURS_LIGHT_RED='\033[1;31m'
declare -rgx __D_TERMINAL_COLOURS_PURPLE='\033[0;35m'
declare -rgx __D_TERMINAL_COLOURS_RED='\033[0;31m'
declare -rgx __D_TERMINAL_COLOURS_WHITE='\033[1;37m'
declare -rgx __D_TERMINAL_COLOURS_YELLOW='\033[1;33m'

# some terminal colours in ANSI
declare -rgx __D_TERMINAL_COLOURS_ANSI_NONE='\u001b[0m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_BLACK='\u001b[30m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_BLUE='\u001b[34m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_CYAN='\u001b[36m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_GREEN='\u001b[32m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_LIGHT_BLUE='\u001b[34;1m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_LIGHT_CYAN='\u001b[36;1m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_LIGHT_GREEN='\u001b[32;1m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_LIGHT_PURPLE='\u001b[35;1m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_LIGHT_RED='\u001b[31;1m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_PURPLE='\u001b[35m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_RED='\u001b[31m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_WHITE='\u001b[37m'
declare -rgx __D_TERMINAL_COLOURS_ANSI_YELLOW='\u001b[33m'

#
# - END: Terminal colours
#
####

#####
#
# - BUILD related settings
#

# the default directory used inside images for staging
declare -grx __D_STAGING_DIRECTORY="/usr/src/staging"

# default setting for debug
# declare -grx __D_C_DEBUG=""

# default setting for the integrated ssh server
# declare -grx __D_C_ENABLE_SSH=""

# default setting for the ssh host key of the integrated ssh server
# declare -grx __D_C_ENABLE_SSH_HOST_KEY=""

# default setting for the ssh host key permissions
declare -grx __D_C_ENABLE_SSH_HOST_KEY_MODE="0400"

# default setting for telemetry
# declare -grx __D_C_ENABLE_TELEMETRY=""

# default setting for updates
# declare -grx __D_C_ENABLE_UPDATES=""

# the default for CS_ENABLE_WHEEL
declare -grx __D_C_ENABLE_WHEEL="1"

# the default UID
declare -gxr __D_C_UID=1000

# the regex to verify it's a UID
declare -gxr __D_C_UID_REGEX='^[0-9]{4,5}$'

# the minimum value of the UID
declare -gxr __D_C_UID_MIN=1000

# the maximum value of the UID
declare -gxr __D_C_UID_MAX=59999

# the default user name
declare -gxr __D_C_USER="u"

# the regex to test the user name
declare -gxr __D_C_USER_REGEX='^^[a-z][-a-z0-9_]*$'

# default settings for CS_GID
declare -girx __D_C_GID=1000

# GID minimum
declare -girx __D_C_GID_MIN=1000

# GID maximum
declare -girx __D_C_GID_MAX=59999

# regex to check gid value
declare -grx __D_C_GID_REGEX='^[0-9]{4,5}$'

# default setting for CS_GROUP
declare -gxr __D_C_GROUP="${__D_C_USER}"

# the regex to test the user group name
declare -gxr __D_C_GROUP_REGEX='^[a-z][-a-z0-9_]*$'

# default settings for installing additional packages
# declare -grx __D_C_INSTALL_ADDITIONAL_PACKAGES=""

# default settings for CS_INSTALL_DOCKER
declare -grx __D_C_INSTALL_DOCKER=""

# default settings for the docker socket (CS_INSTALL_DOCKER_SOCKET)
declare -grx __D_C_INSTALL_DOCKER_SOCKET=""

# default setting for the webserver listening network socket
declare -grx __D_C_LISTEN_HOST="[::]"

# default setting for the webserver listening network port
# declare -grx __D_C_LISTEN_PORT=""

# regex to verify CS_LISTEN_PORT
declare -grx __D_C_LISTEN_PORT_REGEX='^[0-9]{1,5}$'

# listen port minimum
declare -grx -i __D_C_LISTEN_PORT_MIN=1024

# regex to verify the minimum port
declare -grx __D_C_LISTEN_PORT_MIN_REGX='^[0-9]{1,5}$'

# listen port maximum
# yes it goes to 65536. There is no such thing as port 0.
declare -grx -i __D_C_LISTEN_PORT_MAX=65536

#regex to verify the maximum port
declare -grx __D_C_LISTEN_PORT_MAX_REGEX='^[0-9]{1,5}$'
# default setting for the webserver listening UNIX socket
# declare -grx __D_C_LISTEN_SOCKET=""

# default setting for the webserver listening UNIX socket mode
declare -grx __D_C_LISTEN_SOCKET_MODE="0644"

# default regex to select new mode settings
# userd to verify {CS_LISTEN_SOCKET_MODE}
declare -grx __D_C_LISTEN_SOCKET_MODE_REGEX='^[0-7]{3,4}$'

# the default group used for the socket
# declare -grx __D_C_LISTEN_SOCKET_GROUP=""

# the regex to verify the group name.
declare -grx __D_C_LISTEN_SOCKET_GROUP_REGEX='^([0-9]+|[a-z][-a-z0-9_]*)$'

# the default owner used for the socket
# declare -grx __D_C_LISTEN_SOCKET_OWNER=""

# the regex to verify the username
declare -grx __D_C_LISTEN_SOCKET_OWNER_REGEX='^([0-9]+|[a-z][-a-z0-9_]*)$'

# the default of CS_LOCALES
declare -grx __D_C_LOCALES=""

# the default of CS_LOCALES_PACKAGES
# declare -grx __D_C_LOCALES_PACKAGES=""

# default for CS_PROXY_DOMAIN
# declare -grx __D_C_PROXY_DOMAIN=""

# default for CS_TIMEZONE
declare -grx __D_C_TIMEZONE=""

# default for CS_TIMEZONE_PACKAGES
declare -grx __D_C_TIMEZONE_PACKAGES="tzdata"

# default for unminimizing the image
declare -grx __D_C_UNMINIMIZE_IMAGE=""

# default for CS_USER_DATA_DIR
# declare -grx __D_C_USER_DATA_DIR="

# default for CS_USER_EXTENSIONS_DIR
# declare -grx __D_C_USER_EXTENSIONS_DIR=""

# the default for user home enforce owner
# declare -grx __D_C_USER_HOME_ENFORCE_OWNER=""

# the default for CS_USER_HOME
declare -grx __D_C_USER_HOME="/data"

# the user's path
declare -gxr __D_C_USER_PATH="Project"

# the default shell
declare -grx __D_C_USER_SHELL="/bin/bash"

# default password for code-server's web authentication.
# If empty, then no authentication will be used.
declare -grx __D_C_WEB_AUTH=""

# default file for webssl certificate
# declare -grx __D_C_WEBSSL_CERT=""

# default permissions for the webssl certificate to be used when there are
# permission problems only.
declare -grx __D_C_WEBSSL_CERT_PERMISSIONS="0444"

# default permissions regex for the webssl cert.
# used to verify CS_WEBSSL_CERT_PERMISSIONS
declare -grx __D_C_WEBSSL_CERT_PERMISSIONS_REGEX='^[0-7]{3,4}$'

# default file for webssl key
# declare -grx __D_C_WEBSSL_KEY=""

# default permissions for the webssl key. to be used when there are
# permission problems only.
declare -grx __D_C_WEBSSL_KEY_PERMISSIONS="0444"

# default permissions regex for the webssl key
# used to verify CS_WEBSSL_KEY_PERMISSIONS
declare -grx __D_C_WEBSSL_KEY_PERMISSIONS_REGEX='^[0-7]{3,4}$'

#
# - END: Default settings.
#
##########
