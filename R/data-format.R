#' Create a gwas_data object
#'
#' Convert a data.frame to the standardized gwas_data format used by all
#' gwasplot plotting functions.
#'
#' @param x A data.frame, tibble, or data.table.
#' @param chr,bp,snp,p,beta,se,a1,a2,af,n,info Column names to use.
#'   If NULL, auto-detection is attempted.
#' @param log_p If TRUE, the p-value column contains -log10(p) values that
#'   will be back-transformed.
#' @return A tibble with class `gwas_data`.
#' @export
#' @examples
#' df <- data.frame(CHR = c(1, 1, 2), BP = c(1e6, 2e6, 5e6),
#'                  P = c(1e-8, 0.5, 0.01), SNP = c("rs1", "rs2", "rs3"))
#' gd <- as_gwas_data(df)
#' gd
as_gwas_data <- function(x,
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
                         log_p = FALSE) {
  if (!is.data.frame(x)) {
    cli_abort("{.arg x} must be a data.frame, tibble, or data.table.")
  }

  x <- as.data.frame(x)
  header <- names(x)

  user_map <- list(
    CHR = chr, BP = bp, SNP = snp, P = p, BETA = beta, SE = se,
    A1 = a1, A2 = a2, AF = af, N = n, INFO = info
  )
  user_map <- user_map[!vapply(user_map, is.null, logical(1))]

  auto_map <- detect_columns(header)
  mapping <- auto_map
  mapping[names(user_map)] <- user_map

  required <- c("CHR", "BP", "P")
  missing_req <- setdiff(required, names(mapping))
  if (length(missing_req) > 0) {
    cli_abort("Cannot detect required column{?s}: {.field {missing_req}}.
              Specify manually via {.arg {tolower(missing_req)}} argument.")
  }

  result <- data.frame(row.names = seq_len(nrow(x)))
  for (col in names(mapping)) {
    src <- mapping[[col]]
    if (!src %in% header) {
      cli_abort("Column {.val {src}} not found in data.")
    }
    result[[col]] <- x[[src]]
  }

  mapped_src <- unlist(mapping, use.names = FALSE)
  extra_cols <- setdiff(header, mapped_src)
  for (col in extra_cols) {
    result[[col]] <- x[[col]]
  }

  result$CHR <- chr_to_int(result$CHR)
  result$BP <- as.integer(result$BP)

  if (log_p) {
    result$P <- 10^(-result$P)
  }
  result$P <- as.numeric(result$P)

  if (!is.null(result$BETA)) result$BETA <- as.numeric(result$BETA)
  if (!is.null(result$SE)) result$SE <- as.numeric(result$SE)

  if (!is.null(result$AF)) result$AF <- as.numeric(result$AF)
  if (!is.null(result$N)) result$N <- as.integer(result$N)
  if (!is.null(result$INFO)) result$INFO <- as.numeric(result$INFO)

  class(result) <- c("gwas_data", "data.frame")
  validate_gwas_data(result)
  result
}

#' Validate a gwas_data object
#'
#' @param x A gwas_data object.
#' @return Invisible x (raises warnings/errors on invalid data).
#' @examples
#' data(example_gwas)
#' validate_gwas_data(example_gwas)
#' @export
validate_gwas_data <- function(x) {
  if (!"CHR" %in% names(x)) cli_abort("Missing required column: {.field CHR}")
  if (!"BP" %in% names(x)) cli_abort("Missing required column: {.field BP}")
  if (!"P" %in% names(x)) cli_abort("Missing required column: {.field P}")

  n_na_p <- sum(is.na(x$P))
  if (n_na_p > 0) {
    cli_warn("{n_na_p} NA p-value{?s} detected (will be excluded from plots).")
  }

  n_zero_p <- sum(x$P == 0, na.rm = TRUE)
  if (n_zero_p > 0) {
    cli_warn("{n_zero_p} p-value{?s} of exactly 0 detected. Consider setting
             to .Machine$double.xmin.")
  }

  n_invalid_p <- sum(x$P < 0 | x$P > 1, na.rm = TRUE)
  if (n_invalid_p > 0) {
    cli_abort("{n_invalid_p} p-value{?s} outside [0, 1] range.")
  }

  invisible(x)
}

#' @export
print.gwas_data <- function(x, ...) {
  n <- nrow(x)
  n_chr <- length(unique(x$CHR))
  min_p <- min(x$P, na.rm = TRUE)
  cat(sprintf(
    "A gwas_data object: %s variants across %d chromosome%s\n",
    format(n, big.mark = ","), n_chr, if (n_chr > 1) "s" else ""
  ))
  cat(sprintf("  Min p-value: %.2e\n", min_p))
  cat(sprintf("  Lambda GC:   %.3f\n", calc_lambda(x$P)))
  cols <- names(x)
  cat(sprintf("  Columns:     %s\n", paste(cols, collapse = ", ")))
  invisible(x)
}

#' @export
summary.gwas_data <- function(object, ...) {
  cat("=== GWAS Data Summary ===\n\n")
  cat(sprintf("Variants:     %s\n", format(nrow(object), big.mark = ",")))
  cat(sprintf("Chromosomes:  %s\n", paste(sort(unique(object$CHR)), collapse = ", ")))
  cat(sprintf("Lambda GC:    %.4f\n", calc_lambda(object$P)))
  cat(sprintf("Min p-value:  %.2e\n", min(object$P, na.rm = TRUE)))

  sig_5e8 <- sum(object$P < 5e-8, na.rm = TRUE)
  sig_1e5 <- sum(object$P < 1e-5, na.rm = TRUE)
  cat(sprintf("Genome-wide significant (p < 5e-8): %d\n", sig_5e8))
  cat(sprintf("Suggestive (p < 1e-5):              %d\n", sig_1e5))

  if ("BETA" %in% names(object)) {
    cat(sprintf("\nEffect sizes (BETA): median = %.4f, range = [%.4f, %.4f]\n",
                median(object$BETA, na.rm = TRUE),
                min(object$BETA, na.rm = TRUE),
                max(object$BETA, na.rm = TRUE)))
  }
  invisible(object)
}
