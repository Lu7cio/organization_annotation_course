#!/bin/bash
#SBATCH --job-name=summarize_annotation
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=02:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/summarize_annotation/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/summarize_annotation/%x_%j.err


set -euo pipefail

WORKDIR=/data/users/mkummer/organization_annotation_course
FINALDIR="$WORKDIR/output/MAKER/final"
OUTDIR="$WORKDIR/output/comparisons"

PROTEINS="$FINALDIR/assembly.all.maker.all.maker.proteins.fasta.renamed.filtered.fasta"
BESTHITS="$OUTDIR/blastp_uniprot.besthits.tsv"
UNIPROT="$OUTDIR/uniprot_viridiplantae_reviewed.maker.fa"
GFF="$OUTDIR/filtered.genes.Uniprot.gff3"
REPORT="$OUTDIR/annotation_summary.txt"

for file in "$PROTEINS" "$BESTHITS" "$UNIPROT" "$GFF"; do
    [[ -s "$file" ]] || { echo "Missing or empty input: $file" >&2; exit 1; }
done

{
    echo "1. UniProt hit proportions"
    echo "=========================="

    awk -v fasta="$PROTEINS" -v hits="$BESTHITS" -v uniprot="$UNIPROT" '
        FILENAME == fasta {
            if (/^>/) {
                id = $1
                sub(/^>/, "", id)
                n[id] = 0
                protein_count++
                current = id
            } else if (current != "") {
                gsub(/[[:space:]]/, "", $0)
                n[current] += length($0)
            }
            next
        }
        FILENAME == uniprot {
            if (/^>/) {
                id = $1
                sub(/^>/, "", id)
                desc = $0
                sub(/^>[^ ]+[[:space:]]*/, "", desc)
                category[id] = (desc ~ /[Uu]ncharacterized|[Hh]ypothetical|[Uu]nknown protein/ ?
                    "uncharacterized" : "curated/characterized")
            }
            next
        }
        FILENAME == hits {
            if (NF >= 2 && !seen[$1]++) {
                total++
                hit[$1] = 1
                if (category[$2] == "uncharacterized") unknown++
                else curated++
            }
            next
        }
        END {
            nohit = 0
            for (id in n) if (!(id in hit)) nohit++
            printf "Total proteins: %d\n", protein_count
            printf "Proteins with UniProt hit: %d (%.2f%%)\n", total, 100 * total / protein_count
            printf "Proteins without UniProt hit: %d (%.2f%%)\n", nohit, 100 * nohit / protein_count
            printf "Hit descriptions classified as curated/characterized: %d (%.2f%% of hits)\n",
                curated, 100 * curated / total
            printf "Hit descriptions classified as uncharacterized: %d (%.2f%% of hits)\n",
                unknown, 100 * unknown / total
        }
    ' "$PROTEINS" "$UNIPROT" "$BESTHITS"

    echo
    echo "2. Length and completeness bias"
    echo "================================"
    awk -v fasta="$PROTEINS" -v hits="$BESTHITS" '
        FILENAME == fasta {
            if (/^>/) {
                id = $1
                sub(/^>/, "", id)
                current = id
                plen[current] = 0
            } else if (current != "") {
                gsub(/[[:space:]]/, "", $0)
                plen[current] += length($0)
            }
            next
        }
        FILENAME == hits { if (NF >= 1) hit[$1] = 1; next }
        END {
            for (id in plen) {
                group = (id in hit ? "with_hit" : "without_hit")
                count[group]++
                sum[group] += plen[id]
                if (!(group in min) || plen[id] < min[group]) min[group] = plen[id]
                if (plen[id] > max[group]) max[group] = plen[id]
            }
            for (group in count) {
                printf "%s: n=%d mean_length=%.1f min=%d max=%d\n",
                    group, count[group], sum[group] / count[group], min[group], max[group]
            }
        }
    ' "$PROTEINS" "$BESTHITS" 2>/dev/null || true

    awk -F '\t' -v hits="$BESTHITS" '
        FILENAME == hits {
            if (NF >= 1) hit[$1] = 1
            next
        }
        $3 == "mRNA" {
            id = ""
            aed = ""
            n = split($9, a, ";")
            for (i = 1; i <= n; i++) {
                if (a[i] ~ /^ID=/) { sub(/^ID=/, "", a[i]); id = a[i] }
                if (a[i] ~ /^_AED=/) { sub(/^_AED=/, "", a[i]); aed = a[i] }
            }
            if (id != "" && aed != "") {
                hit_group = (id in hit ? "with_hit" : "without_hit")
                aed_group = (aed + 0 <= 0.5 ? "AED<=0.5" : "AED>0.5")
                count[hit_group, aed_group]++
                total[hit_group]++
            }
        }
        END {
            for (group in total) {
                printf "%s: %d mRNAs, AED<=0.5: %d (%.2f%%), AED>0.5: %d (%.2f%%)\n",
                    group, total[group],
                    count[group, "AED<=0.5"], 100 * count[group, "AED<=0.5"] / total[group],
                    count[group, "AED>0.5"], 100 * count[group, "AED>0.5"] / total[group]
            }
        }
    ' "$BESTHITS" "$GFF"

        echo
    echo "3. FLC (AT5G10140)"
    echo "==================="
    # Select the gene feature only (column 3 == gene), not mRNA/exon lines
    flc_gene=$(awk -F '\t' '$3 == "gene" && ($9 ~ /AT5G10140/ || $9 ~ /FLOWERING LOCUS C/)' "$GFF" | head -n1 || true)
    if [[ -n "$flc_gene" ]]; then
        printf '%s\n' "$flc_gene" |
            awk -F '\t' '{
                id = "NA"; note = "NA"; domains = "NA"; go = "NA"
                n = split($9, a, ";")
                for (i = 1; i <= n; i++) {
                    if (a[i] ~ /^ID=/)            { sub(/^ID=/, "", a[i]);            id = a[i] }
                    if (a[i] ~ /^Note=/)          { sub(/^Note=/, "", a[i]);          note = a[i] }
                    if (a[i] ~ /^Dbxref=/)        { sub(/^Dbxref=/, "", a[i]);        domains = a[i] }
                    if (a[i] ~ /^Ontology_term=/) { sub(/^Ontology_term=/, "", a[i]); go = a[i] }
                }
                printf "Candidate: %s\nLocation: %s:%s-%s (%s)\nFunction annotation: %s\nPfam/InterPro: %s\nGO terms: %s\n",
                    id, $1, $4, $5, $7, note, domains, go
            }'
        # AED of the corresponding mRNA, taken from the GFF
        cand_id=$(printf '%s\n' "$flc_gene" | awk -F '\t' '{n=split($9,a,";"); for(i=1;i<=n;i++) if(a[i] ~ /^ID=/){sub(/^ID=/,"",a[i]); print a[i]}}')
        awk -F '\t' -v gid="$cand_id" '
            $3 == "mRNA" && $9 ~ ("Parent=" gid ";") {
                n = split($9, a, ";")
                for (i = 1; i <= n; i++) if (a[i] ~ /^_AED=/) { sub(/^_AED=/, "", a[i]); print "AED: " a[i] }
            }' "$GFF"
    else
        echo "No explicit FLC/AT5G10140 annotation found."
    fi
} > "$REPORT"

cat "$REPORT"
echo
echo "Wrote $REPORT"
