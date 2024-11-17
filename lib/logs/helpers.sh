#!/bin/bash
# Helper functions for the "Logs" functionality


# Function to search through sogelogs for a certain prefixed pattern 
# PARAM - ${1} - Pattern to search for 
# PARAM - ${2} - Optional - If provided, just print a random value from all the patterns matched
function search_prefix() {
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

# Can add a "Prefix" to a log
# Appends the prefix before open user input 
# PARAM - ${1} - "prefix" to track before input
function new_prefix() {
    statistic=${1}

    echo -e "${YELLOW}When finished: CTRL+D${CLEAR}" >&2
    user_input=$(cat)

    # Replace actual newlines with the string '\n'
    converted_input=$(echo "${user_input}" | awk '{printf "%s\\n", $0}')
    converted_input=$(echo "${converted_input}" | sed 's/\\n$//') # Remove the last '\n'

    echo -n "${statistic}${converted_input}"
}

# Prints every instance of the prefix with a numerical value in front
# PARAM - ${1} - Prefix to search for and print
function print_all_prefix() {
    search_string=${1}
    matches=()
    count=0

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
        _sogelogs_print_hash_bar
        echo -e "${CYAN}${search_string}S${CLEAR}"
        _sogelogs_print_hash_bar
        for match in "${matches[@]}"; do
            ((count++))
            echo -e "${count}: ${match}"
        done
        _sogelogs_print_hash_bar
    fi
}

# Function to print out navigation commands to move through logs
function all_log_navigation() {
    echo -e "${CYAN}Navigate${CLEAR} 
    Up/Down Arrow: Move one line up or down.
    Fn+Up/Fn+Down Arrow: Move one page up or down.
    Spacebar: Move one page down.
    b: Move one page up.
    g: Go to the beginning of the file.
    G: Go to the end of the file.
${CYAN}Search:${CLEAR}
    /pattern: Search forward for a pattern.
    ?pattern: Search backward for a pattern.
    n: Repeat the last search forward.
    N: Repeat the last search backward.
${CYAN}Exit:${CLEAR}
    q: Quit.
${CYAN}Line Numbers:${CLEAR}
    -N: Display line numbers.
${CYAN}Case-Insensitive Search:${CLEAR}
    -I: Ignore case when searching.
"
}