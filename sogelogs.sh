#!/bin/bash
# Journal / Workout / Life / 
# Version .1 

# User Functionality 
# Opens Main Information Page 
# > sogelogs 

# Workout Stats (Displays a list of all workouts for a given period)
# > sogelogs -s --workout

# Go back and mkdir logs/ if it DNE

# Add in ability to create new workout from command line -n --workout

# Go back and make all variables local or maybe global?


## 
# Color Variables 
## 
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[35m'
cyan='\033[36m'
gray='\033[37m'
clear='\033[0m'

##
# Helper Functions 
## 

# Helper function to print 
function _sogelogs_print_hash_bar() {
    terminal_width=$(tput cols)
    printf '#%.0s' $(seq 1 $terminal_width) 
    echo
}

# Helper function to capitalize the first letter of a string
function _capitalize_first_letter() {
    input="${1}"
    capitalized=$(echo "${input}" | awk '{print toupper(substr($0, 1, 1)) tolower(substr($0, 2))}')
    echo "${capitalized}"
}

# Helper function that concatenates an array with a given delimeter
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

# Helper function to update an array 
# PARAM - ${1} - Array to update 
# PARAM - ${2} - Name of value to update
# PARAM - ${3} - Number to increase value by
function _update_workout_reps() {
    arr_name="$1"
    name="${2}"
    add="${3}"
    updated=0

    eval "arr=(\"\${${arr_name}[@]}\")"

    for i in "${!arr[@]}"; do
        if [[ "${arr[i]%%:*}" == "${name}" ]]; then
            curr_val="${arr[i]#*:}"
            new_val=$((curr_val + add))
            arr[i]="${name}:${new_val}"
            updated=1
            break
        fi
    done

    if [[ $updated -eq 0 ]]; then
        arr+=("${workout_name}:${add}")
    fi

    eval "${arr_name}=(\"\${arr[@]}\")"
}

# Helper function to print out workout string
function _print_workout_string() {
    input_string="${1}"

    # Extract the title
    title="${input_string%%-*}"
    echo -e "${red}${title}${clear}"

    # Remove the title from the string
    workout_string="${input_string#*-}"

    # Split the workout string by '-'
    IFS='-' read -ra workouts <<< "${workout_string}"

    # Loop through the workouts array and parse each workout:reps pair
    for workout in "${workouts[@]}"; do
        # Extract workout name and reps
        workout_name="${workout%%:*}"
        reps="${workout#*:}"
        echo -e "  ${clear}* $(_capitalize_first_letter ${workout_name}): ${cyan}${reps}${clear}"
    done
}

## 
# Main Functionality functions 
## 

# Function that tracks a workout in the following format through user prompts
# RETURNS - <String> - EX: SOGE_WORKOUT Jawns-Pushups:1000-Pullups:1000-1000 Touches:1
function sogelogs_track_workout() {
    read -p "$(echo -ne "${green}Workout Name: ${clear}")" workout_name
    echo -e "${yellow}When finished: CTRL+D${clear}\n" >&2
    echo -e "${green}Exercises${clear}" >&2

    workout_string="SOGE_WORKOUT ${workout_name}"
    while true; do 
        exercise=""
        reps=""
        read -p "Exercise: " exercise 
        if [[ $? -ne 0 ]]; then
            clear > /dev/null 2>&1; break
        else 
            # Append 
            lower_case_exercise=$(echo "${exercise}" | tr '[:upper:]' '[:lower:]')
            workout_string+="-${lower_case_exercise}"
        fi

        read -p "Reps    : " reps 
        if [[ $? -ne 0 ]]; then
            clear; break
        else
            workout_string+=":${reps}"
        fi
        echo -e "\n" >&2
    done

    echo ${workout_string}
}

# Gets all workout statistics from the log 
# RETURNS - <String> - EX: Statistics-Pushups:1000-Pullups:1000-1000 Touches:1
function sogelogs_workout_statistics() {
    search_string="SOGE_WORKOUT"
    title="Workout Statistics"

    for file in ./logs/*.txt; do
        # Find lines that start with the search string, remove the search string, and add to matches array
        while IFS= read -r line; do
            matches+=("$line")
        done < <(grep "^${search_string}" "$file" | sed "s/^${search_string}//")
    done

    # Check if the array is not empty
    if [ ${#matches[@]} -eq 0 ]; then
        echo "No matches found"
    else
        workouts_map=() # Declare an array
        for match in "${matches[@]}"; do
            workout_string="${match#*-}" # Remove the title from the string

            IFS='-' read -ra workouts <<< "${workout_string}"  # Split the workout string by '-'
            for workout in "${workouts[@]}"; do
                # Extract workout name and reps
                workout_name="${workout%%:*}"
                reps="${workout#*:}" 

                _update_workout_reps workouts_map "${workout_name}" $(( $reps ))
            done
        done


        result=$(_concat_array "${workouts_map[*]}"  "-")
        echo "${title}-${result}"
    fi
}

# Function to search through sogelogs for a certain pattern 
# PARAM - ${1} - Pattern to search for 
# PARAM - ${2} - If it exists, just print a random value
function sogelogs_search_logs() {
    search_string=${1}
    random_value=${2}
    matches=()
    returnString=""

    for file in ./logs/*.txt; do
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
            echo -e "${green}${matches[$random_index]}${clear}"
        fi
    fi
}

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

# Creates a log file at ~/Scripts/sogelogs/logs/${currentDate}.txt
# If no PARAMs are provided then the user gets an open prompt
# PARAM - ${1} - OPTIONAL - Appends to the log 
function sogelogs_new_entry() {
    current_date=$(date +"%Y-%m-%d")
    current_time=$(date +"%H:%M:%S")
    filename="./logs/${current_date}.txt"

    # If file exists (Date)
    if [ -e "${filename}" ]; then
        echo -e "${cyan}${current_time}${clear}" >> ${filename}
    else 
        echo -e "${blue}${current_date}${clear} - ${cyan}${current_time}"${clear} >> ${filename}
    fi 

    # Input handling
    if [ $# -eq 0 ]; then 
        echo -e "${yellow}When finished: CTRL+D${clear}"
        cat >> ${filename}
    else 
        echo "${1}" >> ${filename}
    fi 
  
    echo -e "\n\n" >> ${filename}
}

function sogelogs_help() {
    echo -e "${red}HELP${red}
    ${green}Opens Main Information Page${clear}
      > sogelogs 

    ${green}Create a new entry${clear}
      > sogelogs -n 

    ${green}Workout Stats (Displays a list of all workouts for a given period)${clear}
      > sogelogs -s --workout

    ${green}Random Thought (Gets a random thought stored)${clear}
      > sogelogs -r
      \n\n\n
    "
}

## 
# Menus 
## 

function workout_menu() {
    # Clear the terminal only on first instance of menu
    if [ $# -eq 0 ]; then 
        clear
        echo -e "${green}Workout Menu!${clear}"
    fi

    echo -ne "${cyan}Options:${clear}
    ${cyan}1)${clear} Record Workout 
    ${cyan}2)${clear} Workout Statistics (All Time) 
    ${cyan}3)${clear} back
    ${cyan}0)${clear} exit
    ${blue}\nChoose an Option: ${clear}"
        read a 
        case $a in
            1) clear ; sogelogs_new_entry "$(sogelogs_track_workout)" ; clear ; workout_menu 1 ;;
            2) clear ; _print_workout_string "$(sogelogs_workout_statistics)" ; workout_menu 1 ;;
            3) clear ; menu 1 ;;
                0) clear ; exit 0 ;;
                *) echo -e "${red} Wrong option.${clear}" WrongCommand ;;
        esac
}

function menu() {
    # Clear the terminal only on first instance of menu
    if [ $# -eq 0 ]; then 
        clear
        echo -e "${green}Welcome to Sogelogs!${clear}"
    fi

    most_recent_file=$(ls -t "./logs" | head -n 1)

    echo -ne "${cyan}Options:${clear}
    ${cyan}1)${clear} New log 
    ${cyan}2)${clear} View Most Recent log
    ${cyan}3)${clear} Get a Random Thought :)
    ${cyan}4)${clear} Record Workout
    ${cyan}5)${clear} Workout Menu
    ${cyan}6)${clear} help
    ${cyan}0)${clear} exit
    ${blue}\nChoose an Option: ${clear}"
        read a 
        case $a in
            1) clear ; sogelogs_new_entry ; menu 1 ;;
            2) clear ; sogelogs_print_log "./logs/${most_recent_file}"  ; menu 1 ;;
            3) clear ; sogelogs_search_logs "SOGE_THOUGHT" -r ; menu 1 ;;
            4) clear ; sogelogs_new_entry "$(sogelogs_track_workout)" ; clear ; menu 1 ;;
            5) clear ; workout_menu ; menu 1 ;;
            6) clear ; sogelogs_help ; menu 1 ;;
                0) clear ; exit 0 ;;
                *) echo -e "${red} Wrong option.${clear}" WrongCommand ;;
        esac
}

function parse_command_line_options() {
    # variables 
    n_flag=false
    r_flag=false
    s_flag=false
    s_workout=""

    # Parse options 
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h)
                sogelogs_help
                exit 0
                ;;
            -n)
                n_flag=true
                shift
                ;;
            -r)
                r_flag=true
                shift
                ;;
            -s)
                s_flag=true
                shift
                if [[ "$1" == "--workout" ]]; then
                    if [ -n "$2" ] && [[ "$2" != -* ]]; then
                        s_workout=$2
                        shift 2
                    else
                        s_workout="default_workout_value" # Set a default value if no argument is provided
                        shift
                    fi
                fi
                ;;
            --workout)
                echo "Error: --workout option can only be used with -s."
                exit 1
                ;;
            *)
                echo -e "${red} Invalid option $1.${clear}"
                exit 1
                ;;
        esac
    done

    # Shift to next arguement
    shift $((OPTIND-1))


    # Creating Logs 
    if $n_flag; then 
        sogelogs_new_entry
    fi

    # Random Searches 
    if $r_flag; then 
        sogelogs_search_logs "SOGE_THOUGHT" -r 
    fi

    # Statistics 
    if $s_flag; then  
        if [ "${s_workout}" == "default_workout_value" ]; then
            _print_workout_string "$(sogelogs_workout_statistics)"
        elif [ -n "${s_workout}" ]; then 
            echo "${s_workout}"
        else 
            echo -e "${red}Invalid Argument${clear}"
            echo "-s (Statistics) flag takes the following arguements"
            echo ""
            echo "--workout    Gets all workout statistics" 
        fi
    fi
}

function main() {
    # No arguements -- Open menu
    if [ $# -eq 0 ]; then
        menu
        return
    fi

    parse_command_line_options "$@"
}

main "$@"