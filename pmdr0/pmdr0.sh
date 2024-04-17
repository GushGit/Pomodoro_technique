#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2034
source ./pmdr_manager.sh

debug_flag=0
fast_flag=0
for input in "$@"; do
    case $input in
        "-d")
            shift; debug_flag=1;;
        "-f")
            shift; fast_flag=1;;
        *) 
            shift;;
    esac
done

set_up_work_mode

start_pmdr