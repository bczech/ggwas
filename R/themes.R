#' Journal-specific themes for GWAS plots
#'
#' Publication-ready themes matching the style guides of major journals.
#' Includes appropriate fonts, sizes, and spacing.
#'
#' @param base_size Base font size.
#' @param base_family Base font family. Defaults vary by journal.
#' @return A ggplot2 theme object.
#' @name journal_themes
NULL

#' @rdname journal_themes
#' @export
#' @examples
#' data(example_gwas)
#' manhattan_plot(example_gwas) + theme_nature()
theme_nature <- function(base_size = 7, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_line(linewidth = 0.2, color = "grey90"),
      axis.line = element_line(linewidth = 0.4, color = "black"),
      axis.ticks = element_line(linewidth = 0.3, color = "black"),
      axis.text = element_text(size = base_size, color = "black"),
      axis.title = element_text(size = base_size + 1, face = "bold"),
      plot.title = element_text(size = base_size + 2, face = "bold"),
      legend.position = "none",
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
}

#' @rdname journal_themes
#' @export
theme_science <- function(base_size = 8, base_family = "") {
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.line = element_line(linewidth = 0.5, color = "black"),
      axis.ticks = element_line(linewidth = 0.4, color = "black"),
      axis.text = element_text(size = base_size, color = "black"),
      axis.title = element_text(size = base_size + 1),
      plot.title = element_text(size = base_size + 2, face = "bold"),
      legend.position = "none",
      panel.grid = element_blank()
    )
}

#' @rdname journal_themes
#' @export
theme_plos <- function(base_size = 10, base_family = "") {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = ggplot2::element_rect(linewidth = 0.5, color = "black"),
      axis.text = element_text(size = base_size, color = "black"),
      axis.title = element_text(size = base_size + 1),
      plot.title = element_text(size = base_size + 2, face = "bold",
                                hjust = 0.5),
      legend.position = "none"
    )
}

#' @rdname journal_themes
#' @export
theme_cell <- function(base_size = 7, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.line = element_line(linewidth = 0.3, color = "black"),
      axis.ticks = element_line(linewidth = 0.2, color = "black"),
      axis.text = element_text(size = base_size, color = "black"),
      axis.title = element_text(size = base_size + 0.5),
      plot.title = element_text(size = base_size + 1.5, face = "bold"),
      legend.position = "none",
      plot.margin = ggplot2::margin(3, 3, 3, 3)
    )
}

#' @rdname journal_themes
#' @export
theme_presentation <- function(base_size = 16, base_family = "") {
 ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(linewidth = 0.6, color = "black"),
      axis.ticks = element_line(linewidth = 0.4, color = "black"),
      axis.text = element_text(size = base_size * 0.9),
      axis.title = element_text(size = base_size, face = "bold"),
      plot.title = element_text(size = base_size * 1.3, face = "bold"),
      legend.text = element_text(size = base_size * 0.8),
      legend.title = element_text(size = base_size * 0.9, face = "bold"),
      legend.position = "right"
    )
}

#' @rdname journal_themes
#' @export
theme_poster <- function(base_size = 20, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(linewidth = 0.8, color = "black"),
      axis.ticks = element_line(linewidth = 0.6, color = "black"),
      axis.text = element_text(size = base_size * 0.85),
      axis.title = element_text(size = base_size, face = "bold"),
      plot.title = element_text(size = base_size * 1.4, face = "bold"),
      legend.text = element_text(size = base_size * 0.75),
      legend.position = "right"
    )
}

#' GWAS plot presets
#'
#' Apply a preset configuration to any gwasplot function. Presets combine
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
