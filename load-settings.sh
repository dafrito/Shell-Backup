#!/bin/bash
PATH=/bin:/usr/bin
if [ ! -d "$BACKUP_EXECUTABLE_DIR" ]; then
	BACKUP_EXECUTABLE_DIR=${0%/*}
fi
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

PROTOCOLS=$BACKUP_EXECUTABLE_DIR/protocols

SETTINGS=$HOME/.backup
LOG=$SETTINGS/log
if [ ! -e "$SETTINGS" ]; then
	if ! mkdir "$SETTINGS"; then
		echo "$SETTINGS could not be created" 1>&2;
		exit 1
	fi
fi
touch $SETTINGS/log || exit 1

REPOS=$SETTINGS/repos
[ -e $REPOS ] || touch $REPOS

PROFILES=$SETTINGS/profiles
if [ ! -e $PROFILES ]; then
	mkdir -p $PROFILES
	touch $PROFILES/full
fi

SESSION_DIR=/tmp/backup

if [ "$SESSION" ]; then
	source $SESSION_DIR/settings || error "Session settings failed to load"
fi
