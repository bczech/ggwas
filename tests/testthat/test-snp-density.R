test_that("snp_density returns ggplot", {
  plt <- snp_density(example_gwas, bin_size = 5e6)
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density works with chr_info_human", {
  plt <- snp_density(example_gwas, bin_size = 5e6, chr_info = chr_info_human())
  expect_s3_class(plt, "ggplot")
})

test_that("chr_info_human returns correct structure", {
  ci <- chr_info_human()
  expect_equal(nrow(ci), 22)
  expect_true(all(c("chr", "length", "centromere_start", "centromere_end") %in% names(ci)))
})

test_that("chr_info_mouse returns correct structure", {
  ci <- chr_info_mouse()
  expect_equal(nrow(ci), 19)
  expect_true(all(c("chr", "length", "centromere_start", "centromere_end") %in% names(ci)))
})

test_that("chr_info_cattle returns correct structure", {
  ci <- chr_info_cattle()
  expect_equal(nrow(ci), 29)
  expect_true(all(c("chr", "length", "centromere_start", "centromere_end") %in% names(ci)))
})
