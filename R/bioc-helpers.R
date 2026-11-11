# Helpers that turn Bioconductor objects (GRanges, GRangesList, TxDb, EnsDb,
# Seqinfo) into the small data.frames the plotting code works with. Plotting
# keeps integer chromosome codes internally (see chr_to_int()), so every helper
# here also drops sequences that have no such code, such as unplaced scaffolds.

# Columns tried, in order, for the gene label and the gene identifier.
.gene_label_patterns <- c("gene_name", "symbol", "gene_symbol", "gene", "Name",
                          "label")
.gene_id_patterns <- c("gene_id", "GeneID", "ensembl_gene_id", "ID")

# TRUE for sequence names that map to an integer chromosome code: plain numbers
# (with or without a "chr" prefix) and the labels in the sex chromosome map.
#' @noRd
.is_chromosome <- function(x) {
  x <- sub("^chr", "", as.character(x), ignore.case = TRUE)
  sex_map <- getOption("ggwas.sex_chr_map", default = .default_sex_chr_map)
  grepl("^[0-9]+$", x) | x %in% names(sex_map)
}

#' @noRd
.is_annotation_db <- function(x) {
  methods::is(x, "TxDb") || methods::is(x, "EnsDb")
}

#' @noRd
.abort_not_granges <- function(arg, what, call = rlang::caller_env()) {
  cli_abort(c(
    "{.arg {arg}} must be a {.cls GRanges} object, not {.obj_type_friendly {what}}.",
    "i" = "Import annotation files with {.fn rtracklayer::import}, or build ranges with {.fn GenomicRanges::GRanges}.",
    "i" = "Convert a data.frame with {.fn GenomicRanges::makeGRangesFromDataFrame}."
  ), call = call)
}

# Region as a GRanges of length 1 or a "chr:start-end" string -> list with
# integer chr, start and end.
#' @noRd
.as_region <- function(region, arg = "region", call = rlang::caller_env()) {
  if (is.character(region)) {
    region <- tryCatch(
      GenomicRanges::GRanges(region),
      error = function(e) cli_abort(
        "{.arg {arg}} {.val {region}} is not a valid range such as {.val chr6:25000000-34000000}.",
        call = call
      )
    )
  }
  if (!methods::is(region, "GRanges") || length(region) != 1L) {
    cli_abort(
      "{.arg {arg}} must be a {.cls GRanges} of length 1 or a string such as {.val chr6:25000000-34000000}.",
      call = call
    )
  }
  seq <- as.character(GenomicRanges::seqnames(region))
  if (!.is_chromosome(seq)) {
    cli_abort("Cannot use sequence {.val {seq}} in {.arg {arg}}: it is not a chromosome.",
              call = call)
  }
  list(
    chr = chr_to_int(seq),
    start = GenomicRanges::start(region),
    end = GenomicRanges::end(region)
  )
}

# Gene ranges from a GRanges, TxDb or EnsDb, with `gene` (label) and `gene_id`
# metadata columns.
#' @noRd
.as_gene_ranges <- function(x, arg = "genes", call = rlang::caller_env()) {
  if (.is_annotation_db(x)) {
    x <- .db_genes(x, call = call)
  }
  if (!methods::is(x, "GRanges")) {
    .abort_not_granges(arg, x, call = call)
  }
  md <- S4Vectors::mcols(x)
  header <- names(md)
  id_col <- .match_col(header, .gene_id_patterns)
  label_col <- .match_col(header, .gene_label_patterns)

  gene_id <- if (!is.na(id_col)) as.character(md[[id_col]]) else names(x)
  label <- if (!is.na(label_col)) as.character(md[[label_col]]) else gene_id
  if (is.null(label)) {
    cli_abort(c(
      "Cannot find gene names in {.arg {arg}}.",
      "i" = "Add a {.field gene_name} metadata column, or set {.code names()}."
    ), call = call)
  }
  if (is.null(gene_id)) gene_id <- label
  missing <- is.na(label) | !nzchar(label)
  label[missing] <- gene_id[missing]

  S4Vectors::mcols(x)$gene <- label
  S4Vectors::mcols(x)$gene_id <- gene_id
  x
}

#' @noRd
.db_genes <- function(db, call = rlang::caller_env()) {
  if (methods::is(db, "EnsDb")) {
    .require_pkg("ensembldb", "use an EnsDb object", call)
    return(ensembldb::genes(db))
  }
  .require_pkg("GenomicFeatures", "use a TxDb object", call)
  GenomicFeatures::genes(db)
}

