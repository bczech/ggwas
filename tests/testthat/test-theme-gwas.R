test_that("theme_gwas returns a theme", {
  expect_s3_class(theme_gwas(), "theme")
})

test_that("theme_gwas respects base_size", {
  t1 <- theme_gwas(base_size = 8)
  t2 <- theme_gwas(base_size = 14)
  expect_s3_class(t1, "theme")
  expect_s3_class(t2, "theme")
})

test_that("scale_color_chromosome returns a scale", {
  s <- scale_color_chromosome()
  expect_s3_class(s, "Scale")
})

test_that("scale_fill_chromosome returns a scale", {
  s <- scale_fill_chromosome()
  expect_s3_class(s, "Scale")
})

test_that("scale_color_chromosome accepts custom colors", {
  s <- scale_color_chromosome(colors = c("red", "blue"))
  expect_s3_class(s, "Scale")
})
