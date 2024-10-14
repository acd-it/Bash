#!/bin/bash

## ACD - 
## Rename One Machine Script ##

## This script is for IT Admins to manually use to rename one machine. This can helpful
## when a user has more than one machine, is using a loaner, or we want a machine to have a specific name.


# Replace with machine name
username="computername"

# Set HostNames
scutil --set HostName $username
scutil --set LocalHostName $username
scutil --set ComputerName $username

#Run a recon to JAMF
sudo jamf recon