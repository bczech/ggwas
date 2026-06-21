#' Multi-trait Manhattan plot
#'
#' Overlay results from multiple GWAS traits or studies on a single
#' Manhattan plot. Each trait is shown in a different color and optionally
#' a different shape, enabling visual identification of shared and
#' trait-specific loci (pleiotropy).
#'
#' @param ... Named `gwas_data` objects or data.frames. Names are used as
#'   trait labels. Alternatively, pass a single named list.
#' @param chr,bp,p,snp Column name overrides applied to all datasets.
#' @param colors Named vector of colors per trait, or a palette name
#'   from [gwas_palette()].
#' @param shapes Named vector of point shapes per trait (integers).
#'   If NULL, all use shape 16 (circle).
#' @param point_size Point size (can be a named vector per trait).
#' @param alpha Point transparency.
#' @param genome_wide Genome-wide significance threshold.
#' @param suggestive Suggestive significance threshold.
#' @param show_legend Show trait legend.
#' @param legend_position Legend position.
#' @param highlight_shared Highlight SNPs significant in multiple traits.
#' @param shared_color Color for shared significant SNPs.
#' @param shared_size Size for shared significant SNPs.
#' @param label_shared_n Label top N shared significant SNPs.
#' @param downsample Enable smart downsampling per trait.
#' @param downsample_n Target points per trait.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#' # Simulate two traits
#' trait1 <- example_gwas
#' trait2 <- example_gwas
#' trait2$P <- runif(nrow(trait2))^3
#' multitrait_manhattan(Trait1 = trait1, Trait2 = trait2)
multitrait_manhattan <- function(...,
                                chr = NULL, bp = NULL, p = NULL, snp = NULL,
                                colors = "nature",
                                shapes = NULL,
                                point_size = 0.8,
                                alpha = 0.7,
                                genome_wide = 5e-8,
                                suggestive = 1e-5,
                                show_legend = TRUE,
                                legend_position = "top",
                                highlight_shared = TRUE,
                                shared_color = "#9B59B6",
                                shared_size = 2.5,
                                label_shared_n = NULL,
                                downsample = TRUE,
                                downsample_n = 150000,
                                title = NULL) {

  datasets <- list(...)
  if (length(datasets) == 1 && is.list(datasets[[1]]) &&
      !is.data.frame(datasets[[1]])) {
    datasets <- datasets[[1]]
  }

  if (is.null(names(datasets)) || any(names(datasets) == "")) {
    cli_abort("All datasets must be named (trait labels).")
  }

  trait_names <- names(datasets)
  n_traits <- length(trait_names)

  if (is.character(colors) && length(colors) == 1 && colors %in% gwas_palettes()) {
    colors <- stats::setNames(gwas_palette(colors, n = n_traits), trait_names)
  } else if (is.null(names(colors))) {
    colors <- stats::setNames(rep_len(colors, n_traits), trait_names)
  }

  if (is.null(shapes)) {
    shapes <- stats::setNames(rep(16L, n_traits), trait_names)
  }

  all_data <- lapply(trait_names, function(nm) {
    d <- datasets[[nm]]
    if (!inherits(d, "gwas_data")) {
      d <- as_gwas_data(d, chr = chr, bp = bp, snp = snp, p = p)
    }
    d <- d[!is.na(d$P) & d$P > 0, , drop = FALSE]
    if (downsample && nrow(d) > downsample_n) {
      d <- smart_downsample(d, target_n = downsample_n)
    }
    d$trait <- nm
    d
  })

  combined <- do.call(rbind, all_data)
  combined$LOG10P <- -log10(combined$P)
  combined <- add_cumulative_bp(combined)
  chr_info <- attr(combined, "chr_info")
  combined$trait <- factor(combined$trait, levels = trait_names)

  plt <- ggplot(combined, aes(x = .data$BP_CUM, y = .data$LOG10P,
                               color = .data$trait, shape = .data$trait)) +
    geom_point(size = point_size, alpha = alpha) +
    scale_color_manual(values = colors, name = "Trait") +
    ggplot2::scale_shape_manual(values = shapes, name = "Trait") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = int_to_chr(chr_info$CHR),
      expand = c(0.01, 0)
    ) +
    labs(x = "Chromosome",
         y = expression(-log[10](italic(p))),
         title = title) +
    theme_gwas()

  if (show_legend) {
    plt <- plt + ggplot2::theme(legend.position = legend_position)
  }

  if (!is.null(genome_wide)) {
    plt <- plt + geom_hline(yintercept = -log10(genome_wide),
                            linetype = "dashed", color = "grey40", linewidth = 0.4)
  }
  if (!is.null(suggestive)) {
    plt <- plt + geom_hline(yintercept = -log10(suggestive),
                            linetype = "dotted", color = "grey60", linewidth = 0.4)
  }

  if (highlight_shared && n_traits > 1 && "SNP" %in% names(combined) &&
      !is.null(genome_wide)) {
    sig <- combined[combined$P < genome_wide, , drop = FALSE]
    if (nrow(sig) > 0) {
      snp_counts <- table(sig$SNP)
      shared_snps <- names(snp_counts[snp_counts >= 2])
      if (length(shared_snps) > 0) {
        shared_data <- combined[combined$SNP %in% shared_snps &
                                  combined$P < genome_wide, , drop = FALSE]
        shared_data <- shared_data[!duplicated(shared_data$SNP), , drop = FALSE]
        plt <- plt + geom_point(
          data = shared_data,
          aes(x = .data$BP_CUM, y = .data$LOG10P),
          color = shared_color, size = shared_size,
          shape = 18, inherit.aes = FALSE
        )

        if (!is.null(label_shared_n) && "SNP" %in% names(shared_data)) {
          top_shared <- utils::head(shared_data[order(shared_data$P), ], label_shared_n)
          plt <- plt + ggrepel::geom_text_repel(
            data = top_shared,
            aes(x = .data$BP_CUM, y = .data$LOG10P, label = .data$SNP),
            inherit.aes = FALSE,
            size = 3, color = shared_color, fontface = "bold"
          )
        }
      }
    }
  }

  plt
}
