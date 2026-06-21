test_that("manhattan_plot returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1000, 100000, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
  plt <- manhattan_plot(df)
  expect_s3_class(plt, "ggplot")
})

test_that("manhattan_plot handles gwas_data input", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100)
  )
  gd <- as_gwas_data(df)
  plt <- manhattan_plot(gd)
  expect_s3_class(plt, "ggplot")
})

test_that("manhattan_plot handles chromosome subsetting", {
  df <- data.frame(
    CHR = rep(1:5, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 5),
    P = runif(250)
  )
  plt <- manhattan_plot(df, chromosomes = c(1, 3))
  expect_s3_class(plt, "ggplot")
})

test_that("manhattan_plot handles labeling", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = c(runif(99), 1e-10),
    SNP = paste0("rs", 1:100)
  )
  plt <- manhattan_plot(df, label_top_n = 3)
  expect_s3_class(plt, "ggplot")
})

test_that("manhattan_plot handles highlighting", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1000, 50000, length.out = 50), 2),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  plt <- manhattan_plot(df, highlight_snps = c("rs1", "rs50"))
  expect_s3_class(plt, "ggplot")
})
