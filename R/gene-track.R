#' Gene annotation track
#'
#' Create a standalone gene annotation panel that can be composed with
#' any ggwas plot using patchwork. Genes are drawn as directional bodies
#' with strand arrows and labels; when `exons` are supplied, each gene is
#' rendered as an intron backbone with exon boxes and a strand arrow.
#'
#' @param genes Gene models as a [GenomicRanges::GRanges] object, or a `TxDb`
#'   (\pkg{GenomicFeatures}) or `EnsDb` (\pkg{ensembldb}) annotation object.
#'   Labels are taken from the first metadata column named `gene_name`,
#'   `symbol`, `gene` or `Name`, falling back to `gene_id` and then to
#'   `names(genes)`. A `TxDb` only carries gene IDs; add a `gene_name` column
#'   to `GenomicFeatures::genes(txdb)` to show symbols (see the vignette).
#'   GTF and GFF3 files can be read with `rtracklayer::import()`.
#' @param region The region to draw: a [GenomicRanges::GRanges] of length 1,
#'   or a string such as `"chr6:25000000-34000000"`.
#' @param exons Optional exon structure: a `GRangesList` of exons split by
#'   gene ID (as returned by `GenomicFeatures::exonsBy(txdb, by = "gene")`), a
#'   `GRanges` with a `gene_id` or gene name column, or `TRUE` to take exons
#'   from `genes` when it is a `TxDb` or `EnsDb`. Exons are matched to genes by
#'   gene ID.
#' @param highlight_genes Character vector of gene names to highlight.
#' @param highlight_color Color for highlighted genes.
#' @param label_size Text size for gene labels.
#' @param track_color Default color for gene bodies.
#' @param show_strand If TRUE, draw arrows indicating gene direction.
#' @param max_genes Maximum number of genes to display. The longest genes
#'   are kept when the limit is exceeded.
#' @return A ggplot object. Compose with a Manhattan or locus plot using
#'   `patchwork::wrap_plots()`.
#' @seealso [locus_plot()], which adds this track under a regional plot.
#' @export
#' @examples
#' library(GenomicRanges)
#' genes <- GRanges(
#'   c("chr1:1000000-2000000:+", "chr1:5000000-6000000:-",
#'     "chr1:8000000-9000000:+"),
#'   gene_name = c("GeneA", "GeneB", "GeneC")
#' )
#'
#' # Gene-body track
#' gene_track(genes, region = "chr1:1-10000000")
#'
#' # With exon structure, one GRanges per gene
#' exons <- GRangesList(
#'   GeneA = GRanges(c("chr1:1000000-1100000", "chr1:1500000-1700000")),
#'   GeneB = GRanges(c("chr1:5000000-5200000", "chr1:5600000-5900000")),
#'   GeneC = GRanges("chr1:8100000-8400000")
#' )
#' names(genes) <- names(exons)
#' gene_track(genes, "chr1:1-10000000", exons = exons)
gene_track <- function(genes,
                       region,
                       exons = NULL,
                       highlight_genes = NULL,
                       highlight_color = "#E74C3C",
                       label_size = 2.5,
                       track_color = "#1A5276",
                       show_strand = TRUE,
                       max_genes = 50) {

  reg <- .as_region(region)
  region_start <- reg$start
  region_end <- reg$end
  db <- if (.is_annotation_db(genes)) genes else NULL

  gene_df <- .ranges_to_df(.as_gene_ranges(genes))
  genes <- gene_df[gene_df$chr == reg$chr &
                     gene_df$end >= region_start &
                     gene_df$start <= region_end, , drop = FALSE]

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

  has_strand <- show_strand
  bar_h <- 0.35
  region_span <- (region_end - region_start) / 1e6
  arrow_w <- region_span * 0.012

  if (!is.null(exons)) {
    exon_df <- .ranges_to_df(.as_exon_ranges(exons, db = db))
    plt <- .gene_track_exons(genes, exon_df, reg$chr,
                             region_start, region_end, has_strand, bar_h)
  } else {
    plt <- .gene_track_bodies(genes, region_start, region_end,
                              has_strand, bar_h, arrow_w)
  }

  label_df <- data.frame(
    x = (genes$start + genes$end) / 2e6,
    y = genes$y + bar_h / 2 + 0.18,
    gene = genes$gene,
    stringsAsFactors = FALSE
  )

  plt +
    ggrepel::geom_text_repel(
      data = label_df,
      aes(x = .data$x, y = .data$y, label = .data$gene),
      size = label_size, fontface = "italic", color = "grey20",
      direction = "x", nudge_y = 0.15,
      min.segment.length = 0, segment.color = "grey70", segment.size = 0.3,
      max.overlaps = 30, box.padding = 0.2, force = 5
    ) +
    scale_x_continuous(limits = c(region_start / 1e6, region_end / 1e6)) +
    scale_y_continuous(expand = ggplot2::expansion(mult = c(0.15, 0.4))) +
    labs(x = NULL, y = NULL) +
    ggplot2::theme_void() +
    ggplot2::theme(
      axis.text.x = element_text(size = 8),
      plot.margin = ggplot2::margin(0, 5.5, 5.5, 5.5)
    )
}

