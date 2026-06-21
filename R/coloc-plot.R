#' Colocalization locus plot
#'
#' Two association signals on a shared genomic coordinate axis — the
#' standard way to visually assess whether a GWAS signal and an eQTL
#' (or two GWAS traits) share the same causal variant.
#'
#' @param gwas1 First dataset (e.g., GWAS). A `gwas_data` or data.frame.
#' @param gwas2 Second dataset (e.g., eQTL). Same format.
#' @param chr,bp,p,snp Column name overrides (applied to both datasets).
#' @param region_chr Chromosome of the region to plot.
#' @param region_start,region_end Start and end positions.
#' @param lead_snp SNP ID to center on (± flank).
#' @param flank Flank size in bp around lead_snp.
#' @param ld Named numeric vector of LD r² values (optional).
#' @param ld_colors Colors for LD bins.
#' @param top_title Label for the top panel.
#' @param bottom_title Label for the bottom panel.
#' @param highlight_snps SNPs to highlight in both panels.
#' @param point_size Point size.
#' @param title Overall title.
#' @return A patchwork composition of two locus plots.
#' @export
#' @examples
#' data(example_gwas)
#' gwas2 <- example_gwas
#' gwas2$P <- runif(nrow(gwas2))^2
#' coloc_plot(example_gwas, gwas2,
#'            region_chr = 1, region_start = 1e6, region_end = 30e6,
#'            top_title = "GWAS", bottom_title = "eQTL")
coloc_plot <- function(gwas1,
                       gwas2,
                       chr = NULL,
                       bp = NULL,
                       p = NULL,
                       snp = NULL,
                       region_chr = NULL,
                       region_start = NULL,
                       region_end = NULL,
                       lead_snp = NULL,
                       flank = 500000,
                       ld = NULL,
                       ld_colors = c("#2166AC", "#67A9CF", "#78C679",
                                     "#F4A582", "#D73027"),
                       top_title = "Trait 1",
                       bottom_title = "Trait 2",
                       highlight_snps = NULL,
                       point_size = 2,
                       title = NULL) {

  if (!inherits(gwas1, "gwas_data")) {
    gwas1 <- as_gwas_data(gwas1, chr = chr, bp = bp, snp = snp, p = p)
  }
  if (!inherits(gwas2, "gwas_data")) {
    gwas2 <- as_gwas_data(gwas2, chr = chr, bp = bp, snp = snp, p = p)
  }

  if (!is.null(lead_snp) && "SNP" %in% names(gwas1)) {
    lead_row <- gwas1[gwas1$SNP == lead_snp, , drop = FALSE]
    if (nrow(lead_row) == 0) cli_abort("Lead SNP {.val {lead_snp}} not found.")
    region_chr <- lead_row$CHR[1]
    region_start <- lead_row$BP[1] - flank
    region_end <- lead_row$BP[1] + flank
  }

  if (is.null(region_chr)) cli_abort("Specify {.arg region_chr} or {.arg lead_snp}.")
  region_start <- max(region_start, 0)

  p_top <- locus_plot(gwas1, region_chr = region_chr,
                      region_start = region_start, region_end = region_end,
                      ld = ld, ld_colors = ld_colors, lead_snp = lead_snp,
                      point_size = point_size) +
    labs(y = expression(-log[10](italic(p))),
         title = top_title, x = NULL) +
    ggplot2::theme(axis.text.x = element_blank(),
                   axis.ticks.x = element_blank())

  p_bottom <- locus_plot(gwas2, region_chr = region_chr,
                         region_start = region_start, region_end = region_end,
                         ld = ld, ld_colors = ld_colors,
                         point_size = point_size) +
    labs(y = expression(-log[10](italic(p))),
         title = bottom_title)

  combined <- patchwork::wrap_plots(p_top, p_bottom, ncol = 1, heights = c(1, 1))
  if (!is.null(title)) {
    combined <- combined + patchwork::plot_annotation(title = title)
  }
  combined
}
