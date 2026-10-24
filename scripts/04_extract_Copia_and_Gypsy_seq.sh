#!/bin/bash
#SBATCH --job-name=extract_Copia_and_Gypsy_seq
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/extract_Copia_and_Gypsy_seq/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/extract_Copia_and_Gypsy_seq/%x_%j.err

# Define workdir and paths to the genome and container
WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
GENOME="$WORKDIR/output/EDTA/assembly.fasta"
SIF_PATH="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
TE_LIBRARY="${GENOME}.mod.EDTA.TElib.fa"
OUTPUT_DIR="$WORKDIR/output/EDTA"

# Extract Copia sequences
apptainer exec \
  -C --bind "$WORKDIR" "$SIF_PATH" \
  seqkit grep -r -p "Copia" "$TE_LIBRARY" > "$OUTPUT_DIR/Copia_sequences.fa"

# Extract Gypsy sequences
apptainer exec \
  -C --bind "$WORKDIR" "$SIF_PATH" \
  seqkit grep -r -p "Gypsy" "$TE_LIBRARY" > "$OUTPUT_DIR/Gypsy_sequences.fa"