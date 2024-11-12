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

# Function to search through sogelogs for a certain pattern 
# PARAM - ${1} - Pattern to search for 
# PARAM - ${2} - Optional - If provided, just print a random value from all the patterns matched
function _sogelogs_search_logs() {
    search_string=${1}
    random_value=${2}
    matches=()
    returnString=""

    for file in ${LOGS_DIRECTORY}/*.txt; do
        # Find lines that start with the search string, remove the search string, and add to matches array
        while IFS= read -r line; do
            matches+=("$line")
        done < <(grep "^${search_string}" "$file" | sed "s/^${search_string}//")
    done

    # Check if the array is not empty
    if [ ${#matches[@]} -eq 0 ]; then
        echo "No matches found"
    else
        # If random_value DNE 
        if [[ -z ${random_value} ]]; then
            for match in "${matches[@]}"; do
                echo -e "${match}"
            done
        else 
            random_index=$((RANDOM % ${#matches[@]}))
            echo -e "${GREEN}${matches[$random_index]}${CLEAR}"
        fi
    fi
}