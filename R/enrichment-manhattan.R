#' Enrichment Manhattan plot
#'
#' A Manhattan plot with colored overlays for functional genomic annotations.
#' SNPs falling within annotated regions (genes, enhancers, eQTLs, custom
#' categories) are highlighted with distinct colors, connecting GWAS results
#' with functional genomics.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param annotations A data.frame or list of data.frames with annotation
#'   regions. Each must have columns: `chr` (integer), `start`, `end`.
#'   Optionally: `category` (annotation type), `name` (region label).
#'   If a named list, names are used as category labels.
#' @param chr,bp,p,snp Column name overrides.
#' @param background_color Color for non-annotated SNPs.
#' @param background_alpha Transparency of background points.
#' @param annotation_colors Named vector of colors for each annotation
#'   category. If NULL, uses a colorblind-friendly palette.
#' @param annotation_size Point size for annotated SNPs.
#' @param annotation_alpha Transparency of annotated SNPs.
#' @param annotation_shape Point shape for annotated SNPs (default 16, circle).
#' @param show_legend Show legend for annotation categories.
#' @param legend_position Legend position.
#' @param genome_wide Genome-wide significance threshold.
#' @param suggestive Suggestive significance threshold.
#' @param label_top_n Label top N annotated significant SNPs.
#' @param label_column Column to use for labels.
#' @param downsample Enable smart downsampling.
#' @param downsample_n Target number of background points.
#' @param title Plot title.
#' @param palette Color palette for annotations (from [gwas_palette()]).
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas)
#' # Define annotation regions
#' annot <- data.frame(
#'   chr = c(1, 2, 5),
#'   start = c(1e6, 50e6, 100e6),
#'   end = c(5e6, 55e6, 110e6),
#'   category = c("Enhancer", "Gene", "eQTL")
#' )
#' enrichment_manhattan(example_gwas, annotations = annot)
enrichment_manhattan <- function(data,
                                 annotations,
                                 chr = NULL, bp = NULL, p = NULL, snp = NULL,
                                 background_color = "grey75",
                                 background_alpha = 0.4,
                                 annotation_colors = NULL,
                                 annotation_size = 1.5,
                                 annotation_alpha = 0.9,
                                 annotation_shape = 16,
                                 show_legend = TRUE,
                                 legend_position = "right",
                                 genome_wide = 5e-8,
                                 suggestive = 1e-5,
                                 label_top_n = NULL,
                                 label_column = "SNP",
                                 downsample = TRUE,
                                 downsample_n = 200000,
                                 title = NULL,
                                 palette = "nature") {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, snp = snp, p = p)
  }
  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (is.data.frame(annotations)) {
    if (!"category" %in% names(annotations)) {
      annotations$category <- "Annotated"
    }
  } else if (is.list(annotations)) {
    ann_list <- lapply(names(annotations), function(nm) {
      a <- annotations[[nm]]
      a$category <- nm
      a
    })
    annotations <- do.call(rbind, ann_list)
  }

  annotations$chr <- chr_to_int(annotations$chr)
  categories <- unique(annotations$category)

  data$annotation <- NA_character_
  for (i in seq_len(nrow(annotations))) {
    ann <- annotations[i, ]
    idx <- which(data$CHR == ann$chr &
                   data$BP >= ann$start &
                   data$BP <= ann$end &
                   is.na(data$annotation))
    if (length(idx) > 0) {
      data$annotation[idx] <- ann$category
    }
  }

  annotated_idx <- which(!is.na(data$annotation))
  bg_idx <- which(is.na(data$annotation))

  if (downsample && length(bg_idx) > downsample_n) {
    bg_data <- data[bg_idx, , drop = FALSE]
    bg_data <- smart_downsample(bg_data, target_n = downsample_n)
    plot_data <- rbind(bg_data, data[annotated_idx, , drop = FALSE])
  } else {
    plot_data <- data
  }

  plot_data$LOG10P <- -log10(plot_data$P)
  plot_data <- add_cumulative_bp(plot_data)
  chr_info <- attr(plot_data, "chr_info")

  bg <- plot_data[is.na(plot_data$annotation), , drop = FALSE]
  fg <- plot_data[!is.na(plot_data$annotation), , drop = FALSE]
  fg$annotation <- factor(fg$annotation, levels = categories)

  if (is.null(annotation_colors)) {
    ann_pal <- gwas_palette(palette, n = length(categories))
    annotation_colors <- stats::setNames(ann_pal, categories)
  }

  plt <- ggplot() +
    geom_point(
      data = bg,
      aes(x = .data$BP_CUM, y = .data$LOG10P),
      color = background_color, alpha = background_alpha,
      size = 0.6, shape = 16
    )

  if (nrow(fg) > 0) {
    plt <- plt + geom_point(
      data = fg,
      aes(x = .data$BP_CUM, y = .data$LOG10P, color = .data$annotation),
      size = annotation_size, alpha = annotation_alpha,
      shape = annotation_shape
    ) +
      scale_color_manual(
        values = annotation_colors,
        name = "Annotation",
        drop = FALSE
      )
  }

  plt <- plt +
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
    plt <- plt + geom_hline(
      yintercept = -log10(genome_wide),
      linetype = "dashed", color = "#E74C3C", linewidth = 0.4
    )
  }
  if (!is.null(suggestive)) {
    plt <- plt + geom_hline(
      yintercept = -log10(suggestive),
      linetype = "dotted", color = "#3498DB", linewidth = 0.4
    )
  }

  if (!is.null(label_top_n) && nrow(fg) > 0 && label_column %in% names(fg)) {
    top <- fg[order(fg$P), , drop = FALSE]
    top <- utils::head(top, label_top_n)
    top <- top[!duplicated(top[[label_column]]), , drop = FALSE]
    plt <- plt + ggrepel::geom_text_repel(
      data = top,
      aes(x = .data$BP_CUM, y = .data$LOG10P, label = .data[[label_column]]),
      size = 3, max.overlaps = 20, segment.color = "grey40",
      fontface = "italic"
    )
  }

  plt
}
