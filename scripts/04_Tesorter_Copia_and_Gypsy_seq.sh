#!/bin/bash
#SBATCH --job-name=TEsorter_Copia_and_Gypsy_seq
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/TEsorter_Copia_and_Gypsy_seq/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/TEsorter_Copia_and_Gypsy_seq/%x_%j.err

# Define workdir and paths to the extracted sequences and container
WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
SIF_PATH="$COURSEDIR/containers/TEsorter_1.3.0.sif"
OUTPUT_DIR="$WORKDIR/output/EDTA"

# Classify Copia sequences
apptainer exec \
  -C --bind "$WORKDIR" --pwd "$OUTPUT_DIR" "$SIF_PATH" \
  TEsorter "$OUTPUT_DIR/Copia_sequences.fa" -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"

# Classify Gypsy sequences
apptainer exec \
  -C --bind "$WORKDIR" --pwd "$OUTPUT_DIR" "$SIF_PATH" \
  TEsorter "$OUTPUT_DIR/Gypsy_sequences.fa" -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"