#' Manhattan plot
#'
#' Create a genome-wide Manhattan plot from GWAS summary statistics.
#' Returns a ggplot2 object for further customization.
#'
#' @param data A `gwas_data` object or data.frame with GWAS results.
#' @param chr,bp,p,snp Column name overrides (auto-detected if NULL).
#' @param colors Two-color vector for alternating chromosomes.
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param genome_wide Genome-wide significance threshold (p-value).
#' @param suggestive Suggestive significance threshold.
#' @param threshold_colors Colors for significance lines.
#' @param highlight_snps Character vector of SNP IDs to highlight.
#' @param highlight_color Color for highlighted SNPs.
#' @param highlight_size Size for highlighted points.
#' @param label_snps Character vector of SNP IDs to label.
#' @param label_top_n Label the top N most significant SNPs.
#' @param label_column Column to use for label text.
#' @param downsample Enable smart downsampling for large datasets.
#' @param downsample_n Target number of points after downsampling.
#' @param chromosomes Subset of chromosomes to plot (integer vector).
#' @param chr_labels Custom chromosome labels. Options: NULL (all labels),
#'   `"odd"` (only odd-numbered chromosomes labeled), or a character
#'   vector of labels (same length as displayed chromosomes).
#' @param y_limit Upper y-axis limit for -log10(p).
#' @param y_truncate Break the y-axis to cut out a middle region. Either
#'   a single value (break point, resumes at max value) or a vector of
#'   two values `c(break_from, resume_at)` defining the cut range in
#'   -log10(p) units. For example, `y_truncate = c(15, 50)` shows 0-15
#'   at full scale, cuts 15-50, then shows 50+ above the break.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#'
#' # Basic Manhattan plot
#' manhattan_plot(example_gwas)
#'
#' # Label top hits with a different palette
#' manhattan_plot(example_gwas, label_top_n = 5, colors = gwas_palette("vibrant"))
#'
#' # Nature journal style
#' manhattan_plot(example_gwas, label_top_n = 3) + theme_nature()
#'
#' # Lancet palette with Science theme
#' manhattan_plot(example_gwas, colors = gwas_palette("lancet")) + theme_science()
#'
#' # Subset chromosomes
#' manhattan_plot(example_gwas, chromosomes = 1:10)
#'
#' # NEJM palette
#' manhattan_plot(example_gwas, colors = gwas_palette("nejm"), label_top_n = 3)
#'
#' # Broken y-axis: cut 10-50, show 0-10 and 50+
#' manhattan_plot(example_gwas, y_truncate = c(10, 50))
#'
#' # Single value: auto-detect resume point
#' manhattan_plot(example_gwas, y_truncate = 10)
#'
#' # Custom significance threshold (Bonferroni for 500k SNPs)
#' manhattan_plot(example_gwas, genome_wide = 0.05 / 500000)
#'
#' # No threshold lines
#' manhattan_plot(example_gwas, genome_wide = NULL, suggestive = NULL)
#'
#' # Label only odd chromosomes (less crowded x-axis)
#' manhattan_plot(example_gwas, chr_labels = "odd")
manhattan_plot <- function(data,
                           chr = NULL,
                           bp = NULL,
                           p = NULL,
                           snp = NULL,
                           colors = c("#1A5276", "#76D7C4"),
                           point_size = 0.8,
                           alpha = 1,
                           genome_wide = 5e-8,
                           suggestive = 1e-5,
                           threshold_colors = c("#E74C3C", "#3498DB"),
                           highlight_snps = NULL,
                           highlight_color = "#E74C3C",
                           highlight_size = 2,
                           label_snps = NULL,
                           label_top_n = NULL,
                           label_column = "SNP",
                           downsample = TRUE,
                           downsample_n = 200000,
                           chromosomes = NULL,
                           chr_labels = NULL,
                           y_limit = NULL,
                           y_truncate = NULL,
                           title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }

  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!is.null(chromosomes)) {
    data <- data[data$CHR %in% chromosomes, , drop = FALSE]
  }

  if (downsample && nrow(data) > downsample_n) {
    cli_inform("Downsampling from {format(nrow(data), big.mark = ',')} to ~{format(downsample_n, big.mark = ',')} points.")
    data <- smart_downsample(data, target_n = downsample_n,
                             keep_snps = c(highlight_snps, label_snps))
  }

  data$LOG10P <- -log10(data$P)
  data <- add_cumulative_bp(data)
  chr_info <- attr(data, "chr_info")
  data$CHR_F <- factor(data$CHR)

  if (is.null(chr_labels)) {
    chr_labels <- int_to_chr(chr_info$CHR)
  } else if (identical(chr_labels, "odd")) {
    chr_labels <- int_to_chr(chr_info$CHR)
    chr_labels[seq(2, length(chr_labels), by = 2)] <- ""
  }
  n_chr_displayed <- nrow(chr_info)

  plt <- ggplot(data, aes(x = .data$BP_CUM, y = .data$LOG10P,
                           color = .data$CHR_F)) +
    geom_point(size = point_size, alpha = alpha, shape = 16)

  plt <- plt +
    scale_color_chromosome(colors = colors, guide = "none") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = chr_labels,
      expand = c(0.01, 0)
    ) +
    labs(x = "Chromosome",
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas()

  if (!is.null(genome_wide)) {
    plt <- plt + geom_hline(
      yintercept = -log10(genome_wide),
      linetype = "dashed", color = threshold_colors[1], linewidth = 0.4
    )
  }
  if (!is.null(suggestive)) {
    plt <- plt + geom_hline(
      yintercept = -log10(suggestive),
      linetype = "dotted", color = threshold_colors[2], linewidth = 0.4
    )
  }

  if (!is.null(highlight_snps) && "SNP" %in% names(data)) {
    hl <- data[data$SNP %in% highlight_snps, , drop = FALSE]
    if (nrow(hl) > 0) {
      plt <- plt + geom_point(
        data = hl,
        aes(x = .data$BP_CUM, y = .data$LOG10P),
        color = highlight_color, size = highlight_size, shape = 16,
        inherit.aes = FALSE
      )
    }
  }

  label_data <- NULL
  if (!is.null(label_snps) && "SNP" %in% names(data)) {
    label_data <- data[data$SNP %in% label_snps, , drop = FALSE]
  }
  if (!is.null(label_top_n)) {
    top <- data[order(data$P), , drop = FALSE]
    top <- utils::head(top, label_top_n)
    label_data <- if (is.null(label_data)) top else rbind(label_data, top)
  }

  if (!is.null(label_data) && nrow(label_data) > 0 && label_column %in% names(label_data)) {
    label_data <- label_data[!duplicated(label_data[[label_column]]), , drop = FALSE]
    plt <- plt + ggrepel::geom_text_repel(
      data = label_data,
      aes(x = .data$BP_CUM, y = .data$LOG10P, label = .data[[label_column]]),
      inherit.aes = FALSE,
      size = 3, max.overlaps = 20, segment.color = "grey50",
        min.segment.length = 0, nudge_y = 10, box.padding = 0.8,
        force = 10, force_pull = 0.5
    )
  }

  if (!is.null(y_truncate)) {
    if (length(y_truncate) == 1) {
      break_from <- y_truncate
      max_val <- max(data$LOG10P, na.rm = TRUE)
      resume_at <- ceiling(max_val / 10) * 10
    } else {
      break_from <- y_truncate[1]
      resume_at <- y_truncate[2]
    }

    max_val <- max(data$LOG10P, na.rm = TRUE)
    max_label <- ceiling(max_val / 10) * 10
    top_height <- break_from * 0.25
    gap <- top_height * 0.15

    data_below <- data[data$LOG10P <= break_from, , drop = FALSE]
    data_above <- data[data$LOG10P >= resume_at, , drop = FALSE]
    data_below$LOG10P_plot <- data_below$LOG10P
    if (nrow(data_above) > 0) {
      above_range <- max(max_val - resume_at, 1)
      data_above$LOG10P_plot <- break_from + gap +
        (data_above$LOG10P - resume_at) / above_range * (top_height - gap)
    }
    data <- rbind(data_below, data_above)

    y_top <- break_from + top_height * 1.15

    breaks_below <- scales::breaks_pretty(n = 4)(c(0, break_from))
    breaks_below <- breaks_below[breaks_below < break_from]
    breaks_above_real <- max_label
    above_range <- max(max_val - resume_at, 1)
    breaks_above_plot <- break_from + gap +
      (breaks_above_real - resume_at) / above_range * (top_height - gap)
    all_breaks_real <- c(breaks_below, breaks_above_real)
    all_breaks_plot <- c(breaks_below, breaks_above_plot)

    plt <- ggplot(data, aes(x = .data$BP_CUM, y = .data$LOG10P_plot,
                             color = .data$CHR_F)) +
      geom_point(size = point_size, alpha = alpha, shape = 16) +
      scale_color_chromosome(colors = colors, guide = "none") +
      scale_x_continuous(
        breaks = chr_info$center, labels = chr_labels, expand = c(0.01, 0)
      ) +
      scale_y_continuous(
        breaks = all_breaks_plot, labels = all_breaks_real,
        expand = c(0.02, 0)
      ) +
      labs(x = "Chromosome", y = expression(-log[10](italic(p))), title = title) +
      theme_gwas()

    if (!is.null(genome_wide)) {
      gw_val <- -log10(genome_wide)
      if (gw_val <= break_from) {
        plt <- plt + geom_hline(yintercept = gw_val,
          linetype = "dashed", color = threshold_colors[1], linewidth = 0.4)
      }
    }
    if (!is.null(suggestive)) {
      sug_val <- -log10(suggestive)
      if (sug_val <= break_from) {
        plt <- plt + geom_hline(yintercept = sug_val,
          linetype = "dotted", color = threshold_colors[2], linewidth = 0.4)
      }
    }

    if (!is.null(label_data) && nrow(label_data) > 0 && label_column %in% names(label_data)) {
      label_data <- label_data[label_data$LOG10P <= break_from |
                               label_data$LOG10P >= resume_at, , drop = FALSE]
      label_data$LOG10P_plot <- ifelse(
        label_data$LOG10P <= break_from,
        label_data$LOG10P,
        break_from + gap + (label_data$LOG10P - resume_at) /
          above_range * (top_height - gap)
      )
      label_data <- label_data[!duplicated(label_data[[label_column]]), , drop = FALSE]
      plt <- plt + ggrepel::geom_text_repel(
        data = label_data,
        aes(x = .data$BP_CUM, y = .data$LOG10P_plot, label = .data[[label_column]]),
        inherit.aes = FALSE,
        size = 3, max.overlaps = 20, segment.color = "grey50",
        min.segment.length = 0, nudge_y = 10, box.padding = 0.8,
        force = 10, force_pull = 0.5
      )
    }

    y_frac_break <- break_from / y_top

    break_grob <- grid::grobTree(
      grid::rectGrob(
        x = grid::unit(0, "npc"),
        y = grid::unit(y_frac_break, "npc"),
        width = grid::unit(12, "mm"),
        height = grid::unit(10, "mm"),
        just = "centre",
        gp = grid::gpar(fill = "white", col = NA)
      ),
      grid::segmentsGrob(
        x0 = grid::unit(0, "npc") - grid::unit(4, "mm"),
        x1 = grid::unit(0, "npc") + grid::unit(4, "mm"),
        y0 = grid::unit(y_frac_break, "npc") + grid::unit(0.5, "mm"),
        y1 = grid::unit(y_frac_break, "npc") + grid::unit(3.5, "mm"),
        gp = grid::gpar(col = "black", lwd = 2.5)
      ),
      grid::segmentsGrob(
        x0 = grid::unit(0, "npc") - grid::unit(4, "mm"),
        x1 = grid::unit(0, "npc") + grid::unit(4, "mm"),
        y0 = grid::unit(y_frac_break, "npc") - grid::unit(3.5, "mm"),
        y1 = grid::unit(y_frac_break, "npc") - grid::unit(0.5, "mm"),
        gp = grid::gpar(col = "black", lwd = 2.5)
      )
    )

    plt <- plt +
      coord_cartesian(ylim = c(0, y_top), clip = "off") +
      annotation_custom(break_grob)
  } else if (!is.null(y_limit)) {
    plt <- plt + coord_cartesian(ylim = c(0, y_limit))
  }

  plt
}
