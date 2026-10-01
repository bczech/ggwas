#' Map gene IDs or symbols to genome coordinates
#'
#' Look up genomic positions (chromosome, start, end, strand) for a set of
#' Ensembl gene IDs or gene symbols. This is the inverse of [annotate_genes()],
#' which maps variant positions to the nearest gene; here you start from gene
#' identifiers and get their coordinates, ready to feed into [value_manhattan()]
#' or any plot that needs `chr`/`bp`. Several annotation sources are supported,
#' trading offline convenience against coverage and the ability to pick an
#' arbitrary Ensembl release.
#'
#' @param ids Character vector of gene identifiers (Ensembl gene IDs such as
#'   `"ENSG00000141510"`, or gene symbols such as `"TP53"`).
#' @param source Annotation backend:
#'   * `"gtf"` (default) reads a local GTF/GFF3 file via [read_gtf()]. Full
#'     coverage, offline, works for any build you have a file for; requires
#'     `gtf`.
#'   * `"builtin"` uses the protein-coding genes bundled with ggwas
#'     ([gene_annotation()]). Offline and dependency-free, but limited to
#'     protein-coding genes for GRCh38 (release 103) and GRCh37 (release 75).
#'   * `"biomart"` queries Ensembl online (any release/build). Needs the
#'     \pkg{biomaRt} package and network access.
#'   * `"ensdb"` reads an `EnsDb` object you pass via `ensdb`. Needs the
#'     \pkg{ensembldb} package and an installed `EnsDb.Hsapiens.*` data package.
#' @param build Genome build for the `"builtin"` and `"biomart"` sources:
#'   `"GRCh38"` (default) or `"GRCh37"`.
#' @param release Ensembl release for `source = "biomart"`. `NULL` (default)
#'   uses the current release.
#' @param gtf Path to a GTF/GFF3 file (required when `source = "gtf"`).
#' @param ensdb An `EnsDb` object (required when `source = "ensdb"`).
#' @param id_type Whether `ids` are Ensembl gene IDs (`"ensembl_gene_id"`,
#'   default) or gene symbols (`"symbol"`).
#' @return A data.frame with one row per matched identifier and columns `id`
#'   (the input identifier), `chr` (integer), `start`, `end`, `strand`, `gene`
#'   (symbol) and `gene_id` (Ensembl gene ID). Identifiers that cannot be mapped
#'   are dropped.
#' @seealso [value_manhattan()], [read_gtf()], [gene_annotation()]
#' @export
#' @examples
#' # Offline, from a GTF file (uses the tiny example shipped with ggwas)
#' f <- system.file("extdata", "example.gtf", package = "ggwas")
#' ids <- read_gtf(f)$gene_id
#' annotate_positions(ids, source = "gtf", gtf = f)
#'
#' # From the bundled protein-coding annotation, by symbol
#' annotate_positions(c("TP53", "BRCA1"), source = "builtin", id_type = "symbol")
annotate_positions <- function(ids,
                               source = c("gtf", "biomart", "ensdb", "builtin"),
                               build = c("GRCh38", "GRCh37"),
                               release = NULL,
                               gtf = NULL,
                               ensdb = NULL,
                               id_type = c("ensembl_gene_id", "symbol")) {

  source <- match.arg(source)
  build <- match.arg(build)
  id_type <- match.arg(id_type)

  ids <- unique(as.character(ids))
  ids <- ids[!is.na(ids) & nzchar(ids)]
  if (length(ids) == 0) {
    cli_abort("{.arg ids} is empty: provide at least one gene identifier.")
  }

  ann <- switch(source,
    gtf = .annotate_from_gtf(gtf),
    builtin = .annotate_from_builtin(build),
    biomart = .annotate_from_biomart(ids, build, release, id_type),
    ensdb = .annotate_from_ensdb(ensdb)
  )

  # biomaRt already filtered to the requested ids and id_type, so just tidy up.
  key <- if (id_type == "symbol") "gene" else "gene_id"
  out <- ann[match(ids, ann[[key]]), , drop = FALSE]
  out$id <- ids
  out <- out[!is.na(out$chr) & !is.na(out[[key]]), , drop = FALSE]

  n_in <- length(ids)
  cli_inform("Mapped {nrow(out)}/{n_in} identifier{?s} to coordinates ({.val {source}}).")
  if (nrow(out) == 0) {
    cli_warn(c(
      "No identifiers could be mapped.",
      "i" = "Check that {.arg id_type} ({.val {id_type}}) matches your {.arg ids}."
    ))
  }

  out <- out[, c("id", "chr", "start", "end", "strand", "gene", "gene_id"),
             drop = FALSE]
  rownames(out) <- NULL
  out
}

