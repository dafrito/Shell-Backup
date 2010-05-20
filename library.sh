function push_ifs {
	[ "$OLD_IFS" ] && error "push_ifs will not overwrite a currently set OLD_IFS"
	OLD_IFS=$IFS
	IFS=$1
}

function pop_ifs {
	IFS=$OLD_IFS
	unset $OLD_IFS
}

function error {
	echo $* 1>&2
	exit 1
}

