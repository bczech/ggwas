test_that("gwas_palette works as expected", {
  expect_length(gwas_palette("default"), 2)
  expect_length(gwas_palette("nature"), 10)
  expect_length(gwas_palette("brewer_set1"), 9)
  expect_length(gwas_palette("colorblind", n = 5), 5)
})

test_that("gwas_palettes works as expected", {
  pals <- gwas_palettes()
  expect_true(length(pals) >= 10)
  expect_true("nature" %in% pals)
})

test_that("scale_color_gwas works as expected", {
  s <- scale_color_gwas("nature")
  expect_s3_class(s, "Scale")
})
