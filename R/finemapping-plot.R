#' Fine-mapping credible set plot
#'
#' A locus plot where point size encodes posterior inclusion probability
#' (PIP) from fine-mapping tools like SuSiE or FINEMAP. Credible set
#' membership is shown by color. This is the emerging standard for
#' visualizing fine-mapping results in GWAS publications.
#'
#' @param data A data.frame with at minimum CHR, BP, P columns, plus
#'   a PIP column (posterior inclusion probability, 0-1).
#' @param pip Column name for posterior inclusion probability.
#' @param credible_set Column name for credible set assignment (integer).
#'   Variants in the same set get the same color.
#' @param chr,bp,p,snp Column name overrides.
#' @param region_chr,region_start,region_end Region to plot.
#' @param lead_snp Center on this SNP ± flank.
#' @param flank Flank size in bp.
#' @param pip_min_size Minimum point size (for PIP ≈ 0).
#' @param pip_max_size Maximum point size (for PIP ≈ 1).
#' @param set_colors Colors for credible sets.
#' @param nonsig_color Color for variants not in any credible set.
#' @param show_pip_legend Show the PIP size legend.
#' @param label_pip_above Label variants with PIP above this value.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#' # Add simulated fine-mapping results
#' example_gwas$PIP <- runif(nrow(example_gwas))^4
#' example_gwas$PIP[which.min(example_gwas$P)] <- 0.95
#' example_gwas$credible_set <- NA
#' example_gwas$credible_set[example_gwas$PIP > 0.1] <- 1L
#' finemapping_plot(example_gwas, region_chr = 1,
#'                  region_start = 1e6, region_end = 50e6)
finemapping_plot <- function(data,
                             pip = "PIP",
                             credible_set = "credible_set",
                             chr = NULL,
                             bp = NULL,
                             p = NULL,
                             snp = NULL,
                             region_chr = NULL,
                             region_start = NULL,
                             region_end = NULL,
                             lead_snp = NULL,
                             flank = 500000,
                             pip_min_size = 0.3,
                             pip_max_size = 5,
                             set_colors = c("#E64B35", "#4DBBD5", "#00A087",
                                            "#3C5488", "#F39B7F"),
                             nonsig_color = "grey70",
                             show_pip_legend = TRUE,
                             label_pip_above = 0.5,
                             title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }
  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!pip %in% names(data)) {
    cli_abort("Column {.field {pip}} (posterior inclusion probability) not found.")
  }

  if (!is.null(lead_snp) && "SNP" %in% names(data)) {
    lead_row <- data[data$SNP == lead_snp, , drop = FALSE]
    if (nrow(lead_row) == 0) cli_abort("Lead SNP {.val {lead_snp}} not found.")
    region_chr <- lead_row$CHR[1]
    region_start <- lead_row$BP[1] - flank
    region_end <- lead_row$BP[1] + flank
  }

  if (is.null(region_chr)) cli_abort("Specify {.arg region_chr} or {.arg lead_snp}.")
  region_start <- max(region_start, 0)

  region <- data[data$CHR == region_chr &
                   data$BP >= region_start &
                   data$BP <= region_end, , drop = FALSE]

  if (nrow(region) == 0) cli_abort("No variants in specified region.")

  region$LOG10P <- -log10(region$P)
  region$pip_val <- region[[pip]]
  region$pip_val[is.na(region$pip_val)] <- 0

  has_cs <- credible_set %in% names(region)
  if (has_cs) {
    region$cs <- region[[credible_set]]
    region$cs_label <- ifelse(is.na(region$cs), "None",
                              paste("CS", region$cs))
    region$cs_label <- factor(region$cs_label,
                              levels = c(paste("CS", sort(unique(
                                region$cs[!is.na(region$cs)]))), "None"))
    cs_levels <- levels(region$cs_label)
    n_sets <- sum(cs_levels != "None")
    all_colors <- c(stats::setNames(set_colors[seq_len(n_sets)],
                                    cs_levels[cs_levels != "None"]),
                    None = nonsig_color)

    plt <- ggplot(region, aes(x = .data$BP / 1e6, y = .data$LOG10P,
                               size = .data$pip_val,
                               color = .data$cs_label)) +
      geom_point(alpha = 0.8) +
      scale_color_manual(values = all_colors, name = "Credible set")
  } else {
    plt <- ggplot(region, aes(x = .data$BP / 1e6, y = .data$LOG10P,
                               size = .data$pip_val)) +
      geom_point(alpha = 0.8, color = set_colors[1])
  }

  plt <- plt +
    ggplot2::scale_size_continuous(
      range = c(pip_min_size, pip_max_size),
      name = "PIP",
      breaks = c(0.01, 0.1, 0.5, 1.0),
      limits = c(0, 1)
    ) +
    labs(x = paste0("Position on chr", int_to_chr(region_chr), " (Mb)"),
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas() +
    ggplot2::theme(legend.position = "right")

  if (!show_pip_legend) {
    plt <- plt + guides(size = "none")
  }

  if (!is.null(label_pip_above) && "SNP" %in% names(region)) {
    top_pip <- region[region$pip_val >= label_pip_above, , drop = FALSE]
    if (nrow(top_pip) > 0) {
      plt <- plt + ggrepel::geom_text_repel(
        data = top_pip,
        aes(x = .data$BP / 1e6, y = .data$LOG10P, label = .data$SNP),
        inherit.aes = FALSE,
        size = 3, max.overlaps = 15, segment.color = "grey50",
        fontface = "bold"
      )
    }
  }

  plt
}
