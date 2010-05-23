function log {
	echo "`date +'%F %T'` $*" >>$LOG
	[ "$VERBOSE" ] && echo $*
}

function error {
	echo "`date +'%F %T'` error: $*" >>$LOG
	echo $* 1>&2
	exit 1
}

