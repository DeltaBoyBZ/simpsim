#!/bin/sh

SIMPSIM_ID=$1

find "$SIMPSIM_ROOT" -regex "^$SIMPSIM_ROOT/$SIMPSIM_ID-[-0-9a-zx]+$"
