#!/bin/bash

set -e

# https://stackoverflow.com/questions/9057387/process-all-arguments-except-the-first-one-in-a-bash-script
command="$1"
shift
args="$@"

print_usage() {
  echo -e "Usage: $0 <command> <args>"
}

EXIT_CODE=0
if [[ "$command" == "planter" ]]; then
  EXIT_CODE=$(planter $args)
elif [[ "$command" == "plantuml" ]]; then
  EXIT_CODE=$(java -jar /app/plantuml.1.2020.16.jar $args)
else
  print_usage()
  exit 1
fi

exit $EXIT_CODE
