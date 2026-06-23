test_that("coloc_plot works as expected", {
  df1 <- data.frame(
    CHR = rep(1, 100), BP = seq(1e6, 50e6, length.out = 100),
    P = runif(100), SNP = paste0("rs", 1:100)
  )
  df2 <- df1
  df2$P <- runif(100)^2
  plt <- coloc_plot(df1, df2, region_chr = 1,
                    region_start = 1e6, region_end = 50e6)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})
