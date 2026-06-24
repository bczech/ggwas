test_that("example_gwas has correct structure", {
  data(example_gwas, package = "ggwas")
  expect_s3_class(example_gwas, "gwas_data")
  expect_true(nrow(example_gwas) > 0)
  expect_true(all(c("CHR", "BP", "SNP", "P", "BETA", "SE", "AF") %in% names(example_gwas)))
})

test_that("example_gwas has valid p-values", {
  expect_true(all(example_gwas$P > 0 & example_gwas$P <= 1))
})

test_that("example_gwas has valid chromosomes", {
  expect_true(all(example_gwas$CHR %in% 1:22))
})
