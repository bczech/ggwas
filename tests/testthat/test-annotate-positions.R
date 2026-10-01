test_that("annotate_positions maps GTF gene IDs to coordinates", {
  f <- system.file("extdata", "example.gtf", package = "ggwas")
  ids <- read_gtf(f)$gene_id
  res <- annotate_positions(ids, source = "gtf", gtf = f)

  expect_s3_class(res, "data.frame")
  expect_true(all(c("id", "chr", "start", "end", "strand", "gene", "gene_id")
                  %in% names(res)))
  expect_true(nrow(res) >= 1)
  expect_type(res$chr, "integer")
  expect_setequal(res$gene_id, res$id)
})

test_that("annotate_positions errors when source = gtf without a file", {
  expect_error(annotate_positions("ENSG00000141510", source = "gtf"),
               "gtf")
})

test_that("annotate_positions matches symbols from GTF", {
  f <- system.file("extdata", "example.gtf", package = "ggwas")
  genes <- read_gtf(f)
  sym <- genes$gene[1]
  res <- annotate_positions(sym, source = "gtf", gtf = f, id_type = "symbol")

  expect_equal(nrow(res), 1L)
  expect_equal(res$gene, sym)
})

test_that("builtin annotation carries a gene_id column", {
  g <- gene_annotation("GRCh38")
  expect_true("gene_id" %in% names(g))

  res <- annotate_positions("TP53", source = "builtin", id_type = "symbol")
  expect_equal(nrow(res), 1L)
  expect_equal(res$gene, "TP53")
  expect_true(grepl("^ENSG", res$gene_id))
})

test_that("empty ids is an error", {
  expect_error(annotate_positions(character(0), source = "gtf", gtf = "x"),
               "empty")
})

test_that("biomart backend requires biomaRt", {
  skip_if_not_installed("biomaRt")
  # Live network query; keep it off CRAN/CI unless explicitly run.
  skip_on_cran()
  skip("biomaRt backend needs network; run manually")
})

test_that("ensdb backend requires an EnsDb object", {
  expect_error(annotate_positions("ENSG00000141510", source = "ensdb"),
               "ensdb")
})

test_that("value_manhattan annotates gene IDs end to end", {
  f <- system.file("extdata", "example.gtf", package = "ggwas")
  genes <- read_gtf(f)
  df <- data.frame(
    GeneID = genes$gene_id,
    score = seq_len(nrow(genes)) * 1000
  )

  p <- value_manhattan(df, value = "score", annotate = "gtf", gtf = f,
                       id = "GeneID")
  expect_s3_class(p, "ggplot")
})

test_that("value_manhattan auto-detects a gene start column", {
  df <- data.frame(
    chr = rep(1:3, each = 4),
    start = as.integer(seq(1e6, 1e6 + 11e6, length.out = 12)),
    score = runif(12, 0, 100)
  )
  # No GWAS-style position column, only "start": the gene fallback should catch it.
  p <- value_manhattan(df, value = "score")
  expect_s3_class(p, "ggplot")
})
