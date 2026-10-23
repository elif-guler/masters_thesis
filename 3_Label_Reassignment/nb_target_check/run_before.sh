#!/usr/bin/env bash
# run_before.sh
#
# Runs makeFurDb + fur, and seqwin, on the targets_before/neighbors_before
# folders (taxonomy-based labels, pre label-correction), for every
# dataset/pool combination. Mirrors run_fur_seqwin.sh exactly, but reads
# from *_before folders and writes *_before outputs so the original
# (post-correction) results in targets/neighbors/markers.fasta/seqwin-out
# are never touched.
#
# Usage: ./run_before.sh [pool ...]   (default: 100 1000)

set -uo pipefail

DATASETS=(clo mtb sen)
POOLS=("$@")
[[ ${#POOLS[@]} -eq 0 ]] && POOLS=(100 1000)

SUMMARY=()

for d in "${DATASETS[@]}"; do
  for p in "${POOLS[@]}"; do
    outdir="$d/pool_$p"
    echo "$outdir"

    if [[ ! -d "$outdir/targets_before" || ! -d "$outdir/neighbors_before" ]]; then
        echo "skipping - no targets_before/neighbors_before in $outdir"
        SUMMARY+=("$outdir: SKIPPED (missing targets_before/neighbors_before)")
        continue
    fi

    if makeFurDb -t "$outdir/targets_before" -n "$outdir/neighbors_before" -o -d "$outdir/before.db" \
        > "$outdir/makeFurDb_before.log" 2>&1
    then
        echo "makeFurDb ok"
    else
        echo "makeFurDb failed - see $outdir/makeFurDb_before.log"
        SUMMARY+=("$outdir: makeFurDb FAILED")
        continue
    fi

    if fur -d "$outdir/before.db" > "$outdir/markers_before.fasta" 2>"$outdir/fur_before.log"
    then
        n=$(grep -c '^>' "$outdir/markers_before.fasta" 2>/dev/null)
        [[ -z "$n" ]] && n=0
        echo "fur ok, $n markers"
    else
        echo "fur failed - see $outdir/fur_before.log"
        SUMMARY+=("$outdir: fur FAILED")
        continue
    fi

    if seqwin --tar-dir "$outdir/targets_before" --neg-dir "$outdir/neighbors_before" \
               -o "$outdir/seqwin-out-before" --overwrite \
        > "$outdir/seqwin_before.log" 2>&1
    then
        ns=$(grep -c '^>' "$outdir/seqwin-out-before/signatures.fasta" 2>/dev/null)
        [[ -z "$ns" ]] && ns=0
        echo "seqwin ok, $ns markers"
        SUMMARY+=("$outdir: OK - $n fur markers, $ns seqwin markers")
    else
        echo "seqwin failed - see $outdir/seqwin_before.log"
        SUMMARY+=("$outdir: seqwin FAILED")
    fi
    echo
  done
done

echo "summary"
for line in "${SUMMARY[@]}"; do
    echo "  $line"
done
