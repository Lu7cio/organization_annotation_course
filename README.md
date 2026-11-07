# Course

**Organization and annotation of eukaryote genomes, Autumn Semester 2026, University of Bern**

## Authors
Mario Lucio Kummer

## Description
The goal of this course project was to annotate the genome of the plant
species *Arabidopsis thaliana* accession Etna-2, with a focus on transposable
elements (TEs) and the classification of intact LTR retrotransposons.

## Workflow overview

The analysis was performed on the cluster using the numbered scripts in
`scripts/`. Shell scripts were submitted with `sbatch`; generated files are
stored in `output/`, and SLURM logs are stored in `logs/`.

The workflow follows these steps:

1. Build a transposable-element library and annotate the genome with EDTA.
2. Classify intact LTR retrotransposons with TEsorter.
3. Extract and classify Copia and Gypsy sequences.
4. Summarize TE clade abundance and insertion-age distributions.
5. Generate LTR identity and genome-wide TE-density plots.
6. Annotate genes with MAKER.
7. Merge, rename, filter, and evaluate gene models using InterProScan, AED,
   BUSCO, and AGAT analyses.
8. Perform BLAST comparisons, add UniProt functions, and summarize the final
   annotation.
9. Prepare GENESPACE inputs and run comparative synteny analyses against
   TAIR10 and the other accessions.
10. Process the pangenome and generate customized two-genome and five-genome
    riparian plots.


## Folder structure

```text
.
├── README.md
├── scripts/
│   ├── 01-run_EDTA.sh
│   ├── 02-run_TEsorter_full_length_LTRs.sh
│   ├── 03-full_length_LTRs_identity_copy.R
│   ├── 04-annotation_circlize.R
│   ├── 04_index_fasta.sh
│   ├── 04_extract_Copia_and_Gypsy_seq.sh
│   ├── 04_Tesorter_Copia_and_Gypsy_seq.sh
│   ├── 04_count_TE_clades.sh
│   ├── 05_run_parseRM.sh
│   ├── 05-parseRM.pl
│   ├── 06-plot_div.R
│   ├── 07-run_maker.sh
│   ├── 08_merged_gff.sh
│   ├── 09_rename_Genes_Transcripts.sh
│   ├── 10_InterProScan.sh
│   ├── 11_InterProScan_incorparation_GFF3.sh
│   ├── 12_examine_AED_values.sh
│   ├── 13_plot_AED.R
│   ├── 14_filter_gff_quality.sh
│   ├── 15_filter_gff_gene_features.sh
│   ├── 16_extract_filtered_sequences copy.sh
│   ├── 17_extract_longest.sh
│   ├── 18_BUSCO_quality.sh
│   ├── 19_AGAT_annotation_statistics.sh
│   ├── 20_pfam_aed_summary.sh
│   ├── 21_blast_comparisons.sh
│   ├── 22_add_UniProt_functions.sh
│   ├── 23_summarize_annotation.sh
│   ├── 24_prepare_genspace_input.sh
│   ├── 25_genespace.R
│   ├── 26_run_genespace.sh
│   ├── 27_process_pangenome.R
│   ├── 28_run_process_pangenome.sh
│   ├── 29_plot_riparian.R
│   └── 30_run_plot_riparian.sh
```
