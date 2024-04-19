#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2010
#shellcheck disable=SC2017
#shellcheck disable=SC2027
#shellcheck disable=SC2046
#shellcheck disable=SC2086
#shellcheck disable=SC2143
#shellcheck disable=SC2181

export SCRIPT_DIR
source "$SCRIPT_DIR/math_utils.sh"

export debug_flag
export fast_flag

# Separators
FULL_SEP="="
BREAK_SEP="+"
LONG_SHORT_SEP="|"
PLAYER_SEP="&"
VOLUME_SEP="%"
POPUPS_SEP="!"

# Config & databases constants
TEMPLATES_DB="$SCRIPT_DIR/data/templates/"
PLAYLISTS="$SCRIPT_DIR/playlists/"
NA_ALERT_FLAG=0

# Templates' parameters
template=$NULL
name=$NULL
full_time=$NULL
work=$NULL
short_break=$NULL
long_break=$NULL
playlist=$NULL
volume=$NULL
popups=0 

function get_name {
    while [[ -n $0 ]]; do
        # Calling inputbox to get template name from user
        tmp=$(kdialog --inputbox "Name your template.")

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exitcode=$?
            case $exitcode in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi
        
        # Null-name check
        if [[ -z $tmp ]]; then
            kdialog --error "Template name cannot be null!"
            continue
        fi

        # Specific to template name not-ideal-value check: "Template name already exists!"
        if [[ -n "$(ls $TEMPLATES_DB | grep "$tmp.temp")" ]]; then
            kdialog --warningyesno \
            "Template with name \"$tmp\" already exists. \nDo you want to update parameters of the existing one?" \
            --yes-label "Update" \
            --no-label "Cancel"

            if [[ $? -eq 0 ]]; then 
                break
            fi
        else
            break;
        fi

        # Aplhabetical-name check
        if [[ -n ${tmp//[A-z]/} ]]; then
            kdialog --warningyesno "It is better to have only alphabetical symbols in the template name. \nContinue anyway?"
            if [[ $? -ne 0 ]]; then
                continue;
            fi
        fi
    done
    name=$tmp
}
function get_full_time {
    while [[ -n $0 ]]; do
        # Calling inputbox to get full time from user
        tmp=$(kdialog --inputbox "Enter full time for your work, in minutes. \n30~300 minutes is ideal")

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exitcode=$?
            case $exitcode in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi

        # Null-time check
        if [[ -z $tmp ]]; then
            if [[ $fast_flag -eq 1 ]]; then
                full_time=120
                return
            else
                kdialog --error "Time cannot be null!"
                continue
            fi
        fi

        # Positive integer check
        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, input only non-negative integer numbers!"
            continue;
        fi

        # Specific to full time not-ideal-value check: "full_time < 30m OR full_time > 300m!"
        is_bounded "$tmp" 30 300
        if [[ $? -eq 1 && $NA_ALERT_FLAG -eq 0 ]]; then
            kdialog --warningyesnocancel \
            "Full time less, than 30 minutes, or more, than 300 minutes, is not advised. \nContinue anyway?" \
            --yes-label "Continue" \
            --no-label "Cancel" \
            --cancel-label "Do not ask again"

            exitcode=$?
            case $exitcode in
                0)
                    break;;
                2)
                    NA_ALERT_FLAG=1; break;;
            esac
        else
            break;
        fi
    done
    full_time=$tmp
}
function get_work_time {
    while [[ -n $0 ]]; do
        # Calling inputbox to get time for work period from user
        tmp=$(kdialog --inputbox "Enter time for one work period. \n25~45 minutes is ideal")

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exitcode=$?
            case $exitcode in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi

        # Null-time check
        if [[ -z $tmp ]]; then
            if [[ $fast_flag -eq 1 ]]; then
                work=30
                return
            else
                kdialog --error "Time cannot be null!"
                continue
            fi
        fi

        # Positive integer check
        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, input only non-negative integer numbers!"
            continue;
        fi

        # Specific to work period not-ideal-value check: "work_time < 25m OR work_time > 45m!"
        is_bounded "$tmp" 25 45
        if [[ $? -eq 1 && $NA_ALERT_FLAG -eq 0 ]]; then
            kdialog --warningyesnocancel \
            "Work period less, than 25 minutes, or more, than 45 minutes, is not advised. \nContinue anyway?" \
            --yes-label "Continue" \
            --no-label "Cancel" \
            --cancel-label "Do not ask again"

            exitcode=$?
            case $exitcode in
                0)
                    break;;
                2)
                    NA_ALERT_FLAG=1; break;;
            esac
        else
            break;
        fi
    done
    work=$tmp
}
function get_short_break {
    while [[ -n $0 ]]; do
        # Calling inputbox to get time for short break from user
        tmp=$(kdialog --inputbox "Enter time for short break. \n5~10 minutes is ideal")

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exitcode=$?
            case $exitcode in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi

        # Null-time check
        if [[ -z $tmp ]]; then
            if [[ $fast_flag -eq 1 ]]; then
                short_break=5
                return
            else
                kdialog --error "Time cannot be null!"
                continue
            fi
        fi

        # Positive integer check
        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, input only non-negative integer numbers!"
            continue;
        fi

        # Specific to short break not-ideal-value check: "short_time < 5m OR short_time > 15m!"
        is_bounded "$tmp" 5 10
        if [[ $? -eq 1  && $NA_ALERT_FLAG -eq 0 ]]; then
            kdialog --warningyesnocancel \
            "Short break less, than 5 minutes, or more, than 10 minutes, is not advised. \nContinue anyway?" \
            --yes-label "Continue" \
            --no-label "Cancel" \
            --cancel-label "Do not ask again"

            exitcode=$?
            case $exitcode in
                0)
                    break;;
                2)
                    NA_ALERT_FLAG=1; break;;
            esac
        else
            break;
        fi
    done
    short_break=$tmp
}
function get_long_break {
    while [[ -n $0 ]]; do
        # Calling inputbox to get time for long break from user
        tmp=$(kdialog --inputbox "Enter time for long break. \n15~25 minutes is ideal")

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exitcode=$?
            case $exitcode in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi

        # Null-time check
        if [[ -z $tmp ]]; then
            if [[ $fast_flag -eq 1 ]]; then
                long_break=15
                return
            else
                kdialog --error "Time cannot be null!"
                continue
            fi
        fi

        # Positive integer check
        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, input only non-negative integer numbers!"
            continue;
        fi

        # Specific to long break not-ideal-value check: "long_time < 15m OR long_time > 25m"
        is_bounded "$tmp" 15 25
        if [[ $? -eq 1  && $NA_ALERT_FLAG -eq 0 ]]; then
            kdialog --warningyesnocancel \
            "Long break less, than 15 minutes, or more, than 25 minutes, is not advised. \nContin1ue anyway?" \
            --yes-label "Continue" \
            --no-label "Cancel" \
            --cancel-label "Do not ask again"

            exitcode=$?
            case $exitcode in
                0)
                    break;;
                2)
                    NA_ALERT_FLAG=1; break;;
            esac
        else
            break
        fi
    done
    long_break=$tmp
}

