#!/bin/bash
#shellcheck disable=SC1091
source ./pmdr_manager.sh

info_flag=0
debug_flag=0
for input in "$@"; do
    case $input in
        "-i")
            shift; info_flag=1;;
        "-d")
            shift; debug_flag=1;;
    esac
done

if [[ info_flag -eq 1 ]]; then
    kdialog --msgbox \
"This program is a pomodoro technique oriented utility.\n\
Pomodoro technique is used to increase productivity. \n\
It uses a mix of work and break periods to do so."
    kdialog --msgbox \
"This utility, besides potentially increasing your productivity allows you to:\n\
- Configure templates for different work modes\n\
- Create and listen to playlist of your own choice"
    kdialog --msgbox \
"If you encounter a bug, please let me know in GitHub:\n\
"
fi

set_up_work_mode $debug_flag
    
start_pmdr