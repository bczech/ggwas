test_that("highlight_regions works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = runif(150)
  )
  plt <- manhattan_plot(df)
  regions <- data.frame(chr = 1, start = 5e6, end = 20e6, label = "Test")
  result <- highlight_regions(plt, regions)
  expect_s3_class(result, "ggplot")
})
