#' Genetic architecture plot
#'
#' Visualize the relationship between minor allele frequency and effect
#' size, revealing whether a trait's genetic architecture is polygenic
#' (many small effects) or oligogenic (few large effects). Points are
#' colored by significance.
#'
#' @param data A `gwas_data` object or data.frame with P, BETA, and AF columns.
#' @param beta,p,af Column name overrides.
#' @param p_threshold P-value threshold for coloring significant variants.
#' @param colors Named vector with "significant" and "nonsignificant" colors.
#' @param point_size Point size.
#' @param alpha Transparency.
#' @param log_maf If TRUE, use log10(MAF) on x-axis.
#' @param show_density If TRUE, add marginal density curves.
#' @param label_top_n Label the top N variants by significance.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#'
#' # Basic architecture plot
#' architecture_plot(example_gwas)
#'
#' # Label top hits, lower threshold for demo
#' architecture_plot(example_gwas, p_threshold = 0.001, label_top_n = 5)
#'
#' # Log-scale MAF axis
#' architecture_plot(example_gwas, p_threshold = 0.001, log_maf = TRUE)
architecture_plot <- function(data,
                              beta = NULL,
                              p = NULL,
                              af = NULL,
                              p_threshold = 5e-8,
                              colors = c(significant = "#E64B35",
                                         nonsignificant = "#BDC3C7"),
                              point_size = 1,
                              alpha = 0.5,
                              log_maf = FALSE,
                              show_density = FALSE,
                              label_top_n = NULL,
                              title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, beta = beta, p = p, af = af)
  }

  if (!"BETA" %in% names(data)) cli_abort("Column {.field BETA} required.")
  if (!"AF" %in% names(data)) cli_abort("Column {.field AF} required.")

  data <- data[!is.na(data$BETA) & !is.na(data$AF) &
                 !is.na(data$P) & data$P > 0, , drop = FALSE]

  data$MAF <- pmin(data$AF, 1 - data$AF)
  data$ABS_BETA <- abs(data$BETA)
  data$sig <- ifelse(data$P < p_threshold, "significant", "nonsignificant")

  plt <- ggplot(data, aes(x = .data$MAF, y = .data$ABS_BETA,
                           color = .data$sig)) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    scale_color_manual(values = colors, name = "Significance",
                       guide = guide_legend(override.aes = list(size = 3,
                                                                 alpha = 1)))

  if (log_maf) {
    plt <- plt + ggplot2::scale_x_log10(
      labels = scales::label_number()
    ) +
      labs(x = "Minor Allele Frequency (log scale)")
  } else {
    plt <- plt + labs(x = "Minor Allele Frequency")
  }

  plt <- plt +
    labs(y = expression("|" * hat(beta) * "|"), title = title) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  if (!is.null(label_top_n) && "SNP" %in% names(data)) {
    top <- utils::head(data[order(data$P), ], label_top_n)
    plt <- plt + ggrepel::geom_text_repel(
      data = top,
      aes(x = .data$MAF, y = .data$ABS_BETA, label = .data$SNP),
      inherit.aes = FALSE,
      size = 2.8, max.overlaps = 15, segment.color = "grey50"
    )
  }

  plt
}
