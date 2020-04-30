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
#

#####
# This package contains dummy functions that MUST be there and that you can rely on.
# They have to be overwritten in the packages they're from or else they will forever return
# false.

#####
#
# - Package "lib_package_manager.sh"
#

####
#
# Returns true if the package manager has been loaded and initialized.
#
function __pm_exists() {
    __log e -- "NOT OVERWRITTEN. THIS IS A PERMANENT ERROR."
    return 254;
}

function __pm_package_install() {
    __log e -- "NOT OVERWRITTEN. THIS IS A PERMANENT ERROR."
    return 254;
}
#####
#
# The idea behind this function is that it returns true when the package manager
# was loaded, initialized and the cache was updated. It should do the main initialization
# task only once and then store the status somewhere so that the next call to this function
# will return a cached result instead of going throught the initialisation process again
# and again. 
#
# Basically the idea is to call __pm_ready to see if the pm is ready to use and if so, continue
# your work in the script.
#
# When called, loads the package_manager module, runs __pm_init and __pm_cache_update 
# and returns true if this worked. Every future call after this has to return a cached
# result.
#
# this was done successfully.
#
# Returns false (>0) otherwise.
#
function __pm_ready() {
    __log e -- "NOT OVERWRITTEN. THIS IS A PERMANENT ERROR."
    return 254;
}