#' SNP density karyogram
#'
#' Visualize the distribution of genotyped or imputed variants across
#' chromosomes. Two rendering styles are available: `"heatmap"` (default)
#' bins variants and colors tiles by count, while `"points"` draws
#' individual variant positions on chromosome outlines — density is
#' visible through natural clustering. Optionally marks centromere
#' positions when `chr_info` is provided.
#'
#' @param data A `gwas_data` object or data.frame with GWAS results.
#' @param chr,bp,p Column name overrides.
#' @param style Rendering style: `"heatmap"` for binned density tiles,
#'   or `"points"` for individual variant positions on chromosome
#'   outlines.
#' @param bin_size Bin size in base pairs (default 1 Mb). Only used
#'   when `style = "heatmap"`.
#' @param color_by For `style = "points"`: how to color dots.
#'   `"density"` (default) colors by local density, `"significance"`
#'   colors by -log10(p), or `"uniform"` for a single color.
#' @param chr_info Optional data.frame with columns `chr`, `length`, and
#'   optionally `centromere_start`, `centromere_end`. Use
#'   [chr_info_human()] for hg38. If NULL, chromosome lengths are
#'   inferred from the data.
#' @param palette Color palette: "viridis", "magma", "inferno", or
#'   "plasma".
#' @param point_size Point size for `style = "points"`.
#' @param point_alpha Point transparency for `style = "points"`.
#' @param show_centromeres If TRUE and centromere positions are available
#'   in `chr_info`, draw centromere markers.
#' @param downsample_n Maximum number of points to plot in `"points"`
#'   style. Set to NULL to plot all variants (can be slow for >500k).
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#'
#' # Heatmap style (default)
#' snp_density(example_gwas, bin_size = 5e6, chr_info = chr_info_human())
#'
#' # Different palette
#' snp_density(example_gwas, bin_size = 5e6, palette = "magma",
#'   chr_info = chr_info_human())
#'
#' # Points style — individual variants on chromosome outlines
#' snp_density(example_gwas, style = "points", chr_info = chr_info_human())
#'
#' # Points colored by significance
#' snp_density(example_gwas, style = "points", color_by = "significance",
#'   chr_info = chr_info_human())
#'
#' # Uniform color, no centromeres
#' snp_density(example_gwas, style = "points", color_by = "uniform",
#'   show_centromeres = FALSE)
snp_density <- function(data,
                        chr = NULL,
                        bp = NULL,
                        p = NULL,
                        style = c("heatmap", "points"),
                        bin_size = 1e6,
                        color_by = c("density", "significance", "uniform"),
                        chr_info = NULL,
                        palette = "viridis",
                        point_size = 0.3,
                        point_alpha = 0.5,
                        show_centromeres = TRUE,
                        downsample_n = 200000,
                        title = NULL) {

  style <- match.arg(style)
  color_by <- match.arg(color_by)

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, p = p)
  }

  data <- data[!is.na(data$CHR) & !is.na(data$BP), , drop = FALSE]

  present_chrs <- sort(unique(data$CHR))

  if (is.null(chr_info)) {
    chr_max <- tapply(data$BP, data$CHR, max)
    chr_info <- data.frame(
      chr = as.integer(names(chr_max)),
      length = as.numeric(chr_max)
    )
  }

  chr_info <- chr_info[chr_info$chr %in% present_chrs, , drop = FALSE]
  has_centromeres <- show_centromeres &&
    all(c("centromere_start", "centromere_end") %in% names(chr_info))

  pal_option <- switch(palette,
    "viridis" = "D", "magma" = "A", "inferno" = "B", "plasma" = "C", "D")

  if (style == "heatmap") {
    plt <- .snp_density_heatmap(data, chr_info, bin_size, pal_option, title)
  } else {
    plt <- .snp_density_points(data, chr_info, color_by, pal_option,
      point_size, point_alpha, downsample_n, title)
  }

  if (has_centromeres) {
    chr_levels <- levels(plt$data$CHR_label)
    if (is.null(chr_levels)) {
      chr_levels <- rev(int_to_chr(present_chrs))
    }
    cen <- chr_info[, c("chr", "centromere_start", "centromere_end")]
    cen <- cen[!is.na(cen$centromere_start) & !is.na(cen$centromere_end), ,
               drop = FALSE]
    if (nrow(cen) > 0) {
      cen$CHR_label <- factor(int_to_chr(cen$chr), levels = chr_levels)
      cen$cen_mid_mb <- (cen$centromere_start + cen$centromere_end) / 2 / 1e6

      plt <- plt + geom_segment(
        data = cen,
        aes(x = .data$cen_mid_mb, xend = .data$cen_mid_mb,
            y = as.numeric(.data$CHR_label) - 0.42,
            yend = as.numeric(.data$CHR_label) + 0.42),
        color = "#E74C3C", linewidth = 0.6,
        inherit.aes = FALSE
      )
    }
  }

  plt
}

