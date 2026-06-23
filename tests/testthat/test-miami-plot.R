test_that("miami_plot works as expected", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100)
  )
  plt <- miami_plot(df, df)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})
