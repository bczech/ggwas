test_that("volcano_plot works as expected", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100),
    BETA = rnorm(100, 0, 0.1),
    SNP = paste0("rs", 1:100)
  )
  plt <- volcano_plot(df)
  expect_s3_class(plt, "ggplot")
})
