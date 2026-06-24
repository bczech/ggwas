test_that("miami_plot returns patchwork", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100)
  )
  plt <- miami_plot(df, df)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})

test_that("miami_plot accepts titles", {
  plt <- miami_plot(example_gwas, example_gwas,
    top_title = "A", bottom_title = "B")
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})

test_that("miami_plot accepts custom colors", {
  plt <- miami_plot(example_gwas, example_gwas,
    colors = c("red", "blue"))
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})
