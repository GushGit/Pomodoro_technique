#!/bin/bash

function max {
    if [[ $# -ne 2 ]]; then
        echo "Function min takes two values."
        exit # Intentional
    fi

    a=$1
    b=$2
    if [[ a -gt b ]]; then
        echo "$a"
        return 0
    fi
    echo "$b"
}

function is_bounded {
    if [[ $# -ne 3 ]]; then
        echo "Function is_bounded takes three values: n, l, r"
        exit # Intentional
    fi

    n=$1
    l=$2
    r=$3
    if [[ n -ge l && n -le r ]]; then
        return 0
    fi
    return 1
}
