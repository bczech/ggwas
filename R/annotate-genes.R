#' Annotate peaks with nearest gene names
#'
#' Maps significant SNPs to their nearest gene using a provided gene
#' annotation table. Returns the data with a `gene` column, or adds
#' gene labels directly to a Manhattan plot.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param genes A data.frame with gene positions. Required columns:
#'   `chr` (integer or "chr1" format), `start`, `end`, `gene` (gene symbol).
#'   Optional: `strand`.
#' @param p_threshold Only annotate SNPs with p < this value.
#' @param max_distance Maximum distance (bp) from SNP to gene midpoint
#'   to assign annotation. Default 500kb.
#' @param top_n Annotate only the top N most significant SNPs.
#' @param clump_window Clumping window in bp. Within each window, only
#'   the most significant SNP is annotated. Default 1Mb.
#' @return A data.frame with added `nearest_gene` and `gene_distance` columns.
#' @export
#' @examples
#' data(example_gwas)
#' genes <- data.frame(
#'   chr = c(1, 2, 5), start = c(1e6, 50e6, 80e6),
#'   end = c(1.5e6, 51e6, 82e6), gene = c("GENE_A", "GENE_B", "GENE_C")
#' )
#' annotated <- annotate_genes(example_gwas, genes, top_n = 10)
#' head(annotated[!is.na(annotated$nearest_gene), ])
annotate_genes <- function(data,
                           genes,
                           p_threshold = 5e-8,
                           max_distance = 500000,
                           top_n = NULL,
                           clump_window = 1e6) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }

  genes$chr <- chr_to_int(genes$chr)
  genes$midpoint <- (genes$start + genes$end) / 2

  candidates <- data[data$P < p_threshold & !is.na(data$P), , drop = FALSE]

  if (nrow(candidates) == 0) {
    data$nearest_gene <- NA_character_
    data$gene_distance <- NA_real_
    return(data)
  }

  candidates <- candidates[order(candidates$P), , drop = FALSE]

  if (!is.null(clump_window)) {
    candidates <- .clump_snps(candidates, window = clump_window)
  }

  if (!is.null(top_n)) {
    candidates <- utils::head(candidates, top_n)
  }

  data$nearest_gene <- NA_character_
  data$gene_distance <- NA_real_

  for (i in seq_len(nrow(candidates))) {
    snp_chr <- candidates$CHR[i]
    snp_bp <- candidates$BP[i]

    chr_genes <- genes[genes$chr == snp_chr, , drop = FALSE]
    if (nrow(chr_genes) == 0) next

    distances <- abs(chr_genes$midpoint - snp_bp)
    min_idx <- which.min(distances)
    min_dist <- distances[min_idx]

    if (min_dist <= max_distance) {
      row_idx <- which(data$CHR == snp_chr & data$BP == snp_bp)[1]
      if (!is.na(row_idx)) {
        data$nearest_gene[row_idx] <- chr_genes$gene[min_idx]
        data$gene_distance[row_idx] <- min_dist
      }
    }
  }

  data
}

#' Simple window-based clumping
#' @noRd
.clump_snps <- function(data, window = 1e6) {
  kept <- logical(nrow(data))
  kept[1] <- TRUE

  for (i in seq_len(nrow(data))[-1]) {
    is_independent <- TRUE
    for (j in which(kept)) {
      if (data$CHR[i] == data$CHR[j] &&
          abs(data$BP[i] - data$BP[j]) < window) {
        is_independent <- FALSE
        break
      }
    }
    if (is_independent) kept[i] <- TRUE
  }

  data[kept, , drop = FALSE]
}

#' Add gene labels to a Manhattan plot
#'
#' A convenience wrapper that annotates a dataset and then creates a
#' Manhattan plot with gene names as labels instead of SNP IDs.
#'
#' @inheritParams manhattan_plot
#' @param genes Gene annotation data.frame (see [annotate_genes()]).
#' @param gene_p_threshold P-value threshold for gene annotation.
#' @param gene_top_n Number of top genes to label.
#' @param gene_max_distance Maximum distance to nearest gene.
#' @param arrow If TRUE, use annotation arrows instead of text labels.
#' @param arrow_color Color of annotation arrows.
#' @param label_size Font size for gene labels.
#' @param label_face Font face for gene labels ("italic", "bold", "bold.italic").
#' @param ... Additional arguments passed to [manhattan_plot()].
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#' genes <- data.frame(
#'   chr = c(1, 2, 5, 7, 11), start = c(1e6, 50e6, 80e6, 30e6, 60e6),
#'   end = c(2e6, 52e6, 85e6, 35e6, 65e6),
#'   gene = c("BRCA1", "FTO", "TCF7L2", "CDKAL1", "KCNQ1")
#' )
#' manhattan_genes(example_gwas, genes = genes, gene_top_n = 5)
manhattan_genes <- function(data,
                            genes,
                            gene_p_threshold = 1e-5,
                            gene_top_n = 10,
                            gene_max_distance = 500000,
                            arrow = FALSE,
                            arrow_color = "grey30",
                            label_size = 3,
                            label_face = "italic",
                            ...) {

  annotated <- annotate_genes(
    data,
    genes = genes,
    p_threshold = gene_p_threshold,
    top_n = gene_top_n,
    max_distance = gene_max_distance
  )

  plt <- manhattan_plot(annotated, ...)

  label_data <- annotated[!is.na(annotated$nearest_gene), , drop = FALSE]

  if (nrow(label_data) > 0) {
    label_data$LOG10P <- -log10(label_data$P)
    label_data <- add_cumulative_bp(label_data)

    if (arrow) {
      plt <- plt + ggplot2::geom_segment(
        data = label_data,
        aes(x = .data$BP_CUM, xend = .data$BP_CUM,
            y = .data$LOG10P + 0.5, yend = .data$LOG10P + 0.1),
        arrow = ggplot2::arrow(length = ggplot2::unit(0.15, "cm"),
                               type = "closed"),
        color = arrow_color, linewidth = 0.3,
        inherit.aes = FALSE
      ) +
        ggplot2::geom_text(
          data = label_data,
          aes(x = .data$BP_CUM, y = .data$LOG10P + 0.7,
              label = .data$nearest_gene),
          size = label_size, fontface = label_face,
          inherit.aes = FALSE
        )
    } else {
      plt <- plt + ggrepel::geom_text_repel(
        data = label_data,
        aes(x = .data$BP_CUM, y = .data$LOG10P,
            label = .data$nearest_gene),
        size = label_size, fontface = label_face,
        max.overlaps = 20, segment.color = "grey50",
        inherit.aes = FALSE
      )
    }
  }

  plt
}
