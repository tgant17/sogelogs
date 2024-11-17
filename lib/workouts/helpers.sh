#!/bin/bash
# Helper functions for the "Workouts" functionality


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
    echo -e "${RED}${title}${CLEAR}"

    # Remove the title from the string
    workout_string="${input_string#*-}"

    # Split the workout string by '-'
    IFS='-' read -ra workouts <<< "${workout_string}"

    # Loop through the workouts array and parse each workout:reps pair
    for workout in "${workouts[@]}"; do
        # Extract workout name and reps
        workout_name="${workout%%:*}"
        reps="${workout#*:}"
        echo -e "  ${CLEAR}* $(_capitalize_first_letter ${workout_name}): ${CYAN}${reps}${CLEAR}"
    done
}

# Helper function that prints a specific workout from a workout_string
# PARAM - ${1} - Workout to search for 
# PARAM - ${2} - All workouts in a specific format 
#   EX: SOGE_WORKOUT Jawns-Pushups:1000-Pullups:1000-1000 Touches:1
# RETURN - String of Workout and Reps 
function _get_workout() {
    search_string=${1}
    workout_string=${2}


    IFS='-' read -ra workouts <<< "${workout_string}"  # Split the workout string by '-'
    for workout in "${workouts[@]}"; do
        # Extract workout name and reps
        workout_name="${workout%%:*}"
        reps="${workout#*:}" 

        if [[ "${search_string}" == "${workout_name}" ]]; then 
            workout_name_capital="$(_capitalize_first_letter ${workout_name})"
            echo -e "${GREEN}${workout_name_capital}${CLEAR}: ${reps}"
        fi 
    done
}