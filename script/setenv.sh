#!/bin/bash

#
# check rootfs.cfg and export env
#

SRC=$(realpath "${BASH_SOURCE:-$0}")

ROOT=${SRC%/*}/..

PRDIR=$PWD

export PRDIR=$PRDIR ROOT=$ROOT

source "${PRDIR}/"script/function.sh

function usage_help() {
  echo "USAGE: source setenv.sh [-h|-d|-c] [ PARAM=VAL | CONFIG_FILE ]
        -h|--help          - usage help
        -d|--clear         - clear env value
        -c|--config|config - '-c rootfs.cfg'
        PARAM=VALUE        - param value pair
        CONFIG_FILE        - read config/template file"
}

for a in "$@"; do
  case $a in
  -h | --help)
    usage_help
    return 0
    ;;
  -d | --clear)
    unset_vars RELEASE ARCH TARGET VERSION
    info "clear env vars..."
    return 1
    ;;
  -c | --config | config)
    OPTION_CONIFG=1
    ;;
  *=*)
    export $a
    ;;
  *)
    [ "$OPTION_CONIFG" ] &&
      CONFIG_FILE="$a"

    [ -s "$a" ] &&
      CONFIG_FILE="$a"

    [ "$CONFIG_FILE" ] && {
      [ -e "$CONFIG_FILE" ] || {
        error "$CONFIG_FILE not found"
        return 1
      }
      unset_vars RELEASE ARCH TARGET VERSION
      [ ! -f "$PRDIR/$CONFIG_FILE" ] && error "Please config rootfs info in $CONFIG_FILE" && return 1
      source "$PRDIR/$CONFIG_FILE"
      export RELEASE="$RELEASE" ARCH="$ARCH" TARGET="$TARGET" VERSION="$VERSION"

      CONFIG_FILE=
      continue
    }
    error "unrecognized param \"$a\"" && usage_help
    return 1
    ;;
  esac
done
