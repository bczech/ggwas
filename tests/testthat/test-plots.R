test_that("qq_plot returns ggplot", {
  p <- runif(500)
  plt <- qq_plot(p)
  expect_s3_class(plt, "ggplot")
})

test_that("qq_plot works with gwas_data", {
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

test_that("miami_plot returns patchwork", {
  df1 <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100)
  )
  df2 <- df1
  plt <- miami_plot(df1, df2)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})

test_that("locus_plot returns ggplot", {
  df <- data.frame(
    CHR = rep(1, 100),
    BP = seq(1000, 100000, length.out = 100),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  plt <- locus_plot(df, region_chr = 1, region_start = 1000, region_end = 100000)
  expect_s3_class(plt, "ggplot")
})

test_that("volcano_plot returns ggplot", {
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

test_that("pvalue_heatmap returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 1e8, length.out = 100), 3),
    P = runif(300)
  )
  plt <- pvalue_heatmap(df, bin_size = 1e7)
  expect_s3_class(plt, "ggplot")
})
