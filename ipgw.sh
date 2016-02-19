#!/usr/bin/env bash
set -e

if [ -f ~/.ipgwrc ]
then
	source ~/.ipgwrc
elif [ -f /etc/ipgwrc ]
then
	source /etc/ipgwrc
fi

[[ -z "$username" ]] && read -p "Please enter your username: " username
[[ -z "$password" ]] && read -s -p "Please enter your password: " password

URL="https://its.pku.edu.cn:5428/ipgatewayofpku?timeout=1&uid=${username}&password=${password}"

connect() {
	RESULT=$(w3m -dump "${URL}&range=2&operation=connect" 2>/dev/null | uniq)
	echo "$RESULT"
	echo "$RESULT"|grep "Connect successfully" >/dev/null
}

disconnect() {
	RESULT=$(w3m -dump "${URL}&range=2&operation=disconnect" 2>/dev/null | uniq)
	echo "$RESULT"
	echo "$RESULT"|grep "Disconnect Succeeded" >/dev/null
}

connect_global() {
	RESULT=$(w3m -dump "${URL}&range=1&operation=connect" 2>/dev/null | uniq)
	echo "$RESULT"
	echo "$RESULT"|grep "Connect successfully" >/dev/null
}

disconnect_all() {
	RESULT=$(w3m -dump "${URL}&range=2&operation=disconnectall" 2>/dev/null | uniq)
	echo "$RESULT"
	echo "$RESULT"|grep "Disconnect All Succeeded" >/dev/null
}

error() {
	echo "Usage: $(basename "$0") [g|d|da|r]"
	exit 2
}


if [ $# -eq 0 ]
then
	connect && exit 0
	disconnect || exit 1
	connect || exit 1
elif [ $# -eq 1 ]
then
	case $1 in
		g)
			connect_global && exit 0
			disconnect || exit 1
			connect_global || exit 1
			;;
		d)
			disconnect || exit 1
			;;
		da)
			disconnect_all || exit 1
			;;
		r)
			disconnect || exit 1
			connect || exit 1
			;;
		ra)
			disconnect_all || exit 1
			connect || exit 1
			;;
		*)
			error
			;;
	esac
else
	error
fi
