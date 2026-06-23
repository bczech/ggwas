test_that("filter_region works as expected", {
  data(example_gwas, package = "ggwas")
  result <- filter_region(example_gwas, chr = 1, start = 1e6, end = 50e6)
  expect_true(all(result$CHR == 1))
  expect_true(all(result$BP >= 1e6 & result$BP <= 50e6))
})

test_that("maf_filter works as expected", {
  data(example_gwas, package = "ggwas")
  result <- maf_filter(example_gwas, min_maf = 0.05)
  maf <- pmin(result$AF, 1 - result$AF)
  expect_true(all(maf >= 0.05, na.rm = TRUE))
})

test_that("merge_gwas works as expected", {
  df1 <- data.frame(CHR = 1, BP = 100, P = 0.01)
  df2 <- data.frame(CHR = 1, BP = 100, P = 0.05)
  result <- merge_gwas(A = df1, B = df2)
  expect_true("study" %in% names(result))
  expect_equal(nrow(result), 2)
})

test_that("get_loci works as expected", {
  df <- data.frame(
    CHR = rep(1, 100), BP = seq(1e6, 100e6, length.out = 100),
    P = c(1e-9, 1e-8, runif(98)), SNP = paste0("rs", 1:100)
  )
  result <- get_loci(df, p_threshold = 0.01)
  expect_true(nrow(result) > 0)
})
