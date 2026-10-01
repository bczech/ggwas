# =============================================================================
# data-raw/genes.R
#
# Regeneruje wbudowane anotacje genów protein-coding dostarczane z ggwas:
#   inst/extdata/genes_GRCh38.rds   (Ensembl GRCh38, release 103)
#   inst/extdata/genes_GRCh37.rds   (Ensembl GRCh37, release 75)
#
# Każdy plik to data.frame z kolumnami: chr (int), start, end, gene (symbol),
# strand, gene_id (ENSG). Kolumna gene_id pozwala annotate_positions() mapować
# identyfikatory Ensembl offline (source = "builtin").
#
# Wejście: pełne GTF-y Ensembl odpowiadające tym wydaniom. Ścieżki poniżej to
# lokalne pliki na maszynie dewelopera — podmień, jeśli trzymasz je gdzie indziej.
#
# Uruchomienie (z katalogu pakietu):
#   Rscript data-raw/genes.R
# =============================================================================

devtools::load_all(".", quiet = TRUE)

# GTF-y zgodne z wydaniami, z których pochodzą wbudowane dane.
gtf_paths <- c(
  GRCh38 = "~/BRASSVis/annotation/Homo_sapiens.GRCh38.103.gtf.gz",
  GRCh37 = "~/BRASSVis/annotation/Homo_sapiens.GRCh37.75.gtf.gz"
)

for (build in names(gtf_paths)) {
  path <- path.expand(gtf_paths[[build]])
  if (!file.exists(path)) {
    stop(sprintf("Brak GTF-a dla %s: %s", build, path))
  }

  # Tylko geny protein-coding; read_gtf zwraca chr/start/end/strand/gene/gene_id.
  genes <- read_gtf(path, feature_type = "gene", biotype = "protein_coding")

  # Stały układ kolumn (gene_id dochodzi na końcu, zgodnie wstecznie).
  genes <- genes[, c("chr", "start", "end", "gene", "strand", "gene_id")]
  genes <- genes[!is.na(genes$chr), , drop = FALSE]
  rownames(genes) <- NULL

  out <- sprintf("inst/extdata/genes_%s.rds", build)
  saveRDS(genes, out, compress = "xz")
  message(sprintf("Zapisano %s (%d genów).", out, nrow(genes)))
}
