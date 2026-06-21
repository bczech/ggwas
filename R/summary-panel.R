#' GWAS Summary Panel
#'
#' A multi-panel dashboard combining Manhattan plot, QQ plot, top hits
#' table, and summary statistics into a single publication-ready figure.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param chr,bp,p,snp Column name overrides.
#' @param panels Character vector of panels to include. Options:
#'   "manhattan", "qq", "top_hits", "density", "stats".
#' @param n_top Number of top hits to display in the table.
#' @param genome_wide Genome-wide significance threshold.
#' @param suggestive Suggestive significance threshold.
#' @param colors Two-color vector for Manhattan chromosome colors.
#' @param palette Palette name from [gwas_palette()].
#' @param label_top_n Label top N SNPs on Manhattan.
#' @param title Overall title.
#' @param theme_fn Theme function to apply (default [theme_gwas()]).
#' @param layout Layout arrangement: "auto", "wide", or "tall".
#' @return A patchwork composition.
#' @export
#' @examples
#' data(example_gwas)
#' gwas_summary(example_gwas)
gwas_summary <- function(data,
                         chr = NULL, bp = NULL, p = NULL, snp = NULL,
                         panels = c("manhattan", "qq", "top_hits", "density"),
                         n_top = 10,
                         genome_wide = 5e-8,
                         suggestive = 1e-5,
                         colors = NULL,
                         palette = "colorblind",
                         label_top_n = 5,
                         title = NULL,
                         theme_fn = NULL,
                         layout = "auto") {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }

  if (is.null(colors)) colors <- gwas_palette(palette)

  plot_list <- list()

  if ("manhattan" %in% panels) {
    p_man <- manhattan_plot(data, colors = colors,
                           genome_wide = genome_wide,
                           suggestive = suggestive,
                           label_top_n = label_top_n) +
      labs(title = NULL)
    if (!is.null(theme_fn)) p_man <- p_man + theme_fn()
    plot_list$manhattan <- p_man
  }

  if ("qq" %in% panels) {
    p_qq <- qq_plot(data, show_lambda = TRUE, ci = 0.95) +
      labs(title = NULL)
    if (!is.null(theme_fn)) p_qq <- p_qq + theme_fn()
    plot_list$qq <- p_qq
  }

  if ("top_hits" %in% panels) {
    p_table <- .make_top_hits_panel(data, n_top = n_top,
                                   genome_wide = genome_wide)
    plot_list$top_hits <- p_table
  }

  if ("density" %in% panels) {
    p_density <- .make_density_panel(data, colors = colors)
    if (!is.null(theme_fn)) p_density <- p_density + theme_fn()
    plot_list$density <- p_density
  }

  if ("stats" %in% panels) {
    p_stats <- .make_stats_panel(data, genome_wide = genome_wide,
                                suggestive = suggestive)
    plot_list$stats <- p_stats
  }

  n_panels <- length(plot_list)

  if (layout == "auto") {
    if (n_panels <= 2) {
      design <- patchwork::wrap_plots(plot_list, ncol = 1)
    } else if (n_panels == 3) {
      design <- patchwork::wrap_plots(
        plot_list[[1]],
        patchwork::wrap_plots(plot_list[[2]], plot_list[[3]], ncol = 2),
        ncol = 1, heights = c(2, 1)
      )
    } else {
      design <- patchwork::wrap_plots(
        plot_list[[1]],
        patchwork::wrap_plots(plot_list[2:n_panels], ncol = n_panels - 1),
        ncol = 1, heights = c(2, 1)
      )
    }
  } else if (layout == "wide") {
    design <- patchwork::wrap_plots(plot_list, nrow = 1)
  } else {
    design <- patchwork::wrap_plots(plot_list, ncol = 1)
  }

  if (!is.null(title)) {
    design <- design + patchwork::plot_annotation(
      title = title,
      theme = ggplot2::theme(plot.title = element_text(face = "bold", size = 14))
    )
  }

  design <- design + patchwork::plot_annotation(
    tag_levels = "A"
  )

  design
}

#' Create top hits table panel
#' @noRd
.make_top_hits_panel <- function(data, n_top, genome_wide) {
  top <- data[order(data$P), , drop = FALSE]
  top <- utils::head(top, n_top)

  display_cols <- intersect(c("SNP", "CHR", "BP", "P", "BETA", "SE", "AF"),
                            names(top))
  top <- top[, display_cols, drop = FALSE]

  top$CHR <- int_to_chr(top$CHR)
  top$BP <- format(top$BP, big.mark = ",")
  top$P <- formatC(top$P, format = "e", digits = 2)
  if ("BETA" %in% names(top)) top$BETA <- round(top$BETA, 4)
  if ("SE" %in% names(top)) top$SE <- round(top$SE, 4)
  if ("AF" %in% names(top)) top$AF <- round(top$AF, 3)

  table_theme <- gridExtra::ttheme_minimal(
    base_size = 7,
    core = list(fg_params = list(hjust = 0, x = 0.05)),
    colhead = list(
      fg_params = list(hjust = 0, x = 0.05, fontface = "bold"),
      bg_params = list(fill = "grey95")
    )
  )

  grob <- gridExtra::tableGrob(top, rows = NULL, theme = table_theme)

  ggplot() +
    ggplot2::theme_void() +
    annotation_custom(grob) +
    labs(title = "Top Hits")
}

#' Create SNP density panel
#' @noRd
.make_density_panel <- function(data, colors) {
  data$LOG10P <- -log10(data$P)
  plt <- ggplot(data, aes(x = .data$LOG10P)) +
    ggplot2::geom_histogram(
      bins = 50, fill = colors[1], color = "white", linewidth = 0.2
    ) +
    labs(x = expression(-log[10](italic(p))),
         y = "Count",
         title = "P-value Distribution") +
    theme_gwas()
  plt
}

#' Create summary statistics panel
#' @noRd
.make_stats_panel <- function(data, genome_wide, suggestive) {
  n_total <- nrow(data)
  n_gw <- sum(data$P < genome_wide, na.rm = TRUE)
  n_sug <- sum(data$P < suggestive, na.rm = TRUE)
  lambda <- calc_lambda(data$P)
  min_p <- min(data$P, na.rm = TRUE)
  n_chr <- length(unique(data$CHR))

  stats_text <- paste0(
    "Total variants: ", format(n_total, big.mark = ","), "\n",
    "Chromosomes: ", n_chr, "\n",
    "Lambda GC: ", sprintf("%.4f", lambda), "\n",
    "Min p-value: ", formatC(min_p, format = "e", digits = 2), "\n",
    "Genome-wide sig: ", n_gw, "\n",
    "Suggestive: ", n_sug
  )

  ggplot() +
    ggplot2::theme_void() +
    ggplot2::annotate("text", x = 0.5, y = 0.5, label = stats_text,
                      hjust = 0.5, vjust = 0.5, size = 3.5,
                      family = "mono") +
    labs(title = "Summary")
}
