test_that("circular_manhattan works as expected", {
  df <- data.frame(
    CHR = rep(1:5, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 5),
    P = runif(250),
    SNP = paste0("rs", 1:250)
  )
  plt <- circular_manhattan(df)
  expect_s3_class(plt, "ggplot")
})

test_that("circular_manhattan handles multi-ring", {
  df1 <- data.frame(
    CHR = rep(1:3, each = 30),
    BP = rep(seq(1e6, 30e6, length.out = 30), 3),
    P = runif(90)
  )
  df2 <- df1
  df2$P <- runif(90)^2
  plt <- circular_manhattan(list(Trait1 = df1, Trait2 = df2))
  expect_s3_class(plt, "ggplot")
})

test_that("circular_manhattan with palette name works as expected", {
  plt <- circular_manhattan(example_gwas, colors = "nature")
  expect_s3_class(plt, "ggplot")
})

test_that("circular_manhattan highlight and label works as expected", {
  snps <- head(example_gwas$SNP[order(example_gwas$P)], 3)
  plt <- circular_manhattan(example_gwas, highlight_snps = snps,
    label_top_n = 2)
  expect_s3_class(plt, "ggplot")
})
