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
# 1
#
if ! (return 0 2>/dev/null); then
	echo "THIS IS A LIBRARY FILE AND SHOULD NOT BE CALLED DIRECTLY. '($(realpath "${0}"))'"
	exit 254
fi

set -o nounset
function __isenabled_cs_listen() {
	shopt -s nocasematch

	declare __FWS_LISTEN_HOST=""
	declare __FWS_LISTEN_HOST_REGEX='^.*$'
	declare -i __FWS_LISTEN_PORT=-1
	declare __FWS_LISTEN_PORT_REGEX='^[0-9]{1,5}$'
	declare -i __FWS_LISTEN_PORT_MIN=1024
	declare __FWS_LISTEN_PORT_MIN_REGEX='^[0-9]{1,5}$'
	declare -i __FWS_LISTEN_PORT_MAX=65536
	declare __FWS_LISTEN_PORT_MAX_REGEX='^[0-9]{1,5}$'
	declare __FWS_LISTEN_SOCKET=""
	declare __FWS_LISTEN_SOCKET_REGEX='^.*$'
	declare __FWS_LISTEN_SOCKET_GROUP=""
	declare __FWS_LISTEN_SOCKET_GROUP_REGEX='^([0-9]+|[a-z][-a-z0-9_]*)$'
	declare __FWS_LISTEN_SOCKET_MODE=""
	declare __FWS_LISTEN_SOCKET_MODE_REGEX='^[0-7]{3,4}$'
	declare __FWS_LISTEN_SOCKET_OWNER=""
	declare __FWS_LISTEN_SOCKET_OWNER_REGEX='^([0-9]+|[a-z][-a-z0-9_]*)$'

	for __T_PREFIX in __D_C; do
		for __T_SUFFIX in LISTEN_PORT_REGEX LISTEN_PORT_MIN_REGEX LISTEN_PORT_MAX_REGEX LISTEN_SOCKET_GROUP_REGEX LISTEN_SOCKET_MODE_REGEX LISTEN_SOCKET_OWNER_REGEX; do
			unset __T_SRC_VARNAME __T_DEST_VARNAME
			declare __T_SRC_VARNAME="${__T_PREFIX}_${__T_SUFFIX}"
			declare __T_DEST_VARNAME="__FWS_${__T_SUFFIX}"

			if [[ -z ${!__T_SRC_VARNAME+x} ]]; then
				continue
			elif [[ "${!__T_SRC_VARNAME}x" == "x" ]]; then
				continue
			else
				declare "${__T_DEST_VARNAME}="${!__T_SRC_VARNAME}""
			fi
		done
	done

	for __T_PREFIX in __D_C; do
		for __T_SUFFIX in LISTEN_PORT LISTEN_PORT_MIN LISTEN_PORT_MAX; do
			unset __T_SRC_VAR __T_DST_VAR __T_REGEX_VAR
			declare __T_SRC_VAR="${__T_PREFIX}_${__T_SUFFIX}"
			declare __T_DST_VAR="__FWS_${__T_SUFFIX}"
			declare __T_REGEX_VAR="__FWS_${__T_SUFFIX}_REGEX"

			if [[ -z ${!__T_SRC_VAR+x} ]]; then
				continue
			elif [[ "${!__T_SRC_VAR}x" == "x" ]]; then
				continue
			elif [[ "${!__T_SRC_VAR}" =~ ${!__T_REGEX_VAR} ]]; then
				declare -i "${__T_DST_VAR}=${!__T_SRC_VAR}"
			else
				continue
			fi
		done

		unset __T_SRC_VAR __T_DST_VAR __T_REGEX_VAR

		declare __T_SRC_VAR="${__T_PREFIX}_LISTEN_PORT"
		declare __T_DST_VAR="__FWS_LISTEN_PORT"

		if [[ -z ${!__T_SRC_VAR+x} ]]; then
			true
		elif [[ "${!__T_SRC_VAR}x" == "x" ]]; then
			declare -i "${__T_DST_VAR}=-1"
		fi

		unset __T_SRC_VAR __T_DST_VAR __T_REGEX_VAR

	done

	for __T_PREFIX in __D_C_LISTEN; do
		for __T_SUFFIX in HOST SOCKET SOCKET_GROUP SOCKET_MODE SOCKET_OWNER; do
			unset __T_SRC_VAR __T_DST_VAR __T_REGEX_VAR
			declare __T_SRC_VAR="${__T_PREFIX}_${__T_SUFFIX}"
			declare __T_DST_VAR="__FWS_LISTEN_${__T_SUFFIX}"
			declare __T_REGEX_VAR="__FWS_LISTEN_${__T_SUFFIX}_REGEX"
			if [[ -z ${!__T_SRC_VAR+x} ]]; then
				continue
			elif [[ "${!__T_SRC_VAR}x" == "x" ]]; then
				continue
			elif [[ "${!__T_SRC_VAR}" =~ ${!__T_REGEX_VAR} ]]; then
				declare "${__T_DST_VAR}="${!__T_SRC_VAR}""
				continue
			fi
		done
		unset __T_SRC_VAR __T_DST_VAR __T_REGEX_VAR
	done

	if [[ ${__FWS_LISTEN_PORT_MIN} -gt ${__FWS_LISTEN_PORT_MAX} ]]; then
		__FWS_LISTEN_PORT_MIN=${__FWS_LISTEN_PORT_MAX}
	elif [[ ${__FWS_LISTEN_PORT_MAX} -lt ${__FWS_LISTEN_PORT_MIN} ]]; then
		__FWS_LISTEN_PORT_MAX=${__FWS_LISTEN_PORT_MIN}
	fi

	if ([[ ${__FWS_LISTEN_PORT} -lt ${__FWS_LISTEN_PORT_MIN} ]] || [[ ${__FWS_LISTEN_PORT} -gt ${__FWS_LISTEN_PORT_MAX} ]]) &&
		[[ ${__FWS_LISTEN_PORT} != -1 ]]; then
		__FWS_LISTEN_PORT=$(((${__FWS_LISTEN_PORT_MIN} + ${__FWS_LISTEN_PORT_MAX}) / 2))
	fi

	if [[ ${__FWS_LISTEN_PORT} == -1 ]]; then
		__SETTINGS[CS_LISTEN_PORT]=""
	else
		__SETTINGS[CS_LISTEN_PORT]="${__FWS_LISTEN_PORT}"
	fi
	__SETTINGS[CS_LISTEN_HOST]="${__FWS_LISTEN_HOST}"
	__SETTINGS[CS_LISTEN_SOCKET]="${__FWS_LISTEN_SOCKET}"
	__SETTINGS[CS_LISTEN_SOCKET_MODE]="${__FWS_LISTEN_SOCKET_MODE}"
	__SETTINGS[CS_LISTEN_SOCKET_OWNER]="${__FWS_LISTEN_SOCKET_OWNER}"
	__SETTINGS[CS_LISTEN_SOCKET_GROUP]="${__FWS_LISTEN_SOCKET_GROUP}"

	__log i -- "(CS_LISTEN) Configuring integrated webserver socket type...\n"

	if __test_variable_exists CS_LISTEN_SOCKET; then
		if __test_variable_empty CS_LISTEN_SOCKET; then
			true
		else
			__SETTINGS[CS_LISTEN_SOCKET]="${CS_LISTEN_SOCKET}"

			if [[ -z ${CS_LISTEN_SOCKET_MODE+x} ]]; then
				true
			elif [[ "${CS_LISTEN_SOCKET_MODE}" =~ ${__FWS_LISTEN_SOCKET_MODE_REGEX} ]]; then
				__SETTINGS[CS_LISTEN_SOCKET_MODE]="${CS_LISTEN_SOCKET_MODE}"
			else
				true
			fi

			if [[ -z ${CS_LISTEN_SOCKET_OWNER+x} ]]; then
				true
			elif [[ "${CS_LISTEN_SOCKET_OWNER}x" == "x" ]]; then
				true
			elif [[ "${CS_LISTEN_SOCKET_OWNER}" =~ ${__FWS_LISTEN_SOCKET_OWNER_REGEX} ]]; then
				__SETTINGS[CS_LISTEN_SOCKET_OWNER]="${CS_LISTEN_SOCKET_OWNER}"
			else
				true
			fi

			if [[ -z ${CS_LISTEN_SOCKET_GROUP+x} ]]; then
				true
			elif [[ "${CS_LISTEN_SOCKET_GROUP}x" == "x" ]]; then
				true
			elif [[ "${CS_LISTEN_SOCKET_GROUP}" =~ ${__FWS_LISTEN_SOCKET_GROUP_REGEX} ]]; then
				__SETTINGS[CS_LISTEN_SOCKET_GROUP]="${CS_LISTEN_SOCKET_GROUP}"
			else
				true
			fi

			__SETTINGS[CS_LISTEN_HOST]=""
			__SETTINGS[CS_LISTEN_PORT]=""
			__log i -- "(CS_LISTEN) Unix socket provided. Using unix socket only at '${__SETTINGS[CS_LISTEN_SOCKET]}'.\n"
			return 0
		fi
	fi

	if __test_variable_exists CS_LISTEN_PORT; then
		if __test_variable_empty CS_LISTEN_PORT; then
			true
		elif [[ "${CS_LISTEN_PORT}" =~ ${__FWS_LISTEN_PORT_REGEX} ]]; then
			declare -i __T_PORT=${CS_LISTEN_PORT}
			if [[ ${__T_PORT} -ge ${__FWS_LISTEN_PORT_MIN} ]]; then
				if [[ ${__T_PORT} -le ${__FWS_LISTEN_PORT_MAX} ]]; then
					__SETTINGS[CS_LISTEN_PORT]=${__T_PORT}
					unset __T_PORT
				else
					__log w -- "(CS_LISTEN) Port provided too big: '${__T_PORT}' (MAX: '${__FWS_LISTEN_PORT_MAX}').\n"
					if [[ ${__FWS_LISTEN_PORT} == -1 ]]; then
						__log w -- "(CS_LISTEN) Setting no default port, using the service's own default.\n"
					else
						__log w -- "(CS_LISTEN) Reverting to default: '${__SETTINGS[CS_LISTEN_PORT]}'.\n"
					fi
				fi
			else
				__log w -- "(CS_LISTEN) Port provided too small: '${CS_LISTEN_PORT}' ('${__FWS_LISTEN_PORT_MIN}').\n"
				if [[ ${__FWS_LISTEN_PORT} == -1 ]]; then
					__log w -- "(CS_LISTEN) Setting no default port, using the service's own default.\n"
				else
					__log w -- "(CS_LISTEN) Reverting to default: '${__SETTINGS[CS_LISTEN_PORT]}'.\n"
				fi
			fi
		else
			__log w -- "(CS_LISTEN) Port provided not a number: '${CS_LISTEN_PORT}'.\n"
			if [[ ${__FWS_LISTEN_PORT} == -1 ]]; then
				__log w -- "(CS_LISTEN) Setting no default port, using the service's own default.\n"
			else
				__log w -- "(CS_LISTEN) Reverting back to default: '${__SETTINGS[CS_LISTEN_PORT]}'.\n"
			fi
		fi
	fi

	if __test_variable_exists CS_LISTEN_HOST; then
		if __test_variable_empty CS_LISTEN_HOST; then
			true
		else
			__SETTINGS[CS_LISTEN_HOST]="${CS_LISTEN_HOST}"
		fi
	fi

	declare __T_LOG_MESSAGE="(CS_LISTEN) Running on host:"
	if [[ "${__SETTINGS[CS_LISTEN_HOST]}x" == "x" ]]; then
		__T_LOG_MESSAGE+=" '<application default>'"
	else
		__T_LOG_MESSAGE+=" '${__SETTINGS[CS_LISTEN_HOST]}'"
	fi

	__T_LOG_MESSAGE+=" at port:"
	if [[ "${__SETTINGS[CS_LISTEN_PORT]}x" == "x" ]]; then
		__T_LOG_MESSAGE+=" '<application default>'"
	else
		__T_LOG_MESSAGE+=" '${__SETTINGS[CS_LISTEN_PORT]}'"
	fi
	__T_LOG_MESSAGE+=".\n"

	__log i -- "${__T_LOG_MESSAGE}"
	return 0

}

