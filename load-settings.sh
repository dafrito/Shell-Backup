#!/bin/bash
PATH=/bin:/usr/bin
if [ ! -d "$BACKUP_EXECUTABLE_DIR" ]; then
	BACKUP_EXECUTABLE_DIR=${0%/*}
fi
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

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
touch $REPOS

PROFILES=$SETTINGS/profiles
mkdir -p $PROFILES
touch $PROFILES/full

TMP=/tmp/backup
# TMP acts as our lock. If it exists, we're either crashing or already backing up.
[ ! -e $TMP/lock ] || error "Backup appears to be in progress; delete $TMP/lock to unlock."
trap "rm -rf '$TMP'" EXIT
mkdir -p $TMP
touch $TMP/lock

