#!/bin/bash
source "load-settings.sh" || exit 1

if [ "$DRY_RUN" ]; then
	dry="--dry-run";
fi

FAILURES=0
function error {
	let FAILURES++
	echo $* 1>&2
}

function push {
	git push $dry $* 2>&1 || error "Failed to push"
}

function sync {
	if [ "$VERBOSE" ]; then
		verbose="--progress -v"
		verbose=""
	fi
	if [ "$WINDOWS" ]; then
		OS_SPECIFIC="-L"
	else
		OS_SPECIFIC="-pgol"
	fi
	rsync $verbose $dry -ih -rtzR $OS_SPECIFIC --exclude-from ~/.gitignore --exclude '.git/***' $* $path || 
		error "Failed to sync"
}

function all_repos {
	cat $REPOS | sed -e 's/[\t ].*$//'
}

trap 'exit $FAILURES' EXIT
