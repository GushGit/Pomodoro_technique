#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2034
source ./pmdr_manager.sh

trap """pkill -9 play; \
        ps aux | \
        grep './pmdr0.sh' | \
        sed -e 's/.* //' | \
        sed -e 's/ .*//' | \
        kill -9 \
        """ SIGINT

debug_flag=0
fast_templates=0
for input in "$@"; do
    case $input in
        "-d")
            shift; debug_flag=1;;
        "-f")
            shift; fast_templates=1;;
        *) 
            shift;;
    esac
done

set_up_work_mode

start_pmdr