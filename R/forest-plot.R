#' Forest plot of effect estimates
#'
#' Draw a forest plot of effect estimates with confidence intervals, for
#' example to compare a variant across cohorts, several lead variants from
#' one study, or meta-analysis inputs. Estimates and standard errors are
#' turned into confidence intervals; optionally the effects are exponentiated
#' to display odds or hazard ratios.
#'
#' @param data A data.frame (or `gwas_data`) with effect and standard-error
#'   columns.
#' @param effect,se Column names for the effect estimate and its standard
#'   error.
#' @param label Column used for the row labels. Defaults to `SNP` when
#'   present, otherwise the row index.
#' @param group Optional grouping column (e.g. cohort); groups are colored and
#'   offset within each label.
#' @param ci Confidence level for the intervals (default 0.95).
#' @param exponentiate If TRUE, plot `exp(effect)` on a log axis (odds/hazard
#'   ratios) and default the reference line to 1.
#' @param ref_line Position of the vertical reference line.
#' @param order_by Order rows by `"none"`, `"effect"`, or `"label"`.
#' @param colors Optional colors for groups.
#' @param point_size Point size.
#' @param x_label Optional x-axis label.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' df <- data.frame(
#'   SNP = c("rs1", "rs2", "rs3", "rs4"),
#'   BETA = c(0.20, -0.10, 0.35, 0.05),
#'   SE = c(0.05, 0.04, 0.08, 0.03)
#' )
#' forest_plot(df)
#'
#' # Odds ratios, ordered by effect
#' forest_plot(df, exponentiate = TRUE, order_by = "effect")
forest_plot <- function(data,
                        effect = "BETA",
                        se = "SE",
                        label = NULL,
                        group = NULL,
                        ci = 0.95,
                        exponentiate = FALSE,
                        ref_line = if (exponentiate) 1 else 0,
                        order_by = c("none", "effect", "label"),
                        colors = NULL,
                        point_size = 2.5,
                        x_label = NULL,
                        title = NULL) {

  order_by <- match.arg(order_by)
  data <- as.data.frame(data)

  # Resolve default column names case-insensitively (e.g. lowercase headers).
  if (missing(effect) && !effect %in% names(data)) {
    effect <- .na_null(.match_col(names(data), .beta_patterns)) %||% effect
  }
  if (missing(se) && !se %in% names(data)) {
    se <- .na_null(.match_col(names(data), .se_patterns)) %||% se
  }
  if (!effect %in% names(data)) cli_abort("Column {.field {effect}} not found.")
  if (!se %in% names(data)) cli_abort("Column {.field {se}} not found.")

  if (is.null(label)) label <- .na_null(.match_col(names(data), .snp_patterns))

  d <- data.frame(
    label = if (is.null(label)) as.character(seq_len(nrow(data))) else as.character(data[[label]]),
    est = data[[effect]],
    se = data[[se]],
    stringsAsFactors = FALSE
  )
  d$group <- if (!is.null(group) && group %in% names(data)) {
    as.character(data[[group]])
  } else {
    NA_character_
  }
  d <- d[!is.na(d$est) & !is.na(d$se), , drop = FALSE]
  if (nrow(d) == 0) cli_abort("No rows with non-missing {.field {effect}} and {.field {se}}.")

  z <- stats::qnorm(1 - (1 - ci) / 2)
  d$lo <- d$est - z * d$se
  d$hi <- d$est + z * d$se
  if (exponentiate) {
    d$est <- exp(d$est)
    d$lo <- exp(d$lo)
    d$hi <- exp(d$hi)
  }

  lev <- if (order_by == "effect") {
    unique(d$label[order(d$est)])
  } else if (order_by == "label") {
    sort(unique(d$label), decreasing = TRUE)
  } else {
    rev(unique(d$label))
  }
  d$label <- factor(d$label, levels = lev)

  has_group <- any(!is.na(d$group))
  dodge <- ggplot2::position_dodge(width = 0.6)
  pos <- if (has_group) dodge else "identity"

  if (has_group) {
    base_aes <- aes(x = .data$est, y = .data$label, color = .data$group)
    seg_aes  <- aes(x = .data$lo, xend = .data$hi, y = .data$label,
                    yend = .data$label, color = .data$group)
  } else {
    base_aes <- aes(x = .data$est, y = .data$label)
    seg_aes  <- aes(x = .data$lo, xend = .data$hi, y = .data$label,
                    yend = .data$label)
  }

  plt <- ggplot(d, base_aes) +
    ggplot2::geom_vline(xintercept = ref_line, linetype = "dashed",
                        color = "grey50") +
    geom_segment(seg_aes, position = pos, linewidth = 0.6) +
    geom_point(size = point_size, position = pos) +
    labs(
      x = if (!is.null(x_label)) x_label
          else if (exponentiate) "Effect (ratio, log scale)"
          else expression(hat(beta) ~ "(CI)"),
      y = NULL, color = group, title = title
    ) +
    theme_gwas()

  if (exponentiate) plt <- plt + ggplot2::scale_x_log10()
  if (has_group && !is.null(colors)) {
    plt <- plt + scale_color_manual(values = colors)
  }

  plt
}
