#' QQ plot for GWAS p-values
#'
#' Create a quantile-quantile plot with confidence bands and
#' genomic inflation factor.
#'
#' @param data A `gwas_data` object or data.frame, or a numeric vector of p-values.
#' @param p Column name for p-values (auto-detected if NULL).
#' @param ci Confidence level for bands (NULL to disable).
#' @param ci_fill Fill color for confidence band.
#' @param ci_alpha Transparency of confidence band.
#' @param show_lambda Show genomic inflation factor annotation.
#' @param lambda_position Position for lambda annotation: "topleft" or "bottomright".
#' @param group Column name to stratify QQ plot by groups.
#' @param point_size Point size.
#' @param point_color Point color (ignored if group is specified).
#' @param alpha Point transparency.
#' @param line_color Color of the identity line.
#' @param downsample Enable downsampling of dense lower-left region.
#' @param downsample_n Target number of points.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "gwasplot")
#' qq_plot(example_gwas)
#' qq_plot(example_gwas, show_lambda = TRUE)
qq_plot <- function(data,
                    p = NULL,
                    ci = 0.95,
                    ci_fill = "grey80",
                    ci_alpha = 0.3,
                    show_lambda = TRUE,
                    lambda_position = "topleft",
                    group = NULL,
                    point_size = 0.8,
                    point_color = "#2C3E50",
                    alpha = 1,
                    line_color = "#E74C3C",
                    downsample = TRUE,
                    downsample_n = 100000,
                    title = NULL) {

  if (is.numeric(data)) {
    pvals <- data
  } else {
    if (!inherits(data, "gwas_data") && !is.null(p)) {
      pvals <- data[[p]]
    } else if (inherits(data, "gwas_data")) {
      pvals <- data$P
    } else {
      data <- as_gwas_data(data, p = p)
      pvals <- data$P
    }
  }

  if (!is.null(group) && is.data.frame(data)) {
    return(.qq_grouped(data, group = group, ci = ci, ci_fill = ci_fill,
                       ci_alpha = ci_alpha, show_lambda = show_lambda,
                       point_size = point_size, alpha = alpha,
                       line_color = line_color, title = title))
  }

  pvals <- pvals[!is.na(pvals) & pvals > 0 & pvals <= 1]
  pvals <- sort(pvals)
  n <- length(pvals)

  observed <- -log10(pvals)
  expected <- -log10(stats::ppoints(n))

  qq_df <- data.frame(expected = expected, observed = observed)

  if (downsample && nrow(qq_df) > downsample_n) {
    sig_idx <- which(qq_df$observed > -log10(1e-3))
    rest_idx <- setdiff(seq_len(nrow(qq_df)), sig_idx)
    keep <- sort(c(sig_idx, sample(rest_idx, min(downsample_n, length(rest_idx)))))
    qq_df <- qq_df[keep, , drop = FALSE]
  }

  plt <- ggplot(qq_df, aes(x = .data$expected, y = .data$observed))

  if (!is.null(ci)) {
    ci_df <- .qq_ci_band(n, ci)
    plt <- plt + geom_ribbon(
      data = ci_df,
      aes(x = .data$expected, ymin = .data$lower, ymax = .data$upper),
      fill = ci_fill, alpha = ci_alpha, inherit.aes = FALSE
    )
  }

  plt <- plt +
    geom_abline(intercept = 0, slope = 1, color = line_color,
                linetype = "dashed", linewidth = 0.5) +
    geom_point(size = point_size, alpha = alpha, color = point_color, shape = 16) +
    labs(
      x = expression(Expected ~ -log[10](italic(p))),
      y = expression(Observed ~ -log[10](italic(p))),
      title = title
    ) +
    theme_gwas()

  if (show_lambda) {
    lambda <- calc_lambda(pvals)
    label_text <- bquote(lambda[GC] == .(sprintf("%.3f", lambda)))
    if (lambda_position == "topleft") {
      plt <- plt + ggplot2::annotate(
        "text", x = 0, y = max(qq_df$observed) * 0.95,
        label = as.expression(label_text), hjust = 0, size = 3.5
      )
    } else {
      plt <- plt + ggplot2::annotate(
        "text", x = max(qq_df$expected) * 0.7, y = max(qq_df$observed) * 0.1,
        label = as.expression(label_text), hjust = 0, size = 3.5
      )
    }
  }

  plt
}

#' Compute QQ confidence band
#' @noRd
.qq_ci_band <- function(n, ci = 0.95) {
  alpha_level <- (1 - ci) / 2
  expected <- -log10(stats::ppoints(n))
  i <- seq_len(n)
  lower <- -log10(qbeta(1 - alpha_level, i, n - i + 1))
  upper <- -log10(qbeta(alpha_level, i, n - i + 1))

  keep <- seq(1, n, length.out = min(n, 1000))
  data.frame(
    expected = expected[keep],
    lower = lower[keep],
    upper = upper[keep]
  )
}

#' Grouped QQ plot
#' @noRd
.qq_grouped <- function(data,
                        group,
                        ci,
                        ci_fill,
                        ci_alpha,
                        show_lambda,
                        point_size,
                        alpha,
                        line_color,
                        title) {
  groups <- unique(data[[group]])
  qq_list <- lapply(groups, function(g) {
    pvals <- data$P[data[[group]] == g]
    pvals <- pvals[!is.na(pvals) & pvals > 0 & pvals <= 1]
    pvals <- sort(pvals)
    n <- length(pvals)
    data.frame(
      expected = -log10(stats::ppoints(n)),
      observed = -log10(pvals),
      group = g
    )
  })
  qq_df <- do.call(rbind, qq_list)
  rownames(qq_df) <- NULL
  qq_df$group <- factor(qq_df$group)

  plt <- ggplot(qq_df, aes(x = .data$expected, y = .data$observed,
                            color = .data$group)) +
    geom_abline(intercept = 0, slope = 1, color = line_color,
                linetype = "dashed", linewidth = 0.5) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    labs(
      x = expression(Expected ~ -log[10](italic(p))),
      y = expression(Observed ~ -log[10](italic(p))),
      color = "Group",
      title = title
    ) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  plt
}
