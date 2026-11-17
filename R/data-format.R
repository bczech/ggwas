#' Create a gwas_data object
#'
#' Convert a data.frame to the standardized gwas_data format used by all
#' ggwas plotting functions.
#'
#' @param x A data.frame, tibble, data.table, or a Bioconductor `GRanges`
#'   object (variant positions are taken from the ranges and association
#'   statistics from the metadata columns).
#' @param chr,bp,snp,p,beta,se,a1,a2,af,n,info Column names to use.
#'   If NULL, auto-detection is attempted.
#' @param log_p If TRUE, the p-value column contains -log10(p) values. Use
#'   this for p-values smaller than R can store (about 1e-323).
#' @return A data.frame with class `gwas_data`. P-values below the double
#'   range are stored as `P = 0`; their exact -log10(p) is then kept in a
#'   `LOG10P` column, which all plots use. It comes from a -log10(p) column
#'   (`log_p = TRUE`), from p-values read as text (e.g. `"1e-400"`, as
#'   [data.table::fread()] returns them), or from a `LOG10P` column next to
#'   the p-values.
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
  if (inherits(x, "GRanges")) {
    x <- .granges_to_df(x)
  }
  if (!is.data.frame(x)) {
    cli_abort("{.arg x} must be a data.frame, tibble, data.table, or GRanges.")
  }

  x <- as.data.frame(x)
  header <- names(x)

  user_map <- list(
    CHR = chr, BP = bp, SNP = snp, P = p, BETA = beta, SE = se,
    A1 = a1, A2 = a2, AF = af, N = n, INFO = info
  )
  user_map <- user_map[!vapply(user_map, is.null, logical(1))]

  auto_map <- detect_columns(header)
  p_is_log <- isTRUE(attr(auto_map, "P_is_log"))
  mapping <- auto_map
  mapping[names(user_map)] <- user_map

  required <- c("CHR", "BP", "P")
  missing_req <- setdiff(required, names(mapping))
  if (length(missing_req) > 0) {
    cli_abort(c(
      "Cannot detect required column{?s}: {.field {missing_req}}.",
      "i" = "Rename them to standard names, or pass them explicitly via the {.arg chr}, {.arg bp} and {.arg p} arguments."
    ))
  }

  # A -log10(p) column (e.g. LOG10P, neg_log_pvalue) was auto-detected: treat
  # it as -log10(p) unless the user supplied the p column or log_p explicitly.
  if (p_is_log && is.null(p) && !isTRUE(log_p)) {
    log_p <- TRUE
    cli_inform(
      "Detected a -log10 p-value column ({.field {mapping$P}}); interpreting it as -log10(p)."
    )
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

  # Keep -log10(p) exact for p-values below the double range (about 5e-324),
  # which R stores as 0: from a -log10(p) column, from p-values read as text
  # (e.g. "1e-400"), or from an extra LOG10P column next to P.
  if (log_p) {
    logp <- as.numeric(result$P)
    result$P <- 10^(-logp)
  } else {
    parsed <- .parse_p(result$P)
    result$P <- parsed$p
    logp <- parsed$logp
    if ("LOG10P" %in% names(result)) {
      logp_col <- suppressWarnings(as.numeric(result$LOG10P))
      fill <- !is.finite(logp) & is.finite(logp_col)
      logp[fill] <- logp_col[fill]
    }
  }
  tiny <- !is.na(result$P) & result$P < .Machine$double.xmin & is.finite(logp)
  if (any(tiny)) {
    result$LOG10P <- logp
  }

  if (!is.null(result$BETA)) result$BETA <- as.numeric(result$BETA)
  if (!is.null(result$SE)) result$SE <- as.numeric(result$SE)

  if (!is.null(result$AF)) result$AF <- as.numeric(result$AF)
  if (!is.null(result$N)) result$N <- as.integer(result$N)
  if (!is.null(result$INFO)) result$INFO <- as.numeric(result$INFO)

  class(result) <- c("gwas_data", "data.frame")
  validate_gwas_data(result)
  result
}

#' Convert GWAS results to a GRanges object
#'
#' Turn a `gwas_data` object or data.frame into a Bioconductor
#' \link[GenomicRanges]{GRanges} object, with association statistics stored as
#' metadata columns, for interoperability with the Bioconductor ecosystem
#' (e.g. VariantAnnotation, SummarizedExperiment, coloc).
#'
#' @param x A `gwas_data` object or a data.frame accepted by [as_gwas_data()].
#' @param ... Column overrides passed to [as_gwas_data()] when `x` is a plain
#'   data.frame.
#' @return A \link[GenomicRanges]{GRanges} object, one width-1 range per
#'   variant, named by SNP when available.
#' @export
#' @examples
#' data(example_gwas)
#' gr <- as_granges(example_gwas)
#' gr
#'
#' # Round-trip back to gwas_data
#' as_gwas_data(gr)
as_granges <- function(x, ...) {
  if (!inherits(x, "gwas_data")) x <- as_gwas_data(x, ...)
  meta_cols <- setdiff(names(x), c("CHR", "BP"))
  gr <- GenomicRanges::GRanges(
    seqnames = int_to_chr(x$CHR),
    ranges = IRanges::IRanges(start = x$BP, width = 1L)
  )
  if (length(meta_cols) > 0) {
    S4Vectors::mcols(gr) <- x[, meta_cols, drop = FALSE]
  }
  if ("SNP" %in% names(x)) names(gr) <- as.character(x$SNP)
  gr
}

