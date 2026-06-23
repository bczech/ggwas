test_that("genetic_correlation works with matrix input", {
  traits <- c("BMI", "Height", "T2D")
  rg <- matrix(c(1, -0.1, 0.4, -0.1, 1, -0.2, 0.4, -0.2, 1),
               nrow = 3, dimnames = list(traits, traits))
  plt <- genetic_correlation(rg)
  expect_s3_class(plt, "ggplot")
})

test_that("genetic_correlation works with data.frame input", {
  df <- data.frame(
    trait1 = c("BMI", "BMI", "Height"),
    trait2 = c("Height", "T2D", "T2D"),
    rg = c(-0.1, 0.4, -0.2),
    p = c(0.01, 0.001, 0.05)
  )
  plt <- genetic_correlation(df)
  expect_s3_class(plt, "ggplot")
})

test_that("genetic_correlation handles clustering", {
  traits <- c("A", "B", "C", "D")
  rg <- matrix(c(1, .5, .1, .2, .5, 1, .3, .1, .1, .3, 1, .6, .2, .1, .6, 1),
               nrow = 4, dimnames = list(traits, traits))
  plt <- genetic_correlation(rg, cluster = TRUE)
  expect_s3_class(plt, "ggplot")
})
