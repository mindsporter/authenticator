#!/bin/bash

KEYFILE=keys.gpg

show_help(){
	echo ""
	echo "Usage examples:"
	echo "$1    #Display verification codes"
	echo "$1 -c #Display verification codes"
	echo "$1 -d #Printed decrypted keys file to stdout"
	echo "$1 -e #Encrypt keys file supplied via stdin"
	echo "$1 -h #Show this help"
	echo ""
}

decrypt_keys(){
	gpg -q -d $KEYFILE
}

encrypt_keys(){
	gpg -c --cipher-algo=aes256 -o $KEYFILE
}

_show_codes(){
	declare -a ENTRY=("${!1}")
	n=${#ENTRY[@]}

	for i in `seq 0 $(($n-1))`; do
		read -r label key <<< "${ENTRY[$i]}"
		echo -n $label " "
		oathtool --totp --base32 $key
	done
}

show_codes(){
	n=0
	while read l; do
		ENTRIES[$n]="$l"
		n=$(($n+1))
	done < <(decrypt_keys)

	while true; do
		clear
		_show_codes ENTRIES[@]
		sleep 1
	done
}

while getopts ":cdeh" opt; do
	case $opt in
	c)
		;;
	d)
		decrypt_keys
		exit 0
		;;
	e)
		encrypt_keys
		exit 0
		;;
	h)
		show_help $0
		exit 0
		;;
	\?)
		echo "Invalid option: -$OPTARG"
		show_help $0
		exit 1
	esac
done

show_codes
