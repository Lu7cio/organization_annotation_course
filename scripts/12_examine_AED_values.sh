#!/bin/bash
#SBATCH --job-name=examine_AED
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/examine_AED/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/examine_AED/%x_%j.err

WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
gff="assembly.all.maker.noseq.gff.renamed.iprscan.gff"

mkdir -p "$FINALDIR/tmp" 
cd "$FINALDIR"

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$FINALDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    perl /usr/local/bin/AED_cdf_generator.pl \
    -b 0.025 "$gff" \
    > assembly.all.maker.renamed.gff.AED.txt