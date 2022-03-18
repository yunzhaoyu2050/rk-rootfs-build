#!/bin/bash

# info log
info() {
	[ -n "$*" ] &&
		echo -e "\033[32m $* \033[0m"
}

info_() {
	[ -n "$*" ] &&
		echo -e "$*"
}

# warn log
warn() {
	[ -n "$*" ] &&
		echo -e "\033[33m $* \033[0m"
}

# error log
error() {
	[ -n "$*" ] &&
		echo -e "\033[31m $* \033[0m"
}

# debug log
debug() {
	[ -n "$*" ] &&
		echo -e "\033[34m $* \033[0m"
}

unset_vars() {
	local t
	for t in $@; do
		unset $t
		export $t
	done
}
