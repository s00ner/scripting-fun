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
		nc -v -n -z -w 1 $i $p 2>>$ofile
		echo -n "."
	done
	echo
done
grep "open" $ofile > "$ofile.tmp"
mv "$ofile.tmp" $ofile
echo "Output file is $ofile"

if command -v "gpg" > /dev/null
then
	echo "Using gpg"
	gpg -c "$ofile"
	mv "$ofile.gpg" $ofile
elif command -v "openssl" > /dev/null
then
	echo "Using openssl, enter password:"
	openssl enc -in $ofile -out $ofile.dat -e -aes256 -pass stdin
	mv "$ofile.dat" $ofile
elif command -v "base64" > /dev/null
then
	echo "Can't find gpg or openssl, I guess base64 is better than nothing"
	base64 $ofile > "$ofile.b64"
	mv "$ofile.b64" $ofile
else
	echo "Can't encrypt or encode, output file is plaintext"
fi