.snp_density_heatmap <- function(data, chr_info, bin_size, pal_option, title) {
  data$bin <- floor(data$BP / bin_size) * bin_size
  bins <- stats::aggregate(data$BP, by = list(CHR = data$CHR, bin = data$bin),
                           FUN = length)
  names(bins)[3] <- "count"

  all_bins <- do.call(rbind, lapply(chr_info$chr, function(ch) {
    max_bp <- chr_info$length[chr_info$chr == ch]
    bin_seq <- seq(0, max_bp, by = bin_size)
    data.frame(CHR = ch, bin = bin_seq)
  }))

  bins <- merge(all_bins, bins, by = c("CHR", "bin"), all.x = TRUE)
  bins$count[is.na(bins$count)] <- 0
  bins$bin_mb <- bins$bin / 1e6
  bins$CHR_label <- factor(int_to_chr(bins$CHR),
                           levels = rev(int_to_chr(sort(unique(bins$CHR)))))

  ggplot(bins, aes(x = .data$bin_mb, y = .data$CHR_label,
                    fill = .data$count)) +
    geom_tile(width = bin_size / 1e6, height = 0.85) +
    scale_fill_viridis_c(option = pal_option, direction = -1, name = "SNP count") +
    labs(x = "Position (Mb)", y = "Chromosome", title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.text.y = element_text(size = 7),
      legend.position = "right"
    )
}

.snp_density_points <- function(data, chr_info, color_by, pal_option,
                                point_size, point_alpha, downsample_n, title) {
  if (!is.null(downsample_n) && nrow(data) > downsample_n) {
    data <- data[sample(nrow(data), downsample_n), , drop = FALSE]
  }

  present_chrs <- sort(unique(data$CHR))
  chr_levels <- rev(int_to_chr(present_chrs))

  chr_outlines <- data.frame(
    chr = chr_info$chr,
    xmin = 0,
    xmax = chr_info$length / 1e6,
    CHR_label = factor(int_to_chr(chr_info$chr), levels = chr_levels)
  )

  data$bp_mb <- data$BP / 1e6
  data$CHR_label <- factor(int_to_chr(data$CHR), levels = chr_levels)
  data$y_jitter <- as.numeric(data$CHR_label) +
    stats::runif(nrow(data), -0.3, 0.3)

  plt <- ggplot() +
    ggplot2::geom_rect(
      data = chr_outlines,
      aes(xmin = .data$xmin, xmax = .data$xmax,
          ymin = as.numeric(.data$CHR_label) - 0.4,
          ymax = as.numeric(.data$CHR_label) + 0.4),
      fill = "grey95", color = "grey60", linewidth = 0.3
    )

  if (color_by == "uniform") {
    plt <- plt + geom_point(
      data = data,
      aes(x = .data$bp_mb, y = .data$y_jitter),
      size = point_size, alpha = point_alpha, color = "#1A5276", shape = 16
    )
  } else if (color_by == "significance" && "P" %in% names(data)) {
    data$neglog10p <- -log10(pmax(data$P, .Machine$double.xmin))
    plt <- plt + geom_point(
      data = data,
      aes(x = .data$bp_mb, y = .data$y_jitter, color = .data$neglog10p),
      size = point_size, alpha = point_alpha, shape = 16
    ) +
      scale_color_viridis_c(option = pal_option, direction = -1,
        name = expression(-log[10](italic(p))))
  } else {
    bin_size_local <- 1e6
    data$density_bin <- floor(data$BP / bin_size_local)
    density_counts <- stats::aggregate(
      data$BP, by = list(CHR = data$CHR, bin = data$density_bin), FUN = length)
    names(density_counts)[3] <- "local_density"
    data <- merge(data, density_counts,
      by.x = c("CHR", "density_bin"), by.y = c("CHR", "bin"), all.x = TRUE)
    data$CHR_label <- factor(int_to_chr(data$CHR), levels = chr_levels)

    plt <- plt + geom_point(
      data = data,
      aes(x = .data$bp_mb, y = .data$y_jitter, color = .data$local_density),
      size = point_size, alpha = point_alpha, shape = 16
    ) +
      scale_color_viridis_c(option = pal_option, direction = -1, name = "Local density")
  }

  plt +
    scale_y_continuous(
      breaks = seq_along(chr_levels), labels = chr_levels, expand = c(0.02, 0)
    ) +
    labs(x = "Position (Mb)", y = "Chromosome", title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.text.y = element_text(size = 7),
      legend.position = "right"
    )
}
