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

#
# DO NOT ASK WHAT GOT INTO ME TO WRITE THIS
#
#####
#
# - __print_table
#
# - Takes an associative array of values and an associative array of column definitions and calculates/formats/prints
#   the columns/rows to stdout
#
# - The format array follows a certain order, as does the data array...
#
# - === FORMAT ARRAY === 
#
#   - Description: 
#       This array will contain all the formating settings that the table is going to use.
#       It is an associative array.
#
#   - Example:
#       declare -Agx __FORMAT=()
#
#
# - ==== GLOBAL SETTINGS ==== 
#
#   - Description:
#       The format array can contain global settings. They do not have a prefix and are just named once.
#
# - ===== GLOBAL SETTINGS LIST =====
#
# - ======= TABLE_DELIMITER [OPTIONAL] =======
#
#   - Description:
#       This is a single character that is used to separate the single columns from eachother.
#
#   - Default: "|"
#
#   - Example:
#       declare -Agx __FORMAT=([TABLE_DELIMITER]="|")
#
# - ==== PER COLUMN SETTINGS ====
#
# Each name in the associative array o format begins with the prefix "COLUMN####" where "####" 
# represents a number. It's a good idea to go with at least two, if not three numbers in the prefix.
# Leading zeroes will be removed, so "COLUMN001" becomes "COLUMN1".
#
# Let's assume the prefix is "COLUMN1"
#
# Then, each PREFIX is followed by the following names to complete the configuration setting:
#
# - ===== COLUMN SETTINGS LIST =====
#
# - ====== _HEADER_TEXT [OPTIONAL] ======
#
#   - Description:
#       The text that should be printed as header of the column.
#
#   - Default: Empty
#
#   - Example:
#       __FORMAT[COLUMN1_HEADER_TEXT]="THIS IS THE HEADER TEXT"
#
#
# - ====== _HEADER_ALIGN [OPTIONAL] ======
#
#   - Description
#       The alignment of the header text, check the _ALIGN option later.
#
#   - Default: "l"
#
#   - Example: 
#       __FORMAT[COLUMN1_HEADER_ALIGN]="l"
#
# - ====== _DELIMITER [OPTIONAL] ======
#
#   - Description:
#       Sets the delimiter for this column. Remember this is always AFTER the value was printed (!)
#
#    - Default: Global delimiter
#
# - ====== _ALIGN [OPTIONAL] ======
#
# - Description
#       The following values are supported:
#
#       - "l" - Left
#       - "c" - Center left
#       - "cr" - Center right
#       - "r" - "Right"
#
#   The difference between center left and center right is as follows:
#   When you have an uneven width of the spaces that need to be added to the column
#   to make it adjust with the other rows' column width, let's say "5" and you 
#   divide this by 2, to get the space BEFORE and AFTER the value that you have to
#   print, then bash only knows integers and 5/2 becomes "2".
#
#   Now if you have set the alignment to "Center left" or "c", then the space
#   will be calculated as follows:
#   TOTAL_WIDTH=20
#   VALUE_WIDTH=15
#   MAX_SPACE_TO_ADD=(TOTAL_WIDTH - VALUE_WIDTH) = 20 - 15 = 5
#   SPACE_TO_ADD_LEFT=(MAX_SPACE_TO_ADD/2) = 5/2 = 2
#   SPACE_TO_ADD_RIGHT=(MAX_SPACE_TO_ADD - SPACE_TO_ADD_LEFT) = 5 - 2 = 3
#
#   This will get you two spaces on the left and three spaces on the right.
#   So we're still in the center, but the value is leaning left.
#
#   If the alignment is set to "Center right" or "cr", then the space
#   will be calculated as follows:
#
#   TOTAL_WIDTH=20
#   VALUE_WIDTH=15
#   MAX_SPACE_TO_ADD=(TOTAL_WIDTH - VALUE_WIDTH) = 20 - 15 = 5
#   SPACE_TO_ADD_RIGHT=(MAX_SPACE_TO_ADD/2) = 5/2 = 2
#   SPACE_TO_ADD_LEFT=(MAX_SPACE_TO_ADD - SPACE_TO_ADD_RIGHT) = 5 - 2 = 3
#
#   This will get you three spaces to the left and two spaces on the right.
#   We're still in center, but the value is leaning right.
#
#   BONUS: Now figure out in which way the value leans if MAX_SPACE_TO_ADD
#   is 10.
#
# - Default "l"
#
# - Example:
#   __FORMAT[COLUMN1_ALIGN]="l"
#
# - ====== _DATA_NAME_PREFIX ======
#
#   - Description:
#       This variable contains the PREFIX of the column name that is used to determine if an
#       entry in the data array actually belongs to this column. It is also used to get the
#       row name, this works as follows:
#
#   Let's say the data array has the following entries:
#
#   declare -Agx __DATA=()
#   __DATA[__NAME__row17]="Spencer"
#   __DATA[__PRENAME__row17]="Bud"
#   __DATA[__PROFESSION__row17]="Artist"
#
#   Now you set __FORMAT[COLUMN1_DATA_NAME_PREFIX]="__NAME__" - what happens?
#
#   The function will create the following regular expression: '^__NAME__(.+)$' and
#   go over all the names in the data array. Everytime a column matches the regular
#   expression, it will be selected as a valid column, and the regex match in the
#   "()" will become the row's name (!!!!)
#
#   So you will end up with: column name '__NAME__row17' and row name 'row17'
#
#   This row name will be stored in another array containing all the row names and will
#   be later used to identify the columns for each row. 
#
#   If we continue on this, with "__PRENAME__" for column two we get 
#   column name '__PRENAME__row17', row name 'row17'.
#
#   And on column three with "__PROFESSION__" as prefix we will get column name 
#   '__PROFESSION__ROW17' and row name 'row17'
#
# - ====== _DATA_NAME_SUFFIX ======
#
#   - Description:
#       Works the same as _DATA_NAME_PREFIX, except that the value is put at the
#       end of the regular expression like so: '^(.+)__SUFFIX__'.
#
#   Let's assume we have the following data array:
#
#   declare -Agx __DATA=()
#   __DATA[row17__NAME__]="Spencer"
#   __DATA[row17__PRENAME__]="Bud"
#   __DATA[row17__PROFESSION__]="Artist"
#
#   And we set __FORMAT[COLUMN1_DATA_NAME_SUFFIX]="__NAME__" then we get:
#
#   "row17__NAME__" as column name, and "row17" as row name.
#
#   For column two with suffix "__PRENAME__" we get "row17__PRENAME__" as column name
#   and "row17" as row name.
#
#   And column three with suffix "__PROFESSSION__" would produce "row17__PROFESSION__" as
#   column name and "row17" as row name.
#
# - ====== _DATA_NAME_PREFIX & _DATA_NAME_SUFFIX ======
#
#   - Description:
#       You can use both and the following regex will be created:
#       '^__PREFIX__(.+)__SUFFIX__$'
#
#   Please read the above sections for a full explanation, quick example:
#
#   declare -Agx __DATA=()
#   __DATA[__NAME__row17__DATABASE1]="Spencer"
#   __DATA[__PRENAME__row17__DATABASE1]="Bud"
#   __DATA[__PROFESSION__row17__DATABASE1]="Artist"
#
#   Column 1: Prefix: "__NAME__", suffix: "__DATABASE1", column name: "__NAME__row17__DATABASE1", row name: "row17"
#   Column 2: Prefix: "__PRENAME__", suffix: "__DATABASE1", column name: "__PRENAME__row17__DATABASE1", row name: "row17"
#   Column 3: Prefix: "__PROFESSION__", suffix: "__DATABASE1", column name: "__PROFESSION__row17__DATABASE1", row name: "row17"
#
# - ====== _DATA_NAME_REGEX_FORMULA ======
#
#   - Description:
#       You can provide your own regular expression to match against the
#       entry names in the data array. It works the same as the PREFIX/SUFFIX
#       settings as long as you provide a valid match in the "()" for the function
#       to create a set of row names.
#
#       Quick example:
#
#       declare -Agx __DATA=()
#       __DATA[__NAME__row17]="Spencer"
#       __DATA[__PRENAME__row17]="Spencer"
#
#       declare -Agx __FORMAT=()
#       __FORMAT[COLUMN1_DATA_REGEX_FORMULA]='^(__NAME__)(.+)$'
#       __FORMAT[COLUMN1_DATA_REGEX_MATCH]=2
#
#       Column name: "__NAME_row17", row name: "row17"
#
# - ====== _DATA_NAME_REGEX_MATCH ======
#
#   - Description:
#       This is only in affect if _DATA_NAME_REGEX_FORMULA is set. It provides
#       The position of the "()" that we use to create the column name.
#       As you now regular expressions can have multiple matching groups and we
#       need to use the one that you have defined as a valid match in your regular
#       expression provided via _DATA_NAME_REGEX_FORMULA.
#
# - ====== _DATA_VALUE_CALUCLATE_TOTAL ======
#
#   - Description:
#       IF the value in the column is a number, then the function will try to calculate
#       the total value and print it at the bottom of the table.
#
#
# - ====== _DATA_VALUE_DISPLAY_NAME ======
#
#   - Description:
#       Sometimes it can be nice to print the name of the column as value, especially
#       when the name of the column has been reworked via _DATA_VALUE_DISPLAY_NAME_REGEX.
#
#   - Example:
#       Column name: "__SUCCESS_function_do_something"
#       Regex: '^(__SUCCESS_function_)(.+)$'
#       Regex index: 2
#       Result: "do_something"
#       Displayed value: "do_something"
#
# - ====== _DATA_VALUE_DISPLAY_NAME_REGEX ======
#
#   - Description:
#       A regular expression that is used to find the matching part of the column's name
#       that should be displayed when _DATA_VALUE_DISPLAY_NAME is active.
#
# - ====== _DATA_VALUE_DISPLAY_NAME_REGEX_INDEX ======
#
#   - Description:
#       The index number that is used to find the matching group of the previous
#       regular expression to generate the displayed value you want.
#
# - ====== _DATA_VALUE_REGEX_FORMULA ======
#
#   - Description:
#       A regular expression that is used to match against the displayed value.
#
# - ====== _DATA_VALUE_REGEX_MATCH ======
#
#   - Description:
#       The index of the matching group of _DATA_VALUE_REGEX_FORMULA that should be used
#
# - ====== _DATA_VALUE_REGEX_MATCH_PREFIX ======
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA produces a match, then this is put before said match
#       when it is displayed in the table.
#
# - ===== _DATA_VALUE_REGEX_MATCH_SUFFIX =====
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA produces a match, then this is put after said match
#       when it is displayed in the table.
#
# - ====== _DATA_VALUE_REGEX_MATCH_PREFIX_ARRAY ======
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA produces a match, then the function will check if the
#       the match is a name in the associative array provided via this setting. If this is the
#       case, then whatever the value is, is put before the match.
#
# - ====== _DATA_VALUE_REGEX_MATCH_SUFFIX_ARRAY ======
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA produces a match, then the function will check if the
#       the match is a name in the associative array provided via this setting. If this is the
#       case, then whatever the value is, is put after the match.
#
#   The both values mentioned before can be useful to colorize the column's value by putting
#   ANSI color escape codes in the PREFIX and SUFFIX settings.
#
#   A good example of this can be seen in the testlib provided with this scripts collection.
#
# - ====== _DATA_VALUE_REGEX_NOMATCH_PREFIX ======
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA DOES NOT produce a match, then this is put before
#       the existing value.
#
# - ===== _DATA_VALUE_REGEX_NOMATCH_SUFFIX =====
#
#   - Description:
#       If _DATA_VALUE_REGEX_FORMULA DOES NOT produce a match, then this is put after 
#       the existing value.
#

