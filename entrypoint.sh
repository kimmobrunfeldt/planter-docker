#!/bin/bash

set -e

PLANTUML_PATH="/app/plantuml.1.2020.16.jar"

# PlantUML limits image width and height to 4096. There is a environment
# variable that you can set to override this limit: PLANTUML_LIMIT_SIZE.
# Note that if you generate very big diagrams, (for example, something like
# 20 000 x 10 000 pixels), you can have some memory issues.
# The solution is to add this parameter to the java vm : -Xmx1024m.
export PLANTUML_LIMIT_SIZE=32768
JAVA_ARGS="-Xmx1024m"

print_usage () {
  echo -e "Usage: $0 <command> <args>"
}

# https://stackoverflow.com/questions/9057387/process-all-arguments-except-the-first-one-in-a-bash-script
command="$1"

if [[ -z "$command" ]]; then
  print_usage
  exit 1
fi

shift
args="$@"

if [[ "$command" == "planter" ]]; then
  set -x
  planter $args
  set +x
elif [[ "$command" == "plantuml" ]]; then
  set -x
  java $JAVA_ARGS -jar $PLANTUML_PATH $args
  set +x
elif [[ "$command" == "er" ]]; then
  postgres_url="$1"
  postgres_schema_name=${2:-public}
  table_name_matcher="$3"
  default_file_name="er-$(date '+%Y-%m-%dT%H_%M_%S')"
  output_file_name=${4:-$default_file_name}

  if [[ -z "$postgres_url" ]]; then
    echo "Postgres connection url argument missing"
    exit 1
  fi

  table_args=""
  if [[ -n "$table_name_matcher" ]]; then
    # WARNING: Don't expose this to unsafe input, direct SQL string concat is used
    output=$(psql "$postgres_url" -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema = '$postgres_schema_name' AND table_name $table_name_matcher")
    if [[ -z "$output" ]]; then
      echo "No tables found matching pattern \"WHERE table_name $table_name_matcher\""
      exit 2
    fi

    # Output contains all table names separated by space.
    # * Split them to individual lines
    # * Add -t prefix for each line
    # * Join lines back to a single line
    table_args=$(echo $output | xargs -n 1 | sed -e 's/^/-t /' | xargs)
  fi

  set -x
  planter $postgres_url -s $postgres_schema_name $table_args -o "$output_file_name.uml"
  java $JAVA_ARGS -jar $PLANTUML_PATH -verbose "$output_file_name.uml"
  set +x
else
  print_usage
  exit 1
fi
