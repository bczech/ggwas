#' Circular Manhattan plot
#'
#' A circos-style Manhattan plot where chromosomes are arranged in a circle.
#' Built entirely with ggplot2, unlike CMplot's base R implementation.
#' Supports multiple rings for multi-trait comparison.
#'
#' @param data A `gwas_data` object, data.frame, or named list of gwas_data
#'   objects for multi-ring display.
#' @param chr,bp,p,snp Column name overrides.
#' @param colors Two-color vector for alternating chromosomes, or a
#'   palette name from [gwas_palette()].
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param genome_wide Genome-wide significance threshold.
#' @param threshold_color Color for threshold ring.
#' @param highlight_snps SNP IDs to highlight.
#' @param highlight_color Color for highlighted SNPs.
#' @param highlight_size Size for highlighted points.
#' @param label_snps SNP IDs to label.
#' @param label_top_n Label top N SNPs.
#' @param show_chr_labels Show chromosome labels.
#' @param inner_radius Inner radius of the circle (proportion, 0-1).
#' @param chr_gap_fraction Gap between chromosomes as fraction of total.
#' @param ring_labels For multi-ring: labels for each ring.
#' @param downsample Enable smart downsampling.
#' @param downsample_n Target points after downsampling.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#' circular_manhattan(example_gwas)
circular_manhattan <- function(data,
                               chr = NULL,
                               bp = NULL,
                               p = NULL,
                               snp = NULL,
                               colors = c("#1A5276", "#76D7C4"),
                               point_size = 1.2,
                               alpha = 0.85,
                               genome_wide = 5e-8,
                               threshold_color = "#E74C3C",
                               highlight_snps = NULL,
                               highlight_color = "#E74C3C",
                               highlight_size = 2,
                               label_snps = NULL,
                               label_top_n = NULL,
                               show_chr_labels = TRUE,
                               inner_radius = 0.35,
                               chr_gap_fraction = 0.012,
                               ring_labels = NULL,
                               downsample = TRUE,
                               downsample_n = 100000,
                               title = NULL) {

  if (is.list(data) && !is.data.frame(data)) {
    return(.circular_multiring(
      data, chr = chr, bp = bp, p = p, snp = snp,
      colors = colors, point_size = point_size, alpha = alpha,
      genome_wide = genome_wide, threshold_color = threshold_color,
      show_chr_labels = show_chr_labels, inner_radius = inner_radius,
      chr_gap_fraction = chr_gap_fraction, ring_labels = ring_labels,
      downsample = downsample, downsample_n = downsample_n, title = title
    ))
  }

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }
  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (downsample && nrow(data) > downsample_n) {
    data <- smart_downsample(data, target_n = downsample_n,
                             keep_snps = c(highlight_snps, label_snps))
  }

  data$LOG10P <- -log10(data$P)
  max_logp <- max(data$LOG10P, na.rm = TRUE) * 1.05

  circ <- .compute_circular_coords(data, inner_radius, max_logp, chr_gap_fraction)
  data <- circ$data
  chr_info <- circ$chr_info

  if (is.character(colors) && length(colors) == 1 && colors %in% gwas_palettes()) {
    colors <- gwas_palette(colors)
  }
  n_chr <- length(unique(data$CHR))
  chr_cols <- rep_len(colors, n_chr)
  names(chr_cols) <- as.character(sort(unique(data$CHR)))

  data$CHR_F <- factor(data$CHR)

  plt <- ggplot(data, aes(x = .data$angle, y = .data$radius,
                           color = .data$CHR_F)) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    scale_color_manual(values = chr_cols, guide = "none") +
    ggplot2::coord_polar(start = -pi / 2, direction = 1) +
    scale_x_continuous(limits = c(0, 2 * pi), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 1.15), expand = c(0, 0)) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    ) +
    labs(title = title)

  if (!is.null(genome_wide)) {
    threshold_r <- inner_radius + (1 - inner_radius) * (-log10(genome_wide) / max_logp)
    threshold_r <- min(threshold_r, 1)
    angles <- seq(0, 2 * pi, length.out = 200)
    thr_df <- data.frame(angle = angles, radius = threshold_r)
    plt <- plt + ggplot2::geom_path(
      data = thr_df,
      aes(x = .data$angle, y = .data$radius),
      color = threshold_color, linetype = "dashed",
      linewidth = 0.3, inherit.aes = FALSE
    )
  }

  if (!is.null(highlight_snps) && "SNP" %in% names(data)) {
    hl <- data[data$SNP %in% highlight_snps, , drop = FALSE]
    if (nrow(hl) > 0) {
      plt <- plt + geom_point(
        data = hl,
        aes(x = .data$angle, y = .data$radius),
        color = highlight_color, size = highlight_size,
        shape = 16, inherit.aes = FALSE
      )
    }
  }

  if (show_chr_labels) {
    label_info <- chr_info
    label_info$label_y <- 1.06
    label_info$label_angle <- label_info$mid_angle * 180 / pi - 90
    label_info$hjust_val <- ifelse(
      label_info$mid_angle > pi, 1, 0
    )
    label_info$label_angle <- ifelse(
      label_info$mid_angle > pi,
      label_info$label_angle + 180,
      label_info$label_angle
    )
    n_chrs <- nrow(label_info)
    label_sz <- if (n_chrs > 18) 2.5 else 3

    plt <- plt + ggplot2::geom_text(
      data = label_info,
      aes(x = .data$mid_angle, y = .data$label_y,
          label = .data$label, angle = .data$label_angle,
          hjust = .data$hjust_val),
      size = label_sz, inherit.aes = FALSE
    )
  }

  label_data <- NULL
  if (!is.null(label_snps) && "SNP" %in% names(data)) {
    label_data <- data[data$SNP %in% label_snps, , drop = FALSE]
  }
  if (!is.null(label_top_n)) {
    top <- data[order(data$P), , drop = FALSE]
    top <- utils::head(top, label_top_n)
    label_data <- if (is.null(label_data)) top else rbind(label_data, top)
  }
  if (!is.null(label_data) && nrow(label_data) > 0 && "SNP" %in% names(label_data)) {
    label_data <- label_data[!duplicated(label_data$SNP), , drop = FALSE]
    plt <- plt + ggrepel::geom_text_repel(
      data = label_data,
      aes(x = .data$angle, y = .data$radius, label = .data$SNP),
      inherit.aes = FALSE,
      size = 2.5, max.overlaps = 15, segment.color = "grey50"
    )
  }

  plt
}

