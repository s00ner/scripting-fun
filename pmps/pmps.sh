#!/bin/sh
#Poor Man's Port Scanner
#There is no help.
#If you can't figure out what this does from the code then you shouldn't be using it.

ifile=$1
portfile=$2
ofile="/tmp/$(uuidgen)"


for i in $(cat $ifile)
do
	echo -n "Scanning $i"
	for p in $(cat $portfile)
	do
		nc -v -n -z -w 1 $i $p 2>>$ofile &
		sleep .3
		echo -n "."
	done
	sleep 2
	echo
done
grep "open" $ofile > "$ofile.tmp"
mv "$ofile.tmp" $ofile
echo "Output file is $ofile"

if command -v "gpg" > /dev/null
then
	echo "Using gpg"
	gpg -c "$ofile"
	#use gpg -d to decrypt
	mv "$ofile.gpg" $ofile
elif command -v "openssl" > /dev/null
then
	echo "Using openssl, enter password:"
	openssl enc -in $ofile -out $ofile.dat -e -aes256 -pass stdin
	#use same command with "-d" instead of "-e" to decrypt
	mv "$ofile.dat" $ofile
elif command -v "base64" > /dev/null
then
	echo "Can't find gpg or openssl, I guess base64 is better than nothing"
	base64 $ofile > "$ofile.b64"
	#it's base64 if you can't decode it then gtfo
	mv "$ofile.b64" $ofile
else
	echo "Can't encrypt or encode; Output file is plaintext"
fi
