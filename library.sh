function log {
	if [ "$VERBOSE" ]; then
		echo $*
	else
		echo "`date +'%F %T'` $*" >>$LOG
	fi
}

function error {
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
