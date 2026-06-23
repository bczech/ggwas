test_that("finemapping_plot works as expected", {
  df <- data.frame(
    CHR = rep(1, 100), BP = seq(1e6, 50e6, length.out = 100),
    P = runif(100), SNP = paste0("rs", 1:100),
    PIP = runif(100)^4,
    credible_set = c(rep(1L, 5), rep(NA_integer_, 95))
  )
  df$PIP[1] <- 0.9
  plt <- finemapping_plot(df, region_chr = 1,
                          region_start = 1e6, region_end = 50e6)
  expect_s3_class(plt, "ggplot")
})

test_that("finemapping_plot works without credible sets", {
  df <- data.frame(
    CHR = rep(1, 50), BP = seq(1e6, 30e6, length.out = 50),
    P = runif(50), SNP = paste0("rs", 1:50),
    PIP = runif(50)^3
  )
  plt <- finemapping_plot(df, region_chr = 1,
                          region_start = 1e6, region_end = 30e6)
  expect_s3_class(plt, "ggplot")
})
