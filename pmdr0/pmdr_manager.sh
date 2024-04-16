#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2001
#shellcheck disable=SC2046
#shellcheck disable=SC2181
source ./template_manager.sh
source ./player.sh

TITLE="pmdr0"
TEMPLATES_DB="./data/templates/"

speed_debug=60

# Separators for extracting info from templates
FULL_SEP="="
BREAK_SEP="+"
LONG_SHORT_SEP="|"
PLAYER_SEP="&"
VOLUME_SEP="%"
POPUPS_SEP="!"

# Mode related parameters
mode="default"
full_time=$NULL
work=$NULL
short_break=$NULL
long_break=$NULL
playlist=$NULL
volume=$NULL
popups=$NULL
break_counter=0

# Popups related parameters
popup_last_stretch="Only a little bit more until the end! For the last cycle you need to work for "
popup_start="Your work cycles begin. Good luck doing your tasks! You need to work for "
popup_continue="Your break's over - it's time to get to work! You need to work for "
popup_break="Time's up! You can take a break for "
popup_end="You can finally rest. Your work is done, congratulations!"

function use_template {
    name=$1
    template=$(cat "$TEMPLATES_DB$name")
    full_time=$(echo "$template" | \
                sed -e "s/$FULL_SEP.*//")
    work=$(echo "$template" | \
                sed -e "s/.*$FULL_SEP//" | \
                sed -e "s/$BREAK_SEP.*//")
    short_break=$(echo "$template" | \
                sed -e "s/.*$BREAK_SEP//" | \
                sed -e "s/$LONG_SHORT_SEP.*//")
    long_break=$(echo "$template" | \
                sed -e "s/.*$LONG_SHORT_SEP//" | \
                sed -e "s/$PLAYER_SEP.*//")
    playlist=$(echo "$template" | \
                sed -e "s/.*$PLAYER_SEP//" | \
                sed -e "s/$VOLUME_SEP.*//")
    volume=$(echo "$template" | \
                sed -e "s/.*$VOLUME_SEP//" | \
                sed -e "s/$POPUPS_SEP.*//")
    popups=$(echo "$template" | \
                sed -e "s/.*$POPUPS_SEP//")
}

function set_up_work_mode { 
    if [[ $1 -eq 1 ]]; then
        speed_debug=1
    fi
    
    kdialog --yesno "Do you want to use existing template, or set up your own work mode?" \
                    --yes-label "New template" \
                    --no-label "Use existing"
    
    if [[ $? -eq 0 ]]; then
        create_new_template $speed_debug
    fi
    
    while [[ -n $0 ]]; do
        mode=$(kdialog \
                    --combobox "Choose a template to use" \
                    $(ls -1 $TEMPLATES_DB))
        if [[ $? -eq 0 ]]; then
            if [[ -f "./data/templates/$mode" ]]; then
                use_template "$mode"
                break
            else
                kdialog --error "You didn't choose a template!"
                continue
            fi
        else
            exit
        fi
    done
}

function notify () {
    kdialog \
        --icon player-time \
        --title "$TITLE" \
        --passivepopup "$@"
}

function start_pmdr {
    current_break=$short_break
    current_work=$work
    notification=$popup_start$work" minutes."
    notify "$notification"
    while [[ $full_time -gt 0 ]]; do
        play_phase_sfx 0
        configure_music "-u $popups -v $volume -p $playlist"

        sleep $((current_work * speed_debug))
        full_time=$((full_time-current_work))

        if [[ $full_time -le 0 ]]; then
            break;
        fi
        notification=$popup_break$current_break" minutes."
        notify "$notification"

        _=$((break_counter++))
        if [[ $((break_counter%4)) -ne 0 ]]; then
            current_break=$short_break
            play_phase_sfx 1
        else
            current_break=$long_break
            play_phase_sfx 2
        fi

        sleep $((current_break * speed_debug))
        full_time=$((full_time-current_break))

        if [[ $full_time -le 0 ]]; then
            break;
        fi

        if [[ $full_time -le $((work+current_break)) ]]; then
            current_work=$((work+current_break));
            notification=$popup_last_stretch$current_work" minutes!"
        else
            notification=$popup_continue$current_work" minutes."
        fi

        notify "$notification"
    done
    play_phase_sfx 3
    notify "$popup_end"
    kdialog --imgbox job_is_done.jpg
}