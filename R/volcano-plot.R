#' GWAS effect-size volcano plot
#'
#' Plot effect size (BETA) against statistical significance (-log10(p)),
#' revealing both the magnitude and direction of genetic effects.
#' Unlike RNA-seq volcano plots, this variant can color by chromosome
#' and scale point size by allele frequency.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param beta,p,snp Column name overrides.
#' @param p_threshold P-value significance threshold.
#' @param beta_threshold Minimum |BETA| to consider significant.
#' @param color_by How to color points: "significance", "chromosome", or a column name.
#' @param size_by Column name to scale point size (e.g. "AF"), or NULL.
#' @param point_size Base point size (used when size_by is NULL).
#' @param alpha Point transparency.
#' @param label_snps Character vector of SNP IDs to label.
#' @param label_top_n Label the top N most significant SNPs.
#' @param colors Named color vector: "significant" and "nonsignificant" for
#'   significance mode, or any custom palette.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "gwasplot")
#' volcano_plot(example_gwas)
volcano_plot <- function(data,
                         beta = NULL, p = NULL, snp = NULL,
                         p_threshold = 5e-8,
                         beta_threshold = NULL,
                         color_by = "significance",
                         size_by = NULL,
                         point_size = 0.8,
                         alpha = 0.6,
                         label_snps = NULL,
                         label_top_n = NULL,
                         colors = c(significant = "#E74C3C",
                                    nonsignificant = "#BDC3C7"),
                         title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, beta = beta, p = p, snp = snp)
  }

  if (!"BETA" %in% names(data)) {
    cli_abort("Effect size column (BETA) is required for volcano plots.")
  }

  data <- data[!is.na(data$P) & data$P > 0 & !is.na(data$BETA), , drop = FALSE]
  data$LOG10P <- -log10(data$P)

  if (color_by == "significance") {
    data$sig <- ifelse(data$P < p_threshold, "significant", "nonsignificant")
    if (!is.null(beta_threshold)) {
      data$sig[abs(data$BETA) < beta_threshold] <- "nonsignificant"
    }
    plt <- ggplot(data, aes(x = .data$BETA, y = .data$LOG10P,
                             color = .data$sig))
    plt <- plt + scale_color_manual(values = colors, guide = "none")
  } else if (color_by == "chromosome") {
    data$CHR_F <- factor(data$CHR)
    plt <- ggplot(data, aes(x = .data$BETA, y = .data$LOG10P,
                             color = .data$CHR_F))
    plt <- plt + scale_color_chromosome(guide = "none")
  } else {
    plt <- ggplot(data, aes(x = .data$BETA, y = .data$LOG10P,
                             color = .data[[color_by]]))
  }

  if (!is.null(size_by) && size_by %in% names(data)) {
    plt <- plt + geom_point(aes(size = .data[[size_by]]),
                            alpha = alpha, shape = 16) +
      ggplot2::scale_size_continuous(range = c(0.3, 3), name = size_by)
  } else {
    plt <- plt + geom_point(size = point_size, alpha = alpha, shape = 16)
  }

  plt <- plt +
    geom_hline(yintercept = -log10(p_threshold),
               linetype = "dashed", color = "grey40", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = 0, linetype = "solid",
                        color = "grey60", linewidth = 0.3) +
    labs(x = "Effect Size (BETA)",
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas()

  if (!is.null(beta_threshold)) {
    plt <- plt +
      ggplot2::geom_vline(xintercept = c(-beta_threshold, beta_threshold),
                          linetype = "dotted", color = "grey40", linewidth = 0.4)
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
      aes(x = .data$BETA, y = .data$LOG10P, label = .data$SNP),
      inherit.aes = FALSE,
      size = 3, max.overlaps = 20, segment.color = "grey50"
    )
  }

  plt
}
