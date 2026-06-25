#' Journal-specific themes for GWAS plots
#'
#' Publication-ready themes matching the figure style guides of major
#' journals. Each theme sets appropriate font family, sizes, line
#' weights, and spacing.
#'
#' @param base_size Base font size in pt.
#' @param base_family Base font family.
#' @return A ggplot2 theme object.
#' @name journal_themes
NULL

#' @rdname journal_themes
#' @details
#' `theme_nature()`: Helvetica/Arial 5-7 pt, minimal gridlines, thin
#' axes (0.25 pt), compact margins. Matches Nature's requirement for
#' figures at 89 mm (single column) or 183 mm (double column) width.
#' @export
#' @examples
#' data(example_gwas)
#' manhattan_plot(example_gwas) + theme_nature()
theme_nature <- function(base_size = 7, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_line(linewidth = 0.15, color = "grey90"),
      axis.line = element_line(linewidth = 0.25, color = "black"),
      axis.ticks = element_line(linewidth = 0.25, color = "black"),
      axis.ticks.length = ggplot2::unit(1, "mm"),
      axis.text = element_text(size = base_size - 1, color = "black"),
      axis.title = element_text(size = base_size, face = "plain"),
      plot.title = element_text(size = base_size + 1, face = "bold"),
      legend.position = "right",
      legend.key.size = ggplot2::unit(3, "mm"),
      legend.text = element_text(size = base_size - 1),
      legend.title = element_text(size = base_size, face = "plain"),
      plot.margin = ggplot2::margin(2, 2, 2, 2)
    )
}

#' @rdname journal_themes
#' @details
#' `theme_science()`: Helvetica 6-8 pt, classic axes (no panel border),
#' thicker axis lines (0.5 pt), no grid. Science figures are narrow
#' (55 mm single, 120 mm double, 174 mm full width).
#' @export
theme_science <- function(base_size = 8, base_family = "") {
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.line = element_line(linewidth = 0.5, color = "black"),
      axis.ticks = element_line(linewidth = 0.4, color = "black"),
      axis.ticks.length = ggplot2::unit(1.5, "mm"),
      axis.text = element_text(size = base_size - 1, color = "black"),
      axis.title = element_text(size = base_size, face = "plain"),
      plot.title = element_text(size = base_size + 1, face = "bold"),
      legend.position = "right",
      panel.grid = element_blank()
    )
}

#' @rdname journal_themes
#' @details
#' `theme_plos()`: Arial 8-12 pt (larger than Nature/Science), panel
#' border, centered title. PLOS requires figures at 13.2 cm single
#' column width, 300 dpi minimum.
#' @export
theme_plos <- function(base_size = 10, base_family = "") {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = ggplot2::element_rect(linewidth = 0.5, color = "black",
                                           fill = NA),
      axis.text = element_text(size = base_size - 1, color = "black"),
      axis.title = element_text(size = base_size),
      plot.title = element_text(size = base_size + 1, face = "bold",
                                hjust = 0.5),
      legend.position = "right"
    )
}

#' @rdname journal_themes
#' @details
#' `theme_cell()`: Arial 6-8 pt, minimalist with very thin axes
#' (0.2 pt), no grid, tight margins. Cell Press figures use 85 mm
#' single and 178 mm full width.
#' @export
theme_cell <- function(base_size = 7, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.line = element_line(linewidth = 0.2, color = "black"),
      axis.ticks = element_line(linewidth = 0.15, color = "black"),
      axis.ticks.length = ggplot2::unit(0.8, "mm"),
      axis.text = element_text(size = base_size - 1, color = "black"),
      axis.title = element_text(size = base_size),
      plot.title = element_text(size = base_size + 1, face = "bold"),
      legend.position = "right",
      plot.margin = ggplot2::margin(1, 1, 1, 1)
    )
}

#' @rdname journal_themes
#' @details
#' `theme_presentation()`: Large fonts (16 pt base), thick axes,
#' high contrast for slides projected at a distance.
#' @export
theme_presentation <- function(base_size = 16, base_family = "") {
 ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(linewidth = 0.8, color = "black"),
      axis.ticks = element_line(linewidth = 0.5, color = "black"),
      axis.text = element_text(size = base_size * 0.85),
      axis.title = element_text(size = base_size, face = "bold"),
      plot.title = element_text(size = base_size * 1.3, face = "bold"),
      legend.text = element_text(size = base_size * 0.8),
      legend.title = element_text(size = base_size * 0.9, face = "bold"),
      legend.position = "right"
    )
}

#' @rdname journal_themes
#' @details
#' `theme_poster()`: Extra-large fonts (20 pt base), thick axes,
#' readable from 1-2 meters at a conference poster.
#' @export
theme_poster <- function(base_size = 20, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(linewidth = 1, color = "black"),
      axis.ticks = element_line(linewidth = 0.7, color = "black"),
      axis.text = element_text(size = base_size * 0.85),
      axis.title = element_text(size = base_size, face = "bold"),
      plot.title = element_text(size = base_size * 1.4, face = "bold"),
      legend.text = element_text(size = base_size * 0.75),
      legend.position = "right"
    )
}

#' GWAS plot presets
#'
#' Apply a preset configuration to any ggwas function. Presets combine
#' a theme, color palette, and sizing appropriate for the context.
#'
#' @param preset One of: "publication", "presentation", "poster", "exploratory".
#' @return A list with components: `theme`, `colors`, `point_size`, `alpha`,
#'   `label_size`.
#' @export
#' @examples
#' p <- gwas_preset("publication")
#' manhattan_plot(example_gwas, colors = p$colors, point_size = p$point_size) +
#'   p$theme
gwas_preset <- function(preset = "publication") {
  switch(preset,
    "publication" = list(
      theme = theme_nature(),
      colors = gwas_palette("colorblind"),
      point_size = 0.6,
      alpha = 1,
      label_size = 2.5
    ),
    "presentation" = list(
      theme = theme_presentation(),
      colors = gwas_palette("vibrant"),
      point_size = 1.5,
      alpha = 0.9,
      label_size = 4
    ),
    "poster" = list(
      theme = theme_poster(),
      colors = gwas_palette("vibrant"),
      point_size = 2,
      alpha = 0.9,
      label_size = 5
    ),
    "exploratory" = list(
      theme = theme_gwas(),
      colors = gwas_palette("default"),
      point_size = 0.8,
      alpha = 0.7,
      label_size = 3
    ),
    cli_abort("Unknown preset: {.val {preset}}. Options: publication, presentation, poster, exploratory.")
  )
}
