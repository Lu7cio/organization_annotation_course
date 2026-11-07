#!/bin/bash
#SBATCH --job-name=ipr_update_gff
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/interproscan_incorporation/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/interproscan_incorporation/%x_%j.err

WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
INTERPROSCAN_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
gff="assembly.all.maker.noseq.gff.renamed.gff"

mkdir -p "$FINALDIR/tmp"
cd "$FINALDIR"

apptainer exec --cleanenv --env TMPDIR=/tmp \
    --bind "$FINALDIR/tmp":/tmp \
    --bind "$COURSEDIR" \
    --bind "$WORKDIR" \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    ipr_update_gff "$gff" output.iprscan \
    > "${gff%.gff}.iprscan.gff"