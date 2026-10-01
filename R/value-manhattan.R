#' Manhattan plot of an arbitrary per-feature value
#'
#' Plot any numeric value assigned to a genomic feature (gene, transcript,
#' window) along the genome in Manhattan style: features on the genomic x-axis,
#' the value on the y-axis, alternating chromosome colors. Unlike
#' [manhattan_plot()], which expects GWAS p-values, this plots the value
#' as-is, so it suits rankings, effect sizes, ranking differences between two
#' transcriptome references, conservation scores, read counts, and similar
#' per-feature metrics. Returns a ggplot2 object for further customization.
#'
#' @param data A data.frame (or tibble/data.table) with one row per feature.
#' @param value Name of the column holding the value to plot on the y-axis.
#'   Required.
#' @param chr,bp Column names for chromosome and genomic position
#'   (auto-detected if NULL). Ignored when `annotate` is set, because the
#'   coordinates are then looked up from the gene IDs.
#' @param id Column holding gene identifiers (Ensembl gene IDs or symbols),
#'   used when `annotate` is set (auto-detected if NULL).
#' @param annotate Annotation backend to map `id` to genomic coordinates:
#'   one of `"gtf"`, `"builtin"`, `"biomart"` or `"ensdb"` (see
#'   [annotate_positions()]). `NULL` (default) means the data already carry
#'   `chr`/`bp` columns.
#' @param build Genome build for `annotate = "builtin"`/`"biomart"`:
#'   `"GRCh38"` (default) or `"GRCh37"`.
#' @param release Ensembl release for `annotate = "biomart"` (`NULL` = current).
#' @param gtf Path to a GTF/GFF3 file for `annotate = "gtf"`.
#' @param ensdb An `EnsDb` object for `annotate = "ensdb"`.
#' @param id_type Whether `id` holds Ensembl gene IDs (`"ensembl_gene_id"`,
#'   default) or gene symbols (`"symbol"`).
#' @param label Column holding feature labels (e.g. gene symbol), used by
#'   `highlight`, `label_ids` and `label_top_n`. When `annotate` is set and
#'   `label` is NULL, the looked-up gene symbol is used.
#' @param colors Two-color vector for alternating chromosomes.
#' @param point_size Point size.
#' @param alpha Point transparency.
#' @param threshold Optional numeric vector of y-values at which to draw
#'   horizontal reference lines (in the units of `value`).
#' @param threshold_color Color for the threshold lines.
#' @param highlight Values of the `label` column to highlight.
#' @param highlight_color Color for highlighted features.
#' @param highlight_size Size for highlighted points.
#' @param label_ids Values of the `label` column to annotate with text.
#' @param label_top_n Annotate the N features with the largest value (largest
#'   absolute value when the data contains negative values).
#' @param chromosomes Subset of chromosomes to plot (integer vector).
#' @param chr_labels Custom chromosome labels. Options: NULL (all labels),
#'   `"odd"` (only odd-numbered chromosomes labeled), or a character vector of
#'   labels (same length as displayed chromosomes).
#' @param y_label Y-axis title. Defaults to the `value` column name.
#' @param y_limit Upper y-axis limit.
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' set.seed(1)
#' df <- data.frame(
#'   chr = rep(1:5, each = 200),
#'   bp = as.integer(runif(1000, 1, 2e8)),
#'   score = round(runif(1000, 0, 1e5)),
#'   gene = paste0("g", 1:1000)
#' )
#'
#' # Basic value Manhattan
#' value_manhattan(df, value = "score")
#'
#' # Label the top features and set a custom y-axis title
#' value_manhattan(df, value = "score", label = "gene",
#'                 label_top_n = 5, y_label = "ranking difference")
#'
#' # Add a reference line and restrict to a few chromosomes
#' value_manhattan(df, value = "score", threshold = 90000,
#'                 chromosomes = 1:3)
value_manhattan <- function(data,
                            value = NULL,
                            chr = NULL,
                            bp = NULL,
                            id = NULL,
                            annotate = NULL,
                            build = c("GRCh38", "GRCh37"),
                            release = NULL,
                            gtf = NULL,
                            ensdb = NULL,
                            id_type = c("ensembl_gene_id", "symbol"),
                            label = NULL,
                            colors = c("#1A5276", "#76D7C4"),
                            point_size = 0.8,
                            alpha = 1,
                            threshold = NULL,
                            threshold_color = "#E74C3C",
                            highlight = NULL,
                            highlight_color = "#E74C3C",
                            highlight_size = 2,
                            label_ids = NULL,
                            label_top_n = NULL,
                            chromosomes = NULL,
                            chr_labels = NULL,
                            y_label = NULL,
                            y_limit = NULL,
                            title = NULL) {

  data <- as.data.frame(data)
  header <- names(data)

  if (is.null(value)) {
    cli_abort("{.arg value} is required: name the column to plot on the y-axis.")
  }
  if (!value %in% header) {
    cli_abort("Column {.val {value}} not found in {.arg data}.")
  }

  # Look up coordinates from gene IDs when requested, then fall through to the
  # usual chr/bp handling using the columns we just added.
  if (!is.null(annotate)) {
    annotate <- match.arg(annotate, c("gtf", "biomart", "ensdb", "builtin"))
    build <- match.arg(build)
    id_type <- match.arg(id_type)

    id <- id %||% .match_col(header, .id_patterns)
    if (is.na(id)) {
      cli_abort(c(
        "Cannot detect the gene identifier column for annotation.",
        "i" = "Pass it via {.arg id}."
      ))
    }
    ann <- annotate_positions(data[[id]], source = annotate, build = build,
                              release = release, gtf = gtf, ensdb = ensdb,
                              id_type = id_type)
    hit <- match(data[[id]], ann$id)
    data$.ggwas_chr <- ann$chr[hit]
    data$.ggwas_bp <- ann$start[hit]
    chr <- ".ggwas_chr"
    bp <- ".ggwas_bp"
    if (is.null(label)) {
      data$.ggwas_gene <- ann$gene[hit]
      label <- ".ggwas_gene"
    }
    header <- names(data)
  }

  chr <- chr %||% .match_col(header, .chr_patterns)
  if (is.null(bp)) {
    bp <- .na_null(.match_col(header, .bp_patterns)) %||%
      .match_col(header, .bp_gene_patterns)
  }
  if (is.na(chr) || is.na(bp)) {
    cli_abort(c(
      "Cannot detect the chromosome and/or position column.",
      "i" = "Rename them to standard names, or pass them via {.arg chr} and {.arg bp}."
    ))
  }

  need_label <- !is.null(highlight) || !is.null(label_ids) || !is.null(label_top_n)
  if (need_label && is.null(label)) {
    cli_abort("{.arg label} is required to use {.arg highlight}, {.arg label_ids} or {.arg label_top_n}.")
  }
  if (!is.null(label) && !label %in% header) {
    cli_abort("Column {.val {label}} not found in {.arg data}.")
  }

  d <- data.frame(
    CHR = chr_to_int(data[[chr]]),
    BP = as.integer(data[[bp]]),
    VALUE = as.numeric(data[[value]])
  )
  if (!is.null(label)) d$LABEL <- data[[label]]

  d <- d[!is.na(d$CHR) & !is.na(d$BP) & !is.na(d$VALUE), , drop = FALSE]
  if (!is.null(chromosomes)) {
    d <- d[d$CHR %in% chromosomes, , drop = FALSE]
  }
  if (nrow(d) == 0) {
    cli_abort("No rows left to plot after removing missing values.")
  }

  d <- add_cumulative_bp(d)
  chr_info <- attr(d, "chr_info")
  d$CHR_F <- factor(d$CHR)

  if (is.null(chr_labels)) {
    chr_labels <- int_to_chr(chr_info$CHR)
  } else if (identical(chr_labels, "odd")) {
    chr_labels <- int_to_chr(chr_info$CHR)
    chr_labels[seq(2, length(chr_labels), by = 2)] <- ""
  }

  has_neg <- any(d$VALUE < 0)

  plt <- ggplot(d, aes(x = .data$BP_CUM, y = .data$VALUE,
                       color = .data$CHR_F)) +
    geom_point(size = point_size, alpha = alpha, shape = 16) +
    scale_color_chromosome(colors = colors, chromosomes = chr_info$CHR,
                           guide = "none") +
    scale_x_continuous(
      breaks = chr_info$center,
      labels = chr_labels,
      expand = c(0.01, 0)
    ) +
    scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.02, 0.12))
    ) +
    labs(x = "Chromosome",
         y = y_label %||% value,
         title = title) +
    theme_gwas()

  if (has_neg) {
    plt <- plt + geom_hline(yintercept = 0, color = "grey30", linewidth = 0.3)
  }

  if (!is.null(threshold)) {
    for (t in threshold) {
      plt <- plt + geom_hline(
        yintercept = t, linetype = "dashed",
        color = threshold_color, linewidth = 0.4
      )
    }
  }

  if (!is.null(highlight)) {
    hl <- d[d$LABEL %in% highlight, , drop = FALSE]
    if (nrow(hl) > 0) {
      plt <- plt + geom_point(
        data = hl,
        aes(x = .data$BP_CUM, y = .data$VALUE),
        color = highlight_color, size = highlight_size, shape = 16,
        inherit.aes = FALSE
      )
    }
  }

  label_data <- NULL
  if (!is.null(label_ids)) {
    label_data <- d[d$LABEL %in% label_ids, , drop = FALSE]
  }
  if (!is.null(label_top_n)) {
    ord <- if (has_neg) order(-abs(d$VALUE)) else order(-d$VALUE)
    top <- utils::head(d[ord, , drop = FALSE], label_top_n)
    label_data <- if (is.null(label_data)) top else rbind(label_data, top)
  }
  if (!is.null(label_data) && nrow(label_data) > 0) {
    label_data <- label_data[!duplicated(label_data$LABEL), , drop = FALSE]
    plt <- plt + .snp_repel(
      aes(x = .data$BP_CUM, y = .data$VALUE, label = .data$LABEL),
      data = label_data, direction = "both"
    )
  }

  if (!is.null(y_limit)) {
    lower <- if (has_neg) -y_limit else 0
    plt <- plt + coord_cartesian(ylim = c(lower, y_limit), clip = "off")
  } else if (has_neg) {
    m <- max(abs(d$VALUE)) * 1.14
    plt <- plt + coord_cartesian(ylim = c(-m, m), clip = "off")
  } else {
    plt <- plt + coord_cartesian(clip = "off")
  }

  plt
}
