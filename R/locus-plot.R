#' Locus zoom plot
#'
#' Create a regional association plot centered on a genomic region or
#' lead SNP, with optional LD coloring and gene annotation track.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param chr,bp,p,snp Column name overrides.
#' @param region_chr Chromosome of the region to plot.
#' @param region_start,region_end Start and end positions.
#' @param lead_snp SNP ID to center the region around.
#' @param flank Flank size in bp around the lead SNP (default 500kb).
#' @param ld Named numeric vector of LD (r2) values with the lead SNP.
#'   Names are SNP IDs, values are r2.
#' @param ld_colors Colors for LD bins (5 levels).
#' @param ld_breaks Breaks for LD color bins.
#' @param gene_data A data.frame with columns: chr, start, end, gene, strand.
#' @param gene_height Proportion of plot height for the gene track.
#' @param point_size Point size.
#' @param lead_snp_shape Shape for the lead SNP marker.
#' @param lead_snp_size Size for the lead SNP marker.
#' @param title Plot title.
#' @return A ggplot object (or patchwork composition if gene_data is provided).
#' @export
#' @examples
#' data(example_gwas, package = "gwasplot")
#' locus_plot(example_gwas, region_chr = 1,
#'            region_start = 1e6, region_end = 20e6)
locus_plot <- function(data,
                       chr = NULL,
                       bp = NULL,
                       p = NULL,
                       snp = NULL,
                       region_chr = NULL,
                       region_start = NULL,
                       region_end = NULL,
                       lead_snp = NULL,
                       flank = 500000,
                       ld = NULL,
                       ld_colors = c("#2166AC", "#67A9CF", "#78C679",
                                     "#F4A582", "#D73027"),
                       ld_breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1.0),
                       gene_data = NULL,
                       gene_height = 0.25,
                       point_size = 2,
                       lead_snp_shape = 23,
                       lead_snp_size = 4,
                       title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }

  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!is.null(lead_snp) && "SNP" %in% names(data)) {
    lead_row <- data[data$SNP == lead_snp, , drop = FALSE]
    if (nrow(lead_row) == 0) cli_abort("Lead SNP {.val {lead_snp}} not found.")
    region_chr <- lead_row$CHR[1]
    region_start <- lead_row$BP[1] - flank
    region_end <- lead_row$BP[1] + flank
  }

  if (is.null(region_chr) || is.null(region_start) || is.null(region_end)) {
    cli_abort("Specify {.arg region_chr}/{.arg region_start}/{.arg region_end} or {.arg lead_snp}.")
  }

  region_start <- max(region_start, 0)
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
      geom_point(size = point_size, color = "#7F8C8D", shape = 16)
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

  if (!is.null(gene_data)) {
    gene_track <- .make_gene_track(gene_data, region_chr, region_start, region_end)
    plt <- patchwork::wrap_plots(
      plt, gene_track,
      ncol = 1,
      heights = c(1 - gene_height, gene_height)
    )
  }

  plt
}

#' Create gene annotation track
#' @noRd
.make_gene_track <- function(gene_data, region_chr, region_start, region_end) {
  genes <- gene_data[gene_data$chr == region_chr &
                       gene_data$end >= region_start &
                       gene_data$start <= region_end, , drop = FALSE]

  if (nrow(genes) == 0) {
    return(ggplot() + ggplot2::theme_void() +
             ggplot2::annotate("text", x = 0.5, y = 0.5,
                               label = "No genes in region"))
  }

  genes$y <- .assign_gene_tracks(genes$start, genes$end)

  plt <- ggplot(genes) +
    geom_segment(
      aes(x = .data$start / 1e6, xend = .data$end / 1e6,
          y = .data$y, yend = .data$y),
      linewidth = 3, color = "#2C3E50"
    ) +
    ggrepel::geom_text_repel(
      aes(x = (.data$start + .data$end) / 2e6, y = .data$y,
          label = .data$gene),
      size = 2.5, fontface = "italic", direction = "y",
      nudge_y = 0.3
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
