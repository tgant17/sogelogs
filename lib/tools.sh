#!/bin/bash
# Various helper functions that can be used throughout the program 

# Function to capitalize the first letter of a string
function _capitalize_first_letter() {
    input="${1}"
    capitalized=$(echo "${input}" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')
    echo "${capitalized}"
}

# Function that concatenates an array with a given delimeter
# PARAM - ${1} - Array to concatenate 
# PARAM - ${2} - Delimeter
# RETURNS - <String> 
function _concat_array() {
    array_str="${1}"
    delim="${2}"
    concatenated=""
    IFS=' '  # Internal Field Separator for splitting the string into array elements

    # Read the string into an array
    read -r -a arr <<< "${array_str}"

    for element in "${arr[@]}"; do
        if [ -z "${concatenated}" ]; then
            concatenated="${element}"
        else
            concatenated="${concatenated}${delim}${element}"
        fi
    done

    echo "${concatenated}"
}

# Helper function to print hashbar for formatting
function _sogelogs_print_hash_bar() {
    terminal_width=$(tput cols)
    printf '#%.0s' $(seq 1 $terminal_width) 
    echo
}