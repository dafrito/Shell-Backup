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

function load_repo {
	local name=$1
	local data=`grep "^$name" "$REPOS"`
	[ -n "$data" ] || error "Repository data could not be found: $name" 
	set - $data
	shift
	load_protocol $1
	shift
	protocol_load_settings $* || error "settings for repository $namefailed to load";
	[ "$DRY_RUN" ] && load_protocol dry
}
