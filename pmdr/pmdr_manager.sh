#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2001
#shellcheck disable=SC2046
#shellcheck disable=SC2086
#shellcheck disable=SC2181

export SCRIPT_DIR
source "$SCRIPT_DIR/template_manager.sh"
source "$SCRIPT_DIR/player.sh"

export debug_flag
export fast_flag

TITLE="pmdr0"
export TEMPLATES_DB

speed_debug=60
WAIT_FLAG="$SCRIPT_DIR/wait_flag.conf"

# Separators for extracting info from templates
export FULL_SEP
export BREAK_SEP
export LONG_SHORT_SEP
export PLAYER_SEP
export VOLUME_SEP
export POPUPS_SEP

# Current work parameters
mode="default"
full_time=$NULL
work=$NULL
short_break=$NULL
long_break=$NULL
playlist=$NULL
volume=$NULL
popups=$NULL

# Popups related parameters
popup_last_stretch="Only a little bit more until the end! For the last cycle you need to work for "
popup_start="Your work cycles begin. Good luck doing your tasks! You need to work for "
popup_continue="Your break's over - it's time to get to work! You need to work for "
popup_break="Time's up! You can take a break for "
popup_end="You can finally rest. Your work is done, congratulations!"

function use_template {
    ### Each line in this function after initializing $template 
    ### simply deletes everything after and before separators besides the required value,
    ### which leaves the required value itself
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
    # Flag analyzer
    if [[ $debug_flag -eq 1 ]]; then
        speed_debug=1
    fi

    # Calling yes-no box to decide on usage of templates
    kdialog --yesno "Do you want to use existing template, or set up your own work mode?" \
            --yes-label "New template" \
            --no-label "Use existing"


    case $? in 
        0) 
            create_new_template;;
        2)
            exit 1;;
    esac
    
    # Picking template to use
    while [[ -n $0 ]]; do
        mode=$(kdialog \
                    --combobox "Choose a template to use" \
                    $(ls -1 $TEMPLATES_DB))
        if [[ $? -eq 0 ]]; then
            if [[ -f "$SCRIPT_DIR/data/templates/$mode" ]]; then
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

# Alias
function notify () {
    kdialog \
        --icon player-time \
        --title "$TITLE" \
        --passivepopup "$@"
}

function stop_waiting {
    echo 0 > "$WAIT_FLAG"
}
function start_waiting {
    echo 1 > "$WAIT_FLAG"
}
function wait {
    start_waiting
    sleep $1
    stop_waiting
}

function start_pmdr {
    # Setting up initial values for work
    remaining_time=$full_time
    current_break=$short_break
    current_work=$work
    notification=$popup_start$work" minutes."
    break_counter=0

    start=$(date +%s)
    # Main loop
    while [[ $remaining_time -gt 0 ]]; do
        # If cycles end on break, expand work time to match remaining time
        if [[ $remaining_time -le $((work+current_break)) ]]; then
            current_work=$remaining_time;
            notification=$popup_last_stretch$current_work" minutes!"
        else
            notification=$popup_continue$current_work" minutes."
        fi

        notify "$notification"

        play_phase_sfx 0
        configure_music "-u $popups -v $volume -p $playlist"

        # Wait for the work cycle to end and update remaining time
        wait $((current_work * speed_debug))&
        cycle_start=$(date +%s)
        cycle_end=$((cycle_start + current_work * speed_debug))
        while [[ $(cat $WAIT_FLAG) == "1" ]]; do
            now=$(date +%s)
            
            from_full_start=$(date -d@$((now - start)) -u \
            +"Time passed since the start: %H:%M:%S")
            
            time_full_remaining=$(date -d@$((start + full_time * speed_debug - now)) -u \
            +"Time remaining of your full work cycles: %H:%M:%S")

            time_cycle_remaining=$(date -d@$((cycle_end - now)) -u \
            +"Time remaining of work period: %H:%M:%S")

            from_cycle_start=$(date -d@$((now - cycle_start)) -u \
            +"Time passed since the start of work: %H:%M:%S")
            
            printf "\n%s\n" "$INFO_SEP"
            printf "%s\n%s\n\n%s\n%s\n" \
                            "$from_full_start" \
                            "$time_full_remaining" \
                            "$from_cycle_start" \
                            "$time_cycle_remaining"
            
            printf "%s\n\n" "$INFO_SEP"

            sleep 30
            printf "\r"
            i=0
            while [[ i -lt 9 ]]; do
                printf "\33[2K"
                printf "\033[A"
                _=$((i++))
            done
        done

        remaining_time=$((remaining_time-current_work))

        # Default end-of-time check
        if [[ $remaining_time -le 0 ]]; then
            break;
        fi
        notification=$popup_break$current_break" minutes."
        notify "$notification"

        _=$((break_counter++))
        if [[ $((break_counter%3)) -ne 0 ]]; then
            current_break=$short_break
            play_phase_sfx 1
        else
            current_break=$long_break
            play_phase_sfx 2
        fi

        wait $((current_break * speed_debug))&
        cycle_start=$(date +%s)
        cycle_end=$((cycle_start + current_work * speed_debug))
        while [[ $(cat $WAIT_FLAG) == "1" ]]; do
            now=$(date +%s)
            
            from_full_start=$(date -d@$((now - start)) -u \
            +"Time passed since the start: %H:%M:%S")
            
            time_full_remaining=$(date -d@$((start + full_time * speed_debug - now)) -u \
            +"Time remaining of your full work cycles: %H:%M:%S")

            time_cycle_remaining=$(date -d@$((cycle_end - now)) -u \
            +"Time remaining of break period: %H:%M:%S")

            from_cycle_start=$(date -d@$((now - cycle_start)) -u \
            +"Time passed since the start of break: %H:%M:%S")

            
            printf "\n%s\n" "$INFO_SEP"
            printf "%s\n%s\n\n%s\n%s\n" \
                            "$from_full_start" \
                            "$time_full_remaining" \
                            "$from_cycle_start" \
                            "$time_cycle_remaining"
            
            printf "%s\n\n" "$INFO_SEP"

            sleep 30
            printf "\r"
            i=0
            while [[ i -lt 9 ]]; do
                printf "\33[2K"
                printf "\033[A"
                _=$((i++))
            done
        done
        remaining_time=$((remaining_time-current_break))
    done
    play_phase_sfx 3
    notify "$popup_end"
    kdialog --imgbox job_is_done.jpg
}
