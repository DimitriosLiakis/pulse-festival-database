    #!/usr/bin/env bash
    # run_all.sh — execute all Q01.sql through Q15.sql and capture their outputs

    DB_USER="root"
    DB_PASS="2001"
    DB_NAME="festival_database"
    SQL_DIR="."

    for i in $(seq -w 1 15); do
    SRC="${SQL_DIR}/Q${i}.sql"
    OUT="${SQL_DIR}/Q${i}_out.txt"

    if [[ -f "$SRC" ]]; then
        echo "Running Q${i}..."
        mysql -u "${DB_USER}" -p2001 "${DB_NAME}" < "$SRC" > "$OUT"
        echo "  → Output written to $OUT"
    else
        echo "Warning: $SRC not found, skipping."
    fi
    done

    echo "All done."
