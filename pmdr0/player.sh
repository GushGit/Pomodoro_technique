#!/bin/bash
#shellcheck disable=SC2012
#shellcheck disable=SC2181
#shellcheck disable=SC2046

# Initializing constants
NULL="null"
ERROR=137
PLAYLIST_DB="./data/playlist.db"
SFX_DIR="./sfx/"
SFX_START=$SFX_DIR"start.wav"
SFX_SHORT=$SFX_DIR"short.wav"
SFX_LONG=$SFX_DIR"long.wav"
SFX_END=$SFX_DIR"end.wav"
popup_flag=$NULL

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

    if [[ volume -gt 1 ]]; then
        volume=$(bc<<<"scale=3;$volume/100.0")
    fi

    echo $volume

    playlist_dir="./playlists/$playlist/"
    playlist_len="$(ls "$playlist_dir" | wc -l)"

    rng_idx=$((RANDOM%playlist_len + 1))
    current_song=$( cat $PLAYLIST_DB | 
                    grep "$rng_idx" | 
                    sed -e 's/^ *[0-9]*	//')

    # Initializing/preformatting database
    ls "$playlist_dir" -1 | \
    sed -e 's/\.mp3$//' | \
    nl | \
    sed -e 's/ *//' > $PLAYLIST_DB 

    play_music "-s $current_song -v $volume" 2> /dev/null&
}

# Main recursive play function
function play_music () {
    # Processing arguements
    current_song=$NULL
    for input in "$@"; do
        case $input in
            "-v") 
                shift; volume=$1; shift;;
            "-s") 
                shift; current_song=$1; shift;;
            *) 
                shift;;
        esac
    done

    # Randomise values for first iteration - after being called from <start_music()>
    rng_idx=$((RANDOM%playlist_len + 1))
    current_song=$( cat $PLAYLIST_DB | 
                    grep "$rng_idx" | 
                    sed -e 's/^ *[0-9]*	//')

    # Randomise values for next iteration
    next_song=$current_song
    while [[ "$next_song" == "$current_song" ]]; do
        rng_idx=$((RANDOM%playlist_len + 1))
        next_song=$(cat $PLAYLIST_DB | 
                    grep "$rng_idx" | 
                    sed -e 's/^ *[0-9]*	//')
    done

    # A "Now Playing" banner
    if [[ $popup_flag -eq 0 ]]; then
        kdialog \
            --icon audio-headphones-symbolic \
            --title "Now playing: $current_song." \
            --passivepopup "Playing next: $next_song."
    fi

    # Play and exit/continue recursion
    play -v "$volume" "$playlist_dir$current_song.mp3"
    exitcode=$?
    if [[ exitcode -eq $ERROR ]]; then
        exit
    else 
        play_music "-s $next_song -v $volume"
    fi
}

function play_phase_sfx { 
    exec 2>/dev/null
    pkill -9 "play"

    case $1 in
        "0") 
            play $SFX_START;;
        "1") 
            play $SFX_SHORT;;
        "2") 
            play $SFX_LONG;;
        "3")
            play $SFX_END;;
    esac&
}
