#!/bin/bash
#SBATCH --job-name=extract_longest
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/extract_longest/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/extract_longest/%x_%j.err

set -euo pipefail

# Define directories and file names
WORKDIR="/data/users/mkummer/organization_annotation_course"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
transcript="assembly.all.maker.all.maker.transcripts.fasta"
protein="assembly.all.maker.all.maker.proteins.fasta"
 
# Make sure we are in the final directory where the longest sequences are located
cd "$FINALDIR" || {
    printf 'ERROR: output directory does not exist: %s\n' "$FINALDIR" >&2
    exit 1
}
 
# Keep one longest record per gene.
# Gene = ID (first word of header) up to the last "-R" (-RA, -RB, ... = isoforms).
# Ties: the first record is kept.
longest_per_gene() {
    awk '
    function store(   g, s, l) {
        if (h == "") return
        g = id; sub(/-R.*/, "", g)
        s = seq; sub(/\*$/, "", s); l = length(s)
        if (!(g in len)) { order[++n] = g; len[g] = -1 }
        if (l > len[g]) { len[g] = l; bh[g] = h; bs[g] = seq }
    }
    /^>/ { store(); h = $0; id = substr($1, 2); seq = ""; next }
    { gsub(/[ \r]/, ""); seq = seq $0 }
    END { store(); for (i = 1; i <= n; i++) { g = order[i]; print bh[g]; print bs[g] } }
    ' "$1" > "$2"
    echo "$1 -> $2: $(grep -c '>' "$2") genes"
}
 
# Apply the function 
for input in \
    "${protein}.renamed.filtered.fasta" \
    "${transcript}.renamed.filtered.fasta"
do
    if [[ ! -s "$input" ]]; then
        printf 'ERROR: input FASTA is missing or empty: %s\n' "$input" >&2
        exit 1
    fi
done

longest_per_gene "${protein}.renamed.filtered.fasta" \
    "${protein}.renamed.longest.fasta"
longest_per_gene "${transcript}.renamed.filtered.fasta" \
    "${transcript}.renamed.longest.fasta"
 