# Exon ranges from a GRanges (with a gene label or gene ID column), a
# GRangesList named by gene ID, or TRUE to take exons from a TxDb/EnsDb `db`.
#' @noRd
.as_exon_ranges <- function(x, db = NULL, arg = "exons", call = rlang::caller_env()) {
  if (isTRUE(x)) {
    if (is.null(db)) {
      cli_abort(
        "{.code {arg} = TRUE} needs {.arg genes} to be a {.cls TxDb} or {.cls EnsDb} object.",
        call = call
      )
    }
    x <- if (methods::is(db, "EnsDb")) {
      .require_pkg("ensembldb", "use an EnsDb object", call)
      ensembldb::exonsBy(db, by = "gene")
    } else {
      .require_pkg("GenomicFeatures", "use a TxDb object", call)
      GenomicFeatures::exonsBy(db, by = "gene")
    }
  }
  if (methods::is(x, "GRangesList")) {
    x <- GenomicRanges::reduce(x)
    gene_id <- rep(names(x), lengths(x))
    x <- unlist(x, use.names = FALSE)
    S4Vectors::mcols(x) <- S4Vectors::DataFrame(gene_id = gene_id, gene = gene_id)
    return(x)
  }
  .as_gene_ranges(x, arg = arg, call = call)
}

# GRanges -> data.frame with integer chr, start, end, strand and every metadata
# column. Sequences without an integer chromosome code are dropped.
#' @noRd
.ranges_to_df <- function(gr) {
  seq <- as.character(GenomicRanges::seqnames(gr))
  keep <- .is_chromosome(seq)
  gr <- gr[keep]
  strand <- as.character(GenomicRanges::strand(gr))
  strand[strand == "*"] <- "."
  df <- data.frame(
    chr = chr_to_int(seq[keep]),
    start = GenomicRanges::start(gr),
    end = GenomicRanges::end(gr),
    strand = strand,
    stringsAsFactors = FALSE
  )
  md <- S4Vectors::mcols(gr)
  # Keep plain columns only; list-like ones (e.g. CharacterList) do not fit a
  # data.frame and no plot uses them.
  plain <- vapply(names(md), function(nm) is.atomic(md[[nm]]), logical(1))
  extra <- setdiff(names(md)[plain], names(df))
  for (nm in extra) {
    df[[nm]] <- as.vector(md[[nm]])
  }
  rownames(df) <- NULL
  df
}

# Chromosome lengths from a Seqinfo, or from any object that has one (TxDb,
# EnsDb, BSgenome, GRanges). Returns data.frame(chr, length).
#' @noRd
.as_seqinfo <- function(x, arg = "seqinfo", call = rlang::caller_env()) {
  if (!methods::is(x, "Seqinfo")) {
    x <- tryCatch(GenomeInfoDb::seqinfo(x), error = function(e) NULL)
  }
  if (is.null(x)) {
    cli_abort(c(
      "{.arg {arg}} must be a {.cls Seqinfo} object or an object with one.",
      "i" = "For example {.code GenomeInfoDb::Seqinfo(genome = \"hg38\")} or {.code seqinfo(txdb)}."
    ), call = call)
  }
  len <- GenomeInfoDb::seqlengths(x)
  keep <- .is_chromosome(names(len)) & !is.na(len)
  if (!any(keep)) {
    cli_abort("{.arg {arg}} has no chromosomes with known lengths.",
              call = call)
  }
  data.frame(chr = chr_to_int(names(len)[keep]), length = as.numeric(len[keep]))
}

# Centromeres as a GRanges -> data.frame(chr, centromere_start, centromere_end),
# one row per chromosome (the span of all ranges on it).
#' @noRd
.centromere_df <- function(x, arg = "centromeres", call = rlang::caller_env()) {
  if (!methods::is(x, "GRanges")) .abort_not_granges(arg, x, call = call)
  df <- .ranges_to_df(x)
  if (nrow(df) == 0) {
    return(data.frame(chr = integer(), centromere_start = numeric(),
                      centromere_end = numeric()))
  }
  starts <- tapply(df$start, df$chr, min)
  ends <- tapply(df$end, df$chr, max)
  data.frame(
    chr = as.integer(names(starts)),
    centromere_start = as.numeric(starts),
    centromere_end = as.numeric(ends)
  )
}

# Sex chromosome map from a Seqinfo: numbered chromosomes keep their number and
# named ones (X, Y, Z, W, MT, ...) are numbered after the last autosome, in the
# order of the Seqinfo. Scaffolds and unplaced contigs are skipped.
#' @noRd
.sex_map_from_seqinfo <- function(si) {
  seq <- sub("^chr", "", GenomeInfoDb::seqnames(si), ignore.case = TRUE)
  autosomes <- as.integer(seq[grepl("^[0-9]+$", seq)])
  named <- seq[grepl("^[A-Za-z]{1,2}$", seq)]
  if (length(named) == 0) {
    return(stats::setNames(integer(), character()))
  }
  first <- if (length(autosomes)) max(autosomes) + 1L else 1L
  map <- stats::setNames(first + seq_along(named) - 1L, named)
  if ("M" %in% names(map) && !"MT" %in% names(map)) {
    map <- c(map, MT = map[["M"]])
  }
  map
}

