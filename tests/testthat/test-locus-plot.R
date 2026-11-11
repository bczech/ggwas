make_locus_df <- function(n = 100, from = 1e6, to = 10e6) {
  set.seed(1)
  data.frame(
    CHR = rep(1, n),
    BP = seq(from, to, length.out = n),
    P = c(1e-10, runif(n - 1)),
    SNP = paste0("rs", seq_len(n))
  )
}

test_that("locus_plot keeps only variants in the region", {
  plt <- locus_plot(make_locus_df(), region = "chr1:1000000-5000000")
  expect_s3_class(plt, "ggplot")
  expect_true(all(plt$data$BP >= 1e6 & plt$data$BP <= 5e6))
  expect_equal(plt$labels$x, "Position on chr1 (Mb)")
})

test_that("locus_plot accepts a GRanges region", {
  region <- GenomicRanges::GRanges("1", IRanges::IRanges(2e6, 4e6))
  plt <- locus_plot(make_locus_df(), region = region)
  expect_true(all(plt$data$BP >= 2e6 & plt$data$BP <= 4e6))
})

test_that("locus_plot centres on lead_snp", {
  plt <- locus_plot(make_locus_df(), lead_snp = "rs1", flank = 2e6)
  expect_true(all(plt$data$BP <= 1e6 + 2e6))
})

test_that("locus_plot needs a region or a lead SNP", {
  expect_error(locus_plot(make_locus_df()), "region")
  expect_error(locus_plot(make_locus_df(), region = "chr2:1-10"), "No variants")
})

test_that("locus_plot works with LD coloring", {
  df <- make_locus_df(50, 1e6, 5e6)
  ld <- stats::setNames(runif(50), df$SNP)
  plt <- locus_plot(df, region = "chr1:1000000-5000000", ld = ld)
  expect_true("LD_BIN" %in% names(plt$data))
})

test_that("locus_plot adds a gene track from GRanges", {
  genes <- GenomicRanges::GRanges("chr1:2000000-3000000:+", gene_name = "GENE1")
  plt <- locus_plot(make_locus_df(), region = "chr1:1000000-5000000",
                    genes = genes)
  expect_s3_class(plt, "patchwork")
  expect_error(
    locus_plot(make_locus_df(), region = "chr1:1000000-5000000",
               genes = data.frame(chr = 1, start = 2e6, end = 3e6)),
    "GRanges"
  )
})
