#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/interproscan/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/interproscan/%x_%j.err

WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"
protein_fasta="assembly.all.maker.all.maker.proteins.fasta.renamed.fasta"

cd "$FINALDIR"

apptainer exec --cleanenv --pwd "$FINALDIR" \
  --bind "$COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data" \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --bind "$FINALDIR/tmp":/temp \
  "$INTERPROSCAN_SIF" \
  /opt/interproscan/interproscan.sh \
  -appl pfam --disable-precalc -f TSV \
  --goterms --iprlookup --seqtype p \
  -i "$protein_fasta" -o output.iprscan