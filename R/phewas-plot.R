#' PheWAS plot
#'
#' Visualize one variant tested across many phenotypes, grouped by
#' phenotype category. The standard figure for biobank-scale phenome-wide
#' association studies (UK Biobank, FinnGen, BioBank Japan).
#'
#' @param data A data.frame with columns: `phenotype`, `p` (p-value),
#'   and `category` (phenotype group). Optional: `beta`, `description`.
#' @param p Column name for p-values.
#' @param phenotype Column name for phenotype labels.
#' @param category Column name for phenotype categories.
#' @param beta Column name for effect sizes (used for direction triangles).
#' @param p_threshold Significance threshold line.
#' @param colors Named vector of colors per category, or a palette name.
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param label_top_n Label the top N most significant phenotypes.
#' @param label_column Column for label text (default: phenotype).
#' @param show_categories Show category labels on x-axis.
#' @param category_label_angle Rotation angle for category labels.
#' @param direction_shape If TRUE and `beta` is provided, use triangles
#'   pointing up (positive) or down (negative) instead of circles.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' phewas_data <- data.frame(
#'   phenotype = paste0("Pheno_", 1:50),
#'   p = 10^(-runif(50, 0, 8)),
#'   category = rep(c("Metabolic", "Immune", "Neuro", "Cardio", "Other"), 10),
#'   beta = rnorm(50, 0, 0.2)
#' )
#' phewas_plot(phewas_data)
phewas_plot <- function(data,
                        p = "p",
                        phenotype = "phenotype",
                        category = "category",
                        beta = "beta",
                        p_threshold = 5e-8,
                        colors = NULL,
                        point_size = 2,
                        alpha = 0.8,
                        label_top_n = 5,
                        label_column = NULL,
                        show_categories = TRUE,
                        category_label_angle = 45,
                        direction_shape = TRUE,
                        title = NULL) {

  if (!p %in% names(data)) cli_abort("Column {.field {p}} not found.")
  if (!phenotype %in% names(data)) cli_abort("Column {.field {phenotype}} not found.")
  if (!category %in% names(data)) cli_abort("Column {.field {category}} not found.")

  if (is.null(label_column)) label_column <- phenotype

  data$LOG10P <- -log10(data[[p]])
  data$cat_f <- factor(data[[category]])

  cat_levels <- levels(data$cat_f)
  data$cat_order <- as.integer(data$cat_f)
  data <- data[order(data$cat_order, data[[phenotype]]), ]
  data$x_pos <- seq_len(nrow(data))

  if (is.null(colors)) {
    n_cats <- length(cat_levels)
    colors <- gwas_palette("nature", n = n_cats)
    names(colors) <- cat_levels
  } else if (is.character(colors) && length(colors) == 1 && colors %in% gwas_palettes()) {
    n_cats <- length(cat_levels)
    colors <- gwas_palette(colors, n = n_cats)
    names(colors) <- cat_levels
  }

  has_beta <- beta %in% names(data)
  if (has_beta && direction_shape) {
    data$direction <- ifelse(data[[beta]] >= 0, "up", "down")
    plt <- ggplot(data, aes(x = .data$x_pos, y = .data$LOG10P,
                             color = .data$cat_f, shape = .data$direction)) +
      geom_point(size = point_size, alpha = alpha) +
      ggplot2::scale_shape_manual(
        values = c(up = 24, down = 25),
        labels = c(up = "Positive", down = "Negative"),
        name = "Effect direction"
      )
  } else {
    plt <- ggplot(data, aes(x = .data$x_pos, y = .data$LOG10P,
                             color = .data$cat_f)) +
      geom_point(size = point_size, alpha = alpha, shape = 16)
  }

  cat_centers <- tapply(data$x_pos, data$cat_f, mean)
  cat_breaks <- tapply(data$x_pos, data$cat_f, max)

  plt <- plt +
    scale_color_manual(values = colors, name = "Category") +
    labs(x = NULL, y = expression(-log[10](italic(p))), title = title) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  if (!is.null(p_threshold)) {
    plt <- plt + geom_hline(yintercept = -log10(p_threshold),
                            linetype = "dashed", color = "#E74C3C",
                            linewidth = 0.4)
  }

  if (show_categories) {
    plt <- plt + scale_x_continuous(
      breaks = cat_centers,
      labels = names(cat_centers),
      expand = c(0.02, 0)
    ) +
      ggplot2::theme(
        axis.text.x = element_text(angle = category_label_angle,
                                   hjust = 1, vjust = 1, size = 6)
      )
  } else {
    plt <- plt + scale_x_continuous(breaks = NULL, expand = c(0.02, 0))
  }

  for (i in seq_along(cat_breaks)[-length(cat_breaks)]) {
    plt <- plt + ggplot2::geom_vline(
      xintercept = cat_breaks[i] + 0.5,
      color = "grey85", linewidth = 0.3
    )
  }

  if (!is.null(label_top_n) && label_column %in% names(data)) {
    top <- utils::head(data[order(data[[p]]), ], label_top_n)
    plt <- plt + ggrepel::geom_text_repel(
      data = top,
      aes(x = .data$x_pos, y = .data$LOG10P,
          label = .data[[label_column]]),
      inherit.aes = FALSE,
      size = 2.8, max.overlaps = 20, segment.color = "grey50"
    )
  }

  plt
}
