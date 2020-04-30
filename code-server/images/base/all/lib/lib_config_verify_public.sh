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

if __test_variable_exists GLOBAL_PUBLIC_TAGS; then
        if __test_array_exists GLOBAL_PUBLIC_TAGS; then
                true
        elif __test_variable_empty; then
                declare -ga GLOBAL_PUBLIC_TAGS=()
                __logw -- GLOBAL_PUBLIC_TAGS
        else
                declare -ga GLOBAL_PUBLIC_TAGS=(${GLOBAL_PUBLIC_TAGS})
                __logw -- GLOBAL_PUBLIC_TAGS
        fi
else
        declare -ga GLOBAL_PUBLIC_TAGS=()
        __logw -- GLOBAL_PUBLIC_TAGS
fi

__REGISTERED_VARIABLES+=(GLOBAL_PUBLIC_TAGS)

if __test_variable_exists GLOBAL_PUBLIC_PUSH; then
    if __test_variable_empty GLOBAL_PUBLIC_PUSH; then
        declare -g GLOBAL_PUBLIC_PUSH=""
    elif __test_variable_text_true GLOBAL_PUBLIC_PUSH; then
        declare -g GLOBAL_PUBLIC_PUSH=1
    else
        declare -g GLOBAL_PUBLIC_PUSH=""
    fi
else
    declare -g GLOBAL_PUBLIC_PUSH=""
fi

REGISTERED_VARIABLES+=( GLOBAL_PUBLIC_PUSH )