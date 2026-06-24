test_that("as_gwas_data converts data.frame correctly", {
  df <- data.frame(
    CHR = c(1, 1, 2),
    BP = c(100, 200, 300),
    P = c(0.1, 0.5, 0.001),
    SNP = c("rs1", "rs2", "rs3")
  )
  result <- as_gwas_data(df)
  expect_s3_class(result, "gwas_data")
  expect_equal(nrow(result), 3)
  expect_true(all(c("CHR", "BP", "P") %in% names(result)))
})

test_that("as_gwas_data handles custom column names", {
  df <- data.frame(
    chromosome = c(1, 2),
    position = c(100, 200),
    pvalue = c(0.1, 0.5)
  )
  result <- as_gwas_data(df, chr = "chromosome", bp = "position", p = "pvalue")
  expect_s3_class(result, "gwas_data")
  expect_equal(result$CHR, c(1L, 2L))
})

test_that("as_gwas_data handles log_p transformation", {
  df <- data.frame(CHR = 1, BP = 100, P = 5)
  result <- as_gwas_data(df, log_p = TRUE)
  expect_equal(result$P, 1e-5, tolerance = 1e-10)
})

test_that("as_gwas_data parses chromosome strings", {
  df <- data.frame(CHR = c("chr1", "chrX", "chr22", "chrMT"), BP = 1:4, P = rep(0.5, 4))
  result <- as_gwas_data(df)
  expect_equal(result$CHR, c(1L, 23L, 22L, 26L))
})

test_that("validate_gwas_data errors on invalid p-values", {
  df <- data.frame(CHR = 1, BP = 100, P = -0.5)
  expect_error(as_gwas_data(df), "outside")
})

test_that("validate_gwas_data warns on zero p-values", {
  df <- data.frame(CHR = 1, BP = 100, P = 0)
  expect_warning(as_gwas_data(df), "exactly 0")
})

test_that("print.gwas_data produces output", {
  df <- data.frame(CHR = c(1, 2), BP = c(100, 200), P = c(0.1, 0.5))
  gd <- as_gwas_data(df)
  expect_output(print(gd), "gwas_data")
})

test_that("summary.gwas_data produces output", {
  df <- data.frame(CHR = c(1, 2), BP = c(100, 200), P = c(0.1, 0.5))
  gd <- as_gwas_data(df)
  expect_output(summary(gd), "GWAS Data Summary")
})

test_that("as_gwas_data auto-detects common column names", {
  df <- data.frame(CHROM = 1, POS = 100, PVALUE = 0.05, ID = "rs1")
  result <- as_gwas_data(df)
  expect_s3_class(result, "gwas_data")
})

test_that("as_gwas_data preserves extra columns", {
  df <- data.frame(CHR = 1, BP = 100, P = 0.05, BETA = 0.1, INFO = 0.99)
  result <- as_gwas_data(df)
  expect_true("INFO" %in% names(result))
})

test_that("validate_gwas_data warns on NA p-values", {
  df <- data.frame(CHR = c(1, 1), BP = c(100, 200), P = c(0.05, NA))
  expect_warning(as_gwas_data(df), "NA")
})
