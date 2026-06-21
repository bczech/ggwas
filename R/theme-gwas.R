#' Minimal GWAS theme for ggplot2
#'
#' A clean, publication-ready theme optimized for GWAS plots.
#'
#' @param base_size Base font size (default 11).
#' @param base_family Base font family.
#' @return A ggplot2 theme object.
#' @export
theme_gwas <- function(base_size = 11, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line.y = element_line(colour = "grey30", linewidth = 0.3),
      axis.ticks.y = element_line(colour = "grey30", linewidth = 0.3),
      axis.text.x = element_text(size = base_size * 0.7, vjust = 0.5),
      plot.title = element_text(face = "bold", size = base_size * 1.2),
      legend.position = "none"
    )
}

#' Chromosome color scale
#'
#' Alternating color scale for chromosomes in Manhattan plots.
#'
#' @param colors Two-element character vector of alternating colors.
#' @param ... Additional arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 color scale.
#' @export
scale_color_chromosome <- function(colors = c("#1A5276", "#76D7C4"), ...) {
  n_chr <- 26
  chr_colors <- rep_len(colors, n_chr)
  names(chr_colors) <- as.character(seq_len(n_chr))
  scale_color_manual(values = chr_colors, ...)
}

#' @rdname scale_color_chromosome
#' @export
scale_fill_chromosome <- function(colors = c("#1A5276", "#76D7C4"), ...) {
  n_chr <- 26
  chr_colors <- rep_len(colors, n_chr)
  names(chr_colors) <- as.character(seq_len(n_chr))
  scale_fill_manual(values = chr_colors, ...)
}
