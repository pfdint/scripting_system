#!/bin/bash
# nt_hash.sh
# by pfdint
# created: 2014-06-29
# modified: 
# purpose: to create md4 hashes of passwords for use in wpa radius conf files & similar

echo -n "$1" | iconv -t utf16le | openssl md4

#Remember, in the file, the line should look like:
#password=hash:nt_hash_here
#except without the #, obviously
