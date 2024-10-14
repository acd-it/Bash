#!/bin/bash

## ACD - 
## Get Token Script ##

## This script will get a valid token from JAMF Pro API.
## The script will spit out your token which you can then add as a bearer token to other scripts that utilize the JAMF Pro API.


## WARNING: NEVER store your passwords in plaintext, replace hard coded
## credentials with reference to secret managers 


username="username" #Make references to secret managers
password="insert failover password" # Make references to secret managers
url="https://yourdomain.jamfcloud.com" #Make references to secret managers


#Variable declarations
bearerToken=""
tokenExpirationEpoch="0"

getBearerToken() {
	response=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST)
	bearerToken=$(echo "$response" | plutil -extract token raw -)
	tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
	tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}


checkTokenExpiration() {
    nowEpochUTC=$(date -j -f "%Y-%m-%dT%T" "$(date -u +"%Y-%m-%dT%T")" +"%s")
    if [[ tokenExpirationEpoch -gt nowEpochUTC ]]
    then
        echo "Token valid until the following epoch time: " "$tokenExpirationEpoch"
    else
        echo "No valid token available, getting new token"
        getBearerToken
    fi
}

getBearerToken

echo $bearerToken