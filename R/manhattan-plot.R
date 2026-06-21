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
#' @param y_limit Upper y-axis limit for -log10(p).
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "gwasplot")
#' manhattan_plot(example_gwas)
#' manhattan_plot(example_gwas, highlight_snps = "rs12345", label_top_n = 3)
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
                           y_limit = NULL,
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

  chr_labels <- int_to_chr(chr_info$CHR)
  n_chr_displayed <- nrow(chr_info)
  chr_label_size <- if (n_chr_displayed > 18) 2.2 else if (n_chr_displayed > 10) 2.8 else 3.2

  plt <- ggplot(data, aes(x = .data$BP_CUM, y = .data$LOG10P,
                           color = .data$CHR_F)) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    scale_color_chromosome(colors = colors, guide = "none") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = chr_labels,
      expand = c(0.01, 0)
    ) +
    labs(x = "Chromosome",
         y = expression(-log[10](italic(p))),
         title = title) +
    ggplot2::theme(axis.text.x = element_text(size = ggplot2::rel(chr_label_size / 3.5))) +
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

  if (!is.null(y_limit)) {
    plt <- plt + coord_cartesian(ylim = c(0, y_limit))
  }

  plt
}
