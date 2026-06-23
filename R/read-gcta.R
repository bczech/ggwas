#' Read GCTA MLMA results
#'
#' @param file Path to a GCTA .mlma file.
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' \donttest{
#' gwas <- read_gcta_mlma("my_results.mlma")
#' }
read_gcta_mlma <- function(file, ...) {
  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")
  as_gwas_data(dt, chr = "Chr", bp = "bp", snp = "SNP",
               p = "p", beta = "b", se = "se",
               a1 = "A1", a2 = "A2", af = "Freq")
}
