#' Trumpet plot: effect size versus allele frequency with power contours
#'
#' Plot per-variant effect sizes against minor allele frequency and overlay
#' statistical-power ("detection") contours. The contours trace the smallest
#' effect a study of the given sample size can detect at a chosen significance
#' level and power, producing the characteristic trumpet shape that flares
#' toward rare variants. Points falling below all contours lie in the region
#' a study is underpowered to discover.
#'
#' The power model assumes an additive test on a standardized quantitative
#' trait (per-allele effect on a unit-variance scale). For each minor allele
#' frequency \eqn{f}, the minimum detectable effect is
#' \eqn{\beta_{min}(f) = \sqrt{\lambda / (2 N f (1 - f))}}, where the
#' non-centrality parameter \eqn{\lambda = (z_{\alpha} + z_{power})^2}.
#'
#' @param data A `gwas_data` object or data.frame with BETA and AF columns.
#' @param beta,af,p Column name overrides.
#' @param n Study sample size (single number). If NULL, taken from `n_col`
#'   or an `N` column (median).
#' @param n_col Name of a per-variant sample-size column.
#' @param sig_level Significance threshold for the power contours.
#' @param power Numeric vector of power levels to draw contours for.
#' @param signed If TRUE, plot signed effects (contours mirrored above and
#'   below zero); otherwise plot the absolute effect.
#' @param colors Named vector with "significant" and "nonsignificant" colors.
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param label_top_n Label the top N variants by significance.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#'
#' # Effect size versus MAF with 50% and 80% power contours
#' trumpet_plot(example_gwas, n = 50000)
#'
#' # Signed effects and a labelled top hit
#' trumpet_plot(example_gwas, n = 50000, signed = TRUE,
#'              p = "P", label_top_n = 3)
trumpet_plot <- function(data,
                         beta = NULL,
                         af = NULL,
                         p = NULL,
                         n = NULL,
                         n_col = NULL,
                         sig_level = 5e-8,
                         power = c(0.5, 0.8),
                         signed = FALSE,
                         colors = c(significant = "#E64B35",
                                    nonsignificant = "#BDC3C7"),
                         point_size = 1,
                         alpha = 0.5,
                         label_top_n = NULL,
                         title = NULL) {

  raw <- as.data.frame(data)
  bcol <- if (!is.null(beta)) beta else .na_null(.match_col(names(raw), .beta_patterns))
  acol <- if (!is.null(af)) af else .na_null(.match_col(names(raw), .af_patterns))
  pcol <- if (!is.null(p)) p else .na_null(.match_col(names(raw), .p_patterns))
  scol <- .na_null(.match_col(names(raw), .snp_patterns))
  if (is.null(bcol) || is.null(acol)) {
    cli_abort("Need effect and allele-frequency columns; specify via {.arg beta} and {.arg af}.")
  }

  if (is.null(n)) {
    if (!is.null(n_col) && n_col %in% names(raw)) {
      big_n <- stats::median(raw[[n_col]], na.rm = TRUE)
    } else if ("N" %in% names(raw)) {
      big_n <- stats::median(raw$N, na.rm = TRUE)
    } else {
      cli_abort("Provide {.arg n} (sample size) or a per-variant column via {.arg n_col}.")
    }
  } else {
    big_n <- n
  }

  data <- data.frame(
    BETA = raw[[bcol]],
    AF = raw[[acol]],
    P = if (!is.null(pcol)) raw[[pcol]] else NA_real_,
    SNP = if (!is.null(scol)) as.character(raw[[scol]]) else NA_character_,
    stringsAsFactors = FALSE
  )
  data <- data[!is.na(data$BETA) & !is.na(data$AF), , drop = FALSE]
  data$MAF <- pmin(data$AF, 1 - data$AF)
  data <- data[data$MAF > 0 & data$MAF <= 0.5, , drop = FALSE]
  if (nrow(data) == 0) cli_abort("No variants with usable effect and allele frequency.")

  data$Y <- if (signed) data$BETA else abs(data$BETA)
  data$sig <- ifelse(!is.na(data$P) & data$P < sig_level,
                     "significant", "nonsignificant")

  z_alpha <- stats::qnorm(1 - sig_level / 2)
  f_grid <- seq(min(data$MAF), 0.5, length.out = 200)
  curves <- do.call(rbind, lapply(power, function(pw) {
    ncp <- (z_alpha + stats::qnorm(pw))^2
    data.frame(
      MAF = f_grid,
      beta_min = sqrt(ncp / (2 * big_n * f_grid * (1 - f_grid))),
      power = factor(paste0(round(pw * 100), "% power")),
      stringsAsFactors = FALSE
    )
  }))

  plt <- ggplot() +
    geom_point(data = data,
               aes(x = .data$MAF, y = .data$Y, color = .data$sig),
               size = point_size, alpha = alpha, shape = 16) +
    ggplot2::geom_line(data = curves,
                       aes(x = .data$MAF, y = .data$beta_min,
                           linetype = .data$power),
                       color = "grey25", linewidth = 0.5)

  if (signed) {
    curves_neg <- curves
    curves_neg$beta_min <- -curves_neg$beta_min
    plt <- plt + ggplot2::geom_line(data = curves_neg,
      aes(x = .data$MAF, y = .data$beta_min, linetype = .data$power),
      color = "grey25", linewidth = 0.5)
  }

  plt <- plt +
    scale_color_manual(values = colors, name = "Significance",
      guide = guide_legend(override.aes = list(size = 3, alpha = 1))) +
    ggplot2::scale_x_log10(labels = scales::label_number()) +
    labs(x = "Minor allele frequency",
         y = if (signed) expression(hat(beta)) else expression("|" * hat(beta) * "|"),
         linetype = NULL, title = title) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  if (!is.null(label_top_n) && any(!is.na(data$P)) && any(!is.na(data$SNP))) {
    top <- utils::head(data[.order_by_p(data), ], label_top_n)
    # significant hits sit near y = 0; lift labels into the open space above
    y_hi <- max(data$Y, na.rm = TRUE)
    plt <- plt + .snp_repel(
      aes(x = .data$MAF, y = .data$Y, label = .data$SNP),
      data = top, ylim = c(y_hi * 0.3, NA)
    )
  }

  plt
}
