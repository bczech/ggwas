test_that("read_gtf works as expected", {
  gtf_path <- test_path("example.gtf")
  genes <- read_gtf(gtf_path)

  expect_s3_class(genes, "data.frame")
  expect_equal(nrow(genes), 4)
  expect_true(all(c("chr", "start", "end", "gene", "strand", "gene_id") %in% names(genes)))
  expect_equal(genes$gene, c("GeneA", "GeneB", "GeneC", "GeneD"))
  expect_equal(genes$chr, c(1L, 1L, 1L, 2L))
})

test_that("read_gtf filters by feature type", {
  gtf_path <- test_path("example.gtf")
  exons <- read_gtf(gtf_path, feature_type = "exon")

  expect_equal(nrow(exons), 2)
  expect_equal(exons$gene, c("GeneA", "GeneA"))
})

test_that("read_gtf returns empty for missing feature type", {
  gtf_path <- test_path("example.gtf")
  expect_warning(result <- read_gtf(gtf_path, feature_type = "CDS"))
  expect_equal(nrow(result), 0)
})

test_that("read_gtf fails on missing file", {
  expect_error(read_gtf("nonexistent.gtf"))
})

test_that("read_gtf output works with gene_track", {
  gtf_path <- test_path("example.gtf")
  genes <- read_gtf(gtf_path)

  p <- gene_track(genes, region_chr = 1, region_start = 0, region_end = 10e6)
  expect_s3_class(p, "gg")
})
