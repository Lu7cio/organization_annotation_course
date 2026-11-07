#!/bin/bash
#SBATCH --job-name=filter_gff_quality
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/filter_gff_quality/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/filter_gff_quality/%x_%j.err

WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
gff="assembly.all.maker.noseq.gff.renamed.iprscan.gff"
output="assembly.all.maker.noseq.gff.renamed.iprscan.quality_filtered.gff"

cd "$FINALDIR"

# Filter the GFF3 file for quality
apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$FINALDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    perl /usr/local/bin/quality_filter.pl \
    -s "$gff" \
    > "$output"