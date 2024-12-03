#!/bin/bash
# Various helper functions that can be used throughout the program 

# Function to capitalize the first letter of a string
function _capitalize_first_letter() {
    input="${1}"
    capitalized=""

    read -a words <<< "${input}"

    for word in "${words[@]}"; do 
        capitalized+=$(echo "${word} " | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')
    done 

    echo "$(_trim_whitespace "${capitalized}")"
}

# Function that concatenates an array with a given delimeter
# PARAM - ${1} - Array to concatenate 
# PARAM - ${2} - Delimeter
# PARAM - ${3} - IFS value - Optional
# RETURNS - <String> 
function _concat_array() {
    array_str="${1}"
    delim="${2}"
    concatenated=""
    
    # IFS value not specified
    if [ -z "$3" ]; then 
        IFS=' '  # Internal Field Separator for splitting the string into array elements
    else 
        IFS=${3}
    fi

    # Read the string into an array
    read -ra arr <<< "${array_str}"

    for element in "${arr[@]}"; do
        temp_element=$(_trim_whitespace "${element}")
        if [ -z "${concatenated}" ]; then
            concatenated="${temp_element}"
        else
            concatenated="${concatenated}${delim}${temp_element}"
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

# Trims leading and trailing whitespace from a string
function _trim_whitespace() {
    echo -e "${1}" | sed "s/^[ $(printf '\t')]*//;s/[ $(printf '\t')]*$//"
}