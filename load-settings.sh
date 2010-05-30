#!/bin/bash
[ -d "$BACKUP_EXECUTABLE_DIR" ] || BACKUP_EXECUTABLE_DIR=${0%/*}
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

[ -n "$SETTINGS" ] || SETTINGS=$HOME/.backup
if [ ! -e "$SETTINGS" ]; then
	if ! mkdir "$SETTINGS"; then
		echo "$SETTINGS could not be created" 1>&2;
		exit 1
	fi
fi

TARGETS=$SETTINGS/targets
[ -e $TARGETS ] || touch $TARGETS

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
