#' Read GWAS summary statistics from any tabular file
#'
#' Reads a GWAS results file with automatic column detection. Supports any
#' delimited text file. Column names are matched against common GWAS naming
#' conventions.
#'
#' @param file Path to the input file.
#' @param chr,bp,snp,p,beta,se,a1,a2,af,n,info Optional column name overrides.
#' @param sep Column separator. "auto" uses [data.table::fread()] auto-detection.
#' @param log_p If TRUE, the p-value column contains -log10(p) values.
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' f <- system.file("extdata", "example_plink.assoc", package = "gwasplot")
#' gwas <- read_gwas_table(f)
#' gwas
read_gwas_table <- function(file,
                            chr = NULL,
                            bp = NULL,
                            snp = NULL,
                            p = NULL,
                            beta = NULL,
                            se = NULL,
                            a1 = NULL,
                            a2 = NULL,
                            af = NULL,
                            n = NULL,
                            info = NULL,
                            sep = "auto",
                            log_p = FALSE,
                            ...) {
  if (!file.exists(file)) {
    cli_abort("File not found: {.file {file}}")
  }

  dt <- data.table::fread(
    file,
    sep = if (sep == "auto") "auto" else sep,
    header = TRUE,
    data.table = FALSE,
    ...
  )

  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")

  as_gwas_data(
    dt,
    chr = chr, bp = bp, snp = snp, p = p,
    beta = beta, se = se, a1 = a1, a2 = a2,
    af = af, n = n, info = info, log_p = log_p
  )
}
