#!/bin/bash
#SBATCH --job-name=annotation_uniprot
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/prepare_Genspace/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/prepare_Genspace/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/mkummer/organization_annotation_course/
COURSEDIR=/data/courses/genome_annotation_resources/2026
Accession="Etna_2"            
OTHER_ACCESSIONS=(Kar_1 Altai_5 Ice_1)
FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.all.maker.proteins.fasta.renamed.longest.fasta"
OUTDIR="$WORKDIR/output/comparisons"
GENESPACE_DIR="$OUTDIR/GENESPACE"
OTHER_DIR_ACCESSIONS="$COURSEDIR/data/Lian_et_al/GENESPACE"

# GENESPACE does not allow "-" in accession names.
Accession="${Accession//-/_}"

# Enusre that the directory structure for GENESPACE is in place.
mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"

# ---- 1. Etna_2 My accession -------------------------------------------------------
# BED = scaffold, 0-based start, end, gene ID (GFF3 start - 1).
grep -P "\tgene\t" "$GENES" > "$GENESPACE_DIR/temp_genes.gff3"

# ID is the first attribute in column 9 (ID=gene_name;...).
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' \
    "$GENESPACE_DIR/temp_genes.gff3" > "$GENESPACE_DIR/bed/${Accession}.bed"

# Longest protein per gene: strip descriptions and transcript suffixes (-RA, -RB, ...).
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" | sed '/^>/s/-R[A-Z]*$//' \
    > "$GENESPACE_DIR/peptide/${Accession}.fa"

# ---- 2. TAIR10 -----------------------------------------------------------------
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/TAIR10.bed"
cp "$COURSEDIR/data/TAIR10.fa"  "$GENESPACE_DIR/peptide/TAIR10.fa"

# ---- 3. The three other accessions ---------------------------------------------------
for other in "${OTHER_ACCESSIONS[@]}"; do
    cp "$OTHER_DIR_ACCESSIONS/bed/${other}.bed"     "$GENESPACE_DIR/bed/${other}.bed"
    cp "$OTHER_DIR_ACCESSIONS/peptide/${other}.fa"  "$GENESPACE_DIR/peptide/${other}.fa"
done

# ---- 4. Validate the GENESPACE input files --------------------------------------------
# Validate that each BED and peptide FASTA contains the same unique gene IDs.
validate_ids() {
    local accession="$1"
    local bed="$GENESPACE_DIR/bed/${accession}.bed"
    local fasta="$GENESPACE_DIR/peptide/${accession}.fa"
    local prefix="$GENESPACE_DIR/tmp/${accession}"
    local bed_ids="${prefix}.bed.ids"
    local fasta_ids="${prefix}.fasta.ids"
    local status=0

    awk -v accession="$accession" '
        NF < 4 || $4 == "" { print accession ": missing BED gene ID at line " NR > "/dev/stderr"; invalid=1 }
        NF >= 4 && $4 != "" && seen[$4]++ { print accession ": duplicate BED gene ID: " $4 > "/dev/stderr"; invalid=1 }
        END { exit invalid }
    ' "$bed" || status=1
    awk -v accession="$accession" '
        /^>/ {
            id=$1
            sub(/^>/, "", id)
            if (id == "") { print accession ": missing FASTA ID at line " NR > "/dev/stderr"; invalid=1 }
            else if (seen[id]++) { print accession ": duplicate FASTA ID: " id > "/dev/stderr"; invalid=1 }
        }
        END { exit invalid }
    ' "$fasta" || status=1

    awk 'NF >= 4 && $4 != "" { print $4 }' "$bed" | LC_ALL=C sort > "$bed_ids"
    awk '/^>/ { id=$1; sub(/^>/, "", id); if (id != "") print id }' "$fasta" |
        LC_ALL=C sort > "$fasta_ids"

    if ! comm -23 "$bed_ids" "$fasta_ids" |
        awk -v accession="$accession" '{
            print accession ": BED ID missing from FASTA: " $0 > "/dev/stderr"
            found=1
        } END { exit found }'
    then
        status=1
    fi
    if ! comm -13 "$bed_ids" "$fasta_ids" |
        awk -v accession="$accession" '{
            print accession ": FASTA ID missing from BED: " $0 > "/dev/stderr"
            found=1
        } END { exit found }'
    then
        status=1
    fi

    rm -f "$bed_ids" "$fasta_ids"
    return "$status"
}

validation_failed=0
for accession in "$Accession" TAIR10 "${OTHER_ACCESSIONS[@]}"; do
    if ! validate_ids "$accession"; then
        validation_failed=1
    else
        echo "$accession: BED and FASTA IDs validated successfully"
    fi
done

if (( validation_failed )); then
    echo "ID validation failed; GENESPACE input files were not validated." >&2
    exit 1
fi
