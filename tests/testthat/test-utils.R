test_that("calc_lambda returns 1 for uniform p-values", {
  set.seed(42)
  p <- runif(10000)
  lambda <- calc_lambda(p)
  expect_equal(lambda, 1, tolerance = 0.1)
})

test_that("calc_lambda detects inflation", {
  set.seed(42)
  p <- runif(10000)^2
  lambda <- calc_lambda(p)
  expect_gt(lambda, 1)
})

test_that("chr_to_int handles various formats", {
  expect_equal(chr_to_int("chr1"), 1L)
  expect_equal(chr_to_int("X"), 23L)
  expect_equal(chr_to_int("chrMT"), 26L)
  expect_equal(chr_to_int("22"), 22L)
})

test_that("int_to_chr converts back correctly", {
  expect_equal(int_to_chr(1), "1")
  expect_equal(int_to_chr(23), "X")
  expect_equal(int_to_chr(26), "MT")
})

test_that("detect_columns finds standard names", {
  header <- c("CHR", "BP", "SNP", "P", "BETA", "SE")
  result <- detect_columns(header)
  expect_equal(result$CHR, "CHR")
  expect_equal(result$BP, "BP")
  expect_equal(result$P, "P")
})

test_that("detect_columns finds alternative names", {
  header <- c("#CHROM", "POS", "ID", "PVALUE", "EFFECT")
  result <- detect_columns(header)
  expect_equal(result$CHR, "#CHROM")
  expect_equal(result$BP, "POS")
})

test_that("add_cumulative_bp adds BP_CUM column", {
  df <- data.frame(CHR = c(1, 1, 2, 2), BP = c(100, 200, 100, 200), P = 0.5)
  result <- add_cumulative_bp(df)
  expect_true("BP_CUM" %in% names(result))
  expect_true(!is.null(attr(result, "chr_info")))
})
