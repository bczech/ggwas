#' Enrichment Manhattan plot
#'
#' A Manhattan plot with colored overlays for functional genomic annotations.
#' SNPs falling within annotated regions (genes, enhancers, eQTLs, custom
#' categories) are highlighted with distinct colors, connecting GWAS results
#' with functional genomics.
#'
#' @param data A `gwas_data` object, data.frame or `GRanges` of variants.
#' @param annotations Annotation regions as a [GenomicRanges::GRanges] with
#'   an optional `category` metadata column (annotation type), or a named
#'   `GRangesList` (or named list of `GRanges`) whose names are used as
#'   categories. BED, GFF or bigBed
#'   files can be read with `rtracklayer::import()`. A variant falling in
#'   several regions takes the category of the first one.
#' @param chr,bp,p,snp Column name overrides.
#' @param background_color Color for non-annotated SNPs.
#' @param background_alpha Transparency of background points.
#' @param annotation_colors Named vector of colors for each annotation
#'   category. If NULL, colors are taken from `palette`.
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
#' # Annotation regions with a category column
#' annot <- GenomicRanges::GRanges(
#'   c("chr1:1000000-5000000", "chr2:50000000-55000000",
#'     "chr5:100000000-110000000"),
#'   category = c("Enhancer", "Gene", "eQTL")
#' )
#' enrichment_manhattan(example_gwas, annotations = annot)
#'
#' # The same as a GRangesList, one element per category
#' annot_list <- GenomicRanges::GRangesList(
#'   Enhancer = annot[1], Gene = annot[2], eQTL = annot[3]
#' )
#' enrichment_manhattan(example_gwas, annotations = annot_list)
enrichment_manhattan <- function(data,
                                 annotations,
                                 chr = NULL,
                                 bp = NULL,
                                 p = NULL,
                                 snp = NULL,
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

  annotations <- .as_annotation_ranges(annotations)
  categories <- unique(annotations$category)
  data$annotation <- .overlap_category(data$CHR, data$BP, annotations)

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
    plt <- plt + .snp_repel(
      aes(x = .data$BP_CUM, y = .data$LOG10P, label = .data[[label_column]]),
      data = top, fontface = "italic"
    )
  }

  plt
}

# GRanges (optional `category` column) or named GRangesList -> data.frame with
# chr, start, end and category.
#' @noRd
.as_annotation_ranges <- function(x, arg = "annotations",
                                  call = rlang::caller_env()) {
  if (is.list(x) && length(x) > 0 &&
      all(vapply(x, methods::is, logical(1), "GRanges"))) {
    x <- GenomicRanges::GRangesList(x)
  }
  if (methods::is(x, "GRangesList")) {
    if (is.null(names(x)) || any(!nzchar(names(x)))) {
      cli_abort("A {.cls GRangesList} in {.arg {arg}} needs names, used as categories.",
                call = call)
    }
    category <- rep(names(x), lengths(x))
    x <- unlist(x, use.names = FALSE)
    S4Vectors::mcols(x)$category <- category
  }
  if (!methods::is(x, "GRanges")) .abort_not_granges(arg, x, call = call)
  if (!"category" %in% names(S4Vectors::mcols(x))) {
    S4Vectors::mcols(x)$category <- "Annotated"
  }
  df <- .ranges_to_df(x)
  df$category <- as.character(df$category)
  df
}

# Category of the first annotation region overlapping each variant, NA when
# there is none.
#' @noRd
.overlap_category <- function(chr, bp, ann) {
  out <- rep(NA_character_, length(chr))
  if (length(chr) == 0 || nrow(ann) == 0) return(out)
  levels <- as.character(sort(union(chr, ann$chr)))
  snp_gr <- GenomicRanges::GRanges(factor(as.character(chr), levels = levels),
                                   IRanges::IRanges(bp, width = 1L))
  ann_gr <- GenomicRanges::GRanges(factor(as.character(ann$chr), levels = levels),
                                   IRanges::IRanges(ann$start, ann$end))
  hits <- GenomicRanges::findOverlaps(snp_gr, ann_gr, select = "first",
                                      ignore.strand = TRUE)
  out[!is.na(hits)] <- ann$category[hits[!is.na(hits)]]
  out
}
