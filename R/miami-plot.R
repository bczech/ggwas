#' Miami plot (mirrored Manhattan)
#'
#' Create a Miami plot showing two GWAS results as mirrored Manhattan plots.
#' The top panel shows one study with -log10(p) going up, and the bottom
#' panel shows another study with -log10(p) going down.
#'
#' @param top A `gwas_data` object or data.frame for the top panel.
#' @param bottom A `gwas_data` object or data.frame for the bottom panel.
#' @param chr,bp,p,snp Column name overrides.
#' @param colors Two-color vector for alternating chromosomes.
#' @param genome_wide Genome-wide significance threshold.
#' @param suggestive Suggestive significance threshold.
#' @param top_highlight,bottom_highlight SNP IDs to highlight in each panel.
#' @param top_label,bottom_label SNP IDs to label in each panel.
#' @param top_title,bottom_title Y-axis titles for each panel.
#' @param downsample Enable smart downsampling.
#' @param downsample_n Target points per panel.
#' @param title Overall plot title.
#' @return A ggplot object composed via patchwork.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#'
#' # Discovery vs replication
#' miami_plot(example_gwas, example_gwas,
#'   top_title = "Discovery", bottom_title = "Replication")
#'
#' # Different colors
#' miami_plot(example_gwas, example_gwas,
#'   colors = gwas_palette("nature"),
#'   top_title = "Study 1", bottom_title = "Study 2")
miami_plot <- function(top, bottom,
                       chr = NULL,
                       bp = NULL,
                       p = NULL,
                       snp = NULL,
                       colors = c("#1A5276", "#76D7C4"),
                       genome_wide = 5e-8,
                       suggestive = 1e-5,
                       top_highlight = NULL,
                       bottom_highlight = NULL,
                       top_label = NULL,
                       bottom_label = NULL,
                       top_title = NULL,
                       bottom_title = NULL,
                       downsample = TRUE,
                       downsample_n = 200000,
                       title = NULL) {

  if (!inherits(top, "gwas_data")) {
    top <- as_gwas_data(top, chr = chr, bp = bp, snp = snp, p = p)
  }
  if (!inherits(bottom, "gwas_data")) {
    bottom <- as_gwas_data(bottom, chr = chr, bp = bp, snp = snp, p = p)
  }

  p_top <- manhattan_plot(
    top,
    colors = colors,
    genome_wide = genome_wide,
    suggestive = suggestive,
    highlight_snps = top_highlight,
    label_snps = top_label,
    downsample = downsample,
    downsample_n = downsample_n,
    title = NULL
  ) +
    labs(x = NULL, y = top_title %||% expression(-log[10](italic(p)))) +
    ggplot2::theme(axis.text.x = element_blank())

  bottom_data <- bottom
  bottom_data <- bottom_data[!is.na(bottom_data$P) & bottom_data$P > 0, , drop = FALSE]

  if (downsample && nrow(bottom_data) > downsample_n) {
    bottom_data <- smart_downsample(bottom_data, target_n = downsample_n,
                                    keep_snps = c(bottom_highlight, bottom_label))
  }

  bottom_data$LOG10P <- -log10(bottom_data$P)
  bottom_data <- add_cumulative_bp(bottom_data)
  chr_info <- attr(bottom_data, "chr_info")
  bottom_data$CHR_F <- factor(bottom_data$CHR)

  p_bottom <- ggplot(bottom_data,
                     aes(x = .data$BP_CUM, y = .data$LOG10P,
                         color = .data$CHR_F)) +
    geom_point(size = 0.8, alpha = 1, shape = 16) +
    scale_color_chromosome(colors = colors, guide = "none") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = int_to_chr(chr_info$CHR),
      expand = c(0.01, 0)
    ) +
    scale_y_continuous(trans = "reverse") +
    labs(x = "Chromosome",
         y = bottom_title %||% expression(-log[10](italic(p)))) +
    theme_gwas()

  if (!is.null(genome_wide)) {
    p_bottom <- p_bottom + geom_hline(
      yintercept = -log10(genome_wide),
      linetype = "dashed", color = "#E74C3C", linewidth = 0.4
    )
  }
  if (!is.null(suggestive)) {
    p_bottom <- p_bottom + geom_hline(
      yintercept = -log10(suggestive),
      linetype = "dotted", color = "#3498DB", linewidth = 0.4
    )
  }

  combined <- patchwork::wrap_plots(p_top, p_bottom, ncol = 1)
  if (!is.null(title)) {
    combined <- combined + patchwork::plot_annotation(title = title)
  }
  combined
}
