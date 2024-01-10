#!/bin/bash

# Netatmo API Parameters
client_id="Your_Client_ID"
client_secret="Your_Client_Secret"
refresh_token="Your_Refresh_Token"

# Log file path
log_file="logfile.log"

# Function to log messages with timestamp
function log_message {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Function to get the access token using the refresh_token
function get_access_token {
    response=$(curl -s -X POST -d "grant_type=refresh_token&client_id=$client_id&client_secret=$client_secret&refresh_token=$refresh_token" "https://api.netatmo.net/oauth2/token")
    access_token=$(echo $response | jq -r '.access_token')
    log_message "Access token obtained: $access_token"
    echo $access_token
}

# Function to enable or disable monitoring of a specific camera
function set_monitoring {
    local camera_name=$1
    local mode=$2 # 'on' or 'off'
    local access_token=$(get_access_token)

    # Get the camera data
    camera_data=$(curl -s -X GET "https://api.netatmo.net/api/gethomedata?access_token=$access_token&size=50")

    # Extract the ID and VPN URL of the camera based on its name
    camera_id=$(echo $camera_data | jq -r --arg cam_name "$camera_name" '.body.homes[0].cameras[] | select(.name == $cam_name) | .id')
    camera_vpn_url=$(echo $camera_data | jq -r --arg cam_name "$camera_name" '.body.homes[0].cameras[] | select(.name == $cam_name) | .vpn_url')

    # Build the request URL to change the monitoring status
    if [ "$mode" == "on" ] || [ "$mode" == "off" ]; then
        request_url="${camera_vpn_url}/command/changestatus?status=$mode"
        # Send the request to change the monitoring status
        response=$(curl -s -X GET "$request_url" -H "Authorization: Bearer $access_token")
        log_message "Monitoring status change response: $response"

        # Check if the response contains "status":"ok" or "error"
        if [[ $response == *'"status":"ok"'* ]]; then
            log_message "Monitoring status changed successfully to $mode for camera $camera_name."
        elif [[ $response == *'"error"'* ]]; then
            log_message "Failed to change monitoring status for camera $camera_name. Response: $response"
        fi
    else
        log_message "Unsupported mode: $mode"
        echo "Unsupported mode"
    fi
}

# Use the function
# set_monitoring "Name_Of_Your_Camera" "on" or "off"
set_monitoring "Your_Camera" "on"
