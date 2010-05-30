#!/bin/bash

function log {
	[ "$VERBOSE" ] && echo $*
}

function error {
	echo $* 1>&2
	[ "$TOLERANT" ] || exit 1
}

function die {
	error $*
	exit 1
}

function load_protocol {
	[ -n "$1" ] || error "Protocol must be specified";
	local protocol=$1
	[ -f "$BACKUP_EXECUTABLE_DIR/protocols/$protocol" ] || error "Unrecognized protocol: $protocol";
	source $BACKUP_EXECUTABLE_DIR/protocols/$protocol || error "Protocol failed to load: $protocol"
	log "Loaded protocol: $protocol"
}

function load_target {
	local name=$1
	local data=`grep "^$name" "$TARGETS"`
	[ -n "$data" ] || error "Target does not exist: $name" 
	set - $data
	shift
	load_protocol $1
	shift
	protocol_load_settings $* || error "Settings for target '$name' failed to load";
	[ "$DRY_RUN" ] && load_protocol dry
}

function check_and_lock {
	[ -e "$SETTINGS" ] || die "SETTINGS must be set"
	if [ "$SESSION" ]; then
		# Already locked, so continue
		return 0;
	fi
	if [ -e "$SESSION/lock" ]; then
		local lock=$(<$SESSION/lock)
		TOLERANT=true
		case "$lock" in
			[[:digit:]]*)
				local cmd=$(ps --no-headers p $lock -o cmd)
				if [ "$cmd" ]; then
					error "Backup is locked by a currently running process - PID: $lock, name: '$cmd'"
				else
					error "Backup is locked, but the lock owner is no longer running."
				fi
				;;
			*)
				error "Backup appears to be explicitly locked."
				;;
		esac
		die "Delete $SESSION/lock to unlock."
	fi
	export SESSION=$SETTINGS/session
	mkdir -p $SESSION || die "Could not create session"
	trap "rm -rf '$SESSION'" EXIT
	echo $$ >$SESSION/lock
	export DRY_RUN VERBOSE ROOT SESSION
}
