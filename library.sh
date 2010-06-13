#!/bin/bash

if [ ! "$TMP" ]; then
	TMP=/tmp/backup.$$
	mkdir $TMP || exit 1
	trap 'rm -rf $TMP' EXIT
fi

function protocol_default_push {
	local args=""
	[ "$DRY_RUN" ] && args="$args --dry-run"
	[ "$DEBUG_LEVEL" -gt 1 ] && args="$args --verbose"
	[ "$DEBUG_LEVEL" -gt 0 ] && args="$args --porcelain"
	[ "$DEBUG_LEVEL" -lt 0 ] && args="$args --quiet"
	git push $* $args >$TMP/push 2>&1  
	local R=$?
	if [ $R != 0 ]; then
		cat $TMP/push | sed -e "s/^/$PROJECT: /g" 1>&2
	elif [ $DEBUG_LEVEL -gt 0 ]; then
		cat $TMP/push | sed -e "s/^/$PROJECT: /g"
	elif [ $DEBUG_LEVEL -eq 0 ]; then
		if [ `wc -l $TMP/push | cut -f1 -d' '` -gt 1 ]; then
			cat $TMP/push | sed -e "s/^/$PROJECT: /g"
		fi
	fi
	return $R
}

function protocol_load_global_args {
	while [ "$1" ]; do
		case "$1" in
			-windows) debug "'$TARGET_NAME' is a windows location"; WINDOWS=true ;;
		esac
		shift
	done
}

function log_at_level {
	if [ -n "$DEBUG_LEVEL" ] && [ "$DEBUG_LEVEL" -ge "$1" ]; then
		local level=$1
		shift
		if [ "$#" = 0 ]; then
			while read l; do
				log_at_level $level $l
			done
		else
			if [ "$PROJECT" ]; then
				echo "$PROJECT: $*"
			else
				echo "$*"
			fi
		fi
	fi
}

function debug {
	log_at_level 2 $*
}

function log {
	log_at_level 1 $*
}

function print {
	log_at_level 0 $*
}

function error {
	if [ "$PROJECT" ]; then
		echo "$PROJECT: $*" 1>&2
	else
		echo "$*" 1>&2
	fi
	exit 1
}

function die {
	error "fatal: $*"
}

function all_syncs {
    cat $CONFIG/syncs | grep -v -e '^[#]' -e '^/\*'
}

function all_targets {
    cat $CONFIG/targets | sed -ne '/^[^#\/]/s/[\t ].*$//p'
}

function all_repos {
    cat $CONFIG/repos | grep -v -e '^[#]' -e '^/\*'
}

function load_protocol {
	[ -n "$1" ] || error "Protocol must be specified";
	local protocol=$1
	[ -f "$BACKUP_EXECUTABLE_DIR/protocols/$protocol" ] || error "Unrecognized protocol: $protocol";
	source $BACKUP_EXECUTABLE_DIR/protocols/$protocol || error "Protocol failed to load: $protocol"
	debug "Loaded protocol: $protocol"
}

function load_group_with_exclusions {
	local IFS='|'
	set - $*
	TARGET_NAME=$1
	shift
	EXCLUDED=$*
}

function populate_group {
	TARGET_TYPE="group"
	IFS=','
	set - $1
	for t; do
		if [ $EXCLUDED ]; then 
			if echo $EXCLUDED | sed 's/ /\n/g' | grep -qe "^$t$"; then
				debug "Excluded $t"
				continue
			fi
		fi
		if [ -n "$GROUP" ]; then
			GROUP="$GROUP,$t"
		else
			GROUP="$t"
		fi
	done
}

function load_target_name {
	local IFS=':'
	set - $*
	TARGET_NAME=$1
	shift
	INLINE_TARGET_PATH="$*"
}

# load_target <name> <optional-target-args...>
# corresponds to targets:
# <target-name> <target-type> <target-args...>
function load_target {
	if echo $1 | grep -q ","; then
		populate_group $1
		return
	fi
	if echo $1 | grep -q '|'; then
		load_group_with_exclusions $1
	else
		load_target_name $1
	fi
	shift
	[ -n "$TARGET_NAME" ] || die "Target must be provided";
	local data=`grep "^$TARGET_NAME[[:space:]]" "$CONFIG/targets"`
	[ -n "$data" ] || die "Target does not exist: $TARGET_NAME" 
	local args=$*
	set - $data
	shift
	TARGET_TYPE=$1
	shift
	if [ "$TARGET_TYPE" = "group" ]; then
		populate_group $*
	else
		load_protocol $TARGET_TYPE
		protocol_load_settings $* $args $INLINE_TARGET_PATH || error "Settings for target '$TARGET_NAME' failed to load";
		[ "$DRY_RUN" ] && load_protocol dry
	fi
	return 0
}

function check_and_lock {
	[ -e "$ROOT" ] || die "ROOT must be set"
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
	SESSION=$ROOT/session
	mkdir -p $SESSION || die "Could not create session"
	mv $TMP $SESSION/tmp
	TMP=$SESSION/tmp
	trap "rm -rf '$SESSION'" EXIT
	echo $$ >$SESSION/lock
}
