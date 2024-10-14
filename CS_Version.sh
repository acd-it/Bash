#!/bin/bash

# Command to get the version with 'version: ' prefix
output=$(sudo /Applications/Falcon.app/Contents/Resources/falconctl stats | grep 'version')

# Use awk to remove the 'version: ' prefix and print only the version number
sensor_version=$(echo "$output" | awk '{print $2}')

# Check if we successfully retrieved the version
if [[ -n "$sensor_version" ]]; then
	echo "<result>$sensor_version</result>"
    else
    echo "<result>""</result>"
fi