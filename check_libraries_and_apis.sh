#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

target="$1"

echo $target

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
    echo $library
    for symbol in "${symbols[@]}"; do
        if echo "${nm_results[$library]}" | grep -Fq " T $symbol"; then
            echo -e "used symbol: $symbol"
        fi
    done
done