function __print_table() {
    declare __T_REGEX_ARRAY_ASSOCIATIVE='^declare -[^\ ]*A[^\ ]*\ .*$'
    declare __T_REGEX_TEXT_NUMBER='^[0-9]+$'
    declare __T_REGEX_COLUMN_ALIGN_LEFT='^(l|L).*$'
    declare __T_REGEX_COLUMN_ALIGN_RIGHT='^(r|R).*$'
    declare __T_REGEX_COLUMN_ALIGN_CENTER='^(c|C)([^r|R].*)?$'
    declare __T_REGEX_COLUMN_ALIGN_CENTER_RIGHT='^(c|C)(r|R).*$'
    declare __T_REGEX_COLUMN_NAME='^(COLUMN[0-9]+)_.+$'
    declare __T_REGEX_COLUMN_NAME_LEADING_ZEROES='^COLUMN[0]*([1-9]|[1-9][0-9]+)_.+$'
    declare __T_PREFIX="__TABLE_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)"

    declare __T_COLUMNS_NAME="${__T_PREFIX}_COLUMNS"
    declare -A "${__T_COLUMNS_NAME}=()"
    declare -n __T_COLUMNS="${__T_COLUMNS_NAME}"
    unset __T_COLUMNS_NAME
    declare __T_ROWNAMES_NAME="${__T_PREFIX}_ROWNAMES"
    declare -a "${__T_ROWNAMES_NAME}=()"
    declare -n __T_ROWNAMES="${__T_ROWNAMES_NAME}"
    unset __T_ROWNAMES_NAME

    declare __T_RESULT=""

    if [[ "${@:1:1}x" == "x" ]]; then
        return 101
    elif __T_RESULT="$(declare -p "${@:1:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_CONTENT="${@:1:1}"
        else
            return 103
        fi
    else
        return 102
    fi
    unset __T_RESULT

    declare __T_RESULT=""

    if [[ "${@:2:1}x" == "x" ]]; then
        return 104
    elif __T_RESULT="$(declare -p "${@:2:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_FORMAT="${@:2:1}"
        else
            return 105
        fi
    else
        return 105
    fi
    unset __T_RESULT
    #####
    #
    # __P_FORMAT - Associative array, that starts with "COLUMN#" and can then contain the following
    #              parameters:
    #
 
    for __T_NAME in "${!__P_FORMAT[@]}"; do
        if [[ "${__T_NAME}" =~ ${__T_REGEX_COLUMN_NAME_LEADING_ZEROES} ]]; then
            declare __T_C="${BASH_REMATCH[1]}"
            if [[ ${#__T_COLUMNS[@]} -gt 0 ]]; then
                for __T_COLUMN in "${!__T_COLUMNS[@]}"; do
                    if [[ "${__T_COLUMN}" == "${__T_C}" ]]; then
                        # iterate the outer loop!!!
                        continue 2
                    fi
                done
            fi

            declare __T_COLUMN_ARRAYNAME="${__T_PREFIX}_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)"
            declare -A "${__T_COLUMN_ARRAYNAME}=()"
            unset -n __T_CA
            declare -n __T_CA="${__T_COLUMN_ARRAYNAME}"
            __T_COLUMNS+=([${__T_C}]=${__T_COLUMN_ARRAYNAME})

            if [[ "${__T_NAME}" =~ ${__T_REGEX_COLUMN_NAME} ]]; then
                __T_CNAME="${BASH_REMATCH[1]}"
                __T_CA[NAME]="${__T_CNAME}"
            else
                return 12
            fi
            if [[ -z ${__P_FORMAT[TABLE_DELIMITER]+x} ]]; then
                __T_CA[DELIMITER]="|"
            elif [[ "${__P_FORMAT[TABLE_DELIMITER]}x" == "x" ]]; then
                __T_CA[DELIMITER]="|"
            else
                __T_CA[DELIMITER]="${__P_FORMAT[TABLE_DELIMITER]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DELIMITER]+x} ]]; then
                true
            elif [[ "${__P_FORMAT[${__T_CNAME}_DELIMITER]}x" == "x" ]]; then
                true
            else
                __T_CA[DELIMITER]="${__P_FORMAT[${__T_CNAME}_DELIMITER]}"
            fi

            __T_CA[MAX_WIDTH]=2
            if [[ -z ${__P_FORMAT[${__T_CNAME}_ALIGN]+x} ]]; then
                __T_CA[ALIGN]="l"
            elif [[ "${__P_FORMAT[${__T_CNAME}_ALIGN]}x" == "x" ]]; then
                __T_CA[ALIGN]="l"
            elif [[ "${__P_FORMAT[${__T_CNAME}_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_LEFT} ]]; then
                __T_CA[ALIGN]="l"
            elif [[ "${__P_FORMAT[${__T_CNAME}_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_RIGHT} ]]; then
                __T_CA[ALIGN]="r"
            elif [[ "${__P_FORMAT[${__T_CNAME}_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_CENTER} ]]; then
                __T_CA[ALIGN]="c"
            elif [[ "${__P_FORMAT[${__T_CNAME}_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_CENTER_RIGHT} ]]; then
                __T_CA[ALIGN]="cr"
            else
                __T_CA[ALIGN]="l"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_HEADER_TEXT]+x} ]]; then
                __T_CA[HEADER_TEXT]=""
            else
                __T_CA[HEADER_TEXT]="${__P_FORMAT[${__T_CNAME}_HEADER_TEXT]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]+x} ]]; then
                __T_CA[HEADER_ALIGN]="${__T_CA[ALIGN]}"
            elif [[ "${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]}x" == "x" ]]; then
                __T_CA[HEADER_ALIGN]="${__T_CA[ALIGN]}"
            elif [[ "${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_LEFT} ]]; then
                __T_CA[HEADER_ALIGN]="l"
            elif [[ "${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_RIGHT} ]]; then
                __T_CA[HEADER_ALIGN]="r"
            elif [[ "${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]}" =~ ${__T_REGEX_COLUMN_ALIGN_CENTER} ]]; then
                __T_CA[HEADER_ALIGN]="c"
            elif [[ "${__P_FORMAT[${__T_CNAME}_HEADER_ALIGN]}" =~ ${__T_REGEX_COLUMN__ALIGN_CENTER_RIGHT} ]]; then
                __T_CA[HEADER_ALIGN]="cr"
            else
                __T_CA[HEADER_ALIGN]="${__T_CA[ALIGN]}"
            fi

            __T_CA[NAME_REGEX_MATCH]=1
            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_NAME_PREFIX]+x} ]]; then
                __T_CA[NAME_REGEX]=""
            else
                __T_CA[NAME_REGEX]="^${__P_FORMAT[${__T_CNAME}_DATA_NAME_PREFIX]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_NAME_SUFFIX]+x} ]]; then
                if [[ "${__T_CA[NAME_REGEX]}x" == "x" ]]; then
                    true
                else
                    __T_CA[NAME_REGEX]+='(.+)$'
                fi
            else
                __T_CA[NAME_REGEX]+='(.+)'
                __T_CA[NAME_REGEX]+="${__P_FORMAT[${__T_CNAME}_DATA_NAME_SUFFIX]}"
                __T_CA[NAME_REGEX]+='$'
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_FORMULA]+x} ]]; then
                if [[ "${__T_CA[NAME_REGEX]}x" == "x" ]]; then
                    return 11
                fi
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_FORMULA]}x" == "x" ]]; then
                if [[ "${__T_CA[NAME_REGEX]}x" == "x" ]]; then
                    return 12
                fi
            else
                __T_CA[NAME_REGEX]="${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_FORMULA]}"

                if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_MATCH]+x} ]]; then
                    true
                elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_MATCH]}x" == "x" ]]; then
                    true
                elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_MATCH]}" =~ ${__T_REGEX_TEXT_NUMBER} ]]; then
                    __T_CA[NAME_REGEX_MATCH]=${__P_FORMAT[${__T_CNAME}_DATA_NAME_REGEX_MATCH]}
                fi
            fi
            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_CALCULATE_TOTAL]+x} ]]; then
                __T_CA[VALUE_CALCULATE_TOTAL]=""
                __T_CA[VALUE_TOTAL]=0
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_CALCULATE_TOTAL]}x" == "x" ]]; then
                __T_CA[VALUE_CALCULATE_TOTAL]=""
                __T_CA[VALUE_TOTAL]=0
            else
                __T_CA[VALUE_CALCULATE_TOTAL]=1
                __T_CA[VALUE_TOTAL]=0
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME]+x} ]]; then
                __T_CA[VALUE_DISPLAY_NAME]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME]}x" == "x" ]]; then
                __T_CA[VALUE_DISPLAY_NAME]=""
            else
                __T_CA[VALUE_DISPLAY_NAME]=1
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX]+x} ]]; then
                __T_CA[VALUE_DISPLAY_NAME_REGEX]='^(.+)$'
                __T_CA[VALUE_DISPLAY_NAME_REGEX_INDEX]=1
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX]}x" == "x" ]]; then
                __T_CA[VALUE_DISPLAY_NAME_REGEX]='^(.+)$'
                __T_CA[VALUE_DISPLAY_NAME_REGEX_INDEX]=1
            else
                __T_CA[VALUE_DISPLAY_NAME_REGEX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX]}"
                __T_CA[VALUE_DISPLAY_NAME_REGEX_INDEX]=1
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX_INDEX]+x} ]]; then
                true
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX_INDEX]}x" == "x" ]]; then
                true
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX_INDEX]}" =~ ${__T_REGEX_TEXT_NUMBER} ]]; then
                __T_CA[VALUE_DISPLAY_NAME_REGEX_INDEX]=${__P_FORMAT[${__T_CNAME}_DATA_VALUE_DISPLAY_NAME_REGEX_INDEX]}
            else
                true
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_FORMULA]+x} ]]; then
                __T_CA[VALUE_REGEX]='^(.*)$'
                __T_CA[VALUE_REGEX_MATCH]=1
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_FORMULA]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX]='^(.*)$'
                __T_CA[VALUE_REGEX_MATCH]=1
            else
                __T_CA[VALUE_REGEX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_FORMULA]}"
                __T_CA[VALUE_REGEX_MATCH]=1
                if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH]+x} ]]; then
                    true
                elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH]}x" == "x" ]]; then
                    true
                elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH]}" =~ ${__T_REGEX_TEXT_NUMBER} ]]; then
                    __T_CA[VALUE_REGEX_MATCH]=${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH]}
                fi
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX]+x} ]]; then
                __T_CA[VALUE_REGEX_MATCH_PREFIX]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_MATCH_PREFIX]=""
            else
                __T_CA[VALUE_REGEX_MATCH_PREFIX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX]+x} ]]; then
                __T_CA[VALUE_REGEX_MATCH_SUFFIX]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_MATCH_SUFFIX]=""
            else
                __T_CA[VALUE_REGEX_MATCH_SUFFIX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX]}"
            fi
            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX_ARRAY]+x} ]]; then
                __T_CA[VALUE_REGEX_MATCH_PREFIX_ARRAY]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX_ARRAY]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_MATCH_PREFIX_ARRAY]=""
            else
                __T_CA[VALUE_REGEX_MATCH_PREFIX_ARRAY]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_PREFIX_ARRAY]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX_ARRAY]+x} ]]; then
                __T_CA[VALUE_REGEX_MATCH_SUFFIX_ARRAY]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX_ARRAY]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_MATCH_SUFFIX_ARRAY]=""
            else
                __T_CA[VALUE_REGEX_MATCH_SUFFIX_ARRAY]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_MATCH_SUFFIX_ARRAY]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_PREFIX]+x} ]]; then
                __T_CA[VALUE_REGEX_NOMATCH_PREFIX]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_PREFIX]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_NOMATCH_PREFIX]=""
            else
                __T_CA[VALUE_REGEX_NOMATCH_PREFIX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_PREFIX]}"
            fi

            if [[ -z ${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_SUFFIX]+x} ]]; then
                __T_CA[VALUE_REGEX_NOMATCH_SUFFIX]=""
            elif [[ "${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_SUFFIX]}x" == "x" ]]; then
                __T_CA[VALUE_REGEX_NOMATCH_SUFFIX]=""
            else
                __T_CA[VALUE_REGEX_NOMATCH_SUFFIX]="${__P_FORMAT[${__T_CNAME}_DATA_VALUE_REGEX_NOMATCH_SUFFIX]}"
            fi

        fi
    done

    for __T_COLUMN_ARRAYNAME in "${__T_COLUMNS[@]}"; do
        if __print_table_column_prepare "${!__P_CONTENT}" "${__T_COLUMN_ARRAYNAME}" "${!__T_ROWNAMES}"; then
            true
        else
            #echo "Problem preparing the columns..."
            return 101
        fi
    done

    if [[ ${#__T_ROWNAMES[@]} -gt 0 ]]; then
        IFS=$'\n' __T_ROWNAMES=($(sort -u <<<"${__T_ROWNAMES[*]}"))
        unset IFS
    else
        #echo "No row names returned. This is odd."
        return 102
    fi
    __print_table_print "\n\n"
    if __print_table_rows_print "${!__P_CONTENT}" "${!__T_COLUMNS}" "${!__T_ROWNAMES}"; then
        __print_table_print "\n\n"
        return 0
    else
        __T_ERROR=$?
        __print_table_print "\n\n"
        return ${__T_ERROR}
    fi
    
}
#####
#
# - __print_table_column_prepare
#
# Takes the associative arrays of data and format and prepares/calculates the columns.
#
# Returns 0 on success
# Reeturns > 0 on failure
#
function __print_table_column_prepare() {

    declare __T_REGEX_ARRAY_ASSOCIATIVE='^declare -[^\ ]*A[^\ ]*\ .*$'
    declare __T_REGEX_ARRAY='^declare -[^\ ]*a[^\ ]*\ .*$'
    declare __T_REGEX_TEXT_NUMBER='^[0-9]+$'
    declare __T_REGEX_TEXT_VARNAME_VALID='^[a-zA-Z0-9_]+$'
    declare __T_RESULT=""
    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __T_RESULT="$(declare -p "${@:1:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_CONTENT="${@:1:1}"
        else
            return 3
        fi
    else
        return 4
    fi
    unset __T_RESULT

    declare __T_RESULT=""
    if [[ "${@:2:1}x" == "x" ]]; then
        return 5
    elif __T_RESULT="$(declare -p "${@:2:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_FORMAT="${@:2:1}"
        else
            return 6
        fi
    else
        return 7
    fi
    unset __T_RESULT

    declare __T_RESULT=""

    if [[ "${@:3:1}x" == "x" ]]; then
        declare -a __P_ROWNAMES=()
    elif __T_RESULT="$(declare -p "${@:3:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY} ]]; then
            declare -n __P_ROWNAMES="${@:3:1}"
        else
            declare -a __P_ROWNAMES=()
        fi
    fi

    if [[ -z ${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX_ARRAY]+x} ]]; then
        declare -A __T_VRMPA=()
    elif [[ "${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX_ARRAY]}x" == "x" ]]; then
        declare -A __T_VRMPA=()
    else
        if __T_RES="$(declare -p "${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX_ARRAY]}" 2>/dev/null)"; then
            if [[ "${__T_RES}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
                declare -n __T_VRMPA="${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX_ARRAY]}"
            else
                declare -A __T_VRMPA=()
            fi
        fi
    fi

    if [[ -z ${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX_ARRAY]+x} ]]; then
        declare -A __T_VRMSA=()
    elif [[ "${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}x" == "x" ]]; then
        declare -A __T_VRMSA=()
    else
        if __T_RES="$(declare -p "${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}" 2>/dev/null)"; then
            if [[ "${__T_RES}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
                declare -n __T_VRMSA="${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}"
            else
                declare -A __T_VRMSA=()
            fi
        fi
    fi

    declare -i __T_WIDTH=${#__P_FORMAT[HEADER_TEXT]}
    for __T_NAME in "${!__P_CONTENT[@]}"; do
        if [[ "${__T_NAME}" =~ ${__P_FORMAT[NAME_REGEX]} ]]; then
            declare -i __T_BASH_REMATCH_INDEX=${__P_FORMAT[NAME_REGEX_MATCH]}
            if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                if [[ -z ${BASH_REMATCH[1]+x} ]]; then
                    # echo "Houston we have a problem..."
                    exit 193
                else
                    declare __T_BASH_REMATCH="${BASH_REMATCH[1]}"
                fi
            else
                declare __T_BASH_REMATCH="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
            fi
            __P_ROWNAMES+=("${__T_BASH_REMATCH}")
            if [[ "${__P_FORMAT[VALUE_DISPLAY_NAME]}x" == "x" ]]; then
                if [[ "${__P_CONTENT[${__T_NAME}]}x" == "x" ]]; then
                    continue
                else
                    declare __T_TESTCONTENT_VALUE="${__P_CONTENT[${__T_NAME}]}"
                fi
            else
                declare __T_TESTCONTENT_NAME="${__T_BASH_REMATCH}"
            fi
            unset __T_BASH_REMATCH
            unset __T_BASH_REMATCH_INDEX

            if [[ -z ${__T_TESTCONTENT_VALUE+x} ]] && [[ -z ${__T_TESTCONTENT_NAME+x} ]]; then
                # echo "HOUSTON?HOUSTON!!"
                exit 200
            fi
            if [[ -n ${__T_TESTCONTENT_VALUE+x} ]]; then
                if [[ "${__T_TESTCONTENT_VALUE}x" == "x" ]]; then
                    declare __T_TESTCONENT=""
                elif [[ "${__T_TESTCONTENT_VALUE}" =~ ${__P_FORMAT[VALUE_REGEX]} ]]; then
                    declare -i __T_BASH_REMATCH_INDEX=${__P_FORMAT[VALUE_REGEX_MATCH]}
                    if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                        if [[ -z ${BASH_REMATCH[1]} ]]; then
                            # echo "NONONONONO"
                            return 201
                        else
                            declare __T_BASH_REMATCH="${BASH_REMATCH[1]}"
                        fi
                    else
                        declare __T_BASH_REMATCH="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                    fi
                    if [[ "${__T_BASH_REMATCH}" =~ ${__T_REGEX_TEXT_VARNAME_VALID} ]]; then
                        if [[ -z ${__T_VRMPA[${__T_BASH_REMATCH}]+x} ]]; then
                            declare __T_TESTCONTENT="${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX]}"
                        else
                            declare __T_TESTCONTENT="${__T_VRMPA[${__T_BASH_REMATCH}]}"
                        fi
                        __T_TESTCONTENT="${__T_TESTCONTENT}${__T_BASH_REMATCH}"
                        if [[ -z ${__T_VRMSA[${__T_BASH_REMATCH}]+x} ]]; then
                            __T_TESTCONTENT="${__T_TESTCONTENT}${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX]}"
                        else
                            __T_TESTCONTENT="${__T_TESTCONTENT}${__T_VRMSA[${__T_BASH_REMATCH}]}"
                        fi
                    else
                        declare __T_TESTCONTENT="${__P_FORMAT[VALUE_REGEX_MATCH_PREFIX]}${__T_BASH_REMATCH}${__P_FORMAT[VALUE_REGEX_MATCH_SUFFIX]}"
                    fi
                else
                    declare __T_TESTCONTENT="${__P_FORMAT[VALUE_REGEX_NOMATCH_PREFIX]}${__T_TESTCONTENT_VALUE}${__P_FORMAT[VALUE_REGEX_NOMATCH_SUFFIX]}"
                fi
                unset __T_TESTCONTENT_VALUE
            fi
            if [[ -n ${__T_TESTCONTENT_NAME+x} ]]; then
                if [[ "${__T_TESTCONTENT_NAME}" =~ ${__P_FORMAT[VALUE_DISPLAY_NAME_REGEX]} ]]; then
                    unset __T_BASH_REMATCH_INDEX
                    declare __T_BASH_REMATCH_INDEX="${__P_FORMAT[VALUE_DISPLAY_NAME_REGEX_INDEX]}"
                    if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                        if [[ -z ${BASH_REMATCH[1]+x} ]]; then
                            return 234
                        else
                            declare __T_TESTCONTENT="${BASH_REMATCH[1]}"
                        fi
                    else
                        declare __T_TESTCONTENT="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                    fi
                else
                    declare __T_TESTCONTENT="${__T_TESTCONTENT_NAME}"
                fi
            fi
            unset __T_TESTCONTENT_NAME
            declare __T_TESTCONTENT_NOESCAPES=""
            if __T_TESTCONTENT_NOESCAPES="$(echo -e "${__T_TESTCONTENT}" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')"; then
                __T_TESTCONTENT="${__T_TESTCONTENT_NOESCAPES}"
            fi

            if [[ ${#__T_TESTCONTENT} -gt ${__T_WIDTH} ]]; then
                declare -i __T_WIDTH=${#__T_TESTCONTENT}
            fi
            if [[ "${__P_FORMAT[VALUE_CALCULATE_TOTAL]}x" != "x" ]]; then
                if [[ ${__T_TESTCONTENT} =~ ${__T_REGEX_TEXT_NUMBER} ]]; then
                    __P_FORMAT[VALUE_TOTAL]=$((${__P_FORMAT[VALUE_TOTAL]} + ${__T_TESTCONTENT}))
                fi
            fi
        fi
    done

    __P_FORMAT[MAX_WIDTH]=$((${__T_WIDTH} + 2))

    return 0
}
function __print_table_print() {
    echo -en "${@}" >&2
}
#####
#
# - __print_table_rows_print
#
# Takes the associative arrays of data and format and prints out the rows.
# It also formats the output.
#
# Returns 0 on success
# Returns 1 on failure
#
function __print_table_rows_print() {

    declare __PT_CONTENT="${@:1:1}"
    declare __PT_COLUMNS="${@:2:1}"
    declare __PT_ROWNAMES="${@:3:1}"
    declare __T_REGEX_ARRAY_ASSOCIATIVE='^declare -[^\ ]*A[^\ ]*\ .*$'
    declare __T_REGEX_ARRAY='^declare -[^\ ]*a[^\ ]*\ .*$'
    declare __T_PRINT_TOTAL=""

    for __PT_V in CONTENT COLUMNS ROWNAMES; do
        declare __PT_VN="__PT_${__PT_V}"
        if [[ "${!__PT_VN}x" == "x" ]]; then
            # echo "__PT_VN: ${!__PT_VN}"
            return 2
        elif __T_RESULT="$(declare -p "${!__PT_VN}" 2>/dev/null)"; then
            if [[ "${__PT_V}" == "ROWNAMES" ]]; then
                if [[ ${__T_RESULT} =~ ${__T_REGEX_ARRAY} ]]; then
                    declare __P_VN="__P_${__PT_V}"
                    declare -n "${__P_VN}=${!__PT_VN}"
                else
                    # echo "__PT_VN: ${!__PT_VN}"
                    return 7
                fi
            else
                if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
                    declare __P_VN="__P_${__PT_V}"
                    declare -n "${__P_VN}=${!__PT_VN}"
                else
                    # echo "__PT_VN: ${!__PT_VN}"
                    return 4
                fi
            fi
        fi
    done
    declare -a __T_COLUMNNUMBERS=()
    IFS=$'\n' __T_COLUMNNUMBERS=($(sort -n <<<"${!__P_COLUMNS[*]}"))
    unset IFS
    declare __T_HEADER_LINE=""
    for __T_COLUMNNUMBER in "${__T_COLUMNNUMBERS[@]}"; do
        declare -n __T_COLUMN="${__P_COLUMNS[${__T_COLUMNNUMBER}]}"
        if __print_table_column_print "${!__P_CONTENT}" "${!__T_COLUMN}" "__HEADER__"; then
            for __T_I in $(seq 1 ${__T_COLUMN[MAX_WIDTH]}); do
                __T_HEADER_LINE+="="
            done
            if [[ ${__T_COLUMNNUMBER} -ne ${__T_COLUMNNUMBERS[-1]} ]]; then
                __print_table_print "${__T_COLUMN[DELIMITER]}"
                __T_HEADER_LINE+="${__T_COLUMN[DELIMITER]}"
            fi
        fi

    done
    __print_table_print "\n${__T_HEADER_LINE}\n"
    unset __T_HEADER_LINE
    declare -a __T_ROWNAMES_SORTED=()
    IFS=$'\n' __T_ROWNAMES_SORTED=($(sort -d <<<"${__P_ROWNAMES[*]}"))
    unset IFS
    for __T_ROWNAME in "${__T_ROWNAMES_SORTED[@]}"; do
        for __T_COLUMNNUMBER in "${__T_COLUMNNUMBERS[@]}"; do
            unset -n __T_COLUMN
            declare -n __T_COLUMN="${__P_COLUMNS[${__T_COLUMNNUMBER}]}"
            for __T_CONTENTNAME in "${!__P_CONTENT[@]}"; do
                if [[ ${__T_CONTENTNAME} =~ ${__T_COLUMN[NAME_REGEX]} ]]; then
                    declare __T_BASH_REMATCH_INDEX=${__T_COLUMN[NAME_REGEX_MATCH]}
                    if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                        if [[ -z ${BASH_REMATCH[1]+x} ]]; then
                            #echo "WHERE THE FUCK I AM?"
                            return 199
                        else
                            declare __T_BASH_REMATCH="${BASH_REMATCH[1]}"
                        fi
                    else
                        declare __T_BASH_REMATCH="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                    fi
                    if [[ "${__T_BASH_REMATCH}" == "${__T_ROWNAME}" ]]; then
                        if __print_table_column_print "${!__P_CONTENT}" "${!__T_COLUMN}" "${__T_ROWNAME}" "${__T_CONTENTNAME}"; then
                            if [[ ${__T_COLUMNNUMBER} -ne ${__T_COLUMNNUMBERS[-1]} ]]; then
                                __print_table_print "${__T_COLUMN[DELIMITER]}"
                            fi
                        else
                            echo "PROBLEMS PRINTING ROW: '${__T_ROWNAME}' COLUMN: '${__T_COLUMN} (${!__T_COLUMN})'."
                        fi
                        continue 2
                    fi
                fi
            done
        done
        __print_table_print "\n"
    done

    for __T_COLUMNNUMBER in "${__T_COLUMNNUMBERS[@]}"; do
        declare -n __T_COLUMN="${__P_COLUMNS[${__T_COLUMNNUMBER}]}"
        if [[ "${__T_COLUMN[VALUE_CALCULATE_TOTAL]}x" != "x" ]]; then
            __T_PRINT_TOTAL=1
            break
        fi
    done

    if [[ "${__T_PRINT_TOTAL}x" != "x" ]]; then
        declare __T_TOTAL_LINE=""
        for __T_COLUMNNUMBER in "${__T_COLUMNNUMBERS[@]}"; do
            declare -n __T_COLUMN="${__P_COLUMNS[${__T_COLUMNNUMBER}]}"
            declare -i __T_CTR=0
            while [[ ${__T_CTR} -lt ${__T_COLUMN[MAX_WIDTH]} ]]; do
                __T_TOTAL_LINE+="="
                ((__T_CTR++)) || true
            done
            if [[ ${__T_COLUMNNUMBER} -ne ${__T_COLUMNNUMBERS[-1]} ]]; then
                __T_TOTAL_LINE+="${__T_COLUMN[DELIMITER]}"
            fi
        done
        __print_table_print "${__T_TOTAL_LINE}\n"
        for __T_COLUMNNUMBER in "${__T_COLUMNNUMBERS[@]}"; do
            declare -n __T_COLUMN="${__P_COLUMNS[${__T_COLUMNNUMBER}]}"
            if [[ ${__T_COLUMNNUMBER} -eq ${__T_COLUMNNUMBERS[0]} ]]; then
                declare __T_OLD_VALUE_TOTAL="${__T_COLUMN[VALUE_TOTAL]}"
                declare __T_OLD_VALUE_CALCULATE_TOTAL="${__T_COLUMN[VALUE_CALCULATE_TOTAL]}"
                __T_COLUMN[VALUE_TOTAL]="Total:"
                __T_COLUMN[VALUE_CALCULATE_TOTAL]=1
            fi
            if __print_table_column_print "${!__P_CONTENT}" "${!__T_COLUMN}" "__TOTAL__"; then
                if [[ ${__T_COLUMNNUMBER} -ne ${__T_COLUMNNUMBERS[-1]} ]]; then
                    __print_table_print "${__T_COLUMN[DELIMITER]}"
                fi
            fi

            if [[ ${__T_COLUMNNUMBER} -eq ${__T_COLUMNNUMBERS[0]} ]]; then
                __T_COLUMN[VALUE_TOTAL]="${__T_OLD_VALUE_TOTAL}"
                __T_COLUMN[VALUE_CALCULATE_TOTAL]="${__T_OLD_VALUE_CALCULATE_TOTAL}"
            fi
        done
    fi

}
#####
#
# - __print_table_column_print
#
# Takes the column information and prints it out with the help of the associative arrays for data and format.
#
# Returns 0 on success
# Returns > 0 on failure
#
function __print_table_column_print() {

    declare __T_REGEX_ARRAY_ASSOCIATIVE='^declare -[^\ ]*A[^\ ]*\ .*$'
    declare __T_REGEX_TEXT_VARNAME_VALID='^[a-zA-Z0-9_]+$'

    if [[ "${@:1:1}x" == "x" ]]; then
        return 2
    elif __T_RESULT="$(declare -p "${@:1:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_CONTENT="${@:1:1}"
        else
            return 3
        fi
    else
        return 4
    fi

    if [[ "${@:2:1}x" == "x" ]]; then
        return 5
    elif __T_RESULT="$(declare -p "${@:2:1}" 2>/dev/null)"; then
        if [[ "${__T_RESULT}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
            declare -n __P_COLUMN="${@:2:1}"
        else
            return 6
        fi
    else
        return 7
    fi

    if [[ "${@:3:1}x" == "x" ]]; then
        return 8
    else
        declare __P_ROWNAME="${@:3:1}"
    fi

    if [[ "${@:4:1}x" == "x" ]]; then
        declare __P_CONTENTNAME=""
    else
        declare __P_CONTENTNAME="${@:4:1}"
    fi
    if [[ -z ${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX_ARRAY]+x} ]]; then
        declare -A __T_VRMPA=()
    elif [[ "${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX_ARRAY]}x" == "x" ]]; then
        declare -A __T_VRMPA=()
    else
        if __T_RES="$(declare -p "${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX_ARRAY]}" 2>/dev/null)"; then
            if [[ "${__T_RES}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
                declare -n __T_VRMPA="${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX_ARRAY]}"
            else
                declare -A __T_VRMPA=()
            fi
        fi
    fi

    if [[ -z ${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX_ARRAY]+x} ]]; then
        declare -A __T_VRMSA=()
    elif [[ "${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}x" == "x" ]]; then
        declare -A __T_VRMSA=()
    else
        if __T_RES="$(declare -p "${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}" 2>/dev/null)"; then
            if [[ "${__T_RES}" =~ ${__T_REGEX_ARRAY_ASSOCIATIVE} ]]; then
                declare -n __T_VRMSA="${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX_ARRAY]}"
            else
                declare -A __T_VRMSA=()
            fi
        fi
    fi

    if [[ "${__P_CONTENTNAME}x" != "x" ]]; then
        if [[ -z ${__P_CONTENT[${__P_CONTENTNAME}]+x} ]]; then
            return 99
        else
            declare __T_VALUE="${__P_CONTENT[${__P_CONTENTNAME}]}"
            declare __T_ALIGN="${__P_COLUMN[ALIGN]}"

            if [[ "${__P_COLUMN[VALUE_DISPLAY_NAME]}x" == "x" ]]; then
                if [[ "${__T_VALUE}" =~ ${__P_COLUMN[VALUE_REGEX]} ]]; then
                    declare __T_BASH_REMATCH_INDEX=${__P_COLUMN[VALUE_REGEX_MATCH]}
                    if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                        declare __T_BASH_REMATCH="${BASH_REMATCH[0]}"
                    else
                        declare __T_BASH_REMATCH="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                    fi
                    if [[ "${__T_BASH_REMATCH}" =~ ${__T_REGEX_TEXT_VARNAME_VALID} ]]; then
                        if [[ -z ${__T_VRMPA[${__T_BASH_REMATCH}]+x} ]]; then
                            declare __T_VALUE_FINAL="${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX]}"
                        else
                            declare __T_VALUE_FINAL="${__T_VRMPA[${__T_BASH_REMATCH}]}"
                        fi
                        __T_VALUE_FINAL+="${__T_BASH_REMATCH}"
                        if [[ -z ${__T_VRMSA[${__T_BASH_REMATCH}]+x} ]]; then
                            __T_VALUE_FINAL+="${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX]}"
                        else
                            __T_VALUE_FINAL+="${__T_VRMSA[${__T_BASH_REMATCH}]}"
                        fi
                    else
                        declare __T_VALUE_FINAL="${__P_COLUMN[VALUE_REGEX_MATCH_PREFIX]}${__T_BASH_REMATCH}${__P_COLUMN[VALUE_REGEX_MATCH_SUFFIX]}"
                    fi
                else
                    declare __T_VALUE_FINAL="${__P_COLUMN[VALUE_REGEX_NOMATCH_PREFIX]}${__T_VALUE}${__P_COLUMN[VALUE_REGEX_NOMATCH_SUFFIX]}"
                fi
            else
                if [[ "${__P_ROWNAME}" =~ ${__P_COLUMN[VALUE_DISPLAY_NAME_REGEX]} ]]; then
                    declare __T_BASH_REMATCH_INDEX=${__P_COLUMN[VALUE_DISPLAY_NAME_REGEX_INDEX]}
                    if [[ -z ${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]+x} ]]; then
                        if [[ -z ${BASH_REMATCH[1]+x} ]]; then
                            return 235
                        else
                            declare __T_VALUE="${BASH_REMATCH[1]}"
                            declare __T_VALUE_FINAL="${BASH_REMATCH[1]}"
                        fi
                    else
                        declare __T_VALUE="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                        declare __T_VALUE_FINAL="${BASH_REMATCH[${__T_BASH_REMATCH_INDEX}]}"
                    fi
                else
                    declare __T_VALUE="${__P_ROWNAME}"
                    declare __T_VALUE_FINAL="${__P_ROWNAME}"
                fi
            fi
        fi
    else
        if [[ "${__P_ROWNAME}" == "__HEADER__" ]]; then
            declare __T_VALUE="${__P_COLUMN[HEADER_TEXT]}"
            declare __T_VALUE_FINAL="${__P_COLUMN[HEADER_TEXT]}"
            declare __T_ALIGN="${__P_COLUMN[HEADER_ALIGN]}"
        elif [[ "${__P_ROWNAME}" == "__TOTAL__" ]]; then
            if [[ "${__P_COLUMN[VALUE_CALCULATE_TOTAL]}x" != "x" ]]; then
                declare __T_VALUE="${__P_COLUMN[VALUE_TOTAL]}"
                declare __T_VALUE_FINAL="${__T_VALUE}"
                declare __T_ALIGN="${__P_COLUMN[ALIGN]}"
            else
                declare __T_VALUE=""
                declare __T_VALUE_FINAL="${__T_VALUE}"
                declare __T_ALIGN="${__P_COLUMN[ALIGN]}"
            fi
        else
            return 123
        fi
    fi
    declare __T_WIDTH_MAX="${__P_COLUMN[MAX_WIDTH]}"
    declare __T_DELIMITER="${__P_COLUMN[DELIMITER]}"
    declare __T_VALUE_NOESCAPES=""
    if __T_VALUE_NOESCAPES="$(echo -e "${__T_VALUE_FINAL}" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')"; then
        true
    else
        __T_VALUE_NOESCAPES="${__T_VALUE_FINAL}"
    fi
    declare __T_WIDTH_MAXWO=$((${__T_WIDTH_MAX} - ${#__T_VALUE_NOESCAPES}))
    if [[ "${__T_ALIGN}" == "l" ]]; then
        declare __T_WIDTH_LEFT=1
        declare __T_WIDTH_RIGHT=$((${__T_WIDTH_MAXWO} - ${__T_WIDTH_LEFT}))
    elif [[ "${__T_ALIGN}" == "r" ]]; then
        declare __T_WIDTH_RIGHT=1
        declare __T_WIDTH_LEFT=$((${__T_WIDTH_MAXWO} - ${__T_WIDTH_RIGHT}))
    elif [[ "${__T_ALIGN}" == "c" ]]; then
        declare __T_WIDTH_LEFT=$((${__T_WIDTH_MAXWO} / 2))
        declare __T_WIDTH_RIGHT=$((${__T_WIDTH_MAXWO} - ${__T_WIDTH_LEFT}))
    elif [[ "${__T_ALIGN}" == "cr" ]]; then
        declare __T_WIDTH_RIGHT=$((${__T_WIDTH_MAXWO} / 2))
        declare __T_WIDTH_LEFT=$((${__T_WIDTH_MAXWO} - ${__T_WIDTH_RIGHT}))
    fi

    declare -i __SPACER=${__T_WIDTH_LEFT}

    while [[ ${__SPACER} -gt 0 ]]; do
        __print_table_print " "
        ((__SPACER--))
    done
    __print_table_print "${__T_VALUE_FINAL}"
    declare -i __SPACER=${__T_WIDTH_RIGHT}
    while [[ ${__SPACER} -gt 0 ]]; do
        __print_table_print " "
        ((__SPACER--))
    done
    return 0

}
