#!/bin/bash
# shellcheck disable=SC1091
source math_utils.sh

NA_ALERT_FLAG=0

while [[ -n $0 ]]; do
    tmp=$(kdialog --inputbox "Enter full time for your work, in minutes. \n30~300 minutes is ideal")

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
            *)
                continue;;
        esac
    else
        break;
    fi
done
full_time=$tmp