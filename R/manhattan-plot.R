#' Manhattan plot
#'
#' Create a genome-wide Manhattan plot from GWAS summary statistics.
#' Returns a ggplot2 object for further customization.
#'
#' @param data A `gwas_data` object or data.frame with GWAS results.
#' @param chr,bp,p,snp Column name overrides (auto-detected if NULL).
#' @param colors Two-color vector for alternating chromosomes.
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param genome_wide Genome-wide significance threshold (p-value).
#' @param suggestive Suggestive significance threshold.
#' @param threshold_colors Colors for significance lines.
#' @param highlight_snps Character vector of SNP IDs to highlight.
#' @param highlight_color Color for highlighted SNPs.
#' @param highlight_size Size for highlighted points.
#' @param label_snps Character vector of SNP IDs to label.
#' @param label_top_n Label the top N most significant SNPs.
#' @param label_column Column to use for label text.
#' @param downsample Enable smart downsampling for large datasets.
#' @param downsample_n Target number of points after downsampling.
#' @param chromosomes Subset of chromosomes to plot (integer vector).
#' @param chr_labels Custom chromosome labels (character vector, same length
#'   as displayed chromosomes). If NULL, auto-generated from chromosome numbers.
#' @param y_limit Upper y-axis limit for -log10(p).
#' @param y_truncate If set, break the y-axis at this -log10(p) value.
#'   The region below is shown at full scale; the region above is
#'   compressed so extreme values remain visible with their true
#'   -log10(p) labels. A break symbol (//) marks the transition.
#' @param y_compress Compression factor for the zone above `y_truncate`
#'   (default 0.1). Values closer to 0 compress more (less space for
#'   extreme points); values closer to 1 compress less.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#'
#' # Basic Manhattan plot
#' manhattan_plot(example_gwas)
#'
#' # Label top hits with a different palette
#' manhattan_plot(example_gwas, label_top_n = 5, colors = gwas_palette("vibrant"))
#'
#' # Nature journal style
#' manhattan_plot(example_gwas, label_top_n = 3) + theme_nature()
#'
#' # Lancet palette with Science theme
#' manhattan_plot(example_gwas, colors = gwas_palette("lancet")) + theme_science()
#'
#' # Subset chromosomes
#' manhattan_plot(example_gwas, chromosomes = 1:10)
#'
#' # NEJM palette
#' manhattan_plot(example_gwas, colors = gwas_palette("nejm"), label_top_n = 3)
#'
#' # Broken y-axis for extreme p-values
#' manhattan_plot(example_gwas, y_truncate = 10)
#'
#' # Less compression (more space for extreme values)
#' manhattan_plot(example_gwas, y_truncate = 10, y_compress = 0.3)
manhattan_plot <- function(data,
                           chr = NULL,
                           bp = NULL,
                           p = NULL,
                           snp = NULL,
                           colors = c("#1A5276", "#76D7C4"),
                           point_size = 0.8,
                           alpha = 1,
                           genome_wide = 5e-8,
                           suggestive = 1e-5,
                           threshold_colors = c("#E74C3C", "#3498DB"),
                           highlight_snps = NULL,
                           highlight_color = "#E74C3C",
                           highlight_size = 2,
                           label_snps = NULL,
                           label_top_n = NULL,
                           label_column = "SNP",
                           downsample = TRUE,
                           downsample_n = 200000,
                           chromosomes = NULL,
                           chr_labels = NULL,
                           y_limit = NULL,
                           y_truncate = NULL,
                           y_compress = 0.1,
                           title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }

  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!is.null(chromosomes)) {
    data <- data[data$CHR %in% chromosomes, , drop = FALSE]
  }

  if (downsample && nrow(data) > downsample_n) {
    cli_inform("Downsampling from {format(nrow(data), big.mark = ',')} to ~{format(downsample_n, big.mark = ',')} points.")
    data <- smart_downsample(data, target_n = downsample_n,
                             keep_snps = c(highlight_snps, label_snps))
  }

  data$LOG10P <- -log10(data$P)
  data <- add_cumulative_bp(data)
  chr_info <- attr(data, "chr_info")
  data$CHR_F <- factor(data$CHR)

  if (is.null(chr_labels)) {
    chr_labels <- int_to_chr(chr_info$CHR)
  }
  n_chr_displayed <- nrow(chr_info)

  plt <- ggplot(data, aes(x = .data$BP_CUM, y = .data$LOG10P,
                           color = .data$CHR_F)) +
    geom_point(size = point_size, alpha = alpha, shape = 16)

  plt <- plt +
    scale_color_chromosome(colors = colors, guide = "none") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = chr_labels,
      expand = c(0.01, 0)
    ) +
    labs(x = "Chromosome",
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas()

  if (!is.null(genome_wide)) {
    plt <- plt + geom_hline(
      yintercept = -log10(genome_wide),
      linetype = "dashed", color = threshold_colors[1], linewidth = 0.4
    )
  }
  if (!is.null(suggestive)) {
    plt <- plt + geom_hline(
      yintercept = -log10(suggestive),
      linetype = "dotted", color = threshold_colors[2], linewidth = 0.4
    )
  }

  if (!is.null(highlight_snps) && "SNP" %in% names(data)) {
    hl <- data[data$SNP %in% highlight_snps, , drop = FALSE]
    if (nrow(hl) > 0) {
      plt <- plt + geom_point(
        data = hl,
        aes(x = .data$BP_CUM, y = .data$LOG10P),
        color = highlight_color, size = highlight_size, shape = 16,
        inherit.aes = FALSE
      )
    }
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

  if (!is.null(label_data) && nrow(label_data) > 0 && label_column %in% names(label_data)) {
    label_data <- label_data[!duplicated(label_data[[label_column]]), , drop = FALSE]
    plt <- plt + ggrepel::geom_text_repel(
      data = label_data,
      aes(x = .data$BP_CUM, y = .data$LOG10P, label = .data[[label_column]]),
      inherit.aes = FALSE,
      size = 3, max.overlaps = 20, segment.color = "grey50"
    )
  }

  if (!is.null(y_truncate)) {
    break_at <- y_truncate
    max_val <- max(data$LOG10P, na.rm = TRUE)
    compress <- y_compress
    top_zone <- (max_val - break_at) * compress

    data$LOG10P_plot <- ifelse(
      data$LOG10P <= break_at,
      data$LOG10P,
      break_at + (data$LOG10P - break_at) * compress
    )

    y_top <- break_at + top_zone * 1.15

    max_real <- ceiling(max_val / 10) * 10
    breaks_below <- scales::breaks_pretty(n = 4)(c(0, break_at))
    breaks_below <- breaks_below[breaks_below < break_at]
    breaks_above <- max_real
    all_breaks_real <- c(breaks_below, breaks_above)
    all_breaks_plot <- c(breaks_below, break_at + (breaks_above - break_at) * compress)

    plt <- ggplot(data, aes(x = .data$BP_CUM, y = .data$LOG10P_plot,
                             color = .data$CHR_F)) +
      geom_point(size = point_size, alpha = alpha, shape = 16) +
      scale_color_chromosome(colors = colors, guide = "none") +
      scale_x_continuous(
        breaks = chr_info$center, labels = chr_labels, expand = c(0.01, 0)
      ) +
      scale_y_continuous(
        breaks = all_breaks_plot, labels = all_breaks_real,
        expand = c(0.02, 0)
      ) +
      labs(x = "Chromosome", y = expression(-log[10](italic(p))), title = title) +
      theme_gwas()

    if (!is.null(genome_wide)) {
      plt <- plt + geom_hline(yintercept = -log10(genome_wide),
        linetype = "dashed", color = threshold_colors[1], linewidth = 0.4)
    }
    if (!is.null(suggestive)) {
      plt <- plt + geom_hline(yintercept = -log10(suggestive),
        linetype = "dotted", color = threshold_colors[2], linewidth = 0.4)
    }

    if (!is.null(label_data) && nrow(label_data) > 0 && label_column %in% names(label_data)) {
      label_data$LOG10P_plot <- ifelse(
        label_data$LOG10P <= break_at,
        label_data$LOG10P,
        break_at + (label_data$LOG10P - break_at) * compress
      )
      label_data <- label_data[!duplicated(label_data[[label_column]]), , drop = FALSE]
      plt <- plt + ggrepel::geom_text_repel(
        data = label_data,
        aes(x = .data$BP_CUM, y = .data$LOG10P_plot, label = .data[[label_column]]),
        inherit.aes = FALSE,
        size = 3, max.overlaps = 20, segment.color = "grey50"
      )
    }

    x_range <- range(data$BP_CUM, na.rm = TRUE)
    x_pad <- diff(x_range) * 0.04
    bh <- break_at * 0.025

    n_zig <- 80
    x_seq <- seq(x_range[1] - x_pad, x_range[2] + x_pad, length.out = n_zig)
    zig_dy <- bh * 0.6
    y_zig <- break_at + ifelse(seq_len(n_zig) %% 2 == 0, zig_dy, -zig_dy)

    zig_upper <- data.frame(x = x_seq, y = y_zig + bh * 0.5)
    zig_lower <- data.frame(x = x_seq, y = y_zig - bh * 0.5)

    plt <- plt +
      coord_cartesian(ylim = c(0, y_top), clip = "off") +
      ggplot2::annotate("rect",
        xmin = x_range[1] - x_pad, xmax = x_range[2] + x_pad,
        ymin = break_at - bh * 1.5, ymax = break_at + bh * 1.5,
        fill = "white") +
      ggplot2::geom_line(data = zig_upper,
        aes(x = .data$x, y = .data$y),
        color = "grey30", linewidth = 0.4, inherit.aes = FALSE) +
      ggplot2::geom_line(data = zig_lower,
        aes(x = .data$x, y = .data$y),
        color = "grey30", linewidth = 0.4, inherit.aes = FALSE)
  } else if (!is.null(y_limit)) {
    plt <- plt + coord_cartesian(ylim = c(0, y_limit))
  }

  plt
}