#' @noRd
.granges_to_df <- function(gr) {
  df <- data.frame(
    CHR = as.character(GenomicRanges::seqnames(gr)),
    BP = GenomicRanges::start(gr),
    stringsAsFactors = FALSE
  )
  md <- S4Vectors::mcols(gr)
  if (!is.null(md) && ncol(md) > 0) {
    df <- cbind(df, as.data.frame(md, stringsAsFactors = FALSE))
  }
  if (!is.null(names(gr)) && !"SNP" %in% names(df)) {
    df$SNP <- names(gr)
  }
  df
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

  n_zero_p <- sum(x$P == 0 & !.drawable_p(x), na.rm = TRUE)
  if (n_zero_p > 0) {
    cli_warn(c(
      "{n_zero_p} p-value{?s} of exactly 0 detected; {?it/they} will be left out of plots.",
      "i" = "P-values below about 1e-323 cannot be stored as numbers in R. Supply -log10(p) instead ({.code log_p = TRUE}), or read the p-values as text so they are parsed exactly."
    ))
  }

  n_invalid_p <- sum(x$P < 0 | x$P > 1, na.rm = TRUE)
  if (n_invalid_p > 0) {
    cli_abort("{n_invalid_p} p-value{?s} outside [0, 1] range.")
  }

  invisible(x)
}

#' Smallest p-value as text, exact also below the double range
#' @noRd
.min_p_label <- function(x) {
  logp <- .neglog10p(x)
  if (!any(is.finite(logp))) {
    p <- x$P[!is.na(x$P)]
    return(if (length(p) > 0) .format_p(min(p)) else "NA")
  }
  i <- which.max(replace(logp, !is.finite(logp), -Inf))
  .format_p(x$P[i], logp[i])
}

#' @export
print.gwas_data <- function(x, ...) {
  n <- nrow(x)
  n_chr <- length(unique(x$CHR))
  cat(sprintf(
    "A gwas_data object: %s variants across %d chromosome%s\n",
    format(n, big.mark = ","), n_chr, if (n_chr > 1) "s" else ""
  ))
  cat(sprintf("  Min p-value: %s\n", .min_p_label(x)))
  cat(sprintf("  Lambda GC:   %.3f\n", calc_lambda(x$P)))
  cols <- names(x)
  cat(sprintf("  Columns:     %s\n", paste(cols, collapse = ", ")))
  invisible(x)
}

#' @export
summary.gwas_data <- function(object, ...) {
  out <- list(
    n = nrow(object),
    chromosomes = sort(unique(object$CHR)),
    lambda = calc_lambda(object$P),
    min_p = min(object$P, na.rm = TRUE),
    min_p_label = .min_p_label(object),
    n_5e8 = sum(object$P < 5e-8, na.rm = TRUE),
    n_1e5 = sum(object$P < 1e-5, na.rm = TRUE),
    beta = if ("BETA" %in% names(object)) {
      c(median = stats::median(object$BETA, na.rm = TRUE),
        min = min(object$BETA, na.rm = TRUE),
        max = max(object$BETA, na.rm = TRUE))
    }
  )
  class(out) <- "summary.gwas_data"
  out
}

#' @export
print.summary.gwas_data <- function(x, ...) {
  cat("=== GWAS Data Summary ===\n\n")
  cat(sprintf("Variants:     %s\n", format(x$n, big.mark = ",")))
  cat(sprintf("Chromosomes:  %s\n", paste(x$chromosomes, collapse = ", ")))
  cat(sprintf("Lambda GC:    %.4f\n", x$lambda))
  cat(sprintf("Min p-value:  %s\n", x$min_p_label))
  cat(sprintf("Genome-wide significant (p < 5e-8): %d\n", x$n_5e8))
  cat(sprintf("Suggestive (p < 1e-5):              %d\n", x$n_1e5))
  if (!is.null(x$beta)) {
    cat(sprintf("\nEffect sizes (BETA): median = %.4f, range = [%.4f, %.4f]\n",
                x$beta[["median"]], x$beta[["min"]], x$beta[["max"]]))
  }
  invisible(x)
}
