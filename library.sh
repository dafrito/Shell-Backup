#!/bin/bash

function log {
	echo $*
}

function error {
	echo $* 1>&2
	[ "$TOLERANT" ] || exit 1
}

function die {
	echo $* 1>&2
	exit 1
}

function load_protocol {
	local repo=$1
	[ "$repo" ] || error "Repository type must be specified for $repo";
	[ -f "$BACKUP_EXECUTABLE_DIR/protocols/$repo" ] || error "Unrecognized repository type: $repo";
	source $BACKUP_EXECUTABLE_DIR/protocols/$repo || error "protocol failed to load: $repo"
	log "Loaded protocol: $repo"
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
