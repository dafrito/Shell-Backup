function log {
	echo "`date +'%F %T'` $*" >>$LOG
	[ "$VERBOSE" ] && echo $*
}

function error {
	echo "`date +'%F %T'` error: $*" >>$LOG
	echo $* 1>&2
	exit 1
}

function load_protocol {
	local repo=$1
	[ "$repo" ] || error "Repository type must be specified for $repo";
	[ -f "$PROTOCOLS/$repo" ] || error "Unrecognized repository type: $repo";
	source $PROTOCOLS/$repo || error "protocol failed to load: $repo"
	log "Loaded protocol: $repo"
}
