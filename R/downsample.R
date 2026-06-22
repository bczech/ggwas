#' Smart downsampling for large GWAS datasets
#'
#' Reduces the number of points while preserving all visually important
#' variants (significant and near-significant SNPs). Non-significant
#' SNPs are binned and deduplicated.
#'
#' @param data A data.frame with at least CHR, BP, P columns.
#' @param target_n Target number of points after downsampling.
#' @param p_keep Keep all variants with p < this threshold.
#' @param keep_snps Character vector of SNP IDs to always keep.
#' @param seed Random seed for reproducibility.
#' @return Downsampled data.frame.
#' @noRd
smart_downsample <- function(data,
                             target_n = 200000,
                             p_keep = 1e-3,
                             keep_snps = NULL,
                             seed = 42) {
  n <- nrow(data)
  if (n <= target_n) return(data)

  keep_idx <- which(data$P < p_keep)

  if (!is.null(keep_snps) && "SNP" %in% names(data)) {
    snp_idx <- which(data$SNP %in% keep_snps)
    keep_idx <- unique(c(keep_idx, snp_idx))
  }

  rest_idx <- setdiff(seq_len(n), keep_idx)
  n_rest_target <- target_n - length(keep_idx)

  if (n_rest_target <= 0 || length(rest_idx) == 0) {
    return(data[keep_idx, , drop = FALSE])
  }

  rest <- data[rest_idx, , drop = FALSE]
  logp <- -log10(rest$P)
  logp_bin <- round(logp, 1)

  genome_range <- max(data$BP, na.rm = TRUE)
  bp_bin_size <- genome_range / (n_rest_target / length(unique(rest$CHR)))
  bp_bin <- floor(rest$BP / bp_bin_size)

  bin_key <- paste(rest$CHR, bp_bin, logp_bin, sep = "_")

  unique_bins <- !duplicated(bin_key)
  deduped_idx <- rest_idx[unique_bins]

  if (length(deduped_idx) > n_rest_target) {
    sampled <- if (!is.null(seed)) {
      withr::with_seed(seed, sample(deduped_idx, n_rest_target))
    } else {
      sample(deduped_idx, n_rest_target)
    }
    final_idx <- sort(c(keep_idx, sampled))
  } else {
    final_idx <- sort(c(keep_idx, deduped_idx))
  }

  data[final_idx, , drop = FALSE]
}
