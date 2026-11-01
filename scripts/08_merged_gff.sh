#!/bin/bash
#SBATCH --job-name=merged_gff
#SBATCH --partition=pshort_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/merged_gff/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/merged_gff/%x_%j.err

COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
WORKDIR="/data/users/mkummer/organization_annotation_course"
OUTDIR="$WORKDIR/output/MAKER"

mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR/assembly.maker.output"

shopt -s nullglob
INDEXES=(*_master_datastore_index.log)
test "${#INDEXES[@]}" -eq 1
INDEX="${INDEXES[0]}"

apptainer exec --cleanenv --env TMPDIR=/tmp \
  --bind "$OUTDIR/tmp":/tmp \
  --bind /data \
  --pwd "$OUTDIR/assembly.maker.output" \
  "$MAKER_SIF" \
  gff3_merge -d "$INDEX" -o ../assembly.all.maker.gff

apptainer exec --cleanenv --env TMPDIR=/tmp \
  --bind "$OUTDIR/tmp":/tmp \
  --bind /data \
  --pwd "$OUTDIR/assembly.maker.output" \
  "$MAKER_SIF" \
  gff3_merge -n -d "$INDEX" -o ../assembly.all.maker.noseq.gff

apptainer exec --cleanenv --env TMPDIR=/tmp \
  --bind "$OUTDIR/tmp":/tmp \
  --bind /data \
  --pwd "$OUTDIR/assembly.maker.output" \
  "$MAKER_SIF" \
  fasta_merge -d "$INDEX" -o ../assembly