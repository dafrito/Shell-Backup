#!/bin/bash
PATH=/bin:/usr/bin
if [ ! "$BACKUP_PATH" ]; then
	echo "BACKUP_PATH must be defined" 1>&2
	exit 1
fi
source $BACKUP_PATH/library.sh

SETTINGS=$HOME/.backup
if [ ! -e "$SETTINGS" ]; then
	mkdir "$SETTINGS" || error "$SETTINGS could not be created";
fi

REPOS=$BACKUP_ROOT/repos
touch $REPOS

PROFILES=$BACKUP_ROOT/profiles
mkdir -p $PROFILES
