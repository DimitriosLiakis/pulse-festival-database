#!/bin/bash

# Output file
OUTPUT_FILE="combined_Q04_results.txt"

# Clear or create the output file
> "$OUTPUT_FILE"

# Function to append content with headers
append_to_file() {
  local sql_file="$1"
  local out_file="$2"
  
  echo "===== $sql_file =====" >> "$OUTPUT_FILE"
  
  if [ -f "$sql_file" ]; then
    cat "$sql_file" >> "$OUTPUT_FILE"
  else
    echo "ERROR: File $sql_file not found" >> "$OUTPUT_FILE"
  fi
  
  echo "" >> "$OUTPUT_FILE"
  echo "===== RESULT =====" >> "$OUTPUT_FILE"
  
  if [ -f "$out_file" ]; then
    cat "$out_file" >> "$OUTPUT_FILE"
  else
    echo "ERROR: File $out_file not found" >> "$OUTPUT_FILE"
  fi
  
  echo "" >> "$OUTPUT_FILE"
  echo "=========================================" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
}

# Check if files are in sql/ subdirectory or current directory
if [ -d "sql" ]; then
  # Files are in sql/ subdirectory
  append_to_file "sql/Q04.sql" "sql/Q04_out.txt"
  append_to_file "sql/Q04a.sql" "sql/Q04a_out.txt"
  append_to_file "sql/Q04b.sql" "sql/Q04b_out.txt"
  append_to_file "sql/Q04c.sql" "sql/Q04c_out.txt"
  append_to_file "sql/Q04d.sql" "sql/Q04d_out.txt"
else
  # Files are in current directory
  append_to_file "Q04.sql" "Q04_out.txt"
  append_to_file "Q04a.sql" "Q04a_out.txt"
  append_to_file "Q04b.sql" "Q04b_out.txt"
  append_to_file "Q04c.sql" "Q04c_out.txt"
  append_to_file "Q04d.sql" "Q04d_out.txt"
fi

echo "Combined output created in $OUTPUT_FILE"