test_that("read_plink_assoc reads example file", {
  f <- system.file("extdata", "example_plink.assoc", package = "ggwas")
  skip_if(f == "")
  result <- read_plink_assoc(f)
  expect_s3_class(result, "gwas_data")
  expect_true(nrow(result) > 0)
})

test_that("read_plink_linear reads linear format", {
  f <- system.file("extdata", "example_plink.assoc.linear", package = "ggwas")
  skip_if(f == "")
  result <- read_plink_linear(f)
  expect_s3_class(result, "gwas_data")
  expect_true("BETA" %in% names(result))
})

test_that("read_plink_logistic reads linear format as fallback", {
  f <- system.file("extdata", "example_plink.assoc.linear", package = "ggwas")
  skip_if(f == "")
  result <- read_plink_logistic(f)
  expect_s3_class(result, "gwas_data")
})

test_that("read_gcta_mlma reads example file", {
  f <- system.file("extdata", "example_gcta.mlma", package = "ggwas")
  skip_if(f == "")
  result <- read_gcta_mlma(f)
  expect_s3_class(result, "gwas_data")
  expect_equal(nrow(result), 4)
})

test_that("read_gemma reads example file", {
  f <- system.file("extdata", "example_gemma.assoc.txt", package = "ggwas")
  skip_if(f == "")
  result <- read_gemma(f)
  expect_s3_class(result, "gwas_data")
  expect_equal(nrow(result), 4)
})

test_that("read_regenie reads example file", {
  f <- system.file("extdata", "example_regenie.regenie", package = "ggwas")
  skip_if(f == "")
  result <- read_regenie(f)
  expect_s3_class(result, "gwas_data")
  expect_equal(nrow(result), 4)
})

test_that("read_gcta_mlma errors on missing file", {
  expect_error(read_gcta_mlma("nonexistent.mlma"))
})

test_that("read_gemma errors on missing file", {
  expect_error(read_gemma("nonexistent.assoc.txt"))
})

test_that("read_regenie errors on missing file", {
  expect_error(read_regenie("nonexistent.regenie"))
})
