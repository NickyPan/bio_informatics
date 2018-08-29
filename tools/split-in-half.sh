#!/usr/bin/bash

fspec=$1
num_files=2

# Work out lines per file.

total_lines=$(wc -l <${fspec})
((lines_per_file = (total_lines + num_files - 1) / num_files))

# Split the actual file, maintaining lines.

head -n ${lines_per_file} $1 > $1.cut

# Debug information

echo "$1"
echo "Total lines     = ${total_lines}"
echo "Lines  per file = ${lines_per_file}"
wc -l $1.cut
