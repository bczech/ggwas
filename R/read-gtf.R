#' Read gene annotations from GTF/GFF3 file
#'
#' Parse a GTF or GFF3 annotation file and return a data.frame of gene
#' positions ready for use with [gene_track()] or [locus_plot()].
#' Supports `.gz` compressed files.
#'
#' @param path Path to GTF or GFF3 file (plain text or gzipped).
#' @param feature_type Feature type to extract (column 3 of GTF).
#'   Default `"gene"`.
#' @param gene_name_attr Attribute key(s) to use as gene name, tried in
#'   order. For GTF: `"gene_name"`, for GFF3: `"Name"`.
#' @param gene_id_attr Attribute key for gene ID (e.g. ENSG...).
#' @param biotype Character vector of gene biotypes to keep, e.g.
#'   `"protein_coding"`. If NULL (default), all biotypes are returned.
#' @return A data.frame with columns: chr (integer), start, end, gene,
#'   strand, gene_id. Ready for [gene_track()] or
#'   `locus_plot(gene_data = ...)`.
#' @export
#' @examples
#' \dontrun{
#' # Ensembl GTF
#' genes <- read_gtf("Homo_sapiens.GRCh38.110.gtf.gz")
#'
#' # Use with gene_track
#' gene_track(genes, region_chr = 6, region_start = 25e6, region_end = 35e6)
#'
#' # GFF3 format
#' genes <- read_gtf("gencode.v44.annotation.gff3.gz")
#' }
read_gtf <- function(path,
                     feature_type = "gene",
                     gene_name_attr = c("gene_name", "Name", "gene"),
                     gene_id_attr = "gene_id",
                     biotype = NULL) {

  if (!file.exists(path)) {
    cli_abort("File not found: {.file {path}}")
  }

  gtf <- data.table::fread(
    path, sep = "\t", header = FALSE, quote = "",
    select = c(1L, 3L, 4L, 5L, 7L, 9L),
    col.names = c("seqname", "feature", "start", "end", "strand", "attributes"),
    comment.char = "#"
  )

  gtf <- gtf[gtf$feature == feature_type, , drop = FALSE]

  if (nrow(gtf) == 0) {
    cli_warn("No features of type {.val {feature_type}} found in {.file {path}}.")
    return(data.frame(chr = integer(), start = numeric(), end = numeric(),
                      gene = character(), strand = character(),
                      gene_id = character()))
  }

  is_gff3 <- any(grepl("=", gtf$attributes[1:min(5, nrow(gtf))]))

  if (is_gff3) {
    parse_fn <- .parse_gff3_attributes
  } else {
    parse_fn <- .parse_gtf_attributes
  }

  genes <- data.frame(
    chr = chr_to_int(gtf$seqname),
    start = gtf$start,
    end = gtf$end,
    strand = gtf$strand,
    stringsAsFactors = FALSE
  )

  genes$gene <- NA_character_
  for (attr_key in gene_name_attr) {
    vals <- parse_fn(gtf$attributes, attr_key)
    missing <- is.na(genes$gene)
    genes$gene[missing] <- vals[missing]
  }

  genes$gene_id <- parse_fn(gtf$attributes, gene_id_attr)

  if (!is.null(biotype)) {
    bt <- parse_fn(gtf$attributes, "gene_biotype")
    if (all(is.na(bt))) bt <- parse_fn(gtf$attributes, "gene_type")
    genes <- genes[!is.na(bt) & bt %in% biotype, , drop = FALSE]
  }

  genes$gene[is.na(genes$gene)] <- genes$gene_id[is.na(genes$gene)]
  genes <- genes[!is.na(genes$chr), , drop = FALSE]

  cli_inform("Read {nrow(genes)} {feature_type} features from {.file {basename(path)}}.")
  rownames(genes) <- NULL
  genes
}

.parse_gtf_attributes <- function(attrs, key) {
  pattern <- paste0(key, '\\s+"([^"]+)"')
  m <- regmatches(attrs, regexec(pattern, attrs))
  vapply(m, function(x) if (length(x) >= 2) x[2] else NA_character_, character(1))
}

.parse_gff3_attributes <- function(attrs, key) {
  pattern <- paste0("(?:^|;)", key, "=([^;]+)")
  m <- regmatches(attrs, regexec(pattern, attrs, perl = TRUE))
  vapply(m, function(x) if (length(x) >= 2) x[2] else NA_character_, character(1))
}
