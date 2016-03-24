#!/usr/local/bin/bash -e 


for i in /mnt/hawking/dvdstorage/01-Source/*
do

#this remove the last character in each item
#j=`echo $i | sed -e 's/.$//'`

# Replace spaces with underscores and clear special characters
j=`echo $i | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | sed 's/_-_/_/g'`

#mv "$i" "$j"
echo "this is still broken for folders without spaces"
done


