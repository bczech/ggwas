test_that("smart_downsample reduces rows", {
  df <- data.frame(
    CHR = rep(1, 10000),
    BP = seq_len(10000),
    P = runif(10000),
    SNP = paste0("rs", 1:10000)
  )
  result <- smart_downsample(df, target_n = 1000)
  expect_lt(nrow(result), 10000)
})

test_that("smart_downsample preserves significant SNPs", {
  df <- data.frame(
    CHR = rep(1, 10000),
    BP = seq_len(10000),
    P = c(1e-10, 1e-8, 1e-6, runif(9997)),
    SNP = paste0("rs", 1:10000)
  )
  result <- smart_downsample(df, target_n = 1000, p_keep = 1e-5)
  expect_true(all(df$SNP[1:3] %in% result$SNP))
})

test_that("smart_downsample preserves specified SNPs", {
  df <- data.frame(
    CHR = rep(1, 10000),
    BP = seq_len(10000),
    P = runif(10000),
    SNP = paste0("rs", 1:10000)
  )
  keep <- c("rs5000", "rs9999")
  result <- smart_downsample(df, target_n = 1000, keep_snps = keep)
  expect_true(all(keep %in% result$SNP))
})

test_that("smart_downsample returns unchanged data below threshold", {
  df <- data.frame(CHR = 1, BP = 1:100, P = runif(100))
  result <- smart_downsample(df, target_n = 200)
  expect_equal(nrow(result), 100)
})
