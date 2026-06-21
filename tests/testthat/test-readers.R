test_that("read_gwas_table reads PLINK assoc format", {
  f <- system.file("extdata", "example_plink.assoc", package = "gwasplot")
  skip_if(f == "", message = "Example data not available")
  result <- read_gwas_table(f)
  expect_s3_class(result, "gwas_data")
  expect_gt(nrow(result), 0)
  expect_true(all(c("CHR", "BP", "P") %in% names(result)))
})

test_that("read_gwas_table errors on missing file", {
  expect_error(read_gwas_table("nonexistent.txt"), "not found")
})

test_that("read_plink_assoc reads correctly", {
  f <- system.file("extdata", "example_plink.assoc", package = "gwasplot")
  skip_if(f == "", message = "Example data not available")
  result <- read_plink_assoc(f)
  expect_s3_class(result, "gwas_data")
  expect_true("SNP" %in% names(result))
})
