#' Map gene IDs or symbols to genome coordinates
#'
#' Look up genomic positions for a set of gene identifiers in a gene
#' annotation. This is the inverse of [annotate_genes()], which maps variant
#' positions to the nearest gene; here you start from gene identifiers and get
#' their coordinates, for example to feed into [value_manhattan()].
#'
#' @param ids Character vector of gene identifiers (Ensembl gene IDs such as
#'   `"ENSG00000141510"`, Entrez IDs, or gene symbols such as `"TP53"`).
#' @param annotation Gene models as a [GenomicRanges::GRanges] object, or a
#'   `TxDb` (\pkg{GenomicFeatures}) or `EnsDb` (\pkg{ensembldb}) object. Gene
#'   IDs are read from the `gene_id` metadata column (or `names()`), symbols
#'   from `gene_name`, `symbol` or `gene`. GTF and GFF3 files can be read with
#'   `rtracklayer::import()`; keep the `type == "gene"` rows.
#' @param id_type Whether `ids` are gene IDs (`"gene_id"`, default) or gene
#'   symbols (`"symbol"`).
#' @return A [GenomicRanges::GRanges] with one range per matched identifier and
#'   metadata columns `id` (the input identifier), `gene` (symbol) and
#'   `gene_id`. Identifiers that cannot be mapped are dropped.
#' @seealso [value_manhattan()], [annotate_genes()]
#' @export
#' @examples
#' genes <- GenomicRanges::GRanges(
#'   c("chr17:7661779-7687538:-", "chr17:43044295-43170245:-"),
#'   gene_id = c("ENSG00000141510", "ENSG00000012048"),
#'   gene_name = c("TP53", "BRCA1")
#' )
#' annotate_positions(c("ENSG00000141510", "ENSG00000012048"), genes)
#' annotate_positions(c("TP53", "NOT_A_GENE"), genes, id_type = "symbol")
annotate_positions <- function(ids,
                               annotation,
                               id_type = c("gene_id", "symbol")) {

  id_type <- match.arg(id_type)
  .check_genes(annotation, arg = "annotation")

  ids <- unique(as.character(ids))
  ids <- ids[!is.na(ids) & nzchar(ids)]
  if (length(ids) == 0) {
    cli_abort("{.arg ids} is empty: provide at least one gene identifier.")
  }

  genes <- .as_gene_ranges(annotation, arg = "annotation")
  key <- if (id_type == "symbol") genes$gene else genes$gene_id
  hit <- match(ids, key)
  out <- genes[hit[!is.na(hit)]]
  S4Vectors::mcols(out) <- S4Vectors::DataFrame(
    id = ids[!is.na(hit)],
    gene = out$gene,
    gene_id = out$gene_id
  )
  names(out) <- NULL

  cli_inform("Mapped {length(out)}/{length(ids)} identifier{?s} to coordinates.")
  if (length(out) == 0) {
    cli_warn(c(
      "No identifiers could be mapped.",
      "i" = "Check that {.arg id_type} ({.val {id_type}}) matches your {.arg ids}."
    ))
  }
  out
}
