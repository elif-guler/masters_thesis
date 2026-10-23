#!/usr/bin/env python3
"""
analyze_cons.py

Usage:
    analyze_cons.py <signatures.fasta> <targets_dir> <neighbors_dir> <output.csv> <evalue> [genome_ext]

Runs BLASTN of signature/marker sequences against every target and
non-target genome.

Reports, per signature:
    conservation          = identical bases across target genomes
    divergence            = mismatch + gap fraction across non-target genomes
    fraction_nontarget_hit = fraction of non-target genomes with a hit
    score                 = conservation + divergence

Example:
    python3 analyze_cons.py \
        markers.fasta \
        targets \
        neighbors \
        cons_div_fur_e5.csv \
        1e-5
"""

import sys
import glob
import subprocess
from collections import defaultdict


def read_fasta_lengths(path):
    """Read sequence lengths from a FASTA file."""
    lengths = {}

    name = None
    length = 0

    with open(path) as f:
        for line in f:
            line = line.rstrip()

            if line.startswith(">"):
                if name is not None:
                    lengths[name] = length

                name = line[1:].split()[0]
                length = 0

            else:
                length += len(line.strip())

    if name is not None:
        lengths[name] = length

    return lengths


def best_hits(query_fasta, genome_fasta, evalue):
    """
    Run BLASTN and retain the highest-bitscore hit for each query.
    """

    cmd = [
        "blastn",
        "-task", "blastn",
        "-query", query_fasta,
        "-subject", genome_fasta,
        "-evalue", str(evalue),
        "-max_hsps", "1000",
        "-max_target_seqs", "50000",
        "-outfmt", "6 qseqid nident mismatch gaps bitscore",
    ]

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True
    )

    best = {}

    for line in result.stdout.strip().split("\n"):

        if line == "":
            continue

        qseqid, nident, mismatch, gaps, bitscore = line.split("\t")

        nident = int(nident)
        mismatch = int(mismatch)
        gaps = int(gaps)
        bitscore = float(bitscore)

        if qseqid not in best or bitscore > best[qseqid][3]:
            best[qseqid] = (
                nident,
                mismatch,
                gaps,
                bitscore
            )

    return best


def main():

    if len(sys.argv) < 6:
        sys.exit(__doc__)

    signatures_fasta = sys.argv[1]
    targets_dir = sys.argv[2]
    nontargets_dir = sys.argv[3]
    output_csv = sys.argv[4]
    evalue = sys.argv[5]

    genome_ext = sys.argv[6] if len(sys.argv) > 6 else "fasta"

    # --------------------------------------------------
    # Read signatures
    # --------------------------------------------------

    sig_lengths = read_fasta_lengths(signatures_fasta)
    sig_ids = list(sig_lengths.keys())

    # --------------------------------------------------
    # Find genomes
    # --------------------------------------------------

    target_files = sorted(
        glob.glob(targets_dir + "/*." + genome_ext)
    )

    nontarget_files = sorted(
        glob.glob(nontargets_dir + "/*." + genome_ext)
    )

    n_target = len(target_files)
    n_nontarget = len(nontarget_files)

    print(
        n_target,
        "target genomes,",
        n_nontarget,
        "non-target genomes,",
        len(sig_ids),
        "signatures,",
        "evalue =",
        evalue
    )

    # --------------------------------------------------
    # Empty input check
    # --------------------------------------------------

    if (
        n_target == 0
        or n_nontarget == 0
        or len(sig_ids) == 0
    ):
        print(
            "Nothing to do "
            "(empty signatures/targets/neighbors) "
            "- writing header-only CSV."
        )

        with open(output_csv, "w") as out:
            out.write(
                "signature_id,length,"
                "conservation,divergence,"
                "fraction_nontarget_hit,score\n"
            )

        return

    # --------------------------------------------------
    # Counters
    # --------------------------------------------------

    identical_bases = defaultdict(int)
    diff_bases = defaultdict(int)
    nontarget_hits = defaultdict(int)

    # --------------------------------------------------
    # Analyze target genomes
    # --------------------------------------------------

    for genome_file in target_files:

        print("target:", genome_file)

        hits = best_hits(
            signatures_fasta,
            genome_file,
            evalue
        )

        for sig in sig_ids:

            if sig in hits:

                nident, mismatch, gaps, bitscore = hits[sig]

                identical_bases[sig] += nident

    # --------------------------------------------------
    # Analyze non-target genomes
    # --------------------------------------------------

    for genome_file in nontarget_files:

        print("nontarget:", genome_file)

        hits = best_hits(
            signatures_fasta,
            genome_file,
            evalue
        )

        for sig in sig_ids:

            if sig in hits:

                nident, mismatch, gaps, bitscore = hits[sig]

                diff_bases[sig] += mismatch + gaps
                nontarget_hits[sig] += 1

    # --------------------------------------------------
    # Write output
    # --------------------------------------------------

    with open(output_csv, "w") as out:

        out.write(
            "signature_id,length,"
            "conservation,divergence,"
            "fraction_nontarget_hit,score\n"
        )

        for sig in sig_ids:

            L = sig_lengths[sig]

            conservation = (
                identical_bases[sig]
                / (L * n_target)
            )

            divergence = (
                diff_bases[sig]
                / (L * n_nontarget)
            )

            frac_hit = (
                nontarget_hits[sig]
                / n_nontarget
            )

            score = conservation + divergence

            out.write(
                f"{sig},{L},"
                f"{conservation:.4f},"
                f"{divergence:.4f},"
                f"{frac_hit:.4f},"
                f"{score:.4f}\n"
            )

    print("wrote", output_csv)


if __name__ == "__main__":
    main()
