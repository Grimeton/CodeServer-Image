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

declare -ga GLOBAL_PUBLIC_TAGS=()
declare -Ag __VARS_TO_IMPORT=()
__VARS_TO_IMPORT[RUN_DISTRIBUTION_ID]="__T_ID"
__VARS_TO_IMPORT[RUN_DISTRIBUTION_VERSION_ID]="__T_VERSION_ID"
__VARS_TO_IMPORT[RUN_DISTRIBUTION_VERSION_CODENAME]="__T_VERSION_CODENAME"
__VARS_TO_IMPORT[RUN_TAG_IMAGE_BASENAME]="__T_TAG_IMAGE_BASENAME"
__VARS_TO_IMPORT[__BUILD_GIT_HASH]="__T_GIT_HASH"
__VARS_TO_IMPORT[__BUILD_GIT_TAG]="__T_GIT_TAG"
__VARS_TO_IMPORT[__BUILD_CODESERVER_VERSION]="__T_CODESERVER_VERSION"
__VARS_TO_IMPORT[BUILD_BUILDVERSION]="__T_BUILDVERSION"
__VARS_TO_IMPORT[BUILD_BUILDVERSION_RELEASE]="__T_BUILDVERSION_RELEASE"
__VARS_TO_IMPORT[BUILD_BUILDVERSION_SUFFIX]="__T_BULDVERSION_SUFFIX"
declare -g __T_LATEST="latest"

for __T_KEY in "${!__VARS_TO_IMPORT[@]}"; do
    declare "${__VARS_TO_IMPORT[${__T_KEY}]}="""
    if [[ -z ${!__T_KEY:+x} ]]; then
        true
    else
        declare "${__VARS_TO_IMPORT[${__T_KEY}]}="${!__T_KEY}""
    fi

    if [[ -z ${__CONFIG[${__T_KEY}]:+x} ]]; then
        true
    else
        declare "${__VARS_TO_IMPORT[${__T_KEY}]}="${__CONFIG[${__T_KEY}]}""
    fi
done

declare __T_TAG="grimages/codeserver:build-${__T_BUILDVERSION}"

for __T_VAR in __T_ID __T_VERSION_ID __T_BUILDVERSION_SUFFIX __T_CODESERVER_VERSION __T_GIT_HASH __T_BUILDVERSION_RELEASE; do
    if [[ -z ${!__T_VAR:+x} ]]; then
        continue
    else
        __T_TAG+="-${!__T_VAR}"
    fi
done
GLOBAL_PUBLIC_TAGS+=("${__T_TAG}")

unset __T_TAG
declare __T_TAG="grimages/codeserver:${__T_ID}"
for __T_VAR in __T_VERSION_ID __T_BUILDVERSION_SUFFIX __T_LATEST __T_BUILDVERSION_RELEASE; do
    if [[ -z ${!__T_VAR:+x} ]]; then
        continue
    else
        __T_TAG+="-${!__T_VAR}"
    fi
done
GLOBAL_PUBLIC_TAGS+=("${__T_TAG}")

GLOBAL_PUBLIC_PUSH=1
