test_that("read_plink_assoc reads example file", {
  f <- system.file("extdata", "example_plink.assoc", package = "ggwas")
  skip_if(f == "")
  result <- read_plink_assoc(f)
  expect_s3_class(result, "gwas_data")
  expect_true(nrow(result) > 0)
})

test_that("read_plink_linear reads example file", {
  f <- system.file("extdata", "example_plink.assoc", package = "ggwas")
  skip_if(f == "")
  result <- read_plink_linear(f)
  expect_s3_class(result, "gwas_data")
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
