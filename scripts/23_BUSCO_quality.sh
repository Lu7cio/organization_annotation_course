#!/bin/bash
#SBATCH --job-name=busco_quality
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/busco_quality/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/busco_quality/%x_%j.err

# Define directories and file names
WORKDIR="/data/users/mkummer/organization_annotation_course"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
transcript="assembly.all.maker.all.maker.transcripts.fasta"
protein="assembly.all.maker.all.maker.proteins.fasta"

# Make sure we are in the final directory where the longest sequences are located
cd "$FINALDIR" 

# Load Busco module
module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1

# Run BUSCO on the LONGEST protein and transcript sequences
busco -i "${protein}.renamed.longest.fasta" \
      -l brassicales_odb10 -o busco_proteins -m proteins -c 4

busco -i "${transcript}.renamed.longest.fasta" \
      -l brassicales_odb10 -o busco_transcripts -m transcriptome -c 4