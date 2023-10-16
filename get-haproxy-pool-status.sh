#!/bin/bash

# Nagios exit codes
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

# Check if two arguments (URL and filter) are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <haproxy_stats_url> <filter_group_name>"
    exit $UNKNOWN
fi

# URL of the HAProxy stats page
stats_url="$1;csv"

# Filter value for the first column (group name)
filter_group_name="$2"

# Initialize the NAGIOS_STATUS and NAGIOS_COMMENT variables
NAGIOS_STATUS=$OK
NAGIOS_COMMENT="$2 is UP"

# Define a function to extract and filter CSV data from HAProxy stats
extract_and_filter_haproxy_stats() {
    # Fetch the HAProxy stats page using curl
    csv_data=$(curl -s "$1")
    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to fetch HAProxy stats from $1"
        exit $CRITICAL
    fi

    # Filter CSV data based on the provided group name
    filtered_data=$(echo "$csv_data" | awk -F ',' -v filter="$2" '$1 == filter {print $2 "," $18}')
    # Check if any row has "BACKEND" in column 2 and "DOWN" status in column 18
    if [[ "$filtered_data" == *"BACKEND,DOWN"* ]]; then
        filtered_data2=$(echo "$filtered_data" | tr '\n\r' ';')
        NAGIOS_STATUS=$CRITICAL
        NAGIOS_COMMENT="Pool $2 DOWN: $filtered_data2"
        
    # Check if any row has a value other than "BACKEND" in column 2 and "DOWN" status in column 18
    elif [[ "$filtered_data" == *",DOWN"* ]]; then
        filtered_data2=$(echo "$filtered_data" | tr '\n\r' ';')
        NAGIOS_STATUS=$WARNING
        NAGIOS_COMMENT="$filtered_data2"
    # Check if any row has "BACKEND" in column 2 and "UP" status in column 18
    elif [[ "$filtered_data" == *"BACKEND,UP"* ]]; then
        NAGIOS_STATUS=$OK
        NAGIOS_COMMENT="$2 is up"
    fi

    # Print the filtered CSV data
    
#    echo "$filtered_data" | tr '\n\r' ';'
}

# Call the function to extract and filter CSV data from HAProxy stats
extract_and_filter_haproxy_stats "$stats_url" "$filter_group_name"

# Return Nagios status and comment
echo "Status: $NAGIOS_STATUS - $NAGIOS_COMMENT"
exit $NAGIOS_STATUS

