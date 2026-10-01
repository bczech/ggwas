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
# Gene identifier columns (for value_manhattan annotation lookups).
.id_patterns <- c(
  "gene_id", "GeneID", "ensembl_gene_id", "ENSEMBL", "ensembl",
  "feature_id", "gene"
)
# Gene-level position columns, used only as a value_manhattan fallback so GWAS
# position detection stays unchanged.
.bp_gene_patterns <- c("start", "gene_start", "txStart", "Start")
.p_patterns <- c(
  "P", "PVALUE", "P_VALUE", "p_value", "pvalue", "p.value",
  "P_BOLT_LMM_INF", "P_BOLT_LMM", "p_wald", "p_lrt", "Pvalue"
)
.logp_patterns <- c(
  "LOG10P", "neg_log_pvalue", "neg_log10_pvalue", "neg_log10_p",
  "log10_p", "log10p", "mlog10p", "minus_log10_p", "neglog10p"
)
.beta_patterns <- c(
  "BETA", "beta", "b", "Effect", "EFFECT", "effect_size", "Beta"
)
.se_patterns <- c(
  "SE", "StdErr", "standard_error", "se_beta", "stderr_beta", "sebeta"
)
.a1_patterns <- c(
  "A1", "ALLELE1", "allele1", "ALT", "effect_allele", "Allele1"
)
.a2_patterns <- c(
  "A2", "ALLELE0", "allele0", "REF", "other_allele", "Allele2"
)
.af_patterns <- c(
  "AF", "A1FREQ", "Freq", "MAF", "allele_frequency", "FRQ",
  "alt_allele_freq", "effect_allele_frequency", "eaf"
)
.n_patterns <- c("N", "n", "NMISS", "n_complete_samples", "OBS_CT")
.info_patterns <- c("INFO", "info", "R2", "r2")

# Case-insensitive lookup of the first matching column name.
#' @noRd
.match_col <- function(header, patterns) {
  idx <- match(tolower(patterns), tolower(header))
  matched <- which(!is.na(idx))[1]
  if (!is.na(matched)) header[idx[matched]] else NA_character_
}

# Return NULL instead of NA, for optional column resolution.
#' @noRd
.na_null <- function(x) if (length(x) == 0 || is.na(x)) NULL else x

#' Detect column mapping from header names
#' @noRd
detect_columns <- function(header) {
  mapping <- list()
  match_col <- function(patterns) .match_col(header, patterns)

  mapping$CHR <- match_col(.chr_patterns)
  mapping$BP <- match_col(.bp_patterns)
  mapping$SNP <- match_col(.snp_patterns)

  # Prefer a raw p-value column; fall back to a -log10(p) column and flag it.
  p_is_log <- FALSE
  p_raw <- match_col(.p_patterns)
  if (!is.na(p_raw)) {
    mapping$P <- p_raw
  } else {
    p_log <- match_col(.logp_patterns)
    if (!is.na(p_log)) {
      mapping$P <- p_log
      p_is_log <- TRUE
    } else {
      mapping$P <- NA_character_
    }
  }

  mapping$BETA <- match_col(.beta_patterns)
  mapping$SE <- match_col(.se_patterns)
  mapping$A1 <- match_col(.a1_patterns)
  mapping$A2 <- match_col(.a2_patterns)
  mapping$AF <- match_col(.af_patterns)
  mapping$N <- match_col(.n_patterns)
  mapping$INFO <- match_col(.info_patterns)

  out <- mapping[!is.na(mapping)]
  attr(out, "P_is_log") <- p_is_log
  out
}

#' Parse chromosome to integer
#' @noRd
chr_to_int <- function(x) {
  x <- as.character(x)
  x <- sub("^chr", "", x, ignore.case = TRUE)
  x <- sub("^0+(\\d)", "\\1", x)
  sex_map <- getOption("ggwas.sex_chr_map", default = .default_sex_chr_map)
  for (label in names(sex_map)) {
    x[x == label] <- as.character(sex_map[[label]])
  }
  as.integer(x)
}

#' Convert integer chromosome back to label
#' @noRd
int_to_chr <- function(x) {
  labels <- as.character(x)
  sex_map <- getOption("ggwas.sex_chr_map", default = .default_sex_chr_map)
  for (label in names(sex_map)) {
    val <- sex_map[[label]]
    labels[!is.na(x) & x == val] <- label
  }
  labels
}

.default_sex_chr_map <- c(X = 23L, Y = 24L, XY = 25L, MT = 26L)

#' Calculate genomic inflation factor (lambda GC)
#'
#' @param p Numeric vector of p-values.
#' @return Genomic inflation factor (lambda).
#' @export
#' @examples
#' data(example_gwas)
#' calc_lambda(example_gwas$P)
calc_lambda <- function(p) {
  p <- p[!is.na(p) & p > 0 & p <= 1]
  chisq <- qchisq(p, df = 1, lower.tail = FALSE)
  median(chisq) / qchisq(0.5, df = 1)
}

#' Add cumulative base pair positions for genome-wide plotting
#' @noRd
add_cumulative_bp <- function(data) {
  chr_f <- data$CHR
  max_bp_raw <- tapply(data$BP, chr_f, max)
  chrs <- as.integer(names(max_bp_raw))
  ord <- order(chrs)
  chrs <- chrs[ord]
  max_bp <- as.numeric(max_bp_raw[ord])

  cumstart <- c(0, cumsum(max_bp[-length(max_bp)]))
  gap <- max_bp[1] * 0.05
  cumstart <- cumstart + (seq_along(chrs) - 1) * gap

  chr_lengths <- data.frame(
    CHR = chrs,
    max_bp = as.numeric(max_bp),
    cumstart = cumstart,
    center = cumstart + as.numeric(max_bp) / 2
  )

  cumstart_vec <- stats::setNames(cumstart, chrs)
  data$BP_CUM <- data$BP + cumstart_vec[as.character(chr_f)]

  attr(data, "chr_info") <- chr_lengths
  data
}

#' Shared repel layer for point labels
#'
#' One set of ggrepel settings for every plot that labels SNPs or genes, so
#' labels spread out, always draw a connector, and never sit on the points.
#' @noRd
.snp_repel <- function(mapping, data = NULL, size = 2.7, ...) {
  defaults <- list(
    mapping = mapping,
    data = data,
    inherit.aes = FALSE,
    size = size,
    max.overlaps = Inf,
    box.padding = 0.7,
    point.padding = 0.3,
    min.segment.length = 0,
    segment.color = "grey55",
    segment.size = 0.25,
    force = 5,
    force_pull = 0.3,
    seed = 42
  )
  overrides <- list(...)
  defaults[names(overrides)] <- overrides
  do.call(ggrepel::geom_text_repel, defaults)
}
