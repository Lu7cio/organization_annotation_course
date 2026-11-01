aed_file <- "~/Desktop/3. Semester/Organization_and_Annotation/Weeks_3-4/assembly.all.maker.renamed.gff.AED.txt"
pdf_file <- "~/Desktop/3. Semester/Organization_and_Annotation/Weeks_3-4/plots/AED_cumulative_distribution.pdf"

aed <- read.table(
  aed_file,
  header = TRUE,
  sep = "\t",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

names(aed)[1:2] <- c("AED", "Cumulative")
aed$AED <- as.numeric(aed$AED)
aed$Cumulative <- as.numeric(aed$Cumulative)

if (anyNA(aed$AED) || anyNA(aed$Cumulative)) {
  stop("AED input contains non-numeric values.")
}
if (any(aed$AED < 0 | aed$AED > 1) ||
    any(aed$Cumulative < 0 | aed$Cumulative > 1)) {
  stop("AED values and cumulative proportions must be between 0 and 1.")
}

at_05 <- aed$Cumulative[which.min(abs(aed$AED - 0.5))]
percentage_at_05 <- 100 * at_05

cat(sprintf(
  "Genes with AED <= 0.5: %.1f%%\n",
  percentage_at_05
))

pdf(pdf_file, width = 7, height = 5)
plot(
  aed$AED,
  aed$Cumulative,
  type = "o",
  pch = 16,
  col = "steelblue",
  xlim = c(0, 1),
  ylim = c(0, 1),
  xlab = "AED",
  ylab = "Cumulative proportion of genes",
  main = "Cumulative AED distribution"
)
abline(v = 0.5, lty = 2, col = "firebrick")
abline(h = at_05, lty = 2, col = "firebrick")
legend(
  "bottomright",
  legend = sprintf("AED <= 0.5: %.1f%%", percentage_at_05),
  lty = 2,
  col = "firebrick",
  bty = "n"
)

dev.off()
