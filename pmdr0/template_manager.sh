#!/bin/bash
#shellcheck disable=SC1091
#shellcheck disable=SC2010
#shellcheck disable=SC2017
#shellcheck disable=SC2027
#shellcheck disable=SC2046
#shellcheck disable=SC2086
#shellcheck disable=SC2143
#shellcheck disable=SC2181
source ./math_utils.sh

FULL_SEP="="
BREAK_SEP="+"
LONG_SHORT_SEP="|"
PLAYER_SEP="&"
VOLUME_SEP="%"
POPUPS_SEP="!"

TEMPLATES_DB="./data/templates/"
PLAYLISTS="./playlists/"
NA_ALERT_FLAG=0

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
        tmp=$(kdialog --inputbox "Name your template.")

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
        
        if [[ -z $tmp ]]; then
            kdialog --error "Template name cannot be null!"
            continue
        fi

        if [[ -n ${tmp//[A-z]/} ]]; then
            kdialog --warningyesno "It is better to have only alphabetical symbols in the template name. \nContinue anyway?"
            if [[ $? -ne 0 ]]; then
                continue;
            fi
        fi

        if [[ -n "$(ls $TEMPLATES_DB | grep $tmp)" ]]; then
            kdialog --warningyesno \
            "Template with name \"$tmp\" already exists. \nDo you want to update parameters of the existing one?" \
            --yes-label "Update" \
            --no-label "Cancel"

            if [[ $? -eq 0 ]]; then 
                rm $TEMPLATES_DB$tmp
                break
            fi
        else
            break;
        fi
    done
    name=$tmp
}
function get_full_time {
    while [[ -n $0 ]]; do
        tmp=$(kdialog --inputbox "Enter full time for your work, in minutes. \n30~300 minutes is ideal")

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

        if [[ -z $tmp ]]; then
            kdialog --error "Time cannot be null!"
            continue
        fi

        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, only input positive integer numbers!"
            continue;
        fi

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
        tmp=$(kdialog --inputbox "Enter time for one work period. \n25~45 minutes is ideal")

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

        if [[ -z $tmp ]]; then
            kdialog --error "Time cannot be null!"
            continue
        fi

        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, only input positive integer numbers!"
            continue;
        fi

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
        tmp=$(kdialog --inputbox "Enter time for short break. \n5~10 minutes is ideal")

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

        if [[ -z $tmp ]]; then
            kdialog --error "Time cannot be null!"
            continue
        fi

        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, only input positive integer numbers!"
            continue;
        fi

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
        tmp=$(kdialog --inputbox "Enter time for long break. \n15~25 minutes is ideal")

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

        if [[ -z $tmp ]]; then
            kdialog --error "Time cannot be null!"
            continue
        fi

        if [[ -n ${tmp//[0-9]/} ]]; then
            kdialog --error "Please, only input positive integer numbers!"
            continue;
        fi

        is_bounded "$tmp" 15 25
        if [[ $? -eq 1  && $NA_ALERT_FLAG -eq 0 ]]; then
            kdialog --warningyesnocancel \
            "Long break less, than 15 minutes, or more, than 25 minutes, is not advised. \nContinue anyway?" \
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
        # Configuring playlist
        playlist=$(kdialog \
                        --combobox "Choose playlist for while you're working: " \
                        $(ls playlists))
        
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

        if [[ -z $(ls $PLAYLISTS$playlist) ]]; then
            kdialog --warningyesno "This playlist is empty. \nContinue anyway?"
            if [[ $? -eq 0 ]]; then
                break
            fi
        else
            break
        fi
    done

    # Setting lofi as default
    if [[ exitcode -ne 0 || $playlist == "" ]]; then
        playlist="lofi"
    fi
}
function get_volume {
    volume=$(kdialog \
            --title "$TITLE" \
            --slider "Choose music's volume while you're working (0%-100%)." 0 100 10)

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
    if [[ $1 -eq 1 ]]; then
        NA_ALERT_FLAG=1
    fi
    get_name
    get_work_info
    get_music_info
    template="$full_time$FULL_SEP$work$BREAK_SEP$short_break$LONG_SHORT_SEP$long_break$PLAYER_SEP$playlist$VOLUME_SEP$volume$POPUPS_SEP$popups"
    
    echo $template > "$TEMPLATES_DB$name.temp"
}
