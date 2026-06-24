#' Read REGENIE results
#'
#' @param file Path to a .regenie results file.
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' \dontrun{
#' gwas <- read_regenie("my_results.regenie")
#' }
read_regenie <- function(file, ...) {
  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")

  log_p <- "LOG10P" %in% names(dt) && !"P" %in% names(dt)
  as_gwas_data(dt, chr = "CHROM", bp = "GENPOS", snp = "ID",
               p = if (log_p) "LOG10P" else NULL,
               beta = "BETA", se = "SE", a1 = "ALLELE1", a2 = "ALLELE0",
               af = "A1FREQ", n = "N", log_p = log_p)
}
