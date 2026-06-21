# Column name detection patterns
.chr_patterns <- c(
  "CHR", "CHROM", "#CHROM", "chromosome", "chr_name", "Chr", "chr"
)
.bp_patterns <- c(
  "BP", "POS", "GENPOS", "bp", "ps", "position", "base_pair_location",
  "BasePairLocation", "Pos"
)
.snp_patterns <- c(

  "SNP", "ID", "rs", "rsid", "MarkerName", "variant_id", "SNPID", "rsID"
)
.p_patterns <- c(
  "P", "PVALUE", "P_VALUE", "p_value", "pvalue", "p.value",
  "P_BOLT_LMM_INF", "P_BOLT_LMM", "p_wald", "p_lrt", "Pvalue"
)
.beta_patterns <- c(
  "BETA", "beta", "b", "Effect", "EFFECT", "effect_size", "Beta"
)
.se_patterns <- c(
  "SE", "se", "StdErr", "standard_error", "se_beta"
)
.a1_patterns <- c(
  "A1", "ALLELE1", "allele1", "ALT", "effect_allele", "Allele1"
)
.a2_patterns <- c(
  "A2", "ALLELE0", "allele0", "REF", "other_allele", "Allele2"
)
.af_patterns <- c(
  "AF", "A1FREQ", "Freq", "MAF", "allele_frequency", "FRQ", "af"
)
.n_patterns <- c("N", "n", "NMISS", "n_complete_samples", "OBS_CT")
.info_patterns <- c("INFO", "info", "R2", "r2")

#' Detect column mapping from header names
#' @noRd
detect_columns <- function(header) {
  mapping <- list()
  match_col <- function(patterns) {
    idx <- match(patterns, header)
    matched <- which(!is.na(idx))[1]
    if (!is.na(matched)) header[idx[matched]] else NA_character_
  }

  mapping$CHR <- match_col(.chr_patterns)
  mapping$BP <- match_col(.bp_patterns)
  mapping$SNP <- match_col(.snp_patterns)
  mapping$P <- match_col(.p_patterns)
  mapping$BETA <- match_col(.beta_patterns)
  mapping$SE <- match_col(.se_patterns)
  mapping$A1 <- match_col(.a1_patterns)
  mapping$A2 <- match_col(.a2_patterns)
  mapping$AF <- match_col(.af_patterns)
  mapping$N <- match_col(.n_patterns)
  mapping$INFO <- match_col(.info_patterns)
  mapping[!is.na(mapping)]
}

#' Parse chromosome to integer
#' @noRd
chr_to_int <- function(x) {
  x <- as.character(x)
  x <- sub("^chr", "", x, ignore.case = TRUE)
  x <- sub("^0+(\\d)", "\\1", x)
  x[x == "X"] <- "23"
  x[x == "Y"] <- "24"
  x[x == "XY"] <- "25"
  x[x == "MT" | x == "M"] <- "26"
  as.integer(x)
}

#' Convert integer chromosome back to label
#' @noRd
int_to_chr <- function(x) {

  labels <- as.character(x)
  labels[x == 23] <- "X"
  labels[x == 24] <- "Y"
  labels[x == 25] <- "XY"
  labels[x == 26] <- "MT"
  labels
}

#' Calculate genomic inflation factor (lambda GC)
#'
#' @param p Numeric vector of p-values.
#' @return Genomic inflation factor (lambda).
#' @export
calc_lambda <- function(p) {
  p <- p[!is.na(p) & p > 0 & p <= 1]
  chisq <- qchisq(p, df = 1, lower.tail = FALSE)
  median(chisq) / qchisq(0.5, df = 1)
}

#' Add cumulative base pair positions for genome-wide plotting
#' @noRd
add_cumulative_bp <- function(data) {
  chr_lengths <- stats::aggregate(
    data$BP,
    by = list(CHR = data$CHR),
    FUN = max
  )
  names(chr_lengths) <- c("CHR", "max_bp")
  chr_lengths <- chr_lengths[order(chr_lengths$CHR), ]
  chr_lengths$cumstart <- cumsum(c(0, chr_lengths$max_bp[-nrow(chr_lengths)]))

  gap <- max(chr_lengths$max_bp) * 0.02
  chr_lengths$cumstart <- chr_lengths$cumstart +
    (seq_len(nrow(chr_lengths)) - 1) * gap

  chr_lengths$center <- chr_lengths$cumstart + chr_lengths$max_bp / 2

  cumstart_vec <- stats::setNames(chr_lengths$cumstart, chr_lengths$CHR)
  data$BP_CUM <- data$BP + cumstart_vec[as.character(data$CHR)]

  attr(data, "chr_info") <- chr_lengths

  data
}