#' Compute circular coordinates for variants
#' @noRd
.compute_circular_coords <- function(data,
                                     inner_radius,
                                     max_logp,
                                     chr_gap_fraction) {
  chrs <- sort(unique(data$CHR))
  chr_lengths <- vapply(chrs, function(ch) max(data$BP[data$CHR == ch]), numeric(1))
  total_length <- sum(chr_lengths)
  total_gap <- chr_gap_fraction * 2 * pi * length(chrs)
  available_angle <- 2 * pi - total_gap
  gap_per_chr <- chr_gap_fraction * 2 * pi

  chr_info <- data.frame(
    CHR = chrs,
    length = chr_lengths,
    angle_width = available_angle * chr_lengths / total_length,
    stringsAsFactors = FALSE
  )

  chr_info$start_angle <- cumsum(c(0, chr_info$angle_width[-nrow(chr_info)] +
                                      gap_per_chr))
  chr_info$mid_angle <- chr_info$start_angle + chr_info$angle_width / 2
  chr_info$label <- int_to_chr(chr_info$CHR)

  data$angle <- NA_real_
  data$radius <- NA_real_

  for (i in seq_len(nrow(chr_info))) {
    ch <- chr_info$CHR[i]
    idx <- which(data$CHR == ch)
    frac <- data$BP[idx] / chr_info$length[i]
    data$angle[idx] <- chr_info$start_angle[i] + frac * chr_info$angle_width[i]
    data$radius[idx] <- inner_radius +
      (1 - inner_radius) * (data$LOG10P[idx] / max_logp)
    data$radius[idx] <- pmin(data$radius[idx], 0.98)
  }

  list(data = data, chr_info = chr_info)
}

#' Multi-ring circular Manhattan
#' @noRd
.circular_multiring <- function(datasets,
                                chr,
                                bp,
                                p,
                                snp,
                                colors,
                                point_size,
                                alpha,
                                genome_wide,
                                threshold_color,
                                show_chr_labels,
                                inner_radius,
                                chr_gap_fraction,
                                ring_labels,
                                downsample,
                                downsample_n,
                                title) {

  trait_names <- names(datasets)
  n_rings <- length(trait_names)

  if (is.null(ring_labels)) ring_labels <- trait_names

  ring_width <- (1 - inner_radius) / n_rings
  ring_gap <- ring_width * 0.05

  if (is.character(colors) && length(colors) == 1 && colors %in% gwas_palettes()) {
    ring_colors <- gwas_palette(colors, n = n_rings)
  } else {
    ring_colors <- rep_len(colors, n_rings)
  }

  all_plot_data <- list()

  for (r in seq_len(n_rings)) {
    d <- datasets[[r]]
    if (!inherits(d, "gwas_data")) {
      d <- as_gwas_data(d, chr = chr, bp = bp, snp = snp, p = p)
    }
    d <- d[!is.na(d$P) & d$P > 0, , drop = FALSE]
    if (downsample && nrow(d) > downsample_n) {
      d <- smart_downsample(d, target_n = downsample_n)
    }
    d$LOG10P <- -log10(d$P)
    max_logp <- max(d$LOG10P, na.rm = TRUE) * 1.05

    ring_inner <- inner_radius + (r - 1) * ring_width + ring_gap
    ring_outer <- inner_radius + r * ring_width - ring_gap

    circ <- .compute_circular_coords(d, 0, max_logp, chr_gap_fraction)
    d <- circ$data

    d$radius <- ring_inner + (ring_outer - ring_inner) * (d$radius)
    d$ring <- trait_names[r]
    d$ring_color <- ring_colors[r]

    if (r == 1) {
      chr_info <- circ$chr_info
    }

    all_plot_data[[r]] <- d
  }

  combined <- do.call(rbind, all_plot_data)
  combined$ring <- factor(combined$ring, levels = trait_names)

  plt <- ggplot(combined, aes(x = .data$angle, y = .data$radius,
                               color = .data$ring)) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    scale_color_manual(values = stats::setNames(ring_colors, trait_names),
                       name = "Trait") +
    ggplot2::coord_polar(start = -pi / 2, direction = 1) +
    scale_x_continuous(limits = c(0, 2 * pi), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      legend.position = "bottom"
    ) +
    labs(title = title)

  if (show_chr_labels) {
    plt <- plt + ggplot2::geom_text(
      data = chr_info,
      aes(x = .data$mid_angle, y = inner_radius * 0.7, label = .data$label),
      size = 2.5, inherit.aes = FALSE
    )
  }

  plt
}