function get_playlist {
    while [[ -n $0 ]]; do
        # Calling combobox window to get playlist
        playlist=$(kdialog \
                        --combobox "Choose playlist for while you're working: " \
                        $(ls playlists))
        exitcode=$?

        # Default exit-confirmation block
        if [[ $? -ne 0 ]]; then
            kdialog --warningyesno "Are you sure, you want to quit?"
            exit=$?
            case $exit in
                0) 
                    exit 1;;
                *)
                    continue;;
            esac
        fi

        # Specific to playlists non-ideal-value check: "Playlist is empty!"
        if [[ -z $(ls $PLAYLISTS$playlist) ]]; then
            kdialog --warningyesno "This playlist is empty. \nContinue anyway?"
            if [[ $? -eq 0 ]]; then
                break
            fi
        else
            break
        fi
    done

    # Setting lofi-playlist as default if previous step fails to establish a playlist
    if [[ exitcode -ne 0 || $playlist == "" ]]; then
        playlist="lofi"
    fi
}
function get_volume {
    # Calling slider window to get volume
    volume=$(kdialog \
            --title "$TITLE" \
            --slider "Choose music's volume while you're working (0%-100%)." 0 100 10)

    # Setting up volume/popups
    if [[ $? -eq 0 ]]; then
        return
    elif [[ $volume -ne 0 ]]; then
        kdialog --warningyesno "Do you want to show pop-ups for upcoming music?"
        popups=$?
    else
        volume=0
    fi
}

function get_work_info {
    get_full_time
    get_work_time
    get_short_break
    get_long_break
}
function get_music_info {
    get_playlist
    get_volume
}

function create_new_template {
    # Turning off alerts on non-ideal input
    if [[ $fast_flag -eq 1 ]]; then
        NA_ALERT_FLAG=1
    fi

    # Getting all the info
    get_name
    get_work_info
    get_music_info

    # Writing info to template, and then to file
    template="$full_time$FULL_SEP$work$BREAK_SEP$short_break$LONG_SHORT_SEP$long_break$PLAYER_SEP$playlist$VOLUME_SEP$volume$POPUPS_SEP$popups"
    
    echo $template > "$TEMPLATES_DB$name.temp"
}
