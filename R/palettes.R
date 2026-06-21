#' GWAS Color Palettes
#'
#' Pre-defined color palettes optimized for GWAS visualizations.
#' All palettes are colorblind-friendly by default.
#'
#' @param name Palette name. One of: "default", "colorblind", "vibrant",
#'   "pastel", "dark", "nature", "science", "lancet", "nejm", "aaas",
#'   "brewer_set1", "brewer_set2", "brewer_paired", "brewer_dark2".
#' @param n Number of colors to return. If NULL, returns the full palette.
#' @param type For chromosome palettes: "alternating" (2 colors) or
#'   "distinct" (one per chromosome).
#' @return A character vector of hex colors.
#' @export
#' @examples
#' gwas_palette("colorblind")
#' gwas_palette("nature", n = 5)
#' manhattan_plot(example_gwas, colors = gwas_palette("vibrant"))
gwas_palette <- function(name = "default", n = NULL, type = "alternating") {
  pal <- switch(name,
    "default" = c("#2C3E50", "#7F8C8D"),
    "colorblind" = c("#0072B2", "#E69F00"),
    "vibrant" = c("#E64B35", "#4DBBD5"),
    "pastel" = c("#8DA0CB", "#FC8D62"),
    "dark" = c("#1B1B1B", "#666666"),
    "nature" = .pal_journal("nature"),
    "science" = .pal_journal("science"),
    "lancet" = .pal_journal("lancet"),
    "nejm" = .pal_journal("nejm"),
    "aaas" = .pal_journal("aaas"),
    "brewer_set1" = RColorBrewer::brewer.pal(9, "Set1"),
    "brewer_set2" = RColorBrewer::brewer.pal(8, "Set2"),
    "brewer_paired" = RColorBrewer::brewer.pal(12, "Paired"),
    "brewer_dark2" = RColorBrewer::brewer.pal(8, "Dark2"),
    cli_abort("Unknown palette: {.val {name}}. See {.fun gwas_palette} for options.")
  )

  if (type == "alternating" && length(pal) > 2 &&
      name %in% c("default", "colorblind", "vibrant", "pastel", "dark")) {
    pal <- pal[1:2]
  }

  if (!is.null(n)) {
    if (n <= length(pal)) {
      pal <- pal[seq_len(n)]
    } else {
      pal <- grDevices::colorRampPalette(pal)(n)
    }
  }

  pal
}

#' List available GWAS palettes
#'
#' @return A character vector of palette names.
#' @export
#' @examples
#' gwas_palettes()
gwas_palettes <- function() {
  c("default", "colorblind", "vibrant", "pastel", "dark",
    "nature", "science", "lancet", "nejm", "aaas",
    "brewer_set1", "brewer_set2", "brewer_paired", "brewer_dark2")
}

#' Journal-inspired color palettes
#' @noRd
.pal_journal <- function(journal) {
  switch(journal,
    "nature" = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488",
                 "#F39B7F", "#8491B4", "#91D1C2", "#DC0000",
                 "#7E6148", "#B09C85"),
    "science" = c("#3B4992", "#EE0000", "#008B45", "#631879",
                  "#008280", "#BB0021", "#5F559B", "#A20056",
                  "#808180", "#1B1919"),
    "lancet" = c("#00468B", "#ED0000", "#42B540", "#0099B4",
                 "#925E9F", "#FDAF91", "#AD002A", "#ADB6B6",
                 "#1B1919"),
    "nejm" = c("#BC3C29", "#0072B5", "#E18727", "#20854E",
               "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97"),
    "aaas" = c("#3B4992", "#EE0000", "#008B45", "#631879",
               "#008280", "#BB0021", "#5F559B", "#A20056",
               "#808180", "#1B1919")
  )
}

#' Colorblind-safe chromosome color scale
#'
#' Scale using colorblind-friendly alternating colors for chromosomes.
#'
#' @param palette Palette name from [gwas_palette()].
#' @param ... Additional arguments passed to [ggplot2::scale_color_manual()].
#' @return A ggplot2 color scale.
#' @export
scale_color_gwas <- function(palette = "colorblind", ...) {
  colors <- gwas_palette(palette)
  n_chr <- 26
  chr_colors <- rep_len(colors, n_chr)
  names(chr_colors) <- as.character(seq_len(n_chr))
  scale_color_manual(values = chr_colors, ...)
}

#' @rdname scale_color_gwas
#' @export
scale_fill_gwas <- function(palette = "colorblind", ...) {
  colors <- gwas_palette(palette)
  n_chr <- 26
  chr_colors <- rep_len(colors, n_chr)
  names(chr_colors) <- as.character(seq_len(n_chr))
  scale_fill_manual(values = chr_colors, ...)
}
