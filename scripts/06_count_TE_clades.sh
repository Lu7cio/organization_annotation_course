#!/bin/bash
#SBATCH --job-name=count_TE_clades
#SBATCH --partition=pibu_el8
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=01:00:00
#SBATCH --output=/data/users/mkummer/organization_annotation_course/logs/count_TE_clades/%x_%j.out
#SBATCH --error=/data/users/mkummer/organization_annotation_course/logs/count_TE_clades/%x_%j.err

# Define working directory and input/output file paths
WORKDIR="/data/users/mkummer/organization_annotation_course"
OUTPUT_DIR="$WORKDIR/output/EDTA"
COPIA="$OUTPUT_DIR/Copia_sequences.fa.rexdb-plant.cls.tsv"
GYPSY="$OUTPUT_DIR/Gypsy_sequences.fa.rexdb-plant.cls.tsv"
GFF="$OUTPUT_DIR/assembly.fasta.mod.EDTA.TEanno.gff3"
TABLE="$OUTPUT_DIR/clade_abundance.tsv"

# Get the count of the TE clades and write to the output table
awk -F '\t' -v OFS='\t' -v copia="$COPIA" -v gypsy="$GYPSY" '
  FILENAME == copia || FILENAME == gypsy {
    if (FNR > 1) {
      split($1, id, "#")
      clade[id[1]] = $3 OFS $4
    }
    next
  }

  /^#/ { next }

  {
    name = ""
    n = split($9, fields, ";")
    for (i = 1; i <= n; i++) {
      split(fields[i], attribute, "=")
      if (attribute[1] == "Name") name = attribute[2]
    }

    if (name in clade) {
      split(clade[name], classification, OFS)
      count[classification[1], classification[2]]++
    }
  }

  END {
    print "Superfamily", "Clade", "Number_of_genomic_elements" > table
    for (key in count) {
      split(key, classification, SUBSEP)
      print classification[1], classification[2], count[key] >> table
    }
  }
' table="$TABLE" "$COPIA" "$GYPSY" "$GFF"

{
  head -n 1 "$TABLE"
  tail -n +2 "$TABLE" | sort -t $'\t' -k3,3nr
} > "$TABLE.tmp"
mv "$TABLE.tmp" "$TABLE"

echo "Created: $TABLE"
