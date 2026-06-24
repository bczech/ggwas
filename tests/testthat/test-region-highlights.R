test_that("highlight_regions works", {
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

test_that("highlight_regions works with multiple regions", {
  plt <- manhattan_plot(example_gwas)
  regions <- data.frame(
    chr = c(1, 6),
    start = c(5e6, 25e6),
    end = c(20e6, 35e6),
    label = c("Region1", "MHC")
  )
  result <- highlight_regions(plt, regions)
  expect_s3_class(result, "ggplot")
})

test_that("highlight_regions accepts custom colors", {
  plt <- manhattan_plot(example_gwas)
  regions <- data.frame(chr = 1, start = 5e6, end = 20e6, label = "Test")
  result <- highlight_regions(plt, regions, color = "blue", alpha = 0.3)
  expect_s3_class(result, "ggplot")
})
