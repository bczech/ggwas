#' Built-in protein-coding gene annotations
#'
#' Return a data.frame of protein-coding gene positions bundled with ggwas,
#' ready for [gene_track()], [locus_plot()] or [manhattan_genes()], so that
#' regional and gene-labelled plots work without downloading a GTF. Data are
#' derived from Ensembl (GRCh38 release 103; GRCh37 release 75) and restricted
#' to protein-coding genes.
#'
#' @param build Genome build: `"GRCh38"` (default) or `"GRCh37"`.
#' @return A data.frame with columns `chr` (integer), `start`, `end`,
#'   `gene` (symbol), `strand`, and `gene_id` (Ensembl gene ID).
#' @export
#' @examples
#' genes <- gene_annotation("GRCh38")
#' head(genes)
#'
#' # Gene track for a region, no GTF needed
#' gene_track(genes, region_chr = 6, region_start = 25e6, region_end = 34e6)
gene_annotation <- function(build = c("GRCh38", "GRCh37")) {
  build <- match.arg(build)
  f <- system.file("extdata", sprintf("genes_%s.rds", build), package = "ggwas")
  if (!nzchar(f) || !file.exists(f)) {
    cli_abort("Built-in gene data for {.val {build}} not found.")
  }
  readRDS(f)
}
