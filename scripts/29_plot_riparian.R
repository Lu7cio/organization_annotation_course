library(GENESPACE)

wd <- "/data/users/mkummer/organization_annotation_course/output/comparisons/GENESPACE"
focal_genome <- "Etna_2"

load(file.path(wd, "results", "gsParams.rda"))
dir.create(file.path(wd, "processed_riparian"), showWarnings = FALSE)

# First-pass comparison with scaffold order determined by synteny.
plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  pdfFile = file.path(wd, "processed_riparian", "Etna_2_vs_TAIR10.pdf")
)

# contig_138 is consistently reverse-oriented in the TAIR10 comparison.
flip_chrs <- c("contig_138")
focal_bed <- file.path(wd, "bed", paste0(focal_genome, ".bed"))
focal_scaffolds <- unique(read.delim(focal_bed, header = FALSE, stringsAsFactors = FALSE)[[1]])
unknown_flips <- setdiff(flip_chrs, focal_scaffolds)
if (length(unknown_flips) > 0) {
  stop(
    "Unknown scaffold(s) in flip_chrs: ",
    paste(unknown_flips, collapse = ", "),
    ". Check the scaffold names in ",
    focal_bed,
    "."
  )
}

flips <- data.frame(
  genome = focal_genome,
  chr = flip_chrs,
  stringsAsFactors = FALSE
)

# Re-render the comparison with the selected scaffold orientation corrected.
plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", focal_genome),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  pdfFile = file.path(
    wd,
    "processed_riparian",
    "Etna_2_vs_TAIR10_oriented.pdf"
  )
)

plot_riparian(
  gsParam,
  genomeIDs = c("TAIR10", "Etna_2", "Kar_1", "Altai_5", "Ice_1"),
  refGenome = "TAIR10",
  reorderBySynteny = TRUE,
  syntenyWeight = 1,
  invertTheseChrs = flips,
  scalePlotWidth = 1.5,
  pdfFile = file.path(wd, "processed_riparian", "all_genomes_TAIR10.pdf")
)
