#' Density--signal dual-track plot
#'
#' Compare SNP genotyping density against association signal strength
#' across the genome. Each chromosome has two rows: the top track shows
#' the number of variants per bin (density), and the bottom track shows
#' the minimum p-value per bin (signal). This helps distinguish genuine
#' association signals from artifacts driven by uneven genotyping or
#' imputation coverage.
#'
#' @param data A `gwas_data` object or data.frame with GWAS results.
#' @param chr,bp,p Column name overrides.
#' @param bin_size Bin size in base pairs (default 1 Mb).
#' @param chr_info Optional data.frame with `chr` and `length` columns.
#'   If NULL, chromosome lengths are inferred from the data.
#' @param density_palette Color palette for the density track.
#' @param signal_palette Color palette for the signal track.
#' @param chromosomes Optional integer vector of chromosomes to display.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#' density_signal_plot(example_gwas, bin_size = 5e6)
density_signal_plot <- function(data,
                                chr = NULL,
                                bp = NULL,
                                p = NULL,
                                bin_size = 1e6,
                                chr_info = NULL,
                                density_palette = "viridis",
                                signal_palette = "magma",
                                chromosomes = NULL,
                                title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, p = p)
  }

  data <- data[!is.na(data$CHR) & !is.na(data$BP) &
               !is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!is.null(chromosomes)) {
    data <- data[data$CHR %in% chromosomes, , drop = FALSE]
  }

  present_chrs <- sort(unique(data$CHR))

  if (is.null(chr_info)) {
    chr_max <- tapply(data$BP, data$CHR, max)
    chr_info <- data.frame(
      chr = as.integer(names(chr_max)),
      length = as.numeric(chr_max)
    )
  }

  chr_info <- chr_info[chr_info$chr %in% present_chrs, , drop = FALSE]

  data$bin <- floor(data$BP / bin_size) * bin_size

  density_bins <- stats::aggregate(data$BP,
    by = list(CHR = data$CHR, bin = data$bin), FUN = length)
  names(density_bins)[3] <- "count"

  signal_bins <- stats::aggregate(data$P,
    by = list(CHR = data$CHR, bin = data$bin),
    FUN = function(x) min(x, na.rm = TRUE))
  names(signal_bins)[3] <- "min_p"
  signal_bins$neglog10p <- -log10(signal_bins$min_p)

  all_bins <- do.call(rbind, lapply(chr_info$chr, function(ch) {
    max_bp <- chr_info$length[chr_info$chr == ch]
    bin_seq <- seq(0, max_bp, by = bin_size)
    data.frame(CHR = ch, bin = bin_seq)
  }))

  density_bins <- merge(all_bins, density_bins, by = c("CHR", "bin"), all.x = TRUE)
  density_bins$count[is.na(density_bins$count)] <- 0
  density_bins$bin_mb <- density_bins$bin / 1e6

  signal_bins <- merge(all_bins, signal_bins[, c("CHR", "bin", "neglog10p")],
                       by = c("CHR", "bin"), all.x = TRUE)
  signal_bins$neglog10p[is.na(signal_bins$neglog10p)] <- 0
  signal_bins$bin_mb <- signal_bins$bin / 1e6

  chr_labels <- int_to_chr(present_chrs)
  chr_levels <- rev(chr_labels)

  density_bins$track <- "SNP density"
  density_bins$fill_val <- density_bins$count
  signal_bins$track <- "Association signal"
  signal_bins$fill_val <- signal_bins$neglog10p

  combined <- rbind(
    density_bins[, c("CHR", "bin_mb", "track", "fill_val")],
    signal_bins[, c("CHR", "bin_mb", "track", "fill_val")]
  )

  combined$CHR_label <- factor(int_to_chr(combined$CHR), levels = chr_levels)
  combined$track <- factor(combined$track,
    levels = c("SNP density", "Association signal"))

  combined$y_pos <- as.numeric(combined$CHR_label) +
    ifelse(combined$track == "SNP density", 0.22, -0.22)

  density_range <- range(combined$fill_val[combined$track == "SNP density"])
  signal_range <- range(combined$fill_val[combined$track == "Association signal"])

  combined$fill_norm <- ifelse(
    combined$track == "SNP density",
    (combined$fill_val - density_range[1]) /
      max(density_range[2] - density_range[1], 1),
    (combined$fill_val - signal_range[1]) /
      max(signal_range[2] - signal_range[1], 1)
  )

  pal_density <- switch(density_palette,
    "viridis" = "D", "magma" = "A", "inferno" = "B", "plasma" = "C", "D")
  pal_signal <- switch(signal_palette,
    "viridis" = "D", "magma" = "A", "inferno" = "B", "plasma" = "C", "D")

  density_colors <- scales::viridis_pal(option = pal_density)(256)
  signal_colors <- scales::viridis_pal(option = pal_signal)(256)

  combined$color <- ifelse(
    combined$track == "SNP density",
    density_colors[pmax(1, ceiling(combined$fill_norm * 255) + 1)],
    signal_colors[pmax(1, ceiling(combined$fill_norm * 255) + 1)]
  )

  plt <- ggplot(combined, aes(x = .data$bin_mb, y = .data$y_pos,
                               fill = .data$color)) +
    geom_tile(width = bin_size / 1e6, height = 0.38) +
    scale_fill_identity() +
    scale_y_continuous(
      breaks = seq_along(chr_levels),
      labels = chr_levels,
      expand = c(0.01, 0)
    ) +
    labs(x = "Position (Mb)", y = "Chromosome", title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.text.y = element_text(size = 7),
      legend.position = "right"
    )

  legend_density <- data.frame(
    x = rep(0, 2), y = rep(0, 2),
    fill = c(density_colors[1], density_colors[256]),
    label = c("Low", "High")
  )

  plt <- plt +
    ggplot2::annotate("text", x = max(combined$bin_mb) * 0.85,
      y = max(combined$y_pos) + 0.6,
      label = "top: density | bottom: signal",
      size = 2.2, color = "grey40", hjust = 0.5)

  plt
}
