#' Add highlighted regions to a Manhattan plot
#'
#' Draws colored rectangular bands behind specified genomic regions.
#' Useful for marking known GWAS loci, MHC region, or custom regions
#' of interest.
#'
#' @param plt A ggplot object from [manhattan_plot()] or similar.
#' @param regions A data.frame with columns: `chr` (integer), `start`, `end`.
#'   Optional: `label`, `color`, `alpha`.
#' @param color Default fill color for regions (if not specified per region).
#' @param alpha Default transparency.
#' @param label_size Font size for region labels.
#' @param label_y Y-axis position for labels ("top" or numeric value).
#' @param border If TRUE, draw a border around regions.
#' @param border_color Border color.
#' @return The ggplot object with region highlights added.
#' @export
#' @examples
#' data(example_gwas)
#' plt <- manhattan_plot(example_gwas)
#' regions <- data.frame(
#'   chr = c(6, 1), start = c(25e6, 5e6), end = c(35e6, 20e6),
#'   label = c("MHC", "1p36")
#' )
#' highlight_regions(plt, regions)
highlight_regions <- function(plt,
                              regions,
                              color = "#FFD700",
                              alpha = 0.15,
                              label_size = 2.5,
                              label_y = "top",
                              border = FALSE,
                              border_color = "grey40") {

  if (!inherits(plt, "ggplot")) {
    cli_abort("{.arg plt} must be a ggplot object (e.g., from manhattan_plot()).")
  }

  regions$chr <- chr_to_int(regions$chr)

  if (!"color" %in% names(regions)) regions$color <- color
  if (!"alpha" %in% names(regions)) regions$alpha <- alpha

  build <- ggplot2::ggplot_build(plt)
  y_range <- build$layout$panel_params[[1]]$y.range
  y_max <- y_range[2]

  plot_data <- build$data[[1]]
  if ("x" %in% names(plot_data)) {
    all_x <- plot_data$x
    all_groups <- plot_data$colour

    chr_info <- .extract_chr_info_from_plot(plt)
  }

  for (i in seq_len(nrow(regions))) {
    r <- regions[i, ]

    x_start <- .chr_bp_to_cum(r$chr, r$start, plt)
    x_end <- .chr_bp_to_cum(r$chr, r$end, plt)

    if (is.na(x_start) || is.na(x_end)) next

    rect_df <- data.frame(
      xmin = x_start, xmax = x_end,
      ymin = -Inf, ymax = Inf
    )

    plt <- plt + geom_rect(
      data = rect_df,
      aes(xmin = .data$xmin, xmax = .data$xmax,
          ymin = .data$ymin, ymax = .data$ymax),
      fill = r$color, alpha = r$alpha,
      inherit.aes = FALSE
    )

    if (border) {
      plt <- plt + geom_rect(
        data = rect_df,
        aes(xmin = .data$xmin, xmax = .data$xmax,
            ymin = .data$ymin, ymax = .data$ymax),
        fill = NA, color = border_color, linewidth = 0.3,
        inherit.aes = FALSE
      )
    }

    if ("label" %in% names(regions) && !is.na(r$label)) {
      label_ypos <- if (is.character(label_y) && label_y == "top") {
        y_max * 0.95
      } else {
        as.numeric(label_y)
      }

      label_df <- data.frame(
        x = (x_start + x_end) / 2,
        y = label_ypos,
        label = r$label
      )

      plt <- plt + ggplot2::geom_text(
        data = label_df,
        aes(x = .data$x, y = .data$y, label = .data$label),
        size = label_size, fontface = "bold", color = "grey30",
        inherit.aes = FALSE
      )
    }
  }

  plt
}

#' Convert chr + bp to cumulative x position from a Manhattan plot
#' @noRd
.chr_bp_to_cum <- function(chr, bp, plt) {
  build <- ggplot2::ggplot_build(plt)
  x_breaks <- build$layout$panel_params[[1]]$x$breaks
  x_labels <- build$layout$panel_params[[1]]$x$get_labels()

  if (is.null(x_labels) || is.null(x_breaks)) return(NA_real_)

  chr_label <- int_to_chr(chr)
  chr_idx <- which(x_labels == chr_label)
  if (length(chr_idx) == 0) return(NA_real_)

  chr_center <- x_breaks[chr_idx]

  data_layer <- build$data[[1]]
  chr_points_x <- data_layer$x[abs(data_layer$x - chr_center) <
                                  (diff(range(data_layer$x, na.rm = TRUE)) /
                                   length(x_breaks))]
  chr_points_x <- chr_points_x[!is.na(chr_points_x)]

  if (length(chr_points_x) == 0) return(chr_center)

  chr_min_x <- min(chr_points_x)
  chr_max_x <- max(chr_points_x)
  chr_width <- chr_max_x - chr_min_x

  if (is.na(chr_width) || chr_width == 0) return(chr_center)

  frac <- bp / (diff(range(data_layer$x)) / length(x_breaks) * 2)
  chr_min_x + frac * chr_width
}

#' @noRd
.extract_chr_info_from_plot <- function(plt) {
  build <- ggplot2::ggplot_build(plt)
  list(
    breaks = build$layout$panel_params[[1]]$x$breaks,
    labels = build$layout$panel_params[[1]]$x$get_labels()
  )
}
