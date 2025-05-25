#!/bin/sh

SECONDS=""
RECENT=""

while read dir ; do
    [[ -f "$dir/meta/seconds" ]] && THIS=$(cat "$dir/meta/seconds") &&
		([[ -z "$RECENT" ]] || [[ $THIS -ge $SECONDS ]]) && SECONDS=$THIS && RECENT=$dir
done

echo $RECENT
