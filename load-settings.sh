#!/bin/bash
if [ ! -d "$BACKUP_EXECUTABLE_DIR" ]; then
	BACKUP_EXECUTABLE_DIR=${0%/*}
fi
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

PROTOCOLS=$BACKUP_EXECUTABLE_DIR/protocols

[ -n "$SETTINGS" ] || SETTINGS=$HOME/.backup
[ -n "$LOG" ] || LOG=$SETTINGS/log
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

if [ -e "$SETTINGS/settings" ]; then
	source "$SETTINGS/settings" || error "Global settings failed to load"
fi 

if [ "$SESSION" ]; then
	source $SESSION/settings || error "Session settings failed to load"
fi
