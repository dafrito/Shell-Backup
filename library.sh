#!/bin/bash
if [ ! -d "$BACKUP_EXECUTABLE_DIR" ]; then
	echo "BACKUP_EXECUTABLE_DIR must be defined"
	exit 1
fi
PATH=/bin:/usr/bin:$BACKUP_EXECUTABLE_DIR
source "$BACKUP_EXECUTABLE_DIR/library.sh"

function push {
	if [ "$DRY_RUN" ]; then
		local dry="--dry-run";
	fi
	git push $dry $* 2>&1 || error "Failed to push"
}

function sync {
	if [ "$DRY_RUN" ]; then
		local dry="--dry-run";
	fi
	local OS_SPECIFIC="-pgol"
	if [ "$WINDOWS" ]; then
		OS_SPECIFIC="-L"
	fi
	rsync $verbose $dry -ih -rtzR $OS_SPECIFIC --exclude-from ~/.gitignore --exclude '.git/***' $* $path || 
		error "Failed to sync"
}

function all_targets {
	cat $TARGETS | sed -e 's/[\t ].*$//'
}

trap 'exit $FAILURES' EXIT

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

function all_targets {
    cat $TARGETS | sed -ne '/^[^#\/]/s/[\t ].*$//p'
}

function all_repos {
    cat $REPOS | grep -v -e '^[#]' -e '^/\*'
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
	if [ "$1" = "group" ]; then
		IFS=','
		set - $2
		GROUP=$*
	else
		load_protocol $1
		protocol_load_settings $* || error "Settings for target '$name' failed to load";
		[ "$DRY_RUN" ] && load_protocol dry
	fi
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
	trap "rm -rf '$SESSION'" EXIT
	echo $$ >$SESSION/lock
}
