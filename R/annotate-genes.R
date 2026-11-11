#' Annotate peaks with nearest gene names
#'
#' Maps significant SNPs to their nearest gene with
#' [GenomicRanges::distanceToNearest()].
#'
#' @param data A `gwas_data` object, data.frame or `GRanges` of variants.
#' @param genes Gene models as a [GenomicRanges::GRanges], `TxDb` or `EnsDb`
#'   object. Gene names are taken as described in [gene_track()].
#' @param p_threshold Only annotate SNPs with p < this value.
#' @param max_distance Maximum distance (bp) between a SNP and the nearest
#'   gene. The distance is 0 for a SNP inside a gene and otherwise the gap
#'   to the closest gene end. Default 500kb.
#' @param top_n Annotate only the top N most significant SNPs.
#' @param clump_window Clumping window in bp. Within each window, only
#'   the most significant SNP is annotated. Default 1Mb.
#' @return The input as a `gwas_data` object with added `nearest_gene` and
#'   `gene_distance` columns.
#' @export
#' @examples
#' data(example_gwas)
#' genes <- GenomicRanges::GRanges(
#'   c("chr1:1000000-1500000", "chr2:50000000-51000000",
#'     "chr5:80000000-82000000"),
#'   gene_name = c("GENE_A", "GENE_B", "GENE_C")
#' )
#' annotated <- annotate_genes(example_gwas, genes, top_n = 10)
#' head(annotated[!is.na(annotated$nearest_gene), ])
annotate_genes <- function(data,
                           genes,
                           p_threshold = 5e-8,
                           max_distance = 500000,
                           top_n = NULL,
                           clump_window = 1e6) {

  .check_genes(genes)
  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data)
  }

  data$nearest_gene <- NA_character_
  data$gene_distance <- NA_real_
  data$.row <- seq_len(nrow(data))

  candidates <- data[data$P < p_threshold & !is.na(data$P), , drop = FALSE]
  if (nrow(candidates) == 0) {
    data$.row <- NULL
    return(data)
  }

  candidates <- candidates[order(candidates$P), , drop = FALSE]
  if (!is.null(clump_window)) {
    candidates <- .clump_snps(candidates, window = clump_window)
  }
  if (!is.null(top_n)) {
    candidates <- utils::head(candidates, top_n)
  }

  near <- .nearest_genes(candidates$CHR, candidates$BP, genes, max_distance)
  data$nearest_gene[candidates$.row] <- near$gene
  data$gene_distance[candidates$.row] <- near$distance
  data$.row <- NULL
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
#' @param genes Gene models as a `GRanges`, `TxDb` or `EnsDb` object (see
#'   [annotate_genes()]).
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
#' genes <- GenomicRanges::GRanges(
#'   c("chr1:1000000-2000000", "chr2:50000000-52000000",
#'     "chr5:80000000-85000000", "chr7:30000000-35000000",
#'     "chr11:60000000-65000000"),
#'   gene_name = c("GENE_A", "GENE_B", "GENE_C", "GENE_D", "GENE_E")
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
    # Use the chromosome offsets of the plotted data. Recomputing them from the
    # labelled rows alone would shift labels when chromosomes are missing.
    offsets <- tapply(plt$data$BP_CUM - plt$data$BP, plt$data$CHR, min)
    label_data$BP_CUM <- label_data$BP + offsets[as.character(label_data$CHR)]

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
