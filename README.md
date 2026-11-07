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
`scripts/`. Shell scripts were submitted with `sbatch`. The generated files are
stored in `output/`, and SLURM logs are stored in `logs/`.

The workflow follows these steps:

1. **TE annotation** (`01`–`03`): build a transposable-element library with
   EDTA, classify intact LTR retrotransposons with TEsorter, and calculate LTR
   identity and copy-number distributions.
2. **TE characterization** (`04`–`11`): extract and classify Copia and Gypsy
   sequences, summarize TE clades, index the genome FASTA, create circular
   annotation plots, and calculate repeat divergence.
3. **Structural annotation** (`12`–`16`): run MAKER, merge and rename gene
   models, and incorporate InterProScan results.
4. **Annotation quality control** (`17`–`25`): examine AED values, generate
   AED plots, filter GFF3 features, extract representative proteins, assess
   BUSCO and AGAT statistics, and summarize Pfam/AED results.
5. **Functional annotation** (`26`–`28`): perform BLAST comparisons, add
   UniProt functions, and summarize the final annotation.
6. **Comparative genomics** (`29`–`31`): prepare GENESPACE inputs, run
   GENESPACE against TAIR10 and the other accessions, and generate synteny
   results.
7. **Pangenome visualization** (`32`–`35`): process the pangenome and generate
   customized two-genome and five-genome riparian plots.


## Folder structure

```text
.
├── README.md
├── scripts/
│   ├── 01-run_EDTA.sh
│   ├── 02-run_TEsorter_full_length_LTRs.sh
│   ├── 03-full_length_LTRs_identity_copy.R
│   ├── 04_extract_Copia_and_Gypsy_seq.sh
│   ├── 05_Tesorter_Copia_and_Gypsy_seq.sh
│   ├── 06_count_TE_clades.sh
│   ├── 07_index_fasta.sh
│   ├── 08-annotation_circlize.R
│   ├── 09-parseRM.pl
│   ├── 10_run_parseRM.sh
│   ├── 11-plot_div.R
│   ├── 12-run_maker.sh
│   ├── 13_merged_gff.sh
│   ├── 14_rename_Genes_Transcripts.sh
│   ├── 15_InterProScan.sh
│   ├── 16_InterProScan_incorparation_GFF3.sh
│   ├── 17_examine_AED_values.sh
│   ├── 18_plot_AED.R
│   ├── 19_filter_gff_quality.sh
│   ├── 20_filter_gff_gene_features.sh
│   ├── 21_extract_filtered_sequences copy.sh
│   ├── 22_extract_longest.sh
│   ├── 23_BUSCO_quality.sh
│   ├── 24_AGAT_annotation_statistics.sh
│   ├── 25_pfam_aed_summary.sh
│   ├── 26_blast_comparisons.sh
│   ├── 27_add_UniProt_functions.sh
│   ├── 28_summarize_annotation.sh
│   ├── 29_prepare_genspace_input.sh
│   ├── 30_genespace.R
│   ├── 31_run_genespace.sh
│   ├── 32_process_pangenome.R
│   ├── 33_run_process_pangenome.sh
│   ├── 34_plot_riparian.R
│   └── 35_run_plot_riparian.sh
```
