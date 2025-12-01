#!/bin/bash
# Functions for writing prompts

PROMPT_PREFIX="SOGE_PROMPT"

# Sets global prompt metadata for the requested key
function _set_prompt_context() {
    local prompt_key="$1"

    case "${prompt_key}" in
        expressive)
            PROMPT_KEY="expressive"
            PROMPT_TITLE="Expressive Writing"
            PROMPT_COLOR="${MAGENTA}"
            PROMPT_DETAILS=$'When emotions feel heavy.\nI.E. A moment that lingers or stays on your mind.\nThe brain treats emotional suppression as unfinished work. Writing completes that loop.'
            ;;
        gratitude)
            PROMPT_KEY="gratitude"
            PROMPT_TITLE="Gratitude Journaling"
            PROMPT_COLOR="${GREEN}"
            PROMPT_DETAILS=$'When you feel numb or distant.\nRetrains your attention on positive things.\nBe specific.'
            ;;
        reflective)
            PROMPT_KEY="reflective"
            PROMPT_TITLE="Reflective Reframing"
            PROMPT_COLOR="${BLUE}"
            PROMPT_DETAILS=$'When life feels confusing.\n\nSteps\n1) What happened? Plainly without judgement.\n2) What it meant?\n3) What it revealed?\n4) What it taught you?\n5) Small action to take next time.'
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

# Prints the active prompt details to stderr with color
function _print_prompt_overview() {
    echo -e "${PROMPT_COLOR}${PROMPT_TITLE}${CLEAR}" >&2
    while IFS= read -r line; do
        if [[ -z "${line}" ]]; then
            echo "" >&2
        else
            echo -e "  ${PROMPT_COLOR}${line}${CLEAR}" >&2
        fi
    done <<< "${PROMPT_DETAILS}"
    echo "" >&2
}

# Captures user input for a prompt and returns the formatted payload
function sogelogs_prompt_entry() {
    local prompt_key="$1"

    if ! _set_prompt_context "${prompt_key}"; then
        echo -e "${RED}Unknown prompt: ${prompt_key}${CLEAR}" >&2
        return 1
    fi

    CLEAR >&2
    echo -e "${CYAN}Writing Prompt${CLEAR}" >&2
    _print_prompt_overview
    echo -e "${YELLOW}When finished: CTRL+D${CLEAR}" >&2

    local user_input
    user_input=$(cat)
    local converted_input
    converted_input=$(_literalize_newlines "${user_input}")

    echo -n "${PROMPT_PREFIX}|${prompt_key}|${converted_input}"
}

# Helper to capture a prompt response and append it as a new log entry
function sogelogs_record_prompt() {
    local prompt_key="$1"
    local payload

    payload="$(sogelogs_prompt_entry "${prompt_key}")" || return 1
    sogelogs_new_entry "${payload}"
}

# Prints a stored prompt entry inside a log
function _print_prompt_log_entry() {
    local prompt_key="$1"
    local stored_text="$2"

    if ! _set_prompt_context "${prompt_key}"; then
        echo "${stored_text}"
        return
    fi

    local decoded
    decoded=$(_expand_literal_newlines "${stored_text}")

    echo -e "${PROMPT_COLOR}${PROMPT_TITLE}${CLEAR}"
    if [[ -n "${decoded}" ]]; then
        printf '%s\n' "${decoded}"
    else
        echo -e "  ${GRAY}<No response recorded>${CLEAR}"
    fi
}

# Prints a random stored prompt entry for the requested key
function sogelogs_random_prompt_entry() {
    local prompt_key="$1"

    if ! _set_prompt_context "${prompt_key}"; then
        echo -e "${RED}Unknown prompt: ${prompt_key}${CLEAR}"
        return 1
    fi

    local matches=()
    local file
    shopt -s nullglob
    for file in ${LOGS_DIRECTORY}/*.txt; do
        while IFS= read -r line; do
            matches+=("${line}")
        done < <(grep "^${PROMPT_PREFIX}|${prompt_key}|" "${file}")
    done
    shopt -u nullglob

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo -e "${RED}No ${PROMPT_TITLE} entries found.${CLEAR}"
        return 0
    fi

    local random_index=$((RANDOM % ${#matches[@]}))
    local payload="${matches[$random_index]}"
    local content="${payload#${PROMPT_PREFIX}|${prompt_key}|}"
    local decoded
    decoded=$(_expand_literal_newlines "${content}")

    echo -e "${PROMPT_COLOR}${PROMPT_TITLE}${CLEAR}"
    if [[ -n "${decoded}" ]]; then
        printf '%s\n' "${decoded}"
    else
        echo -e "  ${GRAY}<No response recorded>${CLEAR}"
    fi
}

# Menu for interactive prompt selection
function prompt_menu() {
    if [ $# -eq 0 ]; then
        CLEAR
        echo -e "${GREEN}Writing Prompts${CLEAR}"
    fi

    echo -ne "${CYAN}Options:${CLEAR}
    ${CYAN}1)${CLEAR} Expressive Writing
    ${CYAN}2)${CLEAR} Gratitude Journaling
    ${CYAN}3)${CLEAR} Reflective Reframing
    ${CYAN}4)${CLEAR} Back
    ${CYAN}0)${CLEAR} Exit
    ${BLUE}\nChoose an Option: ${CLEAR}"
    read selection
    case ${selection} in
        1) CLEAR ; sogelogs_record_prompt "expressive" ; CLEAR ; prompt_menu 1 ;;
        2) CLEAR ; sogelogs_record_prompt "gratitude" ; CLEAR ; prompt_menu 1 ;;
        3) CLEAR ; sogelogs_record_prompt "reflective" ; CLEAR ; prompt_menu 1 ;;
        4) CLEAR ; menu 1 ;;
        0) CLEAR ; exit 0 ;;
        *) echo -e "${RED} Wrong option.${CLEAR}" WrongCommand ;;
    esac
}
