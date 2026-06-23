test_that("gwas_summary works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 100e6, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
  plt <- gwas_summary(df)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})
