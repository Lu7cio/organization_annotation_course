#!/bin/bash
 D
FINALDIR="/data/users/mkummer/organization_annotation_course/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.all.maker.proteins.fasta.renamed.fasta"
IPRSCAN="$FINALDIR/output.iprscan"
GFF="$FINALDIR/assembly.all.maker.noseq.gff.renamed.iprscan.gff"
OUTPUT="$FINALDIR/pfam_aed_summary.tsv"

awk -F '\t' '
FILENAME == ARGV[1] {
    if ($0 ~ /^>/) {
        sub(/^>/, "", $1)
        sub(/[[:space:]].*/, "", $1)
        protein[$1] = 1
    }
    next
}
FILENAME == ARGV[2] {
    if ($4 == "Pfam") pfam[$1] = 1
    next
}
$3 == "mRNA" {
    id = ""
    n = split($9, a, ";")
    for (i = 1; i <= n; i++) {
        if (a[i] ~ /^ID=/) {
            sub(/^ID=/, "", a[i])
            id = a[i]
        }
        if (a[i] ~ /^_AED=/) {
            sub(/^_AED=/, "", a[i])
            aed[id] = a[i]
        }
    }
}
END {
    for (id in protein) {
        if (!(id in aed)) continue
        group = (aed[id] + 0 <= 0.5 ? "low_AED_(<=0.5)" : "high_AED_(>0.5)")
        total[group]++
        if (id in pfam) hit[group]++
    }
    all = total["low_AED_(<=0.5)"] + total["high_AED_(>0.5)"]
    all_hit = hit["low_AED_(<=0.5)"] + hit["high_AED_(>0.5)"]
    print "group\tproteins\twith_pfam\tproportion_percent"
    printf "all\t%d\t%d\t%.2f\n", all, all_hit, 100 * all_hit / all
    printf "low_AED_(<=0.5)\t%d\t%d\t%.2f\n", total["low_AED_(<=0.5)"], hit["low_AED_(<=0.5)"], 100 * hit["low_AED_(<=0.5)"] / total["low_AED_(<=0.5)"]
    printf "high_AED_(>0.5)\t%d\t%d\t%.2f\n", total["high_AED_(>0.5)"], hit["high_AED_(>0.5)"], 100 * hit["high_AED_(>0.5)"] / total["high_AED_(>0.5)"]
}
' "$PROTEINS" "$IPRSCAN" "$GFF" > "$OUTPUT"

printf 'Wrote %s\n' "$OUTPUT"
cat "$OUTPUT"
