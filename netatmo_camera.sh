#!/bin/bash

# Netatmo API Parameters
client_id="Your_Client_ID"
client_secret="Your_Client_Secret"
refresh_token="Your_Refresh_Token"

# Log file path
log_file="/path/to/your/logfile.log"

# Function to log messages with timestamp
function log_message {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Function to get the access token using the refresh_token
function get_access_token {
    response=$(curl -s -X POST -d "grant_type=refresh_token&client_id=$client_id&client_secret=$client_secret&refresh_token=$refresh_token" "https://api.netatmo.net/oauth2/token")
    access_token=$(echo $response | jq -r '.access_token')
    if [ -z "$access_token" ]; then
        log_message "Failed to obtain access token."
        exit 1
    fi
    echo $access_token
}

# Function to check the current status of a specific camera
function check_camera_status {
    local camera_name=$1
    local expected_mode=$2
    local access_token=$(get_access_token)
    
    # Get the camera data
    camera_data=$(curl -s -X GET "https://api.netatmo.net/api/gethomedata?access_token=$access_token&size=50")
    
    # Extract the status of the camera based on its name
    camera_status=$(echo $camera_data | jq -r --arg cam_name "$camera_name" '.body.homes[0].cameras[] | select(.name == $cam_name) | .status')
    
    if [[ "$camera_status" == "$expected_mode" ]]; then
        return 0 # Success
    else
        return 1 # Failure
    fi
}

# Function to enable or disable monitoring of a specific camera with retry logic
function set_monitoring {
    local camera_name=$1
    local mode=$2
    local access_token=$(get_access_token)
    local max_retries=3
    local retry_delay=5
    local check_delay=10 # Delay to allow the camera to change status
    
    for ((retry=1; retry<=max_retries; retry++)); do
        # Attempt to change the monitoring status
        camera_data=$(curl -s -X GET "https://api.netatmo.net/api/gethomedata?access_token=$access_token&size=50")
        camera_vpn_url=$(echo $camera_data | jq -r --arg cam_name "$camera_name" '.body.homes[0].cameras[] | select(.name == $cam_name) | .vpn_url')
        if [ -z "$camera_vpn_url" ]; then
            log_message "Camera $camera_name not found. Exiting."
            exit 1
        fi
        request_url="${camera_vpn_url}/command/changestatus?status=$mode"
        response=$(curl -s -X GET "$request_url" -H "Authorization: Bearer $access_token")
        log_message "Attempt #$retry: Monitoring status change response: $response"
        
        sleep $check_delay # Wait for the camera to potentially change status
        
        # Check the actual status of the camera
        if check_camera_status "$camera_name" "$mode"; then
            log_message "Monitoring status successfully verified as $mode for camera $camera_name."
            return 0
        else
            log_message "Monitoring status verification failed for camera $camera_name. Status not $mode. Retrying in $retry_delay seconds..."
            sleep $retry_delay
        fi
    done
    
    log_message "Failed to verify monitoring status as $mode for camera $camera_name after $max_retries attempts."
    return 1
}

# Use the function
# Replace "Your_Camera" with the actual name of your Netatmo camera.
set_monitoring "Your_Camera" "on"
