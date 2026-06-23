test_that("architecture_plot works as expected", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100), BETA = rnorm(100, 0, 0.1),
    AF = runif(100, 0.01, 0.5), SNP = paste0("rs", 1:100)
  )
  plt <- architecture_plot(df)
  expect_s3_class(plt, "ggplot")
})

test_that("architecture_plot handles log MAF scale", {
  df <- data.frame(
    CHR = rep(1, 50), BP = 1:50,
    P = runif(50), BETA = rnorm(50), AF = runif(50, 0.01, 0.5)
  )
  plt <- architecture_plot(df, log_maf = TRUE)
  expect_s3_class(plt, "ggplot")
})
