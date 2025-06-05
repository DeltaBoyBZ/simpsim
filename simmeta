#!/bin/sh

META_ID=$1
META_VAL=$2

while read dir ; do
	[ -f "$dir/meta/$META_ID" ] && grep "^$META_VAL$" "$dir/meta/$META_ID" > /dev/null && echo $dir
done

	  
