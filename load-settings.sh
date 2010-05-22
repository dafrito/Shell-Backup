#!/bin/bash
PATH=/bin:/usr/bin
if [ ! -d "$BACKUP_EXECUTABLE_DIR" ]; then
	BACKUP_EXECUTABLE_DIR=${0%/*}
fi
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

SETTINGS=$HOME/.backup
if [ ! -e "$SETTINGS" ]; then
	mkdir "$SETTINGS" || error "$SETTINGS could not be created";
fi

REPOS=$SETTINGS/repos
touch $REPOS

PROFILES=$SETTINGS/profiles
mkdir -p $PROFILES
