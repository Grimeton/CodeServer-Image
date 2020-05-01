CodeServer container based on the latest release from the official [CodeServer Github Repository](https://github.com/cdr/code-server).

# License and Warning
Copyright (c) 2020, <grimeton@gmx.net>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the software/distribution.
3. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return, Grimeton.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

This license affects the image itself. CodeServer, the used distribution and other software inside the image come with their own licenses.

# Provided Architectures, Contents, Distributions, Releases & Tags
## Image Architectures
So far, amd64 is the only supported architecure. As NodeJS has dropped x86 support, x86 builds are out of the question.

## Image Contents
Each image will contain CodeServer installed in /opt/code-server/.

The Debian and Ubuntu images use the following additional repositories to make things happen:
* [Nodesource's](https://github.com/nodesource/distributions) NPM version (Distribution version too old).
* [Yarn](https://classic.yarnpkg.com/en/docs/install/) from [yarnpkg.com](https://yarnpkg.com) (Distribution version too old).

All images download the following files during the build phase:
* [Yelp/dumb-init](https://github.com/Yelp/dumb-init/releases)
* [tianon/gosu](https://github.com/tianon/gosu/releases)

Yes, there are distribution packages for those files and there are other/smaller options e.g. su-exec instead of gosu on Alpine Linux. I picked the pre compiled, statically linked versions to have reproducable results and a small footprint.

Debian 8 and 9 images also use the [Docker Repository](https://download.docker.com/linux/debian) to get their hands on a working Docker version. This is mainly on the build image which is used to create the runtime image.

## Image Distributions
The images will be the default distribution images. One exception is Debian, where I'm also going to use the "slim" version of their images to provide a release. All images come from the following sources:

* [Alpine](https://hub.docker.com/_/alpine)
* [Debian](https://hub.docker.com/_/debian)
* [Debian Slim](https://hub.docker.com/_/debian)
* [Ubuntu](https://hub.docker.com/_/ubuntu)

## Image Release Types
I'm going to provide several image variants with two different releases:
* Latest - This is HEAD of the [git repository](https://github.com/cdr/code-server).
* Latest Release - This is the latest release from the list available [here](https://github.com/cdr/code-server/releases)

## Image Tags
The images' tags will be as follows:

Every image has a tag that consists of the following parts:
* The string "build"
* The build version number, e.g "0.01". This is an internal number.
* The distribution name in lowercase, e.g. "debian" or "ubuntu"
* The distribution version, e.g. "8" or "18.04".
* The CodeServer version, e.g. "3.2.0".
* The Git hash that this CodeServer version was built from, e.g. "fd36a99"
* The string "release" if it is a "Latest Release".

You get: "build-0.01-ubuntu-18.04-3.2.0-fd36a99-release". 

## Image Tags (short)
To make it easier, each image also comes with a shorter tag as follows:

Distribution | Architecture | Base Image Tag| Latest (HEAD) | Latest Release
-|-|-|-|-
Alpine 3.10| amd64 | alpine:3.10 | alpine-3.10-latest | alpine-3.10-latest-release
Alpine 3.11| amd64 | alpine:3.11| alpine-3.11-latest | alpine-3.11-latest-release
Debian 8 | amd64 | debian:8 | debian-8-latest | debian-8-latest-release
Debian 9 | amd64 | debian:9 | debian-9-latest | debian-9-latest-release
Debian 10 | amd64 | debian:10 | debian-10-latest | debian-10-latest-release
Debian Sid* | amd64 | debian:sid | debian-0-latest | debian-0-latest-release
Debian 8-slim | amd64 | debian:8-slim | debian-8-slim-latest | debian-8-slim-latest-release
Debian 9-slim | amd64 | debian:9-slim | debian-9-slim-latest | debian-9-slim-latest-release
Debian 10-slim | amd64 | debian:10-slim | debian-10-slim-latest | debian-10-slim-latest-release
Debian Sid-slim* | amd64 | debian:sid-slim | debian-0-slim-latest | debian-0-slim-latest-release
Ubuntu 16.04 | amd64 | ubuntu:16.04 | ubuntu-16.04-latest | ubuntu-16.04-latest-release
Ubuntu 18.04 | amd64 | ubuntu:18.04 | ubuntu-18.04-latest | ubuntu-18.04-latest-release
Ubuntu 19.10 | amd64 | ubuntu:19.10 | ubuntu-19.10-latest | ubuntu-19.10-latest-release
Ubuntu 20.04 | amd64 | ubuntu:20.04 | ubuntu-20.04-latest | ubuntu-20.04-latest-release

'*' 'Debian/Sid' is not marked with a version number anywhere, so I picked '0' as version number. To use the 'Debian/Sid' images use the 'debian-0' prefix and remember: (S)id (I)s (D)angerous!


# Quick Start
This is a 'docker-compose.yaml'-file that should get you started quickly. All environment variables, visible in the 'docker-compose.yaml'-file are explained below.
```yaml
version: "2"
networks:
    tools:
        external: true
services:
        codeserver-ubuntu-1804:
                image: grimages/codeserver:ubuntu-18.04-latest
                container_name: codeserver-ubuntu-1804
                environment:
                        ## CS_DEBUG: ""
                        ## CS_ENABLE_SSH: ""
                        ## CS_ENABLE_SSH_HOST_KEY: ""
                        ## CS_ENABLE_TELEMETRY: ""
                        ## CS_ENABLE_UPDATES: ""
                        ## CS_ENABLE_WHEEL: ""
                        # PUT GID HERE TO MATCH OUTER GID
                        CS_GID: 1234
                        ## CS_GROUP: ""
                        CS_INSTALL_ADDITIONAL_PACKAGES: "git"
                        ## CS_INSTALL_DOCKER: ""
                        ## CS_INSTALL_MICROSOFT_DOTNET_SDK: ""
                        ## CS_INSTALL_MICROSOFT_POWERSHELL: ""
                        ## CS_INSTALL_MICROSOFT_PACKAGELISTS: ""
                        ## CS_LISTEN_HOST: "0.0.0.0"
                        CS_LISTEN_HOST: "0.0.0.0"
                        CS_LISTEN_PORT: "8080"
                        ## CS_LISTEN_PORT: ""
                        ## CS_LISTEN_SOCKET: ""
                        ## CS_LISTEN_SOCKET_MODE: ""
                        ## CS_LISTEN_SOCKET_OWNER: ""
                        ## CS_LISTEN_SOCKET_GROUP: ""
                        ## CS_MICROSOFT_PACKAGELISTS_FILENAME: ""
                        ## CS_MICROSOFT_PACKAGELISTS_LOCATION: "https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb"
                        ## CS_MICROSOFT_PACKAGELISTS_REPOSITORY: ""
                        CS_LOCALES: "de_DE.UTF-8 en_US.UTF-8"
                        ## CS_LOCALES_PACKAGES: ""
                        ## CS_PROXY_DOMAIN: ""
                        CS_TIMEZONE: "Europe/Berlin"
                        # PUT YOUR UID HERE TO MATCH OUTER UID!
                        CS_UID: 1234
                        ## CS_UNMINIMIZE_IMAGE: ""
                        ## CS_USER: ""
                        ## CS_USER_DATA_DIR: ""
                        ## CS_USER_EXTENSIONS_DIR: ""
                        ## CS_USER_HOME: ""
                        ## CS_USER_HOME_ENFORCE_OWNER: ""
                        ## CS_USER_PATH: ""
                        ## CS_USER_SHELL: ""
                        ## CS_VERBOSE: 1
                        CS_WEB_AUTH: ".sup3rs3cr3t"
                        ## CS_WEBSSL_CERT: ""
                        ## CS_WEBSSL_KEY: ""
                networks:
                        tools:
                                ipv4_address: 1.2.3.4
                restart: unless-stopped
                volumes:
                        - /somewhere/codeserver/config:/config
                        - /somewhere/codeserver/data:/data
```
# Volumes
Each image comes with two volumes.
## /config
This volume represents configuration settings and can be used to store SSL/TLS certificates/keys or SSH host keys and stuff.
## /data
This is usually the user's home directory and contains all the data you're working with. Make sure it's stored in a safe place.

# Environment Variables
The image comes with a lot of moving parts that can be configured via environment variables. Usually the rules say to create a small and fast image, however when working with a development environment, version control and several add-ons, these rules don't apply anymore.

This lead to the following environment variables that can be used to control a lot of settings, including installation of additional packages, repositories and other stuff during the first boot.

But be careful! Traps are everywhere. One may be the fact that a lot of these variables depend on eachother. You can't just change the user's home directory without expecting it to have an effect on all the other subdirectories that are usually part of the user's home.

## Default values
When an environment variable is not set, or it's content is empty, e.g. VAR="", then the default behaviour will be applied.

## Boolean values

### - True
The following values will be recognized as being "true":
* 1
* enabled
* true
* yes

### - False
The following values will be recognized as being "false":
* 0
* disabled
* false
* no
* none

### - [PACKAGENAME]
Some variables will allow to hold a specific package name/version instead of the true value. This is useful to install a specific version of the package you want to install and saves another variable.
If the Package which is put into the variable does not exist, it will produce an error message (Garbage In->Garbage Out).

Variables that support this features will be extra marked.

## String values
Some variables can hold strings, e.g. CS_INSTALL_ADDITIONAL_PACKAGES can contain a string of multiple package names separated by space, that should be installed during the first container initialization. One must use a single string with space separated package names, arrays are not supported.

# List of Variables
## - CS_DEBUG
### Description 
As the name suggests, this variable is used to enable the debug feature of the init script system. 

### Type
Boolean - Accepts "True"- and "False"-values.

### Default
Off

## - CS_ENABLE_SSH
### Description
Is used to enable the built-in SSH server of CodeServer.
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Off

## - CS_ENABLE_SSH_KEY
### Description
Is used to hand CodeServer the path to a host key file for the built-in SSH server. You can place the file in the '/config' volume and then hand CodeServer the path to it here.
### Type
String - When it contains a valid file, the feature is enabled.
### Default
Empty

## - CS_ENABLE_TELEMETRY
### Description
Used to enable CodeServer's built-in telemetry option. When not set, telemetry is disabled by default.
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Off

## - CS_ENABLE_UPDATES
### Description
When set, CodeServer tries to detect and download new updates. Should be disabled inside the container for obvious reasons.
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Off

## - CS_ENABLE_WHEEL
### Description
While a lot of people prefer "sudo" nowadays, I prefer "su". Old habbits die hard I guess. When enabled, adds the group "wheel" and edits /etc/pam.d/su to allow members of the group "wheel" to become root without entering a password. 

So far this only works on Debian and Ubuntu based images.
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Enabled

## - CS_INSTALL_ADDITIONAL_PACKAGES
### Description
Can hold multiple package names separated by a space. These packages will be installed on the first boot of the container via the distribution's package management.
### Type
String - Accepts multiple package names, space separated.
### Default
Empty/Disabled.

## - CS_INSTALL_DOCKER
### Description
When enabled, installs the distribution's docker package. This comes in handy when you use CodeServer together wtih a Docker extenension. 

When enabled the following things are going to happen:
* Checks if socket is available at 'CS_INSTALL_DOCKER_SOCKET' and remembers its GID.
* Checks if the group "docker" already exists. If not, creates the group with the GID of the socket found at 'CS_INSTALL_DOCKER_SOCKET'.
* Installs the necessary distribution packages to make docker work inside the container.
* Adds CodeServer's user to the docker group, to make docker usable as non-root user directly from CodeServer.
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Empty/Disabled.
### Packages
The following packages will be installed when the option is enabled:
Distribution | Version | Packages | Repository
-|-|-|-
Alpine|3.10|docker-cli|Default
Alpine|3.11|docker-cli|Default
Debian|8|docker-ce|Docker Repository for Debian
Debian|9|docker-ce-cli|Docker Repository for Debian
Debian|10|docker docker-compose|Default
Debian|0/Sid|docker docker-compose|Default
Ubuntu|16.04|docker.io docker-compose|Default
Ubuntu|18.04|docker.io docker-compose|Default
Ubuntu|19.10|docker.io docker-compose|Default
Ubuntu|20.04|docker.io docker-compose|Default

## - CS_INSTALL_DOCKER_SOCKET
### Description
The socket that should be used to connect to docker. You have to mount the socket to the inside of the container at the location that you specify via this environment variable. The default is '/var/run/docker.sock', which is used when the variable is not set or empty.
### Type
String - Accepts full path to the docker socket INSIDE of the container.
### Default
Empty/Not set.

## - CS_INSTALL_MICROSOFT_DOTNET_SDK
### Description
When enabled, the init system will try to fetch and install Microsoft's dotNET SDK from the official [Microsoft Repository](https://packages.microsoft.com). This only works on supported distributions.

When set to "True", then the default version of Microsoft's dotNET SDK will be installed, which is 3.1 at the time of writing.

When set to "False", nothing will be done.

When the variable contains a package name, then the package suggested in the variable will be installed, IF IT EXISTS. If it doesn't exist, the system reverts back to the default package, which again is dotnet-sdk-3.1 at the time of writing.

### Type
Boolean WITH PACKAGENAME - Accepts "True"-, "False"-values as well as a package name to install.

### Default
Empty/Off

### Packages
Installs either the default or the suggested package and its dependencies.

### Repositories
Installs the Microsoft Package Repository available at [https://packages.microsoft.com](https://packages.microsoft.com).

### Supported Distributions
Distribution|Version|Supported
-|-|-
Alpine|3.10|No
Alpine|3.11|No
Debian|8|Yes
Debian|9|Yes
Debian|10|Yes
Debian|0/Sid|Yes
Ubuntu|16.04|Yes
Ubuntu|18.04|Yes
Ubuntu|19.10|No
Ubuntu|20.04|No

## - CS_INSTALL_MICROSOFT_POWERSHELL
### Description
When enabled the init system will try to fetch the current version of Powershell from the official [Microsoft Repository](https://packages.microsoft.com). Only works on supported Distributions and pulls in CS_INSTALL_MICROSOFT_PACKAGELISTS.
### Type
Boolean WITH [PACKAGENAME]- Accepts "True"-, "False"-values as well as a package name to install.
### Default
Empty/Off
### Packages
Installs either the default or the suggested package and its dependencies.
### Repositories
Installs the Microsoft Package Repository available at [https://packages.microsoft.com](https://packages.microsoft.com).
### Supported Distributions
Distribution|Version|Supported
-|-|-
Alpine|3.10|No
Alpine|3.11|No
Debian|8|Yes
Debian|9|Yes
Debian|10|Yes
Debian|0/Sid|Yes
Ubuntu|16.04|Yes
Ubuntu|18.04|Yes
Ubuntu|19.10|No
Ubuntu|20.04|No


In case of Ubuntu only LTS releases are supported with a Powershell package. If you have a non-LTS version or a newer version as the current, official LTS, then you need to use a Snapcraft image of [Powershell](https://snapcraft.io/powershell). Sadly this is total overkill inside a container and requires so many changes to container security that it becomes completely pointless to use.

If you want to use this container with [Snapcraft Images](https://snapcraft.io/store) you can, but you have to change the following things:
* Install systemd inside the image.
* Change entry point to start image's systemd.
* Follow the additional information at [ogra1/snapd-docker](https://github.com/ogra1/snapd-docker).

What do the SuSE people usually say? Have a lot of fun?

## - CS_INSTALL_MICROSOFT_PACKAGELISTS
### Description
When enabled, installs the official [Microsoft Repository](https://packages.microsoft.com) on supported systems.

Have an eye on the "CS_MICROSOFT_*" options explained below!

### Type
Boolean - Accepts "True"- and "False-values.
### Default
Off/Empty
### Packages
When enabled, installs the following packages:
Distribution|Version|Packages|Repository
-|-|-|-
Debian|8|apt-transport-https ca-certificates curl gnupg2|Default
Debian|9|apt-transport-https ca-certificates curl gnupg2|Default
Debian|10|apt-transport-https ca-certificates curl gnupg2|Default
Debian|0/Sid|apt-transport-https ca-certificates curl gnupg2|Default
Ubuntu|16.04|apt-transport-https ca-certificates curl gnupg2|Default
Ubuntu|18.04|apt-transport-https ca-certificates curl gnupg2|Default
Ubuntu|19.10|apt-transport-https ca-certificates curl gnupg2|Default
Ubuntu|20.04|apt-transport-https ca-certificates curl gnupg2|Default

### Repositories
Installs Microsoft's official repository.

### Supported Distributions
Distribution|Version|Supported
-|-|-
Alpine|3.10|No
Alpine|3.11|No
Debian|8|Yes
Debian|9|Yes
Debian|10|Yes
Debian|0/Sid|Yes
Ubuntu|16.04|Yes
Ubuntu|18.04|Yes
Ubuntu|19.10|Yes
Ubuntu|20.04|Yes

## - CS_LISTEN_HOST
### Description
The address CodeServer listen's on for incoming web requests. This should usually be either "0.0.0.0" or "[::]" or a more specific IP-address where the web server should listen on.

__Read the description of CS_LISTEN_SOCKET!__

### Type
String - Accepts IP-addresses.
### Default
Empty/Not set

## - CS_LISTEN_PORT
### Description
The port CodeServer's web server is listening on for web requests. As CodeServer is not running as root, one should pick a port in the range between greater or equal to 1024 and less or equal to 65536. Yes. 65536. There is no such thing as port 0. Ports are counted from 1 up. Port 0 represents a special case that turns into any random, available port on the system.

Linux' [/net/ipv4/inet_connection_sock.c](https://github.com/torvalds/linux/blob/master/net/ipv4/inet_connection_sock.c) says about this:
```c
/* Obtain a reference to a local port for the given sock,
 * if snum is zero it means select any available local port.
 * We try to allocate an odd port (and leave even ports for connect())
 */
 int inet_csk_get_port(struct sock *sk, unsigned short snum)
 ```

__Read the description of CS_LISTEN_SOCKET!__

### Type
String/Integer - Accepts any number between 1024 and 65536.
### Default
Empty/Not set

## - CS_LISTEN_SOCKET
### Description
When set, contains the full path to a location where a UNIX socket should be created. If there is already a socket said location, the init script tries to remove it and free the location for CodeServer.

__WHEN THIS OPTION IS SET 'CS_LISTEN_HOST' AND 'CS_LISTEN_PORT' ARE IGNORED AND THE SERVER WILL ONLY LISTEN ON THE UNIX SOCKET!__

Also check the documentation on:
* CS_LISTEN_SOCKET_MODE
* CS_LISTEN_SOCKET_OWNER
* CS_LISTEN_SOCKET_GROUP

below.

### Type
String - Accepts full path to location where to create new UNIX socket.
### Default
Empty/Not set.

## - CS_LISTEN_SOCKET_MODE
### Description
This can contain a mode mask either with 3 digits (Owner, Group, World) or 4 digits (Special Bits, Owner, Group, World) and can be used to restrict access to the socket accross container boundaries.
### Type
String - Accepts 3 or 4 digit mode mask for the socket.
### Default
Empty/Not set.

## - CS_LISTEN_SOCKET_OWNER
### Description
Should contain the owner of the future socket. One can use names as well as IDs here. Usually the wiser choise is to use ID only to get access rights set accross container boundaries.

When using a name, the name must exist in /etc/passwd to be accepted while an ID is always accepted.

### Type
String - Accepts owner name or ID of future socket.
### Default
Empty/Not set.

## - CS_LISTEN_SOCKET_GROUP
### Description
Same as CS_LISTEN_SOCKET_OWNER, just for the group. Accepts name or GID. The name MUST EXIST in the passwd database, while a GID is always accepted and used.
### Type
String - Accepts group name or GID of future socket.
### Default
Empty/Not set.

## - CS_WEB_AUTH
### Description
Used to control the password authentication feature of CodeServer's web server. If not set or empty, then password authentication is disabled. As soon as it is set and contains a value, the value will be used as password and the authentication method will be changed from "none" to "password" in CodeServer.
### Type
String - Accepts any string as password for HTTP authentication at CodeServer's web server.
### Default
Empty/Not set.

## - CS_WEBSSL_CERT & CS_WEBSSL_KEY
### Description
Both variables are used to configure the web server's SSL/TLS settings. The whole configuration follows a certain logic, which is as follows:

* CS_WEBSSL_CERT is not set or empty - SSL/TLS is disabled.
* CS_WEBSSL_CERT is not a file or the file it points to cannot be accessed by the user running CodeServer - Auto generated certificate/key pair will be used.
* CS_WEBSSL_KEY is not set, empty, not a file or not accessible by the user running CodeServer - Auto generated certificate/key pair will be used.

So to have no encryption at all, just don't set the variables. If you want to use the auto generated certificates on the other hand, just set 'CS_WEBSSL_CERT' to something that is invalid, like '/dev/null' and watch the auto generation get triggered.

To use a custom certificate/key pair put them into the '/config' volume and then hand the paths to CodeServer via the variables like so:

* CS_WEBSSL_CERT='/config/codeserver.cer'
* CS_WEBSSL_KEY='/config/codeserver.key'

When the init scripts are able to find the files and fix the permissions, in case necessary, then the certificate/key combination will be used at the start of CodeServer.



## - CS_MICROSOFT_PACKAGELISTS_FILENAME
### Description
Providing a full path to a file, or just a filename of a file that will be added as "file to be downloaded" when trying to install the Microsoft Package Repository.
### Type
String - Accepts full path to a faile or just a filename.
### Default
Empty/Not set.
### Supported Distributions
Check 'CS_INSTALL_MICROSOFT_PACKAGELISTS' for a list of supported distributions.

## - CS_MICROSOFT_PACKAGELISTS_LOCATION

### Description
Providing a full path to a file, or a full URL to a location that should be downloaded and then installed to make the Microsoft Package Repository available to the package manager of the container image.

This is the only option that disables the auto detection/auto generation of Microsoft Package Repository URLs.

### Type
String - Accepts full path to a file or full URL to a location that is to be downloaded.
### Default
Empty/Not set.
### Supported Distributions
Check 'CS_INSTALL_MICROSOFT_PACKAGELISTS' for a list of supported distributions.

## - CS_MICROSOFT_PACKAGELISTS_REPOSITORY
### Description
The type of the repository to be installed. Microsoft offers multiple repository types and installation variants of these repository types. 
### Type
String - Accepts any repository_type:install_type combination
### Default
Empty/Not set.
### Available repository/installation type combinations.
Currently there are three different repository types:
* Production
* Insiders fast
* Insiders slow

which come either in distribution package format (deb) or as source (list with keys).

When using the default type "pkg" and the system is not able to install the repository, it falls back to the source version with additional key installation and tries again. If you do NOT want this, you can enforce using "pkg" only by prepending an "f" to the installation type. "pkg" becomes "fpkg".


The package's installation types and their tags:


Repository type|Repository Prefix|Package|Enforce Package Only|Source
-|-|-|-|-
Production|prod|pkg|fpkg|source
Insiders Slow|islow|pkg|fpkg|source
Insiders Fast|ifast|pkg|fpkg|source
### Supported Distributions
Check 'CS_INSTALL_MICROSOFT_PACKAGELISTS' for a list of supported distributions.

## - CS_LOCALES
### Description
Can hold one ore more locale names separated by space. When set, the first locale becomes the default while all locales in the string are installed.
### Type
String - Accepts one ore more locales separated by spaces.
### Default
Empty/Not Set
### Packages
When enabled, pulls in a package that contains the locale data so that locales can be generated and configured. This is not directly supported on Alpine Linux as musl libc's locale implementation is non existant. One can install glibc but that's beyond the scope of the setup script.

Distribution|Version|Packages|Repository
-|-|-|-
Alpine|3.10|N/A|N/A
Alpine|3.11|N/A|N/A
Debian|8|locales|Default
Debian|9|locales|Default
Debian|10|locales|Default
Debian|0/Sid|locales|Default
Ubuntu|16.04|locales|Default
Ubuntu|18.04|locales|Default
Ubuntu|19.10|locales|Default
Ubuntu|20.04|locales|Default

## - CS_LOCALES_PACKAGES
### Description
Can hold one or multiple package names separated by space, that should be installed when 'CS_LOCALES' contains locale names that are to be installed.
### Type
String - Accepts one or more package names separated by space.
### Default
Empty/Not set.

## - CS_PROXY_DOMAIN
### Description
Can hold one or more proxy domain definitions to be used by CodeServer. When using multiple definitions separate them by space.
### Type
String - Accepts one or multiple proxy domain definitions, separated by space.
### Default
Empty/Not set.

## - CS_TIMEZONE
### Description
Contains the name of the timezone that should become system default. Usually this is a relativ path that can be matched against the prefix "/usr/share/zoneinfo/".

When the timezone is set, then the link in '/etc/localtime' is changed, as well as '/etc/timezone', which is modified to reflect the new timezone configuration.

### Type
String - Accepts path that points to valid timezone.
### Default
Empty/Not set.
### Packages
When activated it installs the following packages:
Distribution|Version|Packages|Repositories
-|-|-|-
Alpine|3.10|tzdata|Default
Alpine|3.11|tzdata|Default
Debian|8|tzdata|Default
Debian|9|tzdata|Default
Debian|10|tzdata|Default
Debian|0/Sid|tzdata|Default
Ubuntu|16.04|tzdata|Default
Ubuntu|18.04|tzdata|Default
Ubuntu|19.10|tzdata|Default
Ubuntu|20.04|tzdata|Default

## - CS_UNMINIMIZE_IMAGE
### Description
Container images are usually coming in a minimized, condensed format missing a lot of features like manual pages, documenation and other things. Usually this is a good thing, as it save space and makes the image smaller. When running a development environment inside an image, this can become a bad choice, as one can't just access a manual page or some documentation in '/usr/share/doc' anymore.

Ubuntu adds filters to filter out these things at installation time, so they are not going to be installed in the first place. 

To revert this action and install all the missing information into the image again, this option can be enabled. This is a lengthy process that can take a couple of minutes, so be patient!
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Empty/Not set.
### Supported Distributions
Distribution|Version|Supported
-|-|-
Alpine|3.10|No
Alpine|3.11|No
Debian|8|No
Debian|9|No
Debian|10|No
Debian|0/Sid|No
Ubuntu|16.04|No
Ubuntu|18.04|Yes
Ubuntu|19.10|Yes
Ubuntu|20.04|Yes

## - CS_USER_DATA_DIR
### Description
When set hands the value to CodeServer's '--user-data-dir' option.

Usually this is a subfolder of the user's HOME directory. To make it possible to change just the subfolder, this variable works as follows:
* The path starts with a '/' - The path is considered a full path starting at the system's root '/' and will be set to '\${CS_USER_DATA_DIR}'.
* The path starts NOT with a '/' - The path is considered a subfolder of the user's '\${HOME}' and will be set to '\${HOME}/\${CS_USER_DATA_DIR}'.
### Type
String - Accepts a full or relative path to a new location where the user data directory should reside.
### Default
Empty/Not Set.

## - CS_USER_EXTENSIONS_DIR
### Description
When set hands its value to CodeServer's '--extensions-dir' which changes the location of said directory.

As this is usually a subfolder of the user's '\${HOME}', this variable works as follows:
* The value starts with a '/' - The path is considered a full path starting at the system's root '/' and will be set to '\${CS_USER_EXTENSIONS_DIR}'.
* The value does NOT start with a '/' - The path is considered a sub directory of the user's '\${HOME}' and will be set to '\${HOME}/\${CS_USER_EXTENSIONS_DIR}'.
### Type
String - Accepting either a full or a relativ path to the new location of CodeServer's "extensions directory".
### Default
Empty/Not set.

## - CS_USER_PATH
### Description
Contains the path to CodeServer's "path" option, the last option that is handed to CodeServer when starting it. The option is only positional and does not have a parameter name.

As this is usually a subfolder of the user's '\${HOME}', this variable works as follows:
* The value starts with a '/' - The path is considered a full path starting at the system's root '/' and will be set to '\${CS_USER_PATH}'.
* The value does NOT start with a '/' - The path is considered a sub directory of the user's '\${HOME}' and will be set to '\${HOME}/\${CS_USER_PATH}'.
### Type
String - Accepting either a full or relative path to the new location of CodeServer's "path" option.
### Default
Empty/Not set.

## - CS_GID
### Description
The GID of the future primary group of the future user that will be created to run CodeServer. Use this to match any external GID on the host or on network drives.
### Type
Integer - Accepts any, valid GID between 1000 and 60000.
### Default
Empty/Not set.

## - CS_GROUP
### Description
The new name that the future, primary group of the future user that will run CodeServer will have. Usually this is the username, but feel free to change it to whatever you want/need.
### Type
String - Accepts any, valid Linux group name.
### Default
Empty/Not set.


## - CS_UID
### Description
The UID that will be used when creating the future user that is running CodeServer. Use this to match any external UID on the host or on network drives.
### Type
Integer - Accepts any, valid UID between 1000 and 60000.
### Default
Empty/Not set.


## - CS_USER
### Description
The name of the future user that will be running CodeServer and that the container user will be working as.
### Type
String - Accepts any valid Linux username.
### Default
Empty/Not set.

## - CS_USER_HOME
### Description
The default path, where to create the future user's home directory. Per default this is '\${HOME}/${CS_USER}'.
### Type
String - Accepting full path to the new '\${HOME}' directory location.
### Default
Empty/Not set.

## - CS_USER_HOME_ENFORCE_OWNER
### Description
Imagine you were running the container with UID/GID 1234/1234 and now you have to change it to 2345/2345 because IT has changed something that affects your UID/GID. Well, you recreate the container with 'CS_UID' and 'CS_GID' set to 2345 and enable this setting. When the container boots for the first time, it recursively changes ownership of '\${HOME}' for you.

__BE VERY CAREFUL WITH THIS!__
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Empty/Not set.

## - CS_USER_SHELL
### Description
When set, contains the full path to the executable of the new shell to use for the new user. The system does NOT test if the shell exists. User will be created, shell will be set, problem will be had.
### Type
String - Accepts full path to executable of the new user's shell.
### Default
Empty/Not set.

## - CS_VERBOSE
### Description
Enabling this setting makes the init scripts more chatty. Don't expect tooooo much...
### Type
Boolean - Accepts "True"- and "False"-values.
### Default
Empty/Not set.
