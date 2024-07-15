#!/bin/bash
# Journal / Workout / Life / 
# Version .1 

# User Functionality 
# Opens Main Information Page 
# > sogelogs 

# Create a new entry (file named by date for later)
# > sogelogs -n 

# Workout Stats (Displays a list of all workouts for a given period)
# > sogelogs -s --workout

# Random Thought (Gets a random thought stored)
# > sogelogs -r


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

# Helper function to print 
function _sogelogs_print_hash_bar() {
    terminal_width=$(tput cols)
    printf '#%.0s' $(seq 1 $terminal_width) 
    echo
}

# Helper function to search through sogelogs for a certain pattern 
# PARAM - ${1} - pattern to search for 
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

# Prints the file provided in the first argument 
function sogelogs_print_log() {
    _sogelogs_print_hash_bar
    cat $1
    _sogelogs_print_hash_bar
    echo -e "\n"
}


# Creates a log file at ~/Scripts/sogelogs/logs/${currentDate}.txt
function sogelogs_new_entry() {
    current_date=$(date +"%Y-%m-%d")
    current_time=$(date +"%H:%M:%S")
    filename="./logs/${current_date}.txt"

    if [ -e "${filename}" ]; then
        echo -e "${cyan}${current_time}${clear}" >> ${filename}
        echo -e "${yellow}When finished: CTRL+D${clear}"
        cat >> ${filename}
        echo -e "\n\n" >> ${filename}
    else
        echo -e "${blue}${current_date}${clear} - ${cyan}${current_time}"${clear} >> ${filename}
        cat >> ${filename}
        echo -e "\n\n" >> ${filename}
    fi
    clear
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

function menu() {
    # Clear the terminal only on first instance of menu
    if [ $# -eq 0 ];
        then 
            clear
            echo -e "${green}Welcome to Sogelogs!${clear}"
    fi

    most_recent_file=$(ls -t "./logs" | head -n 1)

    echo -ne "${cyan}Options:${clear}
    ${cyan}1)${clear} New log 
    ${cyan}2)${clear} View Most Recent log
    ${cyan}3)${clear} Get a Random Thought :)
    ${cyan}4)${clear} help
    ${cyan}0)${clear} exit
    ${blue}\nChoose an Option: ${clear}"
        read a 
        case $a in
            1) clear ; sogelogs_new_entry ; menu 1 ;;
            2) clear ; sogelogs_print_log "./logs/${most_recent_file}"  ; menu 1 ;;
            3) clear ; sogelogs_search_logs "SOGE_THOUGHT" -r ; menu 1 ;;
            4) clear ; sogelogs_help ; menu 1 ;;
                0) clear ; exit 0 ;;
                *) echo -e "${red} Wrong option.${clear}" WrongCommand ;;
        esac
}

function parse_command_line_options() {
    # variables 
    n_flag=false
    r_flag=false

    while getopts ":hnr" opt; do 
        case "${opt}" in 
            h) sogelogs_help ;;
            n) n_flag=true ;;
            r) r_flag=true ;;
            :) menu ;;
            \?) echo -e "${red} Invalid Flag -${opt}.${clear}" WrongCommand ;;
        esac
    done 

    # Shift to next arguement
    shift $((OPTIND-1))

    # Process remaining arguments if any
    # if [ $# -gt 0 ]; then
    #     echo "Remaining arguments: $@"
    # fi

    if $n_flag; then 
        sogelogs_new_entry
    fi

    if $r_flag; then 
        sogelogs_search_logs "SOGE_THOUGHT" -r 
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