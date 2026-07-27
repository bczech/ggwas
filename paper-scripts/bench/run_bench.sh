#!/bin/bash
# Full benchmark matrix: tool x size, peak RSS via /usr/bin/time -l.
cd "$(dirname "$0")"
DATA=../data/giant_height_eur.txt.gz
OUT=results.csv
echo "tool,n,median_s,min_s,max_s,peak_rss_mb" > "$OUT"

for size in 50000 200000 500000 1000000 2000000; do
  for tool in qqman CMplot topr ggwas; do
    err=$(mktemp)
    res=$(/usr/bin/time -l Rscript bench_one.R "$tool" "$size" "$DATA" 2>"$err" | grep '^RESULT')
    rss_bytes=$(grep 'maximum resident set size' "$err" | awk '{print $1}')
    rss_mb=$(awk "BEGIN{printf \"%.1f\", ${rss_bytes:-0}/1048576}")
    line=$(echo "$res" | sed 's/RESULT,//')
    if [ -z "$line" ]; then line="$tool,$size,NA,NA,NA"; fi
    echo "$line,$rss_mb" >> "$OUT"
    echo "done: $tool size=$size -> ${line#*,*,} rss=${rss_mb}MB"
    rm -f "$err"
  done
done
echo "BENCH COMPLETE"
