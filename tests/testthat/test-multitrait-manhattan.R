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

test_that("multitrait_manhattan works with palette name", {
  df1 <- data.frame(CHR = rep(1:2, each = 30),
    BP = rep(seq(1e6, 30e6, length.out = 30), 2),
    P = runif(60), SNP = paste0("rs", 1:60))
  df2 <- df1; df2$P <- runif(60)
  plt <- multitrait_manhattan(A = df1, B = df2, colors = "nature")
  expect_s3_class(plt, "ggplot")
})

test_that("multitrait_manhattan works with custom shapes", {
  df1 <- data.frame(CHR = rep(1, 30), BP = seq(1e6, 30e6, length.out = 30),
    P = runif(30), SNP = paste0("rs", 1:30))
  df2 <- df1; df2$P <- runif(30)
  plt <- multitrait_manhattan(X = df1, Y = df2,
    shapes = c(X = 16L, Y = 17L))
  expect_s3_class(plt, "ggplot")
})

test_that("multitrait_manhattan highlight_shared works", {
  df1 <- data.frame(CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100), SNP = paste0("rs", 1:100))
  df2 <- df1
  df2$P <- runif(100)^3
  plt <- multitrait_manhattan(A = df1, B = df2, highlight_shared = TRUE)
  expect_s3_class(plt, "ggplot")
})
