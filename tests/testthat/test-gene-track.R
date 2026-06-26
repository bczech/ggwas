test_that("gene_track works as expected", {
  genes <- data.frame(
    chr = c(1, 1, 1, 2),
    start = c(1e6, 5e6, 8e6, 3e6),
    end = c(2e6, 6e6, 9e6, 4e6),
    gene = c("GeneA", "GeneB", "GeneC", "GeneD"),
    strand = c("+", "-", "+", "+")
  )

  p <- gene_track(genes, region_chr = 1,
                   region_start = 0, region_end = 10e6)
  expect_s3_class(p, "gg")
})

test_that("gene_track filters to region", {
  genes <- data.frame(
    chr = c(1, 1, 2),
    start = c(1e6, 5e6, 3e6),
    end = c(2e6, 6e6, 4e6),
    gene = c("A", "B", "C"),
    strand = c("+", "-", "+")
  )

  p <- gene_track(genes, 1, 4e6, 7e6)
  expect_s3_class(p, "gg")
})

test_that("gene_track handles empty region", {
  genes <- data.frame(
    chr = 2, start = 1e6, end = 2e6, gene = "X", strand = "+"
  )

  p <- gene_track(genes, 1, 0, 10e6)
  expect_s3_class(p, "gg")
})

test_that("gene_track highlight works as expected", {
  genes <- data.frame(
    chr = c(1, 1), start = c(1e6, 5e6), end = c(2e6, 6e6),
    gene = c("TP53", "BRCA1"), strand = c("+", "-")
  )

  p <- gene_track(genes, 1, 0, 10e6, highlight_genes = "TP53")
  expect_s3_class(p, "gg")
})

test_that("gene_track works without strand column", {
  genes <- data.frame(
    chr = c(1, 1), start = c(1e6, 5e6), end = c(2e6, 6e6),
    gene = c("A", "B")
  )

  p <- gene_track(genes, 1, 0, 10e6)
  expect_s3_class(p, "gg")
})

test_that("gene_track respects max_genes", {
  genes <- data.frame(
    chr = rep(1, 100),
    start = seq(1e6, 100e6, length.out = 100),
    end = seq(1e6, 100e6, length.out = 100) + 5e5,
    gene = paste0("Gene", 1:100),
    strand = rep("+", 100)
  )

  p <- gene_track(genes, 1, 0, 110e6, max_genes = 10)
  expect_s3_class(p, "gg")
})

test_that("gene_track handles character chromosome", {
  genes <- data.frame(
    chr = c("chr1", "chr1"), start = c(1e6, 5e6), end = c(2e6, 6e6),
    gene = c("A", "B"), strand = c("+", "-")
  )

  p <- gene_track(genes, "chr1", 0, 10e6)
  expect_s3_class(p, "gg")
})
