test_that("volcano_plot works as expected", {
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

test_that("volcano_plot handles color_by chromosome", {
  df <- data.frame(
    CHR = rep(1:3, each = 30), BP = 1:90,
    P = runif(90), BETA = rnorm(90), SNP = paste0("rs", 1:90)
  )
  plt <- volcano_plot(df, color_by = "chromosome", label_top_n = 3)
  expect_s3_class(plt, "ggplot")
})

test_that("volcano_plot handles beta_threshold", {
  df <- data.frame(
    CHR = 1, BP = 1:50, P = runif(50),
    BETA = rnorm(50, 0, 0.5), SNP = paste0("rs", 1:50)
  )
  plt <- volcano_plot(df, beta_threshold = 0.3)
  expect_s3_class(plt, "ggplot")
})

test_that("volcano_plot size_by works as expected", {
  plt <- volcano_plot(example_gwas, size_by = "AF")
  expect_s3_class(plt, "ggplot")
})

test_that("volcano_plot custom column color_by works as expected", {
  example_gwas$group <- ifelse(example_gwas$CHR < 10, "A", "B")
  plt <- volcano_plot(example_gwas, color_by = "group")
  expect_s3_class(plt, "ggplot")
})
