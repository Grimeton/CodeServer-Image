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
#####
#
# - Main functions used by init.
#

if ([[ -z ${__D_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES+x} ]] || [[ "${__D_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES}x" == "x" ]]); then
    declare -gx __INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES='^([^1-9]+)?([0-9]+)$'
else
    declare -gx __INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES="${__D_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES}"
fi
#####
#
# - __init_codeserver_startup_options_gather
#
# - Description:
#   Searches for the CodeServer executable and checks its startup options. Depending on the build
#   version there are different options available. They're stored in global associative array and
#   can be checked via __init_codeserver_startup_options_available.
#
#   This can be used to test if a startup option is available before the init module adds it to
#   the __START_PARAMETERS array and produces and error.
#
# - Parameters:
#   - None.
#
# - Return Values:
#   - 0 on success.
#   - >0 on failure.
#
function __init_codeserver_startup_options_gather() {

    declare -Ag __CODESERVER_STARTUP_OPTIONS=()
    declare -g __CODESERVER_EXEC=""
    if [[ -f "/opt/code-server/code-server.sh" ]]; then
        __CODESERVER_EXEC="/opt/code-server/code-server.sh"
    elif [[ -f "/opt/code-server/code-server" ]]; then
        __CODESERVER_EXEC="/opt/code-server/code-server"
    else
        __log e -- "CANNOT FIND CODE-SERVER EXECUTABLE. EXITING.\n"
        exit 99
    fi
    while read __T_OPT; do
        __CODESERVER_STARTUP_OPTIONS["${__T_OPT}"]=1
    done < <("${__CODESERVER_EXEC}" --help 2>&1 | grep -E '^[\ |\t]+-.*$' | sed -E 's/.*--([a-zA-Z0-9_\-]+)[\ |\t]+.*$/\1/g' | grep -v '^(help|open|force|install-extension|uninstall-extension|show-versions)$')
}
#####
#
# - __init_codeserver_startup_options_available
#
# - Description:
#   This function is used to check if the startup option a init module wants to add to
#   the __START_PARAMETERS array is actually available with this CodeServer version.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: OPTION - The name of the option to test for.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure/not found.
#
function __init_codeserver_startup_options_available() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_OPTION="${@:1:1}"
    fi

    if [[ -z ${__CODESERVER_STARTUP_OPTIONS[@]+x} ]]; then
        __init_codeserver_startup_options_gather
        __init_codeserver_startup_options_available "${__P_OPTION}"
        return
    elif [[ ${#__CODESERVER_STARTUP_OPTIONS[@]} -lt 1 ]]; then
        __init_codeserver_startup_options_gather
        __init_codeserver_startup_options_available "${__P_OPTION}"
        return
    elif [[ -z ${__CODESERVER_STARTUP_OPTIONS["${__P_OPTION,,}"]+x} ]]; then
        return 113
    elif [[ "${__CODESERVER_STARTUP_OPTIONS["${__P_OPTION,,}"]}x" == "x" ]]; then
        return 114
    elif [[ "${__CODESERVER_STARTUP_OPTIONS["${__P_OPTION,,}"]}" != "1" ]]; then
        return 115
    else
        return 0
    fi
    return 254
}
####
#
# - __init_function_register
#
# - Description:
#   Takes a stage name and a function name of an existing function and registers it to it.
#   If the stage hasn't been registered yet or the function is already registered, it fails.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage to register on.
#   - #2 [IN|MANDATORY]: FUNCTIONNAME - Name of the function to register on said stage
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __init_function_register() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    elif __variable_type_function "${@:2:1}"; then
        declare __P_FUNCTIONNAME="${@:2:1}"
    else
        return 104
    fi

    if __init_function_registered "${__P_STAGENAME}" "${__P_FUNCTIONNAME}"; then
        return 111
    elif __init_stage_registered "${__P_STAGENAME}"; then
        declare __T_INIT_STAGE_ARRAYNAME=""
        if __init_stage_arrayname_get "${__P_STAGENAME}" __T_INIT_STAGE_ARRAYNAME; then
            if __array_add "${__T_INIT_STAGE_ARRAYNAME}" "${__P_FUNCTIONNAME}"; then
                return 0
            else
                return 112
            fi
        else
            return 113
        fi
    else
        return 114
    fi
    return 199
}
#####
#
# - __init_function_register_always
#
# - Description:
#   Takes the name of a stage and a function and registers it _ALWAYS_. If the stage hasn't been registered
#   before, it will be created. If the function is already registered it returns true anyway.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage.
#   - #2 [IN|MANDATORY]: FUNCTIONNAME - Name of an existing function to be registered.
#
# - Return values:
#   - 0 on succes.
#   - >0 on failure.
#
function __init_function_register_always() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    elif __variable_type_function "${@:2:1}"; then
        declare __P_FUNCTIONNAME="${@:2:1}"
    else
        return 104
    fi

    declare __T_INIT_STAGE_ARRAYNAME=""
    if __init_function_registered "${__P_STAGENAME}" "${__P_FUNCTIONNAME}"; then
        return 0
    fi
    if __init_stage_registered "${__P_STAGENAME}"; then
        true
    elif __init_stage_register "${__P_STAGENAME}"; then
        true
    else
        return 111
    fi

    if __init_function_register "${__P_STAGENAME}" "${__P_FUNCTIONNAME}"; then
        return 0
    fi
    return 199
}
#####
#
# - __init_function_register_replace
#
# - Description:
#   Takes the name of a stage, old function, new existing function and replaces it.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME
#       Name of the stage to work on. This can take the special word "all" in which
#       case the function will be replaced in all registered stages found.
#
#   - #2 [IN|MANDATORY]: FUNCTIONNAME_OLD
#       The name of the function that is to be replaced.
#
#   - #3 [IN|MANDATORY]: FUNCTIONNAME_NEW
#       The name of the new, existing function that should take the place.
#
# - Return values:
#   - 0 on success.
#   - > 0 on failure.
#
function __init_function_register_replace() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    elif [[ "${@:1:1}" == "all" ]]; then
        declare __P_STAGENAME="all"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_FUNCTIONNAME_OLD="${@:2:1}"
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 104
    elif __variable_type_function "${@:3:1}"; then
        declare __P_FUNCTIONNAME_NEW="${@:3:1}"
    else
        return 105
    fi

    if [[ "${__P_STAGENAME,,}" == "all" ]]; then
        declare -a __T_STAGENAMES=()
        if __init_stage_registered_get_all __T_STAGENAMES; then
            true
        else
            return 111
        fi
    else
        declare -a __T_STAGENAMES=("${__P_STAGENAME}")
    fi

    for __T_STAGENAME in "${__T_STAGENAMES[@]}"; do
        if __init_function_registered "${__T_STAGENAME}" "${__P_FUNCTIONNAME_OLD}"; then
            if __init_function_unregister "${__T_STAGENAME}" "${__P_FUNCTIONNAME_OLD}"; then
                if __init_function_registered "${__T_STAGENAME}" "${__P_FUNCTIONNAME_NEW}"; then
                    true
                elif __init_function_register_always "${__T_STAGENAME}" "${__P_FUNCTIONNAME_NEW}"; then
                    true
                else
                    return 121
                fi
            else
                return 122
            fi
        else
            if __init_function_register_always "${__T_STAGENAME}" "${__P_FUNCTIONNAME_NEW}"; then
                true
            else
                return 123
            fi
        fi
    done

}
#####
#
# - __init_function_registered
#
# - Description:
#   Takes the name of a stage and a function and checks if the function is registered in said stage.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME
#       Name of the stage. Takes the special word "all". Searches over all registered stages
#       and as soon as one stage is found where the function is NOT registered, returns 1.
#
#   - #2 [IN|MANDATORY]: FUNCTIONNAME - Name of the function to search for.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __init_function_registered() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    elif [[ "${@:1:1}" == "all" ]]; then
        declare __P_STAGENAME="all"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_FUNCTIONNAME="${@:2:1}"
    fi

    declare -a __T_STAGENAMES=()

    if [[ "${__P_STAGENAME}" == "all" ]]; then
        if __init_stage_registered_get_all __T_STAGENAMES; then
            true
        else
            return 111
        fi
    else
        __T_STAGENAMES+=("${__P_STAGENAME}")
    fi

    for __T_STAGENAME in "${__T_STAGENAMES[@]}"; do
        if __init_stage_registered "${__T_STAGENAME}"; then
            declare __T_STAGE_ARRAYNAME=""
            if __init_stage_arrayname_get "${__T_STAGENAME}" __T_STAGE_ARRAYNAME; then
                if __array_contains "${__T_STAGE_ARRAYNAME}" "${__P_FUNCTIONNAME}"; then
                    true
                else
                    return 1
                fi
            else
                return 111
            fi
        else
            return 112
        fi
    done
    return 0
}
#####
#
# - __init_function_unregister
#
# - Description:
#   Takes the name of a stage and a function and unregisters it from said stage if found.
#
# - Paramters:
#   - #1 [IN|MANDATORY]: STAGENAME
#       Name of the stage. Accepts "all". In this case it unregisters the function
#       from all stages it is found in.
#
#   - #2 [IN|MANDATORY]: FUNCTIONNAME - Name of the function to remove.
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __init_function_unregister() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    elif [[ "${@:1:1}" == "all" ]]; then
        declare __P_STAGENAME="all"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 103
    else
        declare __P_FUNCTIONNAME="${@:2:1}"
    fi

    declare -a __T_STAGENAMES=()

    if [[ "${__P_STAGENAME}" == "all" ]]; then
        if __init_stage_registered_get_all __T_STAGENAMES; then
            true
        else
            return 111
        fi
    else
        __T_STAGENAMES+=("${__P_STAGENAME}")
    fi

    for __T_STAGENAME in "${__T_STAGENAMES[@]}"; do
        if __init_function_registered "${__T_STAGENAME}" "${__P_FUNCTIONNAME}"; then
            declare __T_STAGE_ARRAYNAME=""
            if __init_stage_arrayname_get "${__T_STAGENAME}" __T_STAGE_ARRAYNAME; then
                if __array_contains "${__T_STAGE_ARRAYNAME}" "${__P_FUNCTIONNAME}"; then
                    if __array_remove "${__T_STAGE_ARRAYNAME}" "${__P_FUNCTIONNAME}"; then
                        true
                    else
                        __tlog e -- "Problems removing '${__P_FUNCTIONNAME}' from stage '${__T_STAGENAME}'."
                        return 121
                    fi
                else
                    __tlog e -- "Function '${__P_FUNCTIONNAME}' ist not in array of stage '${__T_STAGENAME}'."
                    return 122
                fi
            else
                __tlog e -- "Could not get array name for stage '${__T_STAGENAME}'."
                return 123
            fi
        else
            return 124
        fi
    done
    return 0

}
#####
#
# - __init_function_unregister_always
#
# - Description:
#   Takes the name of a stage and a function and unregisters it from the stage. Tries to do whatever
#   necessary to unregister the function and even returns 0 when the function wasn't found...
#
# - Paramters:
#   - #1 [IN|MANDATORY]: STAGENAME - The name of the stage. Accepts "all"
#   - #2 [IN|MANDATORY]: FUNCTIONNAME - The name of the function.
#
# - Return values:
#   - 0 on success (basically always).
#   - >0 on failure
#
function __init_function_unregister_always() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    elif [[ "${@:1:1}" == "all" ]]; then
        declare __P_STAGENAME="${@:1:1}"
    else
        return 102
    fi

    declare __T_STAGENAMES=()

    if [[ "${__P_STAGENAME}" == "all" ]]; then
        if __init_stage_registered_get_all __T_STAGENAMES; then
            true
        else
            return 111
        fi
    else
        __T_STAGENAMES+=("${__P_STAGENAME}")
    fi

    for __T_STAGENAME in "${__T_STAGENAMES[@]}"; do
        if __init_function_registered "${__T_STAGENAME}" "${__P_FUNCTIONNAME}"; then
            if __init_function_unregister "${__T_STAGENAME}" "${__P_FUNCTIONNAME}"; then
                true
            else
                true
            fi
        fi
    done
    # we return success whatever the cost
    return 0
}
#####
#
# - __init_results_add
#
# - Description
#   Function gets called by the configuration modules after the configuration of a specific
#   feature is done. I then stores the information in an associative array which is later
#   used to print the information via the "print" package.
#
#   The associatige array that holds the information is called '__INIT_RESULTS_FEATURES'.
#   It needs to be created manually. If it is not available, the function just returns
#   with '0'.
#
# - Parameters
#   - #1 [IN|MANDATORY]: FEATURENAME - The name of the feature the status is reported for.
#   - #2 [IN|MANDATORY]: FEATURESTATUS - The status of the feature. Basically a string of your choice.
#
# - Return values
#   - 0 on success/added.
#   - >0 on failure/problems.
#
function __init_results_add() {
    if ! __aarray_exists __INIT_RESULTS_FEATURES; then
        return 0
    fi
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_FEATURENAME="${@:1:1}"
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 102
    else
        declare __P_FEATURESTATUS="${@:2:1}"
    fi

    __INIT_RESULTS_FEATURES["${__P_FEATURENAME}"]="${__P_FEATURESTATUS}"

    return 0
}
#####
#
# - __init_results_show
#
# - Description
#   When the associative array '__INIT_RESULTS_FEATURES' exists, this function will display its
#   contents nicely formatted in a table.
#
# - Parameters
#   - NONE.
#
# - Return values
#   - 0 on success.
#   - >0 on failure.
#
function __init_results_show() {

    if __aarray_exists __INIT_RESULTS_FEATURES; then

        # create the format array
        declare -Agx __G_TABLE_FORMAT_INIT_RESULTS=()

        # set the column name prefix.
        declare __T_CN="COLUMN1"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_ALIGN]="l"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_HEADER_TEXT]="Feature"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_HEADER_ALIGN]="l"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_NAME_REGEX_FORMULA]='^(.+)$'
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_NAME_REGEX_MATCH]=1
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_VALUE_DISPLAY_NAME]=1
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_VALUE_DISPLAY_NAME_REGEX]='^(.+)$'
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_VALUE_DISPLAY_NAME_REGEX_INDEX]=1
        unset __T_CN

        # set the column name prefix.
        declare __T_CN="COLUMN2"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_ALIGN]="l"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_HEADER_TEXT]="Status"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_HEADER_ALIGN]="l"
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_NAME_REGEX_FORMULA]='^(.+)$'
        __G_TABLE_FORMAT_INIT_RESULTS[${__T_CN}_DATA_NAME_REGEX_MATCH]=1
        unset __T_CN

        __log i -- "\n"
        __log_banner i -- "Configuration overview:"
        # let's dance.
        __print_table __INIT_RESULTS_FEATURES __G_TABLE_FORMAT_INIT_RESULTS 2>&1 | __log_stdin i --
        return
    else
        return 0
    fi
    return 254
}
#####
#
# - __init_stage_arrayname_get
#
# - Description:
#   Takes the name of a stage and returns the name of the corresponding array. This function
#   basically exists for convenience to have a single point where the name gets changed.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage
#   - #2 [OUT|OPTIONAL]: RETURN_VALUE - Name of an existing variable that should be filled with the array's name.
#
# - Return value:
#   - 0 on success.
#   - >0 on failure.
#
function __init_stage_arrayname_get() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare -i __P_STAGENAME=${BASH_REMATCH[2]}
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare -a __T_ISAG_INIT_STAGE_ARRAYNAME=""
    elif __variable_exists "${@:2:1}"; then
        declare -n __T_ISAG_INIT_STAGE_ARRAYNAME="${@:2:1}"
    else
        declare -a __T_ISAG_INIT_STAGE_ARRAYNAME=""
    fi
    __T_ISAG_INIT_STAGE_ARRAYNAME="__INIT_STAGE_ARRAY_${__P_STAGENAME}"
    if [[ ! -R __T_ISAG_INIT_STAGE_ARRAYNAME ]]; then
        echo "${__T_ISAG_INIT_STAGE_ARRAYNAME}"
    fi
    return 0
}
#####
#
# - __init_stage_register
#
# - Description:
#   Takes the name of a stage and registers to it.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage
#
# - Return values:
#   - 0 on success.
#   - >0 on failure.
#
function __init_stage_register() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    else
        return 102
    fi
    if __aarray_exists __INIT_STAGE_REGISTERED_STAGES; then
        true
    elif __variable_exists __INIT_STAGE_REGISTERED_STAGES; then
        if unset __INIT_SAGE_REGISTERED_STAGES; then
            if declare -Agx __INIT_STAGE_REGISTERED_STAGES=(); then
                true
            else
                return 103
            fi
        else
            return 104
        fi
    elif declare -Agx __INIT_STAGE_REGISTERED_STAGES=(); then
        true
    else
        return 105
    fi

    declare __T_INIT_STAGE_ARRAYNAME=""
    if __init_stage_arrayname_get "${__P_STAGENAME}" __T_INIT_STAGE_ARRAYNAME; then
        if __array_exists "${__T_INIT_STAGE_ARRAYNAME}"; then
            return 111
        elif declare -agx "${__T_INIT_STAGE_ARRAYNAME}=()"; then
            if __aarray_add __INIT_STAGE_REGISTERED_STAGES "${__P_STAGENAME}" "${__P_STAGENAME}"; then
                return 0
            else
                return 112
            fi
        else
            return 113
        fi
    else
        return 114
    fi
    return 199
}
#####
#
# - __init_stage_registered
#
# - Description:
#   Takes the name of a stage and returns 0 when it's registered.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage.
#
# - Return values:
#   - 0 on success/registered.
#   - >0 on failure/not registered.
#
function __init_stage_registered() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    else
        return 102
    fi

    if __aarray_exists __INIT_STAGE_REGISTERED_STAGES; then
        if [[ -z ${__INIT_STAGE_REGISTERED_STAGES[${__P_STAGENAME}]+x} ]]; then
            return 1
        else
            return 0
        fi
    else
        return 111
    fi
    return 199
}
#####
#
# - __init_stage_registered_get_all
#
# - Description:
#   Returns all registered stages. Either to stdout or to the ARRAY you handed it via the out paramter.
#
# - Parameters:
#   - #1 [IN|OPTIONAL]: RETURN_ARRAY - Name of an existing array that should be filled with the stage namees.
#
# - Return values:
#   - 0 on success/stages found.
#   - 1 on failure/no stages found.
#
function __init_stage_registered_get_all() {
    if [[ "${@:1:1}x" == "x" ]]; then
        declare -a __T_RETURN_ARRAY=()
    elif __array_exists "${@:1:1}"; then
        declare -n __T_RETURN_ARRAY="${@:1:1}"
    elif __aarray_exists "${@:1:1}"; then
        declare -n __T_RETURN_ARRAY"${@:1:1}"
    else
        declare -a __T_RETURN_ARRAY=()
    fi

    if __aarray_exists __INIT_STAGE_REGISTERED_STAGES; then
        if ([[ -R __T_RETURN_ARRAY ]] && __array_exists "${!__T_RETURN_ARRAY}") || __array_exists __T_RETURN_ARRAY; then
            __T_RETURN_ARRAY+=("${!__INIT_STAGE_REGISTERED_STAGES[@]}")
        elif ([[ -R __T_RETURN_ARRAY ]] && __aarray_exists "${!__T_RETURN_ARRAY}") || __aarray_exists __T_RETURN_ARRAY; then
            for __T_ITEM in "${!__INIT_STAGE_REGISTERED_STAGES[@]}"; do
                __T_RETURN_ARRAY+=(["${__T_ITEM}"]="${__INIT_STAGE_REGISTERED_STAGES[${__T_ITEM}]}")
            done
        fi
    fi

    if [[ ${#__T_RETURN_ARRAY[@]} -gt 0 ]]; then
        if [[ ! -R __T_RETURN_ARRAY ]]; then
            echo "${__T_RETURN_ARRAY[@]}"
        fi
        return 0
    else
        return 1
    fi
    return 199
}
#####
#
# - __init_stage_run
#
# - Description
#   Takes the name of a stage and runs all the functions in its array.
#   When a function exits with an error, we try to continue with the next one.
#   Function names that are found but don't exist anymore in the environment are marked
#   for deletion from the array and are deleted after all functions ran successfully.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGENAME - Name of the stage.
#
function __init_stage_run() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${BASH_REMATCH[2]}"
    else
        return 102
    fi

    if __init_stage_registered "${__P_STAGENAME}"; then
        true
    else
        __log e -- "Stage '${__P_STAGENAME}' is not registered ($?)."
        return 111
    fi

    declare -a __T_FUNCTIONS_TO_DELETE=()
    declare -A __T_FUNCTIONS_FAILED=()
    declare -i __T_ERROR=0
    declare __T_STAGE_ARRAYNAME=""
    declare __T_STAGE_ARRAY=""
    if __init_stage_arrayname_get "${__P_STAGENAME}" __T_STAGE_ARRAYNAME; then
        true
    else
        __log e -- "Could not get array name for stage '${__P_STAGENAME}' ($?)."
        return 112
    fi

    if __array_exists "${__T_STAGE_ARRAYNAME}"; then
        true
    else
        __log e -- "Array for stage '${__P_STAGENAME}' does not exists ($?)."
        return 113
    fi

    if declare -n __T_STAGE_ARRAY="${__T_STAGE_ARRAYNAME}"; then
        true
    else
        __log e -- "Could not create nameref to array of stage '${__P_STAGENAME}' ($?)."
        return 114
    fi

    if __array_empty "${__T_STAGE_ARRAYNAME}"; then
        __log e -- "Array for stage '${__P_STAGENAME}' is empty ($?)."
    fi

    unset __LOG_STAGE_CURRENT
    declare -g __LOG_STAGE_CURRENT="${__P_STAGENAME}"

    for __T_FN in "${__T_STAGE_ARRAY[@]}"; do
        unset __T_ROW_PREFIX __T_ROW_NAME
        declare __T_ROW_PREFIX="${__P_STAGENAME}"
        while [[ ${#__T_ROW_PREFIX} -lt 10 ]]; do
            __T_ROW_PREFIX="0${__T_ROW_PREFIX}"
        done
        declare __T_ROW_NAME="${__T_ROW_PREFIX}__STAGE${__P_STAGENAME}__${__T_FN}"
        if __variable_type_function "${__T_FN}"; then
            if ${__T_FN}; then
                if __aarray_exists __INIT_RESULTS; then
                    __INIT_RESULTS[${__T_ROW_NAME}]=0
                fi
            else
                declare -i __T_ERROR=$?
                __log e -- "Problems running function '${__T_FN}' in stage '${__P_STAGENAME}' (${__T_ERROR}).\n"
                if __aarray_exists __INIT_RESULTS; then
                    __INIT_RESULTS[${__T_ROW_NAME}]=${__T_ERROR}
                fi
                __T_FUNCTIONS_FAILED+=([${__T_FN}]="${__T_ERROR}")
            fi
        else
            if __aarray_exists __INIT_RESULTS; then
                __INIT_RESULTS[${__T_ROW_NAME}]="MISSING"
            fi
            __log w -- "Function '${__T_FN}' does not exist anymore. Going to delete it later.\n"
            __T_FUNCTIONS_TO_DELETE+=("${__T_FN}")
        fi
        unset __T_ROW_PREFIX __T_ROW_NAME
    done

    if [[ ${#__T_FUNCTIONS_TO_DELETE[@]} -gt 0 ]]; then
        for __T_FN in "${__T_FUNCTIONS_TO_DELETE[@]}"; do
            if __array_contains "${__T_STAGE_ARRAY_NAME}" "${__T_FN}"; then
                if __array_remove "${__T_STAGE_ARRAY_NAME}" "${__T_FN}"; then
                    true
                else
                    __log e -- "Problems removing function '${__T_FN}' from stage array of stage '${__P_STAGENAME}' ($?)."
                fi
            fi
        done
    fi

    if [[ ${#__T_FUNCTIONS_FAILED[@]} -gt 0 ]]; then
        __log w -- "A total of '${#__T_FUNCTIONS_FAILED[@]}' functions have failed. These are: '${!__T_FUNCTIONS_FAILED[@]}'.\n"
    fi
    unset __LOG_STAGE_CURRENT
    return 0
}
#####
#
# - __init_stage_run_fromto
#
# - Description:
#   Takes two stages, the one to start from and the one to run to (including).
#   And calls __init_stage_run for every stage found. If you omit the "STAGETO"
#   paramter it will run from the first stage found that is >= STAGEFROM to the end
#   of all registered stages.
#
# - Parameters:
#   - #1 [IN|MANDATORY]: STAGEFROM
#       The stage where you want to start from.
#
#   - #2 [IN|OPTIONAL]:  STAGETO
#       The stage where you want to stop. If omitted, runs from STAGEFROM to the very end.
#
#   - #3 [OUT|OPTIONAL]: RETURN_ARRAY
#       Name of an existing array that should be filled with the names of the stages that were run.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#
function __init_stage_run_fromto() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGEFROM="${BASH_REMATCH[2]}"
    else
        return 102
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        declare -i __P_STAGETO=-1
    elif [[ "${@:2:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare -i __P_STAGETO="${BASH_REMATCH[2]}"
    else
        declare -i __P_STAGETO=-1
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        declare -a __T_RETURN_ARRAY=()
    elif __array_exists "${@:3:1}"; then
        declare -n __T_RETURN_ARRAY="${@:3:1}"
    else
        declare -a __T_RETURN_ARRAY=()
    fi

    declare -a __T_STAGES_REGISTERED=()
    declare -a __T_STAGES_SORTED=()
    if __init_stage_registered_get_all __T_STAGES_REGISTERED; then
        if [[ ${#__T_STAGES_REGISTERED[@]} -gt 0 ]]; then
            IFS=$'\n' __T_STAGES_SORTED=($(sort -n <<<"${__T_STAGES_REGISTERED[*]}"))
            unset IFS
            if [[ ${__P_STAGETO} -eq -1 ]]; then
                for __T_STAGENAME in "${__T_STAGES_SORTED[@]}"; do
                    declare -i __TT_STAGENAME=${__T_STAGENAME}
                    if [[ ${__TT_STAGENAME} -ge ${__P_STAGEFROM} ]]; then
                        __T_RETURN_ARRAY+=("${__TT_STAGENAME}")
                    fi
                done
            else
                for __T_STAGENAME in "${__T_STAGES_SORTED[@]}"; do
                    declare -i __TT_STAGENAME=${__T_STAGENAME}
                    if [[ ${__TT_STAGENAME} -ge ${__P_STAGEFROM} ]] && [[ ${__TT_STAGENAME} -le ${__P_STAGETO} ]]; then
                        __T_RETURN_ARRAY+=("${__TT_STAGENAME}")
                    fi
                done
            fi
        fi
    fi
    declare -a __T_STAGES_FAILED=()
    if [[ ${#__T_RETURN_ARRAY[@]} -gt 0 ]]; then
        for __T_STAGE in "${__T_RETURN_ARRAY[@]}"; do
            if __init_stage_run "${__T_STAGE}"; then
                true
            else
                __log e -- "Problems running stage '${__T_STAGE}' ($?)."
                __T_STAGES_FAILED+=("${__T_STAGE}")
            fi
        done
    else
        __log dw -- "No stages found from '${__P_STAGEFROM}' to '${__P_STAGETO}'.\n"
    fi

    if [[ ${#__T_STAGES_FAILED[@]} -gt 0 ]]; then
        __log w -- "Out of '${#__T_RETURN_ARRAY[@]}' stages that have been run '${#__T_STAGES_FAILED[@]}' stages have failed."
        __log w -- "Those are: '${__T_STAGES_FAILED[@]}'."
    fi

    return 0

}
#####
#
# - __init_stage_unregister
#
# - Description:
#   Takes the name of a stage and destroys its array. There is no check if the array still contains
#   any values.
#
# - Parameters:
#   - #1 [IN|MANDATORY] STAGENAME - The stage's name that you want to unregister.
#
# - Return values:
#   - 0 on succes.
#   - >0 on failure.
#
function __init_stage_unregister() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif [[ "${@:1:1}" =~ ${__INIT_TEXT_REGEX_NUMBER_NO_LEADING_ZEROES} ]]; then
        declare __P_STAGENAME="${@:1:1}"
    else
        return 102
    fi

    if __init_stage_registered "${__P_STAGENAME}"; then
        declare __T_INIT_STAGE_ARRAYNAME=""
        if __init_stage_arrayname_get "${__P_STAGENAME}" __T_INIT_STAGE_ARRAYNAME; then
            if __array_exists "${__T_INIT_STAGE_ARRAYNAME}"; then
                if unset "${__T_INIT_STAGE_ARRAYNAME}"; then
                    if __aarray_exists __INIT_STAGE_REGISTERED_STAGES; then
                        if __aarray_remove_key __INIT_STAGE_REGISTERED_STAGES "${__P_STAGENAME}"; then
                            if __aarray_empty __INIT_STAGE_REGISTERED_STAGES; then
                                if unset __INIT_STAGE_REGISTERED_STAGES; then
                                    return 0
                                else
                                    return 131
                                fi
                            else
                                return 0
                            fi
                        else
                            return 121
                        fi
                    else
                        return 122
                    fi
                else
                    return 111
                fi
            else
                return 112
            fi
        else
            return 113
        fi
    else
        return 1
    fi
    return 199
}
#####
#
# - __init_paramter_start_register
#
# - Description:
#   Used to register paramters to hand to the main process that will be started in the container
#   at the end of the init process. Used during the start phase of the image.
#
# - Parameters:
#   - # [IN|MANDATORY] STARTPARAMTERS: One or more paramters to be registered to the init parameters array.
#
# - Return values:
#   - 0 on success.
#   - 1 on failure.
#
function __init_parameter_start_register() {
    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare -a __P_STARTPARAMETERS=("${@}")
    fi

    if __array_exists __INIT_PARAMETER_START; then
        true
    elif __variable_exists __INIT_PARAMETER_START; then
        if undef __INIT_PARAMETER_START; then
            if declare -agx __INIT_PARAMETER_START=(); then
                true
            else
                __log e -- "Could not create array '__INIT_PARAMETER_START' ($?)."
                return 102
            fi
        else
            __log e -- "Could not delete old value to create array '__INIT_PARAMETER_START' ($?)."
            return 103
        fi
    elif declare -agx __INIT_PARAMETER_START=(); then
        true
    else
        __log e -- "Could not create array '__INIT_PARAMETER_START' ($?)."
        return 104
    fi

    for __P_STARTPARAMETER in "${__P_STARTPARAMETERS[@]}"; do
        if __array_add_always __INIT_PARAMETER_START "${__P_STARTPARAMETER}"; then
            true
        else
            __log e -- "Problems adding '${__P_STARTPARAMETER}' to '__INIT_PARAMETER_START' ($?)."
        fi
    done
    return 0
}
#####
#
# - __init_paramter_start_remove
#
# - Description:
#   Takes a list of paramters that should be removed from the init paramters array.
#   Tries to remove the value if it is in the init paramters array, skips otherwise without
#   returning an error.
#
# - Parameter:
#   - # [IN|MANDATORY]: STARTPARAMTERS: One or more paramters to be deleted from the init parmaters array.
#
# - Return values
#   - 0 on succes.
#   - >0 on failure.
#
function __init_parameter_start_remove() {

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    else
        declare __P_STARTPARAMETERS=("${@}")
    fi

    if __array_exists __INIT_PARAMETER_START; then
        true
    else
        return 0
    fi
    for __P_STARTPARAMETER in "${__P_STARTPARAMETERS[@]}"; do
        if __array_contains __INIT_PARAMETER_START "${__P_STARTPARAMETER}"; then
            if __array_remove __INIT_PARAMETER_START "${__P_STARTPARAMETER}"; then
                true
            else
                __log e -- "Problems removing '${__P_STARTPARAMETER}' from the init parameter array..."
            fi
        fi
    done
    return 0
}
