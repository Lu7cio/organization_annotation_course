# Course

**Organization and annotation of eukaryote genomes, Autumn Semester 2026, University of Bern**

## Authors
Mario Lucio Kummer

## Description
The goal of this course project was to annotate the genome of the plant
species *Arabidopsis thaliana* accession Etna-2, with a focus on transposable
elements (TEs) and the classification of intact LTR retrotransposons.

The course examines the main evolutionary processes shaping the organization
of plant and animal genomes. It compares and applies complementary approaches
to characterize gene models and transposable elements in model and non-model
organisms.

## Overview workflow

The bash scirpts were submitted on the cluster with sbatch myscript.sh.

The following wokflwo order of the scripts was used to annotate the genome and classify intact LTR retrotransposons:

1. builds a TE library and annotates the genome with EDTA;
2. classifies intact LTR retrotransposons with TEsorter;
3. extracts and classifies Copia and Gypsy sequences;
4. summarizes TE clade abundance and insertion-age distributions;
5. produces LTR identity and genome-wide TE-density plots;
6. annotates genes with MAKER; and
7. incorporates InterProScan results and evaluates annotation quality.


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
│   └── 20_pfam_aed_summary.sh
```


