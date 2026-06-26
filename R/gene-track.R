#' Gene annotation track
#'
#' Create a standalone gene annotation panel that can be composed with
#' any ggwas plot using patchwork. Genes are displayed as horizontal bars
#' with optional strand arrows and labels.
#'
#' @param gene_data A data.frame with columns: chr, start, end, gene.
#'   Optional: strand ("+"/"-").
#' @param region_chr Chromosome to display (integer or string).
#' @param region_start,region_end Region boundaries in base pairs.
#' @param highlight_genes Character vector of gene names to highlight.
#' @param highlight_color Color for highlighted genes.
#' @param label_size Text size for gene labels.
#' @param track_color Default color for gene bars.
#' @param show_strand If TRUE, draw arrows indicating gene direction.
#' @param max_genes Maximum number of genes to display. The longest genes
#'   are kept when the limit is exceeded.
#' @return A ggplot object. Compose with a Manhattan or locus plot using
#'   `patchwork::wrap_plots()`.
#' @export
#' @examples
#' genes <- data.frame(
#'   chr = c(1, 1, 1), start = c(1e6, 5e6, 8e6),
#'   end = c(2e6, 6e6, 9e6), gene = c("GeneA", "GeneB", "GeneC"),
#'   strand = c("+", "-", "+")
#' )
#'
#' # Standalone track
#' gene_track(genes, region_chr = 1, region_start = 0, region_end = 10e6)
#'
#' # Compose with Manhattan plot
#' data(example_gwas, package = "ggwas")
#' p <- locus_plot(example_gwas, region_chr = 1,
#'                 region_start = 1e6, region_end = 10e6)
#' gt <- gene_track(genes, 1, 1e6, 10e6)
#' \dontrun{
#' patchwork::wrap_plots(p, gt, ncol = 1, heights = c(0.8, 0.2))
#' }
gene_track <- function(gene_data,
                       region_chr,
                       region_start,
                       region_end,
                       highlight_genes = NULL,
                       highlight_color = "#E74C3C",
                       label_size = 2.5,
                       track_color = "#1A5276",
                       show_strand = TRUE,
                       max_genes = 50) {

  region_chr_int <- if (is.character(region_chr)) chr_to_int(region_chr) else region_chr
  gene_data$chr_int <- if (is.character(gene_data$chr)) {
    chr_to_int(gene_data$chr)
  } else {
    as.integer(gene_data$chr)
  }

  genes <- gene_data[gene_data$chr_int == region_chr_int &
                       gene_data$end >= region_start &
                       gene_data$start <= region_end, , drop = FALSE]

  if (nrow(genes) == 0) {
    return(ggplot() + ggplot2::theme_void() +
             ggplot2::annotate("text", x = 0.5, y = 0.5,
                               label = "No genes in region", color = "grey50"))
  }

  if (nrow(genes) > max_genes) {
    genes$length <- genes$end - genes$start
    genes <- genes[order(-genes$length), , drop = FALSE]
    genes <- utils::head(genes, max_genes)
  }

  genes$y <- .assign_gene_tracks(genes$start, genes$end)

  genes$color <- track_color
  if (!is.null(highlight_genes)) {
    genes$color[genes$gene %in% highlight_genes] <- highlight_color
  }

  has_strand <- "strand" %in% names(genes) && show_strand

  if (has_strand) {
    genes$arrow_dir <- ifelse(genes$strand == "-", "last", "first")
    plt <- ggplot(genes) +
      geom_segment(
        data = genes[genes$strand == "+", , drop = FALSE],
        aes(x = .data$start / 1e6, xend = .data$end / 1e6,
            y = .data$y, yend = .data$y),
        linewidth = 3, color = genes$color[genes$strand == "+"],
        arrow = grid::arrow(length = grid::unit(2, "mm"), type = "closed")
      ) +
      geom_segment(
        data = genes[genes$strand == "-", , drop = FALSE],
        aes(x = .data$end / 1e6, xend = .data$start / 1e6,
            y = .data$y, yend = .data$y),
        linewidth = 3, color = genes$color[genes$strand == "-"],
        arrow = grid::arrow(length = grid::unit(2, "mm"), type = "closed")
      )

    no_strand <- genes[!genes$strand %in% c("+", "-"), , drop = FALSE]
    if (nrow(no_strand) > 0) {
      plt <- plt + geom_segment(
        data = no_strand,
        aes(x = .data$start / 1e6, xend = .data$end / 1e6,
            y = .data$y, yend = .data$y),
        linewidth = 3, color = no_strand$color
      )
    }
  } else {
    plt <- ggplot(genes) +
      geom_segment(
        aes(x = .data$start / 1e6, xend = .data$end / 1e6,
            y = .data$y, yend = .data$y),
        linewidth = 3, color = genes$color
      )
  }

  plt <- plt +
    ggrepel::geom_text_repel(
      aes(x = (.data$start + .data$end) / 2e6, y = .data$y,
          label = .data$gene),
      size = label_size, fontface = "italic", direction = "y",
      nudge_y = 0.3, min.segment.length = 0, segment.color = "grey70",
      max.overlaps = 20
    ) +
    scale_x_continuous(
      limits = c(region_start / 1e6, region_end / 1e6)
    ) +
    labs(x = NULL, y = NULL) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = element_text(size = 8),
      plot.margin = ggplot2::margin(0, 5.5, 5.5, 5.5)
    )

  plt
}
