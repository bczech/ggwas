#' Locus zoom plot
#'
#' Create a regional association plot centered on a genomic region or
#' lead SNP, with optional LD coloring and gene annotation track.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param chr,bp,p,snp Column name overrides.
#' @param region The region to plot: a [GenomicRanges::GRanges] of length 1,
#'   or a string such as `"chr1:1000000-20000000"`. Not needed when
#'   `lead_snp` is given.
#' @param lead_snp SNP ID to center the region around.
#' @param flank Flank size in bp around the lead SNP (default 500kb).
#' @param ld Named numeric vector of LD (r2) values with the lead SNP.
#'   Names are SNP IDs, values are r2.
#' @param ld_colors Colors for LD bins (5 levels).
#' @param ld_breaks Breaks for LD color bins.
#' @param genes Optional gene models drawn as a track under the plot: a
#'   [GenomicRanges::GRanges], `TxDb` or `EnsDb` object (see [gene_track()]).
#' @param exons Optional exon structure for the gene track (see
#'   [gene_track()]).
#' @param gene_height Proportion of plot height for the gene track.
#' @param point_size Point size.
#' @param lead_snp_shape Shape for the lead SNP marker.
#' @param lead_snp_size Size for the lead SNP marker.
#' @param title Plot title.
#' @return A ggplot object, or a patchwork composition when `genes` is
#'   provided.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#' locus_plot(example_gwas, region = "chr1:1000000-20000000")
#'
#' # With a gene track
#' genes <- GenomicRanges::GRanges(
#'   c("chr1:2000000-4000000:+", "chr1:9000000-12000000:-"),
#'   gene_name = c("GeneA", "GeneB")
#' )
#' locus_plot(example_gwas, region = "chr1:1000000-20000000", genes = genes)
locus_plot <- function(data,
                       chr = NULL,
                       bp = NULL,
                       p = NULL,
                       snp = NULL,
                       region = NULL,
                       lead_snp = NULL,
                       flank = 500000,
                       ld = NULL,
                       ld_colors = c("#2166AC", "#67A9CF", "#78C679",
                                     "#F4A582", "#D73027"),
                       ld_breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1.0),
                       genes = NULL,
                       exons = NULL,
                       gene_height = 0.25,
                       point_size = 2,
                       lead_snp_shape = 23,
                       lead_snp_size = 4,
                       title = NULL) {

  if (!is.null(genes)) .check_genes(genes)
  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }

  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  reg <- .resolve_region(data, region, lead_snp, flank)
  region_chr <- reg$chr
  region_start <- reg$start
  region_end <- reg$end
  region_gr <- reg$gr
  region <- data[data$CHR == region_chr &
                   data$BP >= region_start &
                   data$BP <= region_end, , drop = FALSE]

  if (nrow(region) == 0) {
    cli_abort("No variants found in the specified region.")
  }

  region$LOG10P <- -log10(region$P)

  if (!is.null(ld) && "SNP" %in% names(region)) {
    region$LD <- ld[region$SNP]
    region$LD[is.na(region$LD)] <- 0
    region$LD_BIN <- cut(region$LD, breaks = ld_breaks, include.lowest = TRUE,
                         labels = c("0-0.2", "0.2-0.4", "0.4-0.6",
                                    "0.6-0.8", "0.8-1.0"))
    ld_color_map <- stats::setNames(ld_colors,
                                    c("0-0.2", "0.2-0.4", "0.4-0.6",
                                      "0.6-0.8", "0.8-1.0"))

    plt <- ggplot(region, aes(x = .data$BP / 1e6, y = .data$LOG10P,
                               color = .data$LD_BIN)) +
      geom_point(size = point_size, shape = 16) +
      scale_color_manual(
        values = ld_color_map,
        name = expression(r^2),
        drop = FALSE
      ) +
      ggplot2::theme(legend.position = "right")
  } else {
    plt <- ggplot(region, aes(x = .data$BP / 1e6, y = .data$LOG10P)) +
      geom_point(size = point_size, color = "#76D7C4", shape = 16)
  }

  if (!is.null(lead_snp) && "SNP" %in% names(region)) {
    lead_data <- region[region$SNP == lead_snp, , drop = FALSE]
    if (nrow(lead_data) > 0) {
      plt <- plt + geom_point(
        data = lead_data,
        aes(x = .data$BP / 1e6, y = .data$LOG10P),
        shape = lead_snp_shape, size = lead_snp_size,
        fill = "#9B59B6", color = "black", stroke = 0.8,
        inherit.aes = FALSE
      )
    }
  }

  plt <- plt +
    labs(x = paste0("Position on chr", int_to_chr(region_chr), " (Mb)"),
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  if (!is.null(genes)) {
    track <- gene_track(genes, region = region_gr, exons = exons)
    plt <- patchwork::wrap_plots(
      plt, track,
      ncol = 1,
      heights = c(1 - gene_height, gene_height)
    )
  }

  plt
}

#' Assign non-overlapping tracks to genes
#' @noRd
.assign_gene_tracks <- function(starts, ends) {
  n <- length(starts)
  tracks <- integer(n)
  track_ends <- numeric(0)

  ord <- order(starts)
  for (i in ord) {
    placed <- FALSE
    for (t in seq_along(track_ends)) {
      if (starts[i] > track_ends[t]) {
        tracks[i] <- t
        track_ends[t] <- ends[i]
        placed <- TRUE
        break
      }
    }
    if (!placed) {
      track_ends <- c(track_ends, ends[i])
      tracks[i] <- length(track_ends)
    }
  }
  tracks
}
