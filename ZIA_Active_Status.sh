#!/bin/bash


## ACD - 
## Check if ZScaler ZIA is On Script
## This script reads the status log files and determines if the user is connected via ZIA,
## by checking the WebSecurityTime in the most recently modified log file.

# Initialize a variable to track connection status
connected="Not Connected"
latest_file=""
latest_time=""

# Find all ztstatus log files and their last modified dates
while IFS= read -r Logfile; do
    if [ -f "$Logfile" ]; then
        ModifiedTime=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$Logfile")

        # Check if this file is the most recently modified
        if [[ -z "$latest_time" || "$ModifiedTime" > "$latest_time" ]]; then
            latest_time="$ModifiedTime"
            latest_file="$Logfile"
        fi
    fi
done < <(find /Library/Application\ Support/Zscaler/ -name "ztstatus*")

# If a log file was found, check its WebSecurityTime
if [ -n "$latest_file" ]; then
    
    # Extract the Web Security Time
    WebSecurityTime=$(xmllint --xpath 'string(//key[text()="websecuritytime"]/following-sibling::string[1])' "$latest_file" 2>/dev/null)

    # Determine connection status based on WebSecurityTime
    if [[ $WebSecurityTime =~ ^[0-9]+$ ]]; then
        if [[ $WebSecurityTime != "0" ]]; then
            connected="Connected"
        fi
    else
        echo "Debug: WebSecurityTime is not numeric."
    fi
else
    echo "No log files found."
fi

# Output the result
echo "<result>$connected</result>"

exit 0