__init_function_register_always 150 __isenabled_cs_listen

function __psp_cs_listen() {

	if [[ -z ${__SETTINGS[CS_LISTEN_SOCKET]+x} ]]; then
		__init_results_add "CS_LISTEN_SOCKET" "Disabled"
		true
	elif [[ "${__SETTINGS[CS_LISTEN_SOCKET]}x" == "x" ]]; then
		__init_results_add "CS_LISTEN_SOCKET" "Disabled"
		true
	else
		__START_PARAMETERS+=("--socket" "${__SETTINGS[CS_LISTEN_SOCKET]}")
		if [[ -e "${__SETTINGS[CS_LISTEN_SOCKET]}" ]]; then
			rm -rf "${__SETTINGS[CS_LISTEN_SOCKET]}"
		fi

		if [[ -f /.socket.opts.sh ]]; then
			rm -f /.sockets.opts.sh
		fi
		for __T_KEY in SOCKET SOCKET_GROUP SOCKET_MODE SOCKET_OWNER; do
			declare __T_VNAME="CS_LISTEN_${__T_KEY}"
			if [[ -z ${__SETTINGS[${__T_VNAME}]+x} ]]; then
				continue
			elif [[ "${__SETTINGS[${__T_VNAME}]}x" == "x" ]]; then
				continue
			else
				declare "__SCRIPT_${__T_KEY}="${__SETTINGS[${__T_VNAME}]}""
				declare -p "__SCRIPT_${__T_KEY}" >>/.socket.opts.sh
				unset "__SCRIPT_${__T_KEY}"
			fi
			unset __T_VNAME
		done

		if [[ -f /.socket.opts.sh ]]; then
			cat >/.socket.sh <<'EOF'
#!/usr/bin/env bash
set -o nounset
declare -i __SCRIPT_CTR=1
declare -i __SCRIPT_CTR_MAX=100
declare __SCRIPT_SOCKET=""
declare __SCRIPT_SOCKET_MODE=""
declare __SCRIPT_SOCKET_OWNER=""
declare __SCRIPT_SOCKET_GROUP=""
declare __SCRIPT_NAME="${0}"
declare __SCRIPT_OPTS_NAME="/.socket.opts.sh"

function __exit() {
	if [[ -f "${__SCRIPT_NAME}" ]]; then
		rm "${__SCRIPT_NAME}"
	fi
	if [[ -f "${__SCRIPT_OPTS_NAME}" ]]; then
		rm -f "${__SCRIPT_OPTS_NAME}"
	fi
}

# trap __exit EXIT

if [[ -f "${__SCRIPT_OPTS_NAME}" ]]; then
	if source "${__SCRIPT_OPTS_NAME}"; then
		true
	else
		exit 253
	fi
fi


if [[ ${__SCRIPT_CTR_MAX} -le ${__SCRIPT_CTR} ]]; then
	exit 0
fi


while [[ ${__SCRIPT_CTR} -lt ${__SCRIPT_CTR_MAX} ]]; do
	if [[ "${__SCRIPT_SOCKET}x" == "x" ]]; then
		exit 249
	fi
	if [[ -S "${__SCRIPT_SOCKET}" ]]; then
		if [[ "${__SCRIPT_SOCKET_MODE}x" != "x" ]]; then
			chmod "${__SCRIPT_SOCKET_MODE}" "${__SCRIPT_SOCKET}"
		fi
		declare __SCRIPT_SOCKET_OG=""
		if [[ "${__SCRIPT_SOCKET_OWNER}x" != "x" ]]; then
			chown "${__SCRIPT_SOCKET_OWNER}" "${__SCRIPT_SOCKET}"
		fi
		if [[ "${__SCRIPT_SOCKET_GROUP}x" != "x" ]]; then
			chgrp "${__SCRIPT_SOCKET_GROUP}" "${__SCRIPT_SOCKET}"
		fi
		exit 0
	fi
	((__SCRIPT_CTR++)) || true
	sleep 1
done
exit 123
EOF
			chmod +x /.socket.sh
			__START_SCRIPTS+=("/.socket.sh")
			__init_results_add "CS_LISTEN_SOCKET" "${__SETTINGS[CS_LISTEN_SOCKET]}"
		fi
		return 0
	fi

	if __init_codeserver_startup_options_available "host" && __init_codeserver_startup_options_available "port"; then
		if [[ -z ${__SETTINGS[CS_LISTEN_HOST]+x} ]]; then
			__init_results_add "CS_LISTEN_HOST" "Disabled"
			true
		elif [[ "${__SETTINGS[CS_LISTEN_HOST]}x" == "x" ]]; then
			__init_results_add "CS_LISTEN_HOST" "Disabled"
			true
		else
			__init_results_add "CS_LISTEN_HOST" "${__SETTINGS[CS_LISTEN_HOST]}"
			__START_PARAMETERS+=("--host" "${__SETTINGS[CS_LISTEN_HOST]}")
		fi

		if [[ -z ${__SETTINGS[CS_LISTEN_PORT]+x} ]]; then
			__init_results_add "CS_LISTEN_PORT" "Disabled"
		elif [[ "${__SETTINGS[CS_LISTEN_PORT]}x" == "x" ]]; then
			true__init_results_add "CS_LISTEN_PORT" "Disabled"
		else
			true__init_results_add "CS_LISTEN_PORT" "${__SETTINGS[CS_LISTEN_PORT]}"
			__START_PARAMETERS+=("--port" "${__SETTINGS[CS_LISTEN_PORT]}")
		fi
		return 0
	elif __init_codeserver_startup_options_available "bind-addr"; then
		declare __T_BIND_ADDR=""
		if [[ -z ${__SETTINGS[CS_LISTEN_HOST]+x} ]]; then
			__T_BIND_ADDR+="0.0.0.0"
		elif [[ "${__SETTINGS[CS_LISTEN_HOST]}x" == "x" ]]; then
			__T_BIND_ADDR+="0.0.0.0"
		else
			__T_BIND_ADDR+="${__SETTINGS[CS_LISTEN_HOST]}"
		fi

		if [[ -z ${__SETTINGS[CS_LISTEN_PORT]+x} ]]; then
			__T_BIND_ADDR+=":8080"
		elif [[ "${__SETTINGS[CS_LISTEN_PORT]}x" == "x" ]]; then
			__T_BIND_ADDR+=":8080"
		else
			__T_BIND_ADDR+=":${__SETTINGS[CS_LISTEN_PORT]}"
		fi
		__init_results_add "CS_BIND_ADDR" "${__T_BIND_ADDR}"
		__START_PARAMETERS+=("--bind-addr" "${__T_BIND_ADDR}")
		unset __T_BIND_ADDR
		return 0
	fi
	return 254

}

__init_function_register_always 1800 __psp_cs_listen
