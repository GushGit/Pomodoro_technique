#!/bin/bash
#shellcheck disable=SC2012
#shellcheck disable=SC2181
#shellcheck disable=SC2046

export SCRIPT_DIR

# Initializing constants
NULL="null"
ERROR=137
PLAYLIST_DB="$SCRIPT_DIR/data/playlist.db"
MAX_INFO_LENGTH=17
SFX_DIR="$SCRIPT_DIR/sfx/"
SFX_START=$SFX_DIR"start.wav"
SFX_SHORT=$SFX_DIR"short.wav"
SFX_LONG=$SFX_DIR"long.wav"
SFX_END=$SFX_DIR"end.wav"
popup_flag=$NULL
volume=0

export playlist_len

# Called at the start of every work cycle
function configure_music {
    for input in "$@"; do
        case $input in
            "-v") 
                shift; volume=$1; shift;;
            "-u") 
                shift; popup_flag=$1; shift;;
            "-p")
                shift; playlist=$1; shift;;
            *) 
                shift;;
        esac
    done

    # Normalizing volume to the interval [0.0, 1.0]
    volume="0$(bc<<<"scale=3;$volume/100.0")"

    playlist_dir="$SCRIPT_DIR/playlists/$playlist/"
    playlist_len="$(ls "$playlist_dir" | wc -l)"

    # Initializing/preformatting database
    ls "$playlist_dir" -1 | \
    sed -e 's/\.mp3$//' | \
    nl | \
    sed -e 's/ *//' > $PLAYLIST_DB 

    play_music 2> /dev/null&
}

# Main recursive play function
function play_music () {
    # Processing arguements
    current_song=$NULL
    for input in "$@"; do
        case $input in
            "-s") 
                shift; current_song=$1; shift;;
            *) 
                shift;;
        esac
    done

    # Randomizing current composition in case of emergency
    if [[ "$current_song" == "$NULL" ]]; then
        rng_idx=$((RANDOM%playlist_len + 1))
        current_song=$( cat $PLAYLIST_DB | 
                        grep "$rng_idx	" | 
                        sed -e 's/^[0-9]	//')
    fi

    # Randomise next composition for the next iteration
    next_song=$current_song
    while [[ "$next_song" == "$current_song" && $playlist_len -ne 1 ]]; do
        rng_idx=$((RANDOM%playlist_len + 1))
        next_song=$(cat $PLAYLIST_DB | \
                    grep "$rng_idx	" | \
                    sed -e 's/^ *[0-9]*	//')
    done

    # A "Now/Next Playing" banner
    if [[ $popup_flag -eq 0 && $current_song != "" ]]; then
        local curr=${current_song:0:$MAX_INFO_LENGTH}
        if [[ "$curr" != "$current_song" ]]; then
            curr="$curr..."
        fi

        local next=${next_song:0:$MAX_INFO_LENGTH}
        if [[ "$next" != "$next_song" ]]; then
            next="$next..."
        fi
        kdialog \
            --icon audio-headphones-symbolic \
            --title "Now playing: $curr" \
            --passivepopup "Playing next: $next"
    fi

    # Play music and exit/continue recursion
    play -v "$volume" "$playlist_dir$current_song.mp3"
    local exitcode=$?
    if [[ $exitcode -eq $ERROR ]]; then
        exit
    else 
        play_music "-s" "$next_song"
    fi
}

function play_phase_sfx { 
    # Without `exec` <play()> will output play-info to terminal
    exec 2>/dev/null
    pkill -9 "play"

    case $1 in
        "0") 
            play -v 0.4 $SFX_START;;
        "1") 
            play $SFX_SHORT;;
        "2") 
            play $SFX_LONG;;
        "3")
            play $SFX_END;;
        "*")
            echo "$0 received unconventional arguement, exiting..."; exit;;
    esac&
}
