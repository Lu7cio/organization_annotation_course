#!/bin/bash
#SBATCH --job-name=rename_genes
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/rename_genes/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/rename_genes/%x_%j.err


WORKDIR="/data/users/mkummer/organization_annotation_course"
COURSEDIR="/data/courses/genome_annotation_resources/2026"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"

protein="assembly.all.maker.all.maker.proteins.fasta"
transcript="assembly.all.maker.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"
prefix="Etna-2"

mkdir -p "$FINALDIR/tmp" "$WORKDIR/logs/rename_genes"

cd "$OUTDIR"

cp "$gff" "$FINALDIR/${gff}.renamed.gff"
cp "$protein" "$FINALDIR/${protein}.renamed.fasta"
cp "$transcript" "$FINALDIR/${transcript}.renamed.fasta"

cd "$FINALDIR"

apptainer exec --cleanenv \
    --bind /data \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    maker_map_ids --prefix "$prefix" --justify 7 \
    "${gff}.renamed.gff" > id.map

apptainer exec --cleanenv \
    --bind /data \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    map_gff_ids id.map "${gff}.renamed.gff"

apptainer exec --cleanenv \
    --bind /data \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    map_fasta_ids id.map "${protein}.renamed.fasta"

apptainer exec --cleanenv \
    --bind /data \
    --pwd "$FINALDIR" \
    "$MAKER_SIF" \
    map_fasta_ids id.map "${transcript}.renamed.fasta"
