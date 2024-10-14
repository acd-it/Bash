#!/bin/bash

###################

## ACD -
## Reboot Machine Script ##

## This script is used to prompt the user to reboot their computer. The user can choose between
## 5, 15, or 30 minutes to reboot their computer. If the window is moved and the user does not
## interact with the window, the script exits and the computer reboots in 5 minutes.

#Message type variables below

#Utility window gives a white background
window="utility"
title="Reboot Imminent"
heading="Reboot Imminent"
description="Your computer has not been restarted in over 30 days.

Per our reboot policy, a reboot is required. 

Please choose a reboot option below. If no option is selected, a reboot will happen in 5 minutes."

icon="/usr/local/marley-logo.png"

selection=$("/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType "$window" -title "$title" -heading "$heading" -description "$description" -icon "$icon" -button1 "Restart" -showDelayOptions "300, 900, 1800" -timeout 300 -defaultButton 1)

buttonClicked="${selection:$i-1}"
timeChosen="${selection%?}"

## Convert seconds to minutes for restart command
timeMinutes=$((timeChosen/60))

## Echoes for troubleshooting purposes
echo "Button clicked was: $buttonClicked"
echo "Time chosen was: $timeChosen"
echo "Time in minutes: $timeMinutes"

if [[ "$buttonClicked" == "1" ]] && [[ ! -z "$timeChosen" ]]; then
    osascript -e "display notification \"Your computer will restart in $timeMinutes minutes\" with title \"Reboot Imminent\""
    sleep 10
    shutdown -r +${timeMinutes}
elif [[ "$buttonClicked" == "1" ]] && [[ -z "$timeChosen" ]]; then
    osascript -e 'display notification "Your computer will restart immediately" with title "Reboot Imminent"'
    sleep 10
    shutdown -r now
elif [[ "$buttonClicked" == "0" ]]; then
    osascript -e 'display notification "Your computer will restart in 5 minutes due to no response" with title "Reboot Imminent"'
    sleep 10
    shutdown -r +5
fi

exit