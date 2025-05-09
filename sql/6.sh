#!/bin/bash

# Output file
OUTPUT_FILE="combined_Q06_results.txt"

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
  append_to_file "sql/Q06.sql" "sql/Q06_out.txt"
  append_to_file "sql/Q06a.sql" "sql/Q06a_out.txt"
  append_to_file "sql/Q06b.sql" "sql/Q06b_out.txt"
  append_to_file "sql/Q06c.sql" "sql/Q06c_out.txt"
  append_to_file "sql/Q06d.sql" "sql/Q06d_out.txt"
else
  # Files are in current directory
  append_to_file "Q06.sql" "Q06_out.txt"
  append_to_file "Q06a.sql" "Q06a_out.txt"
  append_to_file "Q06b.sql" "Q06b_out.txt"
  append_to_file "Q06c.sql" "Q06c_out.txt"
  append_to_file "Q06d.sql" "Q06d_out.txt"
fi

echo "Combined output created in $OUTPUT_FILE"