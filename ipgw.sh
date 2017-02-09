#!/usr/bin/env bash
set -e

if [ -f ~/.ipgwrc ]
then
	conf_file="~/.ipgwrc"
elif [ -f /etc/ipgwrc ]
then
	conf_file="/etc/ipgwrc"
fi

if [ -n ${conf_file} ]
then
	source <(grep = ${conf_file} | tr -d ' ')
fi

[ -z ${username} ] && read -p "Please enter your username: " username
[ -z ${password} ] && read -s -p "Please enter your password: " password

cURL() {
	curl -A "IPGWLinux1.0_Linux_00_00_de_ad_be_ef" -sS \
		"https://its.pku.edu.cn/cas/ITSClient" -d "$@"
}

connect() {
	cURL "cmd=open&username=$username&password=$password&iprange=free" | jq .
}

disconnect() {
	cURL "cmd=close" | jq .
}

connect_global() {
	cURL "cmd=open&username=$username&password=$password&iprange=fee" | jq .
}

disconnect_all() {
	cURL "cmd=closeall&username=$username&password=$password" | jq .
}

error() {
	echo "Usage: $(basename "$0") [g|d|da|r|ra]"
	exit 2
}


if [ $# -eq 0 ]
then
	connect && exit 0
	# disconnect_all || exit 1
	# connect || exit 1
elif [ $# -eq 1 ]
then
	case $1 in
		g)
			connect_global && exit 0
			disconnect_all || exit 1
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
