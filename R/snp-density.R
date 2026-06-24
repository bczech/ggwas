#' SNP density karyogram
#'
#' Visualize the distribution of genotyped or imputed variants across
#' chromosomes. Each chromosome is drawn proportionally to its length
#' and colored by SNP density per genomic bin. Optionally marks
#' centromere positions when `chr_info` is provided.
#'
#' @param data A `gwas_data` object or data.frame with GWAS results.
#' @param chr,bp Column name overrides.
#' @param bin_size Bin size in base pairs (default 1 Mb).
#' @param chr_info Optional data.frame with columns `chr`, `length`, and
#'   optionally `centromere_start`, `centromere_end`. Use
#'   [chr_info_human()] for hg38. If NULL, chromosome lengths are
#'   inferred from the data.
#' @param palette Color palette for density: "viridis", "magma",
#'   "inferno", or "plasma".
#' @param show_centromeres If TRUE and centromere positions are available
#'   in `chr_info`, draw centromere markers.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#' snp_density(example_gwas, bin_size = 5e6)
#'
#' # With human centromere markers
#' snp_density(example_gwas, bin_size = 5e6, chr_info = chr_info_human())
snp_density <- function(data,
                        chr = NULL,
                        bp = NULL,
                        bin_size = 1e6,
                        chr_info = NULL,
                        palette = "viridis",
                        show_centromeres = TRUE,
                        title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp)
  }

  data <- data[!is.na(data$CHR) & !is.na(data$BP), , drop = FALSE]

  present_chrs <- sort(unique(data$CHR))

  if (is.null(chr_info)) {
    chr_max <- tapply(data$BP, data$CHR, max)
    chr_info <- data.frame(
      chr = as.integer(names(chr_max)),
      length = as.numeric(chr_max)
    )
  }

  chr_info <- chr_info[chr_info$chr %in% present_chrs, , drop = FALSE]
  has_centromeres <- show_centromeres &&
    all(c("centromere_start", "centromere_end") %in% names(chr_info))

  data$bin <- floor(data$BP / bin_size) * bin_size
  bins <- stats::aggregate(data$BP, by = list(CHR = data$CHR, bin = data$bin),
                           FUN = length)
  names(bins)[3] <- "count"

  all_bins <- do.call(rbind, lapply(chr_info$chr, function(ch) {
    max_bp <- chr_info$length[chr_info$chr == ch]
    bin_seq <- seq(0, max_bp, by = bin_size)
    data.frame(CHR = ch, bin = bin_seq)
  }))

  bins <- merge(all_bins, bins, by = c("CHR", "bin"), all.x = TRUE)
  bins$count[is.na(bins$count)] <- 0

  bins$bin_mb <- bins$bin / 1e6
  bins$CHR_label <- factor(int_to_chr(bins$CHR),
                           levels = rev(int_to_chr(sort(unique(bins$CHR)))))

  plt <- ggplot(bins, aes(x = .data$bin_mb, y = .data$CHR_label,
                           fill = .data$count)) +
    geom_tile(width = bin_size / 1e6, height = 0.85) +
    scale_fill_viridis_c(
      option = switch(palette,
                       "viridis" = "D", "magma" = "A",
                       "inferno" = "B", "plasma" = "C", "D"),
      name = "SNP count"
    ) +
    labs(x = "Position (Mb)", y = "Chromosome", title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.text.y = element_text(size = 7),
      legend.position = "right"
    )

  if (has_centromeres) {
    cen <- chr_info[, c("chr", "centromere_start", "centromere_end")]
    cen$CHR_label <- factor(int_to_chr(cen$chr),
                            levels = levels(bins$CHR_label))
    cen$cen_start_mb <- cen$centromere_start / 1e6
    cen$cen_end_mb <- cen$centromere_end / 1e6

    plt <- plt + ggplot2::geom_rect(
      data = cen,
      aes(xmin = .data$cen_start_mb, xmax = .data$cen_end_mb,
          ymin = as.numeric(.data$CHR_label) - 0.42,
          ymax = as.numeric(.data$CHR_label) + 0.42),
      fill = "white", color = "grey40", linewidth = 0.2,
      inherit.aes = FALSE
    )
  }

  plt
}
