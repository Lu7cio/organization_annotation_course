#!/bin/bash
#SBATCH --job-name=extract_filtered_sequences
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/extract_filtered_sequences/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/extract_filtered_sequences/%x_%j.err

# Define directories and file names
WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
gff="filtered.genes.renamed.gff3"
transcript="assembly.all.maker.all.maker.transcripts.fasta"
protein="assembly.all.maker.all.maker.proteins.fasta"

# Make sure we are in the final directory where the longest sequences are located
cd "$FINALDIR"

# Extract the IDs of the filtered mRNA sequences from the GFF3 file and save them to a list
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt

# Use seqkit to extract the filtered sequences from the transcript and protein FASTA files based on the list of IDs
apptainer exec --cleanenv \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --pwd "$FINALDIR" \
  "$ANALYSIS_SIF" \
  seqkit grep -f list.txt ${transcript}.renamed.fasta -o ${transcript}.renamed.filtered.fasta

  apptainer exec --cleanenv \
  --bind "$COURSEDIR" \
  --bind "$WORKDIR" \
  --pwd "$FINALDIR" \ cl
  "$ANALYSIS_SIF" \
  seqkit grep -f list.txt ${protein}.renamed.fasta -o ${protein}.renamed.filtered.fasta

# Check
wc -l list.txt
grep -c '>' ${transcript}.renamed.filtered.fasta
grep -c '>' ${protein}.renamed.filtered.fasta