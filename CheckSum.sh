#!/bin/bash

## ACD - 3/30/24
## Checksum/Hash Script ##

## This script will take the files at two file paths, run a checksum, and compare the hashes.
## This can be used for data verification on large files.

# Ask the user for the path of the first file
echo "Please enter the path of the first file:"
read -r file1

# Validate that the file exists
if [ ! -f "$file1" ]; then
    echo "File $file1 does not exist."
    exit 1
fi

# Ask the user for the path of the second file
echo "Please enter the path of the second file:"
read -r file2

# Validate that the file exists
if [ ! -f "$file2" ]; then
    echo "File $file2 does not exist."
    exit 1
fi

# Calculate SHA-256 hashes of both files
hash1=$(shasum -a 256 "$file1" | awk '{print $1}')
hash2=$(shasum -a 256 "$file2" | awk '{print $1}')

# Compare the hashes
if [ "$hash1" = "$hash2" ]; then
    match_result="The files match."
else
    match_result="The files do not match."
fi

# Output the hashes and the comparison result
echo "SHA-256 hash of $file1: $hash1"
echo "SHA-256 hash of $file2: $hash2"
echo "$match_result"