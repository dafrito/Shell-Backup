#!/bin/bash
[ -d "$BACKUP_EXECUTABLE_DIR" ] || BACKUP_EXECUTABLE_DIR=${0%/*}
source $BACKUP_EXECUTABLE_DIR/library.sh || exit 1

ROOT=${ROOT-$HOME/.backup}
mkdir -p "$ROOT/config" || die "$ROOT could not be created"

TARGETS=${TARGETS-$ROOT/config/targets}
[ -e $TARGETS ] || touch $TARGETS
