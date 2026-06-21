#' Read GEMMA association results
#'
#' @param file Path to a GEMMA .assoc.txt file.
#' @param p_column Which p-value column to use: "p_wald", "p_lrt", or "p_score".
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' \donttest{
#' gwas <- read_gemma("my_results.assoc.txt")
#' }
read_gemma <- function(file, p_column = "p_wald", ...) {
  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")
  as_gwas_data(dt, chr = "chr", bp = "ps", snp = "rs",
               p = p_column, beta = "beta", se = "se",
               a1 = "allele1", a2 = "allele0", af = "af")
}
