#' Genome-wide p-value heatmap
#'
#' A compact, binned heatmap of association signals across the genome.
#' Each cell represents a genomic bin colored by the summary statistic
#' (minimum p-value, median, or count of significant variants).
#' Handles 10M+ SNPs efficiently through pre-aggregation.
#'
#' @param data A `gwas_data` object or data.frame.
#' @param chr,bp,p Column name overrides.
#' @param bin_size Bin size in base pairs (default 1 Mb).
#' @param summary_fun How to summarize p-values per bin: "min" (default),
#'   "median", or "count_sig" (count of variants below `threshold`).
#' @param palette Color palette: "viridis", "magma", "inferno", or "plasma".
#' @param na_color Color for empty bins.
#' @param threshold Significance threshold for count_sig mode and
#'   for marking significant bins.
#' @param chromosomes Subset of chromosomes to show.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' data(example_gwas, package = "ggwas")
#'
#' # Default (viridis)
#' pvalue_heatmap(example_gwas, bin_size = 10000)
#'
#' # Magma palette
#' pvalue_heatmap(example_gwas, bin_size = 10000, palette = "magma")
#'
#' # Inferno palette
#' pvalue_heatmap(example_gwas, bin_size = 10000, palette = "inferno")
#'
#' # Count significant variants per bin
#' pvalue_heatmap(example_gwas, bin_size = 10000, summary_fun = "count_sig")
pvalue_heatmap <- function(data,
                           chr = NULL,
                           bp = NULL,
                           p = NULL,
                           bin_size = 1e6,
                           summary_fun = "min",
                           palette = "viridis",
                           na_color = "grey95",
                           threshold = 5e-8,
                           chromosomes = NULL,
                           title = NULL) {

  if (!inherits(data, "gwas_data")) {
    data <- as_gwas_data(data, chr = chr, bp = bp, p = p)
  }

  data <- data[!is.na(data$P) & data$P > 0, , drop = FALSE]

  if (!is.null(chromosomes)) {
    data <- data[data$CHR %in% chromosomes, , drop = FALSE]
  }

  data$bin <- floor(data$BP / bin_size) * bin_size

  agg_fun <- switch(
    summary_fun,
    "min" = function(x) min(x, na.rm = TRUE),
    "median" = function(x) stats::median(x, na.rm = TRUE),
    "count_sig" = function(x) sum(x < threshold, na.rm = TRUE),
    cli_abort("Unknown summary_fun: {.val {summary_fun}}")
  )

  bins <- stats::aggregate(data$P, by = list(CHR = data$CHR, bin = data$bin),
                           FUN = agg_fun)
  names(bins)[3] <- "value"

  if (summary_fun %in% c("min", "median")) {
    bins$fill_val <- -log10(bins$value)
    fill_label <- expression(-log[10](italic(p)))
  } else {
    bins$fill_val <- bins$value
    fill_label <- paste0("Count (p < ", format(threshold, scientific = TRUE), ")")
  }

  chr_lengths <- c(
    248956422, 242193529, 198295559, 190214555, 181538259,
    170805979, 159345973, 145138636, 138394717, 133797422,
    135086622, 133275309, 114364328, 107043718, 101991189,
    90338345, 83257441, 80373285, 58617616, 64444167,
    46709983, 50818468
  )

  present_chrs <- sort(unique(bins$CHR))
  all_bins <- do.call(rbind, lapply(present_chrs, function(ch) {
    max_bp <- if (ch <= length(chr_lengths)) chr_lengths[ch] else max(bins$bin[bins$CHR == ch])
    bin_seq <- seq(0, max_bp, by = bin_size)
    data.frame(CHR = ch, bin = bin_seq)
  }))

  bins <- merge(all_bins, bins, by = c("CHR", "bin"), all.x = TRUE)
  bins$fill_val[is.na(bins$fill_val)] <- 0

  bins$bin_mb <- bins$bin / 1e6
  bins$CHR_label <- factor(int_to_chr(bins$CHR),
                           levels = rev(int_to_chr(present_chrs)))

  plt <- ggplot(bins, aes(x = .data$bin_mb, y = .data$CHR_label,
                           fill = .data$fill_val)) +
    geom_tile(width = bin_size / 1e6, height = 0.9) +
    scale_fill_viridis_c(
      option = switch(palette,
                       "viridis" = "D", "magma" = "A",
                       "inferno" = "B", "plasma" = "C", "D"),
      direction = -1,
      na.value = na_color,
      name = fill_label
    ) +
    labs(x = "Position (Mb)", y = "Chromosome", title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid = element_blank(),
      axis.text.y = element_text(size = 7),
      legend.position = "right"
    )

  plt
}
