#!/bin/bash

DB_USER="root"
DB_PASS="2001"
DB_NAME="11new"
SQL_DIR="."

# Loop through each SQL file
for sql_file in $SQL_DIR/Q04?.sql; do
    base_name=$(basename "$sql_file" .sql)
    out_file="${SQL_DIR}/${base_name}_out.txt"

    echo "Running $sql_file..."

    # Execute SQL and write output to result file
    mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$sql_file" > "$out_file" 2>&1

    echo "Done with $sql_file"
    echo
done
