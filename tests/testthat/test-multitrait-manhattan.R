test_that("multitrait_manhattan works as expected", {
  df1 <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  df2 <- df1
  df2$P <- runif(100)^2
  plt <- multitrait_manhattan(Trait1 = df1, Trait2 = df2)
  expect_s3_class(plt, "ggplot")
})
