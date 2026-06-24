test_that("theme_nature works as expected", {
  expect_s3_class(theme_nature(), "theme")
  expect_s3_class(theme_nature(base_size = 6), "theme")
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
  for (name in c("publication", "presentation", "poster", "exploratory")) {
    p <- gwas_preset(name)
    expect_true(is.list(p))
    expect_true(all(c("theme", "colors", "point_size") %in% names(p)))
  }
})

test_that("gwas_preset errors on unknown preset", {
  expect_error(gwas_preset("nonexistent"))
})
