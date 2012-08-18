#!/bin/bash
[ -z "$EDITOR" ] && export EDITOR="vim"
date_dir=$(date +%Y/%m/%d)
mkdir -pv $date_dir
[ "$1" != "" ] && $EDITOR "$date_dir/$1"
