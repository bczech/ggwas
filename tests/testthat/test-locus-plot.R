test_that("locus_plot works as expected", {
  df <- data.frame(
    CHR = rep(1, 100),
    BP = seq(1000, 100000, length.out = 100),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  plt <- locus_plot(df, region_chr = 1, region_start = 1000, region_end = 100000)
  expect_s3_class(plt, "ggplot")
})
