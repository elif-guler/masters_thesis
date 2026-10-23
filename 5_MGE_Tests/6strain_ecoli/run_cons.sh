#!/usr/bin/env bash

# run_cons.sh
#
# Runs analyze_cons.py for:
#
#   E-value 1e-5
#   E-value 1e-10
#
# For:
#
#   fur
#   seqwin
#
# Across:
#
#   a
#   b1
#   b2
#   d
#   e
#   f
#
# Output files:
#
#   <dataset>/cons_div_fur_e5.csv
#   <dataset>/cons_div_seqwin_e5.csv
#   <dataset>/cons_div_fur_e10.csv
#   <dataset>/cons_div_seqwin_e10.csv
#
# Log files are generated alongside the CSV files.


set -uo pipefail


# --------------------------------------------------
# Datasets
# --------------------------------------------------

DATASETS=(
    a
    b1
    b2
    d
    e
    f
)


# --------------------------------------------------
# E-values
#
# Format:
#   BLAST E-value : output suffix
# --------------------------------------------------

EVALUES=(
    "1e-5:e5"
    "1e-10:e10"
)


# --------------------------------------------------
# Main loop
# --------------------------------------------------

for pair in "${EVALUES[@]}"; do

    evalue="${pair%%:*}"
    suffix="${pair##*:}"


    echo
    echo "=========================================="
    echo "E-value: $evalue"
    echo "Output suffix: $suffix"
    echo "=========================================="
    echo


    for d in "${DATASETS[@]}"; do

        outdir="$d"

        echo
        echo "------------------------------------------"
        echo "Dataset: $outdir"
        echo "E-value: $evalue"
        echo "------------------------------------------"


        # ==================================================
        # FUR
        # ==================================================

        if [[ ! -f "$outdir/markers.fasta" ]]; then

            echo "  skipping fur"
            echo "  missing: $outdir/markers.fasta"

        else

            output="$outdir/cons_div_fur_${suffix}.csv"
            logfile="$outdir/cons_div_fur_${suffix}.log"

            echo "  running fur..."
            echo "  output: $output"

            if python3 analyze_cons.py \
                "$outdir/markers.fasta" \
                "$outdir/targets" \
                "$outdir/neighbors" \
                "$output" \
                "$evalue" \
                > "$logfile" 2>&1
            then

                echo "  fur SUCCESS"
                echo "  -> $output"

            else

                echo "  fur FAILED"
                echo "  see: $logfile"

            fi

        fi


        # ==================================================
        # SEQWIN
        # ==================================================

        if [[ ! -f "$outdir/seqwin-out/signatures.fasta" ]]; then

            echo "  skipping seqwin"
            echo "  missing: $outdir/seqwin-out/signatures.fasta"

        else

            output="$outdir/cons_div_seqwin_${suffix}.csv"
            logfile="$outdir/cons_div_seqwin_${suffix}.log"

            echo "  running seqwin..."
            echo "  output: $output"

            if python3 analyze_cons.py \
                "$outdir/seqwin-out/signatures.fasta" \
                "$outdir/targets" \
                "$outdir/neighbors" \
                "$output" \
                "$evalue" \
                > "$logfile" 2>&1
            then

                echo "  seqwin SUCCESS"
                echo "  -> $output"

            else

                echo "  seqwin FAILED"
                echo "  see: $logfile"

            fi

        fi

    done

done


echo
echo "=========================================="
echo "All conservation/divergence analyses done."
echo "=========================================="
