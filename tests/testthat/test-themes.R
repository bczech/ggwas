test_that("theme_nature works as expected", {
  expect_s3_class(theme_nature(), "theme")
})

test_that("theme_science works as expected", {
  expect_s3_class(theme_science(), "theme")
})

test_that("theme_plos works as expected", {
  expect_s3_class(theme_plos(), "theme")
})

test_that("theme_cell works as expected", {
  expect_s3_class(theme_cell(), "theme")
})

test_that("theme_presentation works as expected", {
  expect_s3_class(theme_presentation(), "theme")
})

test_that("theme_poster works as expected", {
  expect_s3_class(theme_poster(), "theme")
})

test_that("gwas_preset works as expected", {
  p <- gwas_preset("publication")
  expect_true(is.list(p))
  expect_true(all(c("theme", "colors", "point_size") %in% names(p)))
})
