test_that("pvalue_heatmap works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 1e8, length.out = 100), 3),
    P = runif(300)
  )
  plt <- pvalue_heatmap(df, bin_size = 1e7)
  expect_s3_class(plt, "ggplot")
})
