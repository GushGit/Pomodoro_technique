#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2034

# Extracting source directory for later exporting in other scripts
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/pmdr"
source "$SCRIPT_DIR/pmdr_manager.sh"

trap   'kill -9 $(pgrep "pmdr") &>/dev/null | \
        kill -9 $(pgrep "play") &>/dev/null' SIGINT

# Flag analyzer
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

# Main functions
set_up_work_mode 

start_pmdr 