#' Read PLINK association results
#'
#' @param file Path to a PLINK .assoc file.
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' f <- system.file("extdata", "example_plink.assoc", package = "ggwas")
#' gwas <- read_plink_assoc(f)
#' gwas
read_plink_assoc <- function(file, ...) {
  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")
  as_gwas_data(dt)
}

#' Read PLINK linear regression results
#'
#' @param file Path to a PLINK .assoc.linear file.
#' @param test Which test to keep (default "ADD" for additive model).
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' \donttest{
#' gwas <- read_plink_linear("my_results.assoc.linear")
#' }
read_plink_linear <- function(file, test = "ADD", ...) {
  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  if ("TEST" %in% names(dt) && !is.null(test)) {
    dt <- dt[dt$TEST == test, , drop = FALSE]
  }
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")
  as_gwas_data(dt)
}

#' Read PLINK logistic regression results
#'
#' @param file Path to a PLINK .assoc.logistic file.
#' @param test Which test to keep (default "ADD" for additive model).
#' @param ... Additional arguments passed to [data.table::fread()].
#' @return A `gwas_data` object.
#' @export
#' @examples
#' \donttest{
#' gwas <- read_plink_logistic("my_results.assoc.logistic")
#' }
read_plink_logistic <- function(file, test = "ADD", ...) {

  dt <- data.table::fread(file, header = TRUE, data.table = FALSE, ...)
  if ("TEST" %in% names(dt) && !is.null(test)) {
    dt <- dt[dt$TEST == test, , drop = FALSE]
  }
  cli_inform("Read {format(nrow(dt), big.mark = ',')} variants from {.file {basename(file)}}")
  as_gwas_data(dt)
}
