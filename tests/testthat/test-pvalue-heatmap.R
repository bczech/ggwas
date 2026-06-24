test_that("pvalue_heatmap returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 1e8, length.out = 100), 3),
    P = runif(300)
  )
  plt <- pvalue_heatmap(df, bin_size = 1e7)
  expect_s3_class(plt, "ggplot")
})

test_that("pvalue_heatmap works with different palettes", {
  plt <- pvalue_heatmap(example_gwas, bin_size = 1e7, palette = "magma")
  expect_s3_class(plt, "ggplot")
  plt2 <- pvalue_heatmap(example_gwas, bin_size = 1e7, palette = "inferno")
  expect_s3_class(plt2, "ggplot")
})

test_that("pvalue_heatmap count_sig mode works", {
  plt <- pvalue_heatmap(example_gwas, bin_size = 1e7, summary_fun = "count_sig")
  expect_s3_class(plt, "ggplot")
})

test_that("pvalue_heatmap works with chromosome subset", {
  plt <- pvalue_heatmap(example_gwas, bin_size = 1e7, chromosomes = 1:5)
  expect_s3_class(plt, "ggplot")
})
