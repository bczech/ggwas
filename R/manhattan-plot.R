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
#' @param y_truncate If set, truncate the y-axis at this value and draw
#'   a break symbol. Variants above the truncation are shown as triangles
#'   at the truncation line, indicating their values exceed the visible
#'   range. Useful for GWAS with extremely significant loci that compress
#'   the rest of the plot.
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
#' # Truncated y-axis for extreme p-values
#' manhattan_plot(example_gwas, y_truncate = 10)
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
    trunc_val <- y_truncate
    above <- data[data$LOG10P > trunc_val, , drop = FALSE]
    if (nrow(above) > 0) {
      above$LOG10P_orig <- above$LOG10P
      above$LOG10P <- trunc_val
      plt <- plt + geom_point(
        data = above,
        aes(x = .data$BP_CUM, y = .data$LOG10P),
        shape = 17, size = point_size * 2, color = "#E74C3C",
        inherit.aes = FALSE
      )
    }

    x_range <- range(data$BP_CUM, na.rm = TRUE)
    x_break <- x_range[1] - diff(x_range) * 0.015
    gap <- trunc_val * 0.03
    break_df <- data.frame(
      x = rep(x_break, 4),
      xend = rep(x_break, 4),
      y = c(trunc_val - gap * 2, trunc_val - gap,
            trunc_val + gap, trunc_val + gap * 2),
      yend = c(trunc_val - gap, trunc_val + gap,
               trunc_val + gap * 2, trunc_val + gap * 3)
    )

    plt <- plt +
      coord_cartesian(ylim = c(0, trunc_val * 1.05), clip = "off") +
      ggplot2::annotate("segment",
        x = x_break - diff(x_range) * 0.008,
        xend = x_break + diff(x_range) * 0.008,
        y = trunc_val - gap, yend = trunc_val + gap,
        color = "grey30", linewidth = 0.5) +
      ggplot2::annotate("segment",
        x = x_break - diff(x_range) * 0.008,
        xend = x_break + diff(x_range) * 0.008,
        y = trunc_val - gap * 2, yend = trunc_val,
        color = "grey30", linewidth = 0.5)
  } else if (!is.null(y_limit)) {
    plt <- plt + coord_cartesian(ylim = c(0, y_limit))
  }

  plt
}