# --- backends ---------------------------------------------------------------

# Read a GTF/GFF3 and return the standard annotation columns. read_gtf()
# already yields chr/start/end/strand/gene/gene_id, so this just validates the
# argument.
.annotate_from_gtf <- function(gtf) {
  if (is.null(gtf)) {
    cli_abort(c(
      "{.arg gtf} is required when {.arg source} is {.val gtf}.",
      "i" = "Pass a path to a GTF/GFF3 file, or use {.code source = \"builtin\"}."
    ))
  }
  read_gtf(gtf, biotype = NULL)
}

# Bundled protein-coding genes. gene_annotation() gained a gene_id column, so
# this works for both Ensembl IDs and symbols.
.annotate_from_builtin <- function(build) {
  g <- gene_annotation(build)
  if (!"gene_id" %in% names(g)) {
    cli_abort(c(
      "Built-in annotation for {.val {build}} has no {.field gene_id} column.",
      "i" = "Regenerate it with {.file data-raw/genes.R}, or use another source."
    ))
  }
  cli_inform("Using built-in protein-coding genes for {.val {build}}.")
  g
}

# Online Ensembl lookup. Filters to the requested ids server-side.
.annotate_from_biomart <- function(ids, build, release, id_type) {
  if (!requireNamespace("biomaRt", quietly = TRUE)) {
    cli_abort(c(
      "Package {.pkg biomaRt} is required for {.code source = \"biomart\"}.",
      "i" = "Install it with {.code BiocManager::install(\"biomaRt\")}, or use {.code source = \"gtf\"}."
    ))
  }

  grch <- if (build == "GRCh37") 37 else NULL
  mart <- biomaRt::useEnsembl(
    biomart = "genes",
    dataset = "hsapiens_gene_ensembl",
    version = release,
    GRCh = grch
  )

  filter <- if (id_type == "symbol") "external_gene_name" else "ensembl_gene_id"
  res <- biomaRt::getBM(
    attributes = c("ensembl_gene_id", "external_gene_name",
                   "chromosome_name", "start_position", "end_position",
                   "strand"),
    filters = filter,
    values = ids,
    mart = mart
  )

  data.frame(
    chr = chr_to_int(res$chromosome_name),
    start = res$start_position,
    end = res$end_position,
    strand = ifelse(res$strand < 0, "-", "+"),
    gene = res$external_gene_name,
    gene_id = res$ensembl_gene_id,
    stringsAsFactors = FALSE
  )
}

# Offline EnsDb lookup from a user-supplied EnsDb object.
.annotate_from_ensdb <- function(ensdb) {
  if (is.null(ensdb)) {
    cli_abort(c(
      "{.arg ensdb} is required when {.arg source} is {.val ensdb}.",
      "i" = "Pass an EnsDb object, e.g. {.code EnsDb.Hsapiens.v86}."
    ))
  }
  if (!requireNamespace("ensembldb", quietly = TRUE)) {
    cli_abort(c(
      "Package {.pkg ensembldb} is required for {.code source = \"ensdb\"}.",
      "i" = "Install it with {.code BiocManager::install(\"ensembldb\")}, or use {.code source = \"gtf\"}."
    ))
  }

  g <- as.data.frame(ensembldb::genes(ensdb))
  strand <- as.character(g$strand)
  strand[!strand %in% c("+", "-")] <- "*"
  data.frame(
    chr = chr_to_int(g$seqnames),
    start = g$start,
    end = g$end,
    strand = strand,
    gene = g$gene_name,
    gene_id = g$gene_id,
    stringsAsFactors = FALSE
  )
}
