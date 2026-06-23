test_that("qq_plot works as expected", {
  plt <- qq_plot(runif(500))
  expect_s3_class(plt, "ggplot")
})

test_that("qq_plot works with gwas_data input", {
  df <- data.frame(CHR = rep(1, 200), BP = 1:200, P = runif(200))
  gd <- as_gwas_data(df)
  plt <- qq_plot(gd)
  expect_s3_class(plt, "ggplot")
})

test_that("qq_plot handles stratified groups", {
  df <- data.frame(
    CHR = rep(1, 200), BP = 1:200, P = runif(200),
    group = rep(c("A", "B"), 100)
  )
  gd <- as_gwas_data(df)
  plt <- qq_plot(gd, group = "group")
  expect_s3_class(plt, "ggplot")
})
