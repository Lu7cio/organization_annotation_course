#!/bin/bash
#SBATCH --job-name=plot_riparian
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/plot_riparian/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/plot_riparian/%x_%j.err

set -euo pipefail

WORKDIR=/data/users/mkummer/organization_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026   
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"

# Use host-backed temporary storage for R's parallel workers.
TMPDIR="$WORKDIR/output/comparisons/Annotation_R_tmp"
mkdir -p "$TMPDIR"

cd "$WORKDIR"

apptainer exec --cleanenv \
  --bind /data --bind "$WORKDIR" \
  --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" \
  "$GENESPACE_SIF" Rscript "$WORKDIR/scripts/29_plot_riparian.R"