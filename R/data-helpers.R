#' Filter variants by genomic region
#'
#' Subset a GWAS dataset to variants within a specified genomic region.
#'
#' @param data A `gwas_data` object or data.frame with CHR and BP columns.
#' @param chr Chromosome (integer or string like "chr6").
#' @param start Start position (bp).
#' @param end End position (bp).
#' @return A filtered `gwas_data` object.
#' @export
#' @examples
#' data(example_gwas)
#' mhc <- filter_region(example_gwas, chr = 6, start = 25e6, end = 34e6)
filter_region <- function(data,
                          chr,
                          start,
                          end) {
  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }
  chr_int <- chr_to_int(chr)
  data[data$CHR == chr_int & data$BP >= start & data$BP <= end, , drop = FALSE]
}

#' Filter variants by minor allele frequency
#'
#' Keep only variants with allele frequency within a specified range.
#' Requires the AF column.
#'
#' @param data A `gwas_data` object or data.frame with an AF column.
#' @param min_maf Minimum minor allele frequency (default 0.01).
#' @param max_maf Maximum minor allele frequency (default 0.5).
#' @return A filtered `gwas_data` object.
#' @export
#' @examples
#' data(example_gwas)
#' common <- maf_filter(example_gwas, min_maf = 0.05)
maf_filter <- function(data,
                       min_maf = 0.01,
                       max_maf = 0.5) {
  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }
  if (!"AF" %in% names(data)) {
    cli_abort("Column {.field AF} is required for MAF filtering.")
  }
  maf <- pmin(data$AF, 1 - data$AF)
  data[!is.na(maf) & maf >= min_maf & maf <= max_maf, , drop = FALSE]
}

#' Merge multiple GWAS datasets
#'
#' Combine results from multiple GWAS into a single data.frame with a
#' `study` column identifying the source. Useful for multi-trait
#' comparisons and meta-analysis visualization.
#'
#' @param ... Named `gwas_data` objects or data.frames. Names become
#'   the `study` column values.
#' @param by Columns to match variants across studies. Default uses
#'   SNP if available, otherwise CHR + BP.
#' @return A data.frame with an added `study` column.
#' @export
#' @examples
#' data(example_gwas)
#' trait1 <- example_gwas
#' trait2 <- example_gwas
#' trait2$P <- runif(nrow(trait2))
#' merged <- merge_gwas(BMI = trait1, Height = trait2)
#' head(merged)
merge_gwas <- function(..., by = NULL) {
  datasets <- list(...)
  if (length(datasets) == 1 && is.list(datasets[[1]]) &&
      !is.data.frame(datasets[[1]])) {
    datasets <- datasets[[1]]
  }
  if (is.null(names(datasets)) || any(names(datasets) == "")) {
    cli_abort("All datasets must be named.")
  }

  merged <- lapply(names(datasets), function(nm) {
    d <- datasets[[nm]]
    if (!inherits(d, "gwas_data")) {
      d <- as_gwas_data(d)
    }
    d$study <- nm
    d
  })

  result <- do.call(rbind, merged)
  rownames(result) <- NULL
  result
}

#' Get significant loci
#'
#' Extract variants below a p-value threshold, with optional clumping
#' to return only independent lead SNPs.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param p_threshold P-value threshold (default 5e-8).
#' @param clump If TRUE, apply window-based clumping.
#' @param clump_window Clumping window in bp (default 1 Mb).
#' @return A data.frame of significant variants.
#' @export
#' @examples
#' data(example_gwas)
#' get_loci(example_gwas, p_threshold = 0.001)
get_loci <- function(data,
                     p_threshold = 5e-8,
                     clump = TRUE,
                     clump_window = 1e6) {
  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }

  sig <- data[data$P < p_threshold & !is.na(data$P), , drop = FALSE]
  if (nrow(sig) == 0) {
    cli_inform("No variants below p < {p_threshold}.")
    return(sig)
  }

  sig <- sig[order(sig$P), , drop = FALSE]
  if (clump) {
    sig <- .clump_snps(sig, window = clump_window)
  }
  rownames(sig) <- NULL
  sig
}
