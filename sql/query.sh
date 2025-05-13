#!/usr/bin/env bash
# combine_sql_with_results.sh
# Usage: run from project root; requires bash.

OUTFILE="all_queries_and_results.txt"
: > "$OUTFILE"  # truncate or create

for sqlfile in Q*.sql; do
  base=$(basename "$sqlfile" .sql)
  outfile="${base}_out.txt"

  {
    echo "================================================================"
    echo "Query: $base"
    echo "================================================================"
    echo
    cat "$sqlfile"
    echo
    echo "---- Results of $base ----"
    echo

    if [[ -f "$outfile" ]]; then
      cat "$outfile"
    else
      echo "[No results file found: $outfile]"
    fi

    echo
    echo
  } >> "$OUTFILE"
done

echo "All queries + results have been written to $OUTFILE"
