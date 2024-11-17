#!/bin/bash
# Functions regarding the main "Workouts" functionality


# Function that tracks a workout in the following format through user prompts
# RETURNS - <String> - EX: SOGE_WORKOUT Jawns-Pushups:1000-Pullups:1000-1000 Touches:1
function sogelogs_track_workout() {
    read -p "$(echo -ne "${GREEN}Workout Name: ${CLEAR}")" workout_name
    echo -e "${YELLOW}When finished: CTRL+D${CLEAR}\n" >&2
    echo -e "${GREEN}Exercises${CLEAR}" >&2

    workout_string="SOGE_WORKOUT ${workout_name}"
    while true; do 
        exercise=""
        reps=""
        read -p "Exercise: " exercise 
        if [[ $? -ne 0 ]]; then
            CLEAR > /dev/null 2>&1; break
        else 
            # Append 
            lower_case_exercise=$(echo "${exercise}" | tr '[:upper:]' '[:lower:]')
            workout_string+="-${lower_case_exercise}"
        fi

        read -p "Reps    : " reps 
        if [[ $? -ne 0 ]]; then
            CLEAR; break
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

# Prints out the workout menu and waits for user input
function workout_menu() {
    # CLEAR the terminal only on first instance of menu
    if [ $# -eq 0 ]; then 
        CLEAR
        echo -e "${GREEN}Workout Menu!${CLEAR}"
    fi

    echo -ne "${CYAN}Options:${CLEAR}
    ${CYAN}1)${CLEAR} Record Workout 
    ${CYAN}2)${CLEAR} Workout Statistics (All Time) 
    ${CYAN}3)${CLEAR} back
    ${CYAN}0)${CLEAR} exit
    ${BLUE}\nChoose an Option: ${CLEAR}"
        read a 
        case $a in
            1) CLEAR ; sogelogs_new_entry "$(sogelogs_track_workout)" ; CLEAR ; workout_menu 1 ;;
            2) CLEAR ; _print_workout_string "$(sogelogs_workout_statistics)" ; workout_menu 1 ;;
            3) CLEAR ; menu 1 ;;
                0) CLEAR ; exit 0 ;;
                *) echo -e "${RED} Wrong option.${CLEAR}" WrongCommand ;;
        esac
}