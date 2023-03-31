#!/bin/bash

check_symbols() {
  local target="$1"

  echo "Checking target: (${target})"

     # Specify the directories to search
  directories=("/home/lin/07_Phase4_20230116/LGE/5G/TbaNBpdA003/02_DCM_Core/20230116_TNNNFpdA064/App/DCMCore/lib")

  libraries=()
  for directory in "${directories[@]}"; do
    while IFS= read -r -d '' file; do
      # Append the absolute path of each file to the fileList variable
      libraries+=("$file")
    done < <(find "$directory" -maxdepth 1 -type f -print0)
  done

  declare -A nm_results
  for library in "${libraries[@]}"; do
      nm_results["$library"]="$(nm -D "$library")"
  done

  # Get list of symbols in the target
  symbols=($(nm -D "$target" | grep -F " U " | awk '{ print $2 }'))

  for symbol in "${symbols[@]}"; do
      found=false
      for library in "${libraries[@]}"; do
          if echo "${nm_results[$library]}" | grep -Fq " T $symbol"; then
              echo -e "used symbol: $symbol: $library"
              found=true
              break
          fi
      done
      #if ! $found; then
        #echo -e "undefined symbol: $symbol"
      #fi
  done
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

target="$1"

log_file="log.txt"

if [ -f "$target" ]; then
  check_symbols "$target" >> "$log_file"
elif [ -d "$target" ]; then
  for file in "$target"/*; do
    if [[ -x "$file" || ("$file" == *".so"* || "$file" == *".a"* || "$file" == *".out"* || "$file" == *".exe") ]]; then
      check_symbols "$file" >> "$log_file"
    fi
  done
else
  echo "Invalid target: $target"
  exit 1
fi
