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

  genes$start <- pmax(genes$start, region_start)
  genes$end <- pmin(genes$end, region_end)

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
  bar_h <- 0.35
  region_span <- (region_end - region_start) / 1e6
  arrow_w <- region_span * 0.012

  arrow_polys <- do.call(rbind, lapply(seq_len(nrow(genes)), function(i) {
    s <- genes$start[i] / 1e6
    e <- genes$end[i] / 1e6
    yi <- genes$y[i]
    top <- yi + bar_h / 2
    bot <- yi - bar_h / 2
    mid <- yi
    clr <- genes$color[i]
    gname <- genes$gene[i]
    strand_i <- if (has_strand) genes$strand[i] else "."

    if (strand_i == "+") {
      tip <- min(e + arrow_w, region_end / 1e6)
      body_end <- e
      data.frame(
        x = c(s, body_end, tip, body_end, s),
        y = c(top, top, mid, bot, bot),
        id = i, fill = clr, gene = gname,
        stringsAsFactors = FALSE
      )
    } else if (strand_i == "-") {
      tip <- max(s - arrow_w, region_start / 1e6)
      body_start <- s
      data.frame(
        x = c(e, body_start, tip, body_start, e),
        y = c(top, top, mid, bot, bot),
        id = i, fill = clr, gene = gname,
        stringsAsFactors = FALSE
      )
    } else {
      data.frame(
        x = c(s, e, e, s),
        y = c(top, top, bot, bot),
        id = i, fill = clr, gene = gname,
        stringsAsFactors = FALSE
      )
    }
  }))

  label_df <- data.frame(
    x = (genes$start + genes$end) / 2e6,
    y = genes$y + bar_h / 2 + 0.18,
    gene = genes$gene,
    stringsAsFactors = FALSE
  )

  plt <- ggplot() +
    ggplot2::geom_polygon(
      data = arrow_polys,
      aes(x = .data$x, y = .data$y, group = .data$id),
      fill = arrow_polys$fill, color = NA
    ) +
    ggrepel::geom_text_repel(
      data = label_df,
      aes(x = .data$x, y = .data$y, label = .data$gene),
      size = label_size, fontface = "italic", color = "grey20",
      direction = "x", nudge_y = 0.15,
      min.segment.length = 0, segment.color = "grey70", segment.size = 0.3,
      max.overlaps = 30, box.padding = 0.2, force = 5
    ) +
    scale_x_continuous(
      limits = c(region_start / 1e6, region_end / 1e6)
    ) +
    scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.15, 0.4))
    ) +
    labs(x = NULL, y = NULL) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = element_text(size = 8),
      plot.margin = ggplot2::margin(0, 5.5, 5.5, 5.5)
    )

  plt
}
