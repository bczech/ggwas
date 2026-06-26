#' Extract top hits from GWAS results
#'
#' Identifies independent significant loci using window-based clumping,
#' optionally annotates with nearest gene, and returns a publication-ready
#' table.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param p_threshold Significance threshold for lead SNPs.
#' @param clump_window Window size in bp for clumping. Only the most
#'   significant SNP within each window is retained.
#' @param genes Optional gene annotation data.frame (chr, start, end, gene).
#'   If provided, nearest gene is added.
#' @param max_gene_distance Maximum distance to assign a gene.
#' @param n Maximum number of hits to return.
#' @return A data.frame with columns: SNP, CHR, BP, P, BETA, SE,
#'   nearest_gene (if genes provided), gene_distance, cytoband.
#' @export
#' @examples
#' data(example_gwas)
#' top_hits(example_gwas, p_threshold = 0.001, n = 10)
top_hits <- function(data,
                     p_threshold = 5e-8,
                     clump_window = 1e6,
                     genes = NULL,
                     max_gene_distance = 500000,
                     n = 20) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }

  sig <- data[!is.na(data$P) & data$P < p_threshold, , drop = FALSE]

  if (nrow(sig) == 0) {
    cli_inform("No variants below p < {p_threshold}.")
    return(data.frame())
  }

  sig <- sig[!is.na(sig$CHR) & !is.na(sig$BP), , drop = FALSE]
  if (nrow(sig) == 0) return(data.frame())

  sig <- sig[order(sig$P), , drop = FALSE]
  sig <- .clump_snps(sig, window = clump_window)
  sig <- utils::head(sig, n)

  out_cols <- intersect(
    c("SNP", "CHR", "BP", "P", "BETA", "SE", "AF"),
    names(sig)
  )
  result <- sig[, out_cols, drop = FALSE]

  result$cytoband <- .estimate_cytoband(result$CHR, result$BP)

  if (!is.null(genes)) {
    genes$chr <- chr_to_int(genes$chr)
    genes$midpoint <- (genes$start + genes$end) / 2
    result$nearest_gene <- NA_character_
    result$gene_distance <- NA_integer_

    for (i in seq_len(nrow(result))) {
      chr_genes <- genes[genes$chr == result$CHR[i], , drop = FALSE]
      if (nrow(chr_genes) == 0) next
      distances <- abs(chr_genes$midpoint - result$BP[i])
      min_idx <- which.min(distances)
      if (distances[min_idx] <= max_gene_distance) {
        result$nearest_gene[i] <- chr_genes$gene[min_idx]
        result$gene_distance[i] <- as.integer(distances[min_idx])
      }
    }
  }

  result$CHR_label <- int_to_chr(result$CHR)
  result$P_formatted <- formatC(result$P, format = "e", digits = 2)

  rownames(result) <- NULL
  class(result) <- c("gwas_hits", "data.frame")
  result
}

#' Estimate cytoband from chromosome and position
#' @noRd
.estimate_cytoband <- function(chr, bp) {
  vapply(seq_along(chr), function(i) {
    if (is.na(chr[i]) || is.na(bp[i])) return(NA_character_)
    arm <- if (bp[i] < 5e7) "p" else "q"
    band <- floor(bp[i] / 1e7) + 1
    paste0(int_to_chr(chr[i]), arm, band)
  }, character(1))
}

#' @export
print.gwas_hits <- function(x, ...) {
  display <- x[, intersect(
    c("SNP", "CHR_label", "BP", "P_formatted", "BETA", "nearest_gene", "cytoband"),
    names(x)
  ), drop = FALSE]
  names(display)[names(display) == "CHR_label"] <- "CHR"
  names(display)[names(display) == "P_formatted"] <- "P"
  cat(sprintf("=== Top %d GWAS Hits ===\n\n", nrow(display)))
  print.data.frame(display, row.names = FALSE, right = FALSE)
  invisible(x)
}
