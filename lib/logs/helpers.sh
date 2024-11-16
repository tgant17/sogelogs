#!/bin/bash
# Helper functions for the "Logs" functionality


# Helper function to print hashbar for formatting
function _sogelogs_print_hash_bar() {
    terminal_width=$(tput cols)
    printf '#%.0s' $(seq 1 $terminal_width) 
    echo
}