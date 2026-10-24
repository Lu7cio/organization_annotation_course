#!/bin/bash
#SBATCH --job-name=parseRM
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/parseRM/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/parseRM/%x_%j.err

# Define working directory and input/output file paths
WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
SIF_PATH="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
INPUT="$WORKDIR/output/EDTA/assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.EDTA.RM.nonzero.out"

# Run the parseRM.pl script 
apptainer exec \
    -C \
    --bind "$WORKDIR" \
    --bind "$COURSEDIR" \
    "$SIF_PATH" \
    perl "$WORKDIR/scripts/05-parseRM.pl" \
    -i "$INPUT" \
    --l 50,1 \
    -v


