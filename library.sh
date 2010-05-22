function log {
	echo "`date +'%F %T'` $*" >>$LOG
}

function error {
	echo "`date +'%F %T'` error: $*" >>$LOG
	echo $* 1>&2
	exit 1
}

