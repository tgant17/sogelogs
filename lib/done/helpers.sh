#!/bin/bash
# Helper functions for the "Done" functionality


# Gets total count of finished tasks
# RETURNS - <Number>
function _get_finished_task_count() {
    finished_tasks=$(get_all_tasks)
    count=0

    IFS=',' read -ra tasks <<< "${finished_tasks}"
    echo ${#tasks[@]}
}

# Gets all tasks, counts them, and prints out result
function _count_tasks() {
    finished_tasks=$(get_all_tasks)
    counted_tasks=()

    IFS=',' read -ra tasks <<< "${finished_tasks[@]}"

    for task in "${tasks[@]}"; do 
        index=-1
        formatted_task="$(_capitalize_first_letter "${task}")"
        # Check if task exists in the counted_tasks array
        for i in "${!counted_tasks[@]}"; do 
            arr_task="$(_trim_whitespace "${counted_tasks[i]%%:*}")" # loop variable
            temp_task="$(_trim_whitespace "${formatted_task}")" # passed in
            if [[ "${arr_task}" == "${temp_task}" ]]; then 
                index="${i}"
                break
            fi
        done 

        # Either add task to array or increment it's count
        if [[ "${index}" != "-1" ]]; then 
            curr_val="${counted_tasks[index]#*:}" # Gets count of value
            new_val=$(($curr_val + 1))
            counted_tasks[index]="${formatted_task}:${new_val}"
        else 
            counted_tasks+=("${formatted_task}:1")    
        fi
    done

    # Print each task
    for task in "${counted_tasks[@]}"; do
        # Extract task name and count
        task_name="${task%%:*}"
        count="${task#*:}"
        echo -e "  ${CLEAR}* ${task_name}: ${CYAN}${count}${CLEAR}"
    done
}
