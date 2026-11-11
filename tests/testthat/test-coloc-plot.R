test_that("coloc_plot returns two stacked locus plots", {
  df1 <- data.frame(
    CHR = rep(1, 100), BP = seq(1e6, 50e6, length.out = 100),
    P = runif(100), SNP = paste0("rs", 1:100)
  )
  df2 <- df1
  df2$P <- runif(100)^2
  plt <- coloc_plot(df1, df2, region = "chr1:1000000-50000000")
  expect_s3_class(plt, "patchwork")
  expect_length(plt$patches$plots, 1L)
})

test_that("coloc_plot accepts titles and a lead SNP", {
  plt <- coloc_plot(example_gwas, example_gwas,
    region = GenomicRanges::GRanges("chr1:1000000-50000000"),
    top_title = "GWAS", bottom_title = "eQTL")
  expect_s3_class(plt, "patchwork")
  lead <- example_gwas$SNP[which.min(example_gwas$P)]
  expect_s3_class(coloc_plot(example_gwas, example_gwas, lead_snp = lead),
                  "patchwork")
  expect_error(coloc_plot(example_gwas, example_gwas), "region")
})