# Directional gene bodies (chevron polygons) -- default rendering.
.gene_track_bodies <- function(genes, region_start, region_end,
                               has_strand, bar_h, arrow_w) {
  arrow_polys <- do.call(rbind, lapply(seq_len(nrow(genes)), function(i) {
    s <- genes$start[i] / 1e6
    e <- genes$end[i] / 1e6
    yi <- genes$y[i]
    top <- yi + bar_h / 2
    bot <- yi - bar_h / 2
    clr <- genes$color[i]
    strand_i <- if (has_strand) genes$strand[i] else "."

    if (strand_i == "+") {
      tip <- min(e + arrow_w, region_end / 1e6)
      data.frame(x = c(s, e, tip, e, s), y = c(top, top, yi, bot, bot),
                 id = i, fill = clr, stringsAsFactors = FALSE)
    } else if (strand_i == "-") {
      tip <- max(s - arrow_w, region_start / 1e6)
      data.frame(x = c(e, s, tip, s, e), y = c(top, top, yi, bot, bot),
                 id = i, fill = clr, stringsAsFactors = FALSE)
    } else {
      data.frame(x = c(s, e, e, s), y = c(top, top, bot, bot),
                 id = i, fill = clr, stringsAsFactors = FALSE)
    }
  }))

  ggplot() +
    ggplot2::geom_polygon(
      data = arrow_polys,
      aes(x = .data$x, y = .data$y, group = .data$id),
      fill = arrow_polys$fill, color = NA
    )
}

# Intron backbone + exon boxes + strand arrow.
.gene_track_exons <- function(genes, exon_data, region_chr_int,
                              region_start, region_end, has_strand, bar_h) {
  ex <- exon_data
  ex <- ex[ex$chr == region_chr_int &
             ex$end >= region_start & ex$start <= region_end &
             ex$gene_id %in% genes$gene_id, , drop = FALSE]
  ex$start <- pmax(ex$start, region_start)
  ex$end <- pmin(ex$end, region_end)

  ymap <- stats::setNames(genes$y, genes$gene_id)
  cmap <- stats::setNames(genes$color, genes$gene_id)
  exon_h <- bar_h * 0.9

  strand_vec <- if (has_strand) genes$strand else rep(".", nrow(genes))
  intron <- data.frame(
    x = ifelse(strand_vec == "-", genes$end, genes$start) / 1e6,
    xend = ifelse(strand_vec == "-", genes$start, genes$end) / 1e6,
    y = genes$y, color = genes$color, stringsAsFactors = FALSE
  )

  plt <- ggplot() +
    geom_segment(
      data = intron,
      aes(x = .data$x, xend = .data$xend, y = .data$y, yend = .data$y),
      color = intron$color, linewidth = 0.4,
      arrow = grid::arrow(length = grid::unit(0.045, "inches"),
                          type = "closed", ends = "last")
    )

  if (nrow(ex) > 0) {
    ex$y <- ymap[ex$gene_id]
    ex$fill <- cmap[ex$gene_id]
    plt <- plt + geom_rect(
      data = ex,
      aes(xmin = .data$start / 1e6, xmax = .data$end / 1e6,
          ymin = .data$y - exon_h / 2, ymax = .data$y + exon_h / 2),
      fill = ex$fill, color = NA
    )
  }

  plt
}
