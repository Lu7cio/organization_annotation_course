#!/bin/bash
#SBATCH --job-name=annotation_uniprot
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/annotation_uniprot/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/annotation_uniprot/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/mkummer/organization_annotation_course/
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
OUTDIR="$WORKDIR/output/comparisons"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
MAKER_UNIPROT="$OUTDIR/uniprot_viridiplantae_reviewed.maker.fa"

# Requires blastp_uniprot.besthits.tsv from blast_comparisons.sh.
mkdir -p "$OUTDIR/tmp"

# BLAST reports UniProt accessions (for example, Q9FGR8), while the original
# FASTA headers start with sp|accession|entry_name. Use matching accession keys.
awk '/^>/ {
    sub(/^>[^|]+\|/, ">")
    sub(/\|[^ ]+/, "")
}
{ print }' "$UNIPROT" > "$MAKER_UNIPROT"

# Add functional annotation (UniProt hits) to the protein FASTA.
apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind /data --bind "$WORKDIR" \
    --bind "$OUTDIR/tmp":/tmp \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    maker_functional_fasta "$MAKER_UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$PROTEINS" \
    > "$OUTDIR/maker_proteins.filtered.Uniprot.fasta"

# Add functional annotation (UniProt hits) to the gene GFF3.
apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind /data --bind "$WORKDIR" \
    --bind "$OUTDIR/tmp":/tmp \
    --pwd "$OUTDIR" "$MAKER_SIF" \
    maker_functional_gff "$MAKER_UNIPROT" "$OUTDIR/blastp_uniprot.besthits.tsv" "$GENES" \
    > "$OUTDIR/filtered.genes.Uniprot.gff3"