#' @noRd
.require_pkg <- function(pkg, why, call = rlang::caller_env()) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli_abort(c(
      "Package {.pkg {pkg}} is needed to {why}.",
      "i" = "Install it with {.code BiocManager::install(\"{pkg}\")}."
    ), call = call)
  }
}

# Nearest gene for each variant (chr = integer code, bp = position), using
# GenomicRanges::distanceToNearest. The distance is 0 for a variant inside a
# gene and otherwise the gap to the closest gene end. Variants with no gene
# within `max_distance` get NA.
#' @noRd
.nearest_genes <- function(chr, bp, genes, max_distance = Inf,
                           call = rlang::caller_env()) {
  out <- data.frame(gene = rep(NA_character_, length(chr)),
                    distance = rep(NA_real_, length(chr)))
  gene_df <- .ranges_to_df(.as_gene_ranges(genes, call = call))
  common <- intersect(unique(chr), unique(gene_df$chr))
  if (length(chr) == 0 || length(common) == 0) {
    return(out)
  }
  levels <- as.character(sort(union(chr, gene_df$chr)))
  gene_gr <- GenomicRanges::GRanges(
    factor(as.character(gene_df$chr), levels = levels),
    IRanges::IRanges(gene_df$start, gene_df$end)
  )
  snp_gr <- GenomicRanges::GRanges(
    factor(as.character(chr), levels = levels),
    IRanges::IRanges(bp, width = 1L)
  )
  hits <- GenomicRanges::distanceToNearest(snp_gr, gene_gr, ignore.strand = TRUE)
  q <- S4Vectors::queryHits(hits)
  s <- S4Vectors::subjectHits(hits)
  d <- S4Vectors::mcols(hits)$distance
  ok <- !is.na(d) & d <= max_distance
  out$gene[q[ok]] <- gene_df$gene[s[ok]]
  out$distance[q[ok]] <- d[ok]
  out
}

# Fail early, before any work, when gene models are not a GRanges/TxDb/EnsDb.
#' @noRd
.check_genes <- function(x, arg = "genes", call = rlang::caller_env()) {
  if (!methods::is(x, "GRanges") && !.is_annotation_db(x)) {
    .abort_not_granges(arg, x, call = call)
  }
  invisible(x)
}

# Chromosome lengths for plots: from `seqinfo` when given, otherwise the
# largest position seen in the data. Chromosomes in the data but missing from
# `seqinfo` also fall back to the data.
#' @noRd
.chr_lengths <- function(data, seqinfo = NULL, call = rlang::caller_env()) {
  chr_max <- tapply(data$BP, data$CHR, max)
  from_data <- data.frame(chr = as.integer(names(chr_max)),
                          length = as.numeric(chr_max))
  if (is.null(seqinfo)) {
    return(from_data)
  }
  from_si <- .as_seqinfo(seqinfo, call = call)
  rbind(from_si, from_data[!from_data$chr %in% from_si$chr, , drop = FALSE])
}

# Region to plot, from `region` or from `lead_snp` +/- `flank` in `data`.
# Returns the .as_region() list plus the region as a GRanges.
#' @noRd
.resolve_region <- function(data, region = NULL, lead_snp = NULL, flank = 5e5,
                            call = rlang::caller_env()) {
  if (!is.null(lead_snp) && "SNP" %in% names(data)) {
    lead_row <- data[!is.na(data$SNP) & data$SNP == lead_snp, , drop = FALSE]
    if (nrow(lead_row) == 0) {
      cli_abort("Lead SNP {.val {lead_snp}} not found.", call = call)
    }
    region <- GenomicRanges::GRanges(
      paste0("chr", int_to_chr(lead_row$CHR[1])),
      IRanges::IRanges(max(lead_row$BP[1] - flank, 1), lead_row$BP[1] + flank)
    )
  }
  if (is.null(region)) {
    cli_abort("Specify {.arg region} or {.arg lead_snp}.", call = call)
  }
  if (is.character(region)) {
    reg <- .as_region(region, call = call)
    region <- GenomicRanges::GRanges(
      paste0("chr", int_to_chr(reg$chr)), IRanges::IRanges(reg$start, reg$end)
    )
  }
  c(.as_region(region, call = call), list(gr = region))
}
