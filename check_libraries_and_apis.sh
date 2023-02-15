#!/bin/bash

check_symbols() {
  local target="$1"

  echo "Checking target: $target"

  # Get list of shared libraries
  libraries=($(ldd "$target" | awk '{ print $3 }'))

  # Store the results of nm -D for each library in an associative array
  declare -A nm_results
  for library in "${libraries[@]}"; do
      nm_results["$library"]="$(nm -D "$library")"
  done

  # Get list of symbols in the target
  symbols=($(nm -D "$target" | grep -F " U " | awk '{ print $2 }'))

  for library in "${libraries[@]}"; do
      echo "Checking library: $library"
      for symbol in "${symbols[@]}"; do
          if echo "${nm_results[$library]}" | grep -Fq " T $symbol"; then
              echo -e "used symbol: $symbol"
          fi
      done
  done
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

target="$1"

log_file="log.txt"

if [ -f "$target" ]; then
  check_symbols "$target" > "$log_file"
elif [ -d "$target" ]; then
  for file in "$target"/*; do
    if [[ -x "$file" || ("$file" == *".so"* || "$file" == *".a"* || "$file" == *".out"* || "$file" == *".exe") ]]; then
      check_symbols "$file" > "$log_file"
    fi
  done
else
  echo "Invalid target: $target"
  exit 1
fi
