#!/bin/bash
#shellcheck disable=SC1091
source ./pmdr_manager.sh

trap """pkill -9 play; \
        ps aux | \
        grep './pmdr0.sh' | \
        sed -e 's/.* //' | \
        sed -e 's/ .*//' | \
        kill -9 \
        """ SIGINT

debug_flag=0
for input in "$@"; do
    case $input in
        "-d")
            shift; debug_flag=1;;
        *) 
            shift;;
    esac
done

set_up_work_mode $debug_flag

start_pmdr