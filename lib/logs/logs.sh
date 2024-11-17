#!/bin/bash
# Functions regarding the main "Logs" functionality


# Prints out the file provided
# PARAM - ${1} - File to be printed
function sogelogs_print_log() {
    file=${1}

    _sogelogs_print_hash_bar
    while IFS= read -r line; do
        if [[ "$line" == *"SOGE_WORKOUT"* ]]; then
            modified_line=$(echo "$line"  | sed 's/SOGE_WORKOUT//')
            _print_workout_string ${modified_line}
        else
            echo "${line}"
        fi
    done < "${file}"
    _sogelogs_print_hash_bar
    echo -e "\n"
}

# Creates a log file at ${LOGS_DIRECTORY}/${current_date}.txt
# If no PARAMs are provided then the user gets an open prompt
# PARAM - ${1} - OPTIONAL - Appends to the log 
function sogelogs_new_entry() {
    current_date=$(date +"%Y-%m-%d")
    current_time=$(date +"%H:%M:%S")
    filename="${LOGS_DIRECTORY}/${current_date}.txt"

    # If file exists (Date)
    if [ -e "${filename}" ]; then
        echo -e "${CYAN}${current_time}${CLEAR}" >> ${filename}
    else 
        echo -e "${BLUE}${current_date}${CLEAR} - ${CYAN}${current_time}"${CLEAR} >> ${filename}
    fi 

    # Input handling
    if [ $# -eq 0 ]; then 
        echo -e "${YELLOW}When finished: CTRL+D${CLEAR}"
        cat >> ${filename}
    else 
        echo "${1}" >> ${filename}
    fi 
  
    echo -e "\n\n" >> ${filename}
}

# Function to print all logs -> Eventually add functionality for date ranges, other search features(?)
function sogelogs_print_logs() {
    all_logs=""

    for file in ${LOGS_DIRECTORY}/*.txt; do
        all_logs+="$(_sogelogs_print_hash_bar)"
        all_logs+="$(<${file})${NEWLINE}"
    done

    echo "${all_logs}" | less -R
}