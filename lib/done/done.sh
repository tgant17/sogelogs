#!/bin/bash
# Functions regarding the main "Done" functionality
# To track tasks that I did in a day. The end part of a todo list.

# Tracks the "Done List" in the logs
function track_done_list() {
    echo -e "${YELLOW}When finished: CTRL+D${CLEAR}\n" >&2
    echo -e "${GREEN}Completed Tasks${CLEAR}" >&2

    done_list_string="SOGE_DONE"

    while true; do 
        task=""
        read -p "Task: " task

        # Breaks out of the loop
        if [[ $? -ne 0 ]]; then
            CLEAR > /dev/null 2>&1; break
        else 
            # Append to done list
            lower_case_task=$(echo "${task}" | tr '[:upper:]' '[:lower:]')

            if [[ ${done_list_string} == 'SOGE_DONE' ]]; then
                done_list_string+="${lower_case_task}"
            else 
                done_list_string+=",${lower_case_task}"
            fi
        fi
    done 
    echo ${done_list_string}
}

# Gets all the completed tasks
function get_all_tasks() {
    search_string="SOGE_DONE"

    for file in ${LOGS_DIRECTORY}/*.txt; do 
        while IFS= read -r line; do 
            matches+=("${line}=")
        done < <(grep "^${search_string}" "${file}" | sed "s/^${search_string}//")
    done 

    # Check if the array is not empty
    if [ ${#matches[@]} -eq 0 ]; then
        echo "No matches found"
    else
        all_tasks=$(_concat_array "${matches[*]}" "," "=")
        echo "${all_tasks}"
    fi
}

# Done list statistics
# Prints 
#  Total task count
#  How many times each individual task has been completed 
function task_stats() {
    tasks_completed="$(_get_finished_task_count)"
    echo -e "${GREEN}Tasks Completed: ${tasks_completed}${CLEAR}"
    _count_tasks
}