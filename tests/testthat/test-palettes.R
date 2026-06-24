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

test_that("scale_fill_gwas works as expected", {
  s <- scale_fill_gwas("colorblind")
  expect_s3_class(s, "Scale")
})

test_that("gwas_palette interpolates colors", {
  cols <- gwas_palette("nature", n = 20)
  expect_length(cols, 20)
})

test_that("gwas_palette errors on unknown name", {
  expect_error(gwas_palette("nonexistent"))
})

test_that("gwas_palette returns journal palettes", {
  for (j in c("lancet", "nejm", "aaas")) {
    cols <- gwas_palette(j)
    expect_true(length(cols) >= 5)
  }
})
