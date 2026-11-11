make_annotation <- function() {
  GenomicRanges::GRanges(
    c("chr17:7661779-7687538:-", "chr17:43044295-43170245:-",
      "chrX:100000-200000:+"),
    gene_id = c("ENSG00000141510", "ENSG00000012048", "ENSGX"),
    gene_name = c("TP53", "BRCA1", "GENEX")
  )
}

test_that("annotate_positions maps gene IDs to ranges", {
  res <- annotate_positions(c("ENSG00000012048", "ENSG00000141510"),
                            make_annotation())
  expect_s4_class(res, "GRanges")
  expect_equal(res$id, c("ENSG00000012048", "ENSG00000141510"))
  expect_equal(res$gene, c("BRCA1", "TP53"))
  expect_equal(GenomicRanges::start(res), c(43044295, 7661779))
})

test_that("annotate_positions matches symbols and drops unknown IDs", {
  expect_message(
    res <- annotate_positions(c("TP53", "NOPE"), make_annotation(),
                              id_type = "symbol"),
    "1/2"
  )
  expect_equal(res$gene_id, "ENSG00000141510")
  expect_warning(
    expect_message(annotate_positions("NOPE", make_annotation())),
    "No identifiers"
  )
})

test_that("annotate_positions checks its inputs", {
  expect_error(annotate_positions(character(0), make_annotation()), "empty")
  expect_error(annotate_positions("TP53", data.frame(gene = "TP53")), "GRanges")
})

test_that("annotate_positions reads an EnsDb", {
  skip_if_not_installed("EnsDb.Hsapiens.v86")
  edb <- EnsDb.Hsapiens.v86::EnsDb.Hsapiens.v86
  res <- suppressMessages(annotate_positions("TP53", edb, id_type = "symbol"))
  expect_equal(res$gene_id, "ENSG00000141510")
  expect_equal(as.character(GenomicRanges::seqnames(res)), "17")
})

test_that("annotate_positions reads ranges imported with rtracklayer", {
  skip_if_not_installed("rtracklayer")
  f <- system.file("extdata", "example.gtf", package = "ggwas")
  gtf <- rtracklayer::import(f)
  genes <- gtf[gtf$type == "gene"]
  res <- suppressMessages(annotate_positions(genes$gene_id, genes))
  expect_equal(res$id, unique(genes$gene_id))
})

test_that("value_manhattan looks up coordinates from gene IDs", {
  df <- data.frame(
    GeneID = c("ENSG00000141510", "ENSG00000012048", "missing"),
    score = c(10, 20, 30)
  )
  p <- suppressMessages(value_manhattan(df, value = "score",
                                        annotation = make_annotation(),
                                        id = "GeneID"))
  expect_s3_class(p, "ggplot")
  expect_equal(sort(p$data$VALUE), c(10, 20))
})

test_that("value_manhattan auto-detects a gene start column", {
  df <- data.frame(
    chr = rep(1:3, each = 4),
    start = as.integer(seq(1e6, 1e6 + 11e6, length.out = 12)),
    score = runif(12, 0, 100)
  )
  p <- value_manhattan(df, value = "score")
  expect_s3_class(p, "ggplot")
})
