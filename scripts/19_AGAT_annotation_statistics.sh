#!/bin/bash
#SBATCH --job-name=annotation_statistics
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-30
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/annotation_statistics/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/annotation_statistics/%x_%j.err

# Define directories and file names
WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"

# Make sure we are in the final directory where the longest sequences are located
cd "$FINALDIR" 

# Run AGAT statistics on the filtered GFF3 file
apptainer exec --cleanenv \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$AGAT_SIF" \
    agat_sp_statistics.pl \
    --gff filtered.genes.renamed.gff3 \
    --output annotation.stat