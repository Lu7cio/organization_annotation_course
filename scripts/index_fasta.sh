#!/bin/bash
#SBATCH --job-name=index_fasta
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/index_fasta/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/index_fasta/%x_%j.err

SIF_PATH="/containers/apptainer/bwa_0.7.19_samtools_1.21.sif"
WORKDIR="/data/users/mkummer/organization_annotation_course"
FASTA="$WORKDIR/output/EDTA/assembly.fasta"

apptainer exec \
  --bind "$WORKDIR:$WORKDIR" \
  --bind "/data/:/data" \
  "$SIF_PATH" \
  samtools faidx "$FASTA"