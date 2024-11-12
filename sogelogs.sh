#!/bin/bash
# Journal / Workout / Life / 
# Version 0.1.1 

# Go back and mkdir logs/ if it DNE
# sogelogs -s --workout pushups -> has a bug where it needs to read all lowercase

# Global variable necessary to locate additional files from any terminal location 
CURRENT_DIRECTORY=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Source global variables
source "${CURRENT_DIRECTORY}/globals.sh"

# Source helper functions 
source "${CURRENT_DIRECTORY}/lib/tools.sh"

# Source "Logs" functions
source "${CURRENT_DIRECTORY}/lib/logs/helpers.sh"
source "${CURRENT_DIRECTORY}/lib/logs/logs.sh"

# Source "Workouts" functions 
source "${CURRENT_DIRECTORY}/lib/workouts/helpers.sh"
source "${CURRENT_DIRECTORY}/lib/workouts/workouts.sh"



function sogelogs_help() {
    echo -e "${RED}Options:${CLEAR}
        ${GREEN}-h${CLEAR},
            Display this help message and exit.

        ${GREEN}-n${CLEAR},
            Creates new log entry.
            ${CYAN}--workout${CLEAR}
                Prompts new workout entry.
            ${CYAN}--thought${CLEAR} 
                Prompts open text for a new thought.
            
        ${GREEN}-r${CLEAR},
            Gets a random thought.
            
        ${GREEN}-s${CLEAR}, ${CYAN}--workout${CLEAR} 
                Gets all workout statistics.
            ${CYAN}--workout${CLEAR} ${BLUE}<exercise>${CLEAR} 
                Gets workout statistic for specified exercise.
        "   
}

function menu() {
    # CLEAR the terminal only on first instance of menu
    if [ $# -eq 0 ]; then 
        CLEAR
        echo -e "${GREEN}Welcome to Sogelogs!${CLEAR}"
    fi

    most_recent_file=$(ls -t "${LOGS_DIRECTORY}" | head -n 1)

    echo -ne "${CYAN}Options:${CLEAR}
    ${CYAN}1)${CLEAR} New log 
    ${CYAN}2)${CLEAR} View Most Recent log
    ${CYAN}3)${CLEAR} Get a Random Thought :)
    ${CYAN}4)${CLEAR} Record Workout
    ${CYAN}5)${CLEAR} Workout Menu
    ${CYAN}6)${CLEAR} help
    ${CYAN}0)${CLEAR} exit
    ${BLUE}\nChoose an Option: ${CLEAR}"
        read a 
        case $a in
            1) CLEAR ; sogelogs_new_entry ; menu 1 ;;
            2) CLEAR ; sogelogs_print_log "${LOGS_DIRECTORY}/${most_recent_file}"  ; menu 1 ;;
            3) CLEAR ; _sogelogs_search_logs "SOGE_THOUGHT" -r ; menu 1 ;;
            4) CLEAR ; sogelogs_new_entry "$(sogelogs_track_workout)" ; CLEAR ; menu 1 ;;
            5) CLEAR ; workout_menu ; menu 1 ;;
            6) CLEAR ; sogelogs_help ; menu 1 ;;
                0) CLEAR ; exit 0 ;;
                *) echo -e "${RED} Wrong option.${CLEAR}" WrongCommand ;;
        esac
}

function parse_command_line_options() {
    # variables 
    n_flag=false
    n_workout=""
    n_thought=""
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
                if [[ "$1" == "--workout" ]]; then
                    n_workout="exist"
                    shift
                elif [[ "$1" == "--thought" ]]; then 
                    n_thought="exist"
                    shift
                fi
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
                echo -e "${RED} Invalid option $1.${CLEAR}"
                exit 1
                ;;
        esac
    done

    # Shift to next arguement
    shift $((OPTIND-1))


    # Creating Logs 
    if $n_flag; then 
        if [ "${n_workout}" == "exist" ]; then
            sogelogs_new_entry "$(sogelogs_track_workout)"
        elif [ "${n_thought}" == "exist" ]; then 
            sogelogs_new_entry "$(sogelogs_new_statistic "SOGE_THOUGHT")"
        else 
            sogelogs_new_entry
        fi
    fi

    # Random Searches 
    if $r_flag; then 
        _sogelogs_search_logs "SOGE_THOUGHT" -r 
    fi

    # Statistics 
    if $s_flag; then  
        if [ "${s_workout}" == "default_workout_value" ]; then
            _print_workout_string "$(sogelogs_workout_statistics)"
        elif [ -n "${s_workout}" ]; then 
            all=$(sogelogs_workout_statistics)
            echo "$(_get_workout ${s_workout} "${all}")"
        else 
            echo -e "${RED}Invalid Argument${CLEAR}"
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