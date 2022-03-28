#!/bin/bash

set -e 

ask_input() {
  read -rp "$1" input
  if [ -n "$input" ]; then
    echo "$input"
  else
    ask_input "The input is required. Please enter again: "
  fi
}

path=$(ask_input "Enter absolute file path containing migration scripts: ")
export MIGRATION_ABS_PATH=$path

make pdf