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

test_that("genetic_correlation shows every unique pair once in the lower triangle", {
  traits <- c("BMI", "Height", "WHR", "T2D", "CAD")
  rg <- matrix(c(
    1.0,  -0.1,  0.6,  0.4,  0.2,
   -0.1,   1.0, -0.3, -0.1,  0.0,
    0.6,  -0.3,  1.0,  0.3,  0.15,
    0.4,  -0.1,  0.3,  1.0,  0.5,
    0.2,   0.0,  0.15, 0.5,  1.0
  ), nrow = 5, dimnames = list(traits, traits))

  plt <- genetic_correlation(rg, cluster = FALSE, show_diagonal = FALSE)
  shown <- plt$data[!is.na(plt$data$rg), ]
  expect_equal(nrow(shown), choose(length(traits), 2))
  i1 <- match(as.character(shown$trait1), traits)
  i2 <- match(as.character(shown$trait2), traits)
  expect_true(all(i1 < i2))
  pairs <- paste(pmin(i1, i2), pmax(i1, i2), sep = "-")
  expect_equal(length(unique(pairs)), choose(length(traits), 2))

  plt_diag <- genetic_correlation(rg, cluster = FALSE, show_diagonal = TRUE)
  diag_rows <- plt_diag$data[
    as.character(plt_diag$data$trait1) == as.character(plt_diag$data$trait2),
  ]
  expect_equal(nrow(diag_rows), length(traits))
  expect_true(all(!is.na(diag_rows$rg)))
  expect_equal(sum(!is.na(plt_diag$data$rg)),
               choose(length(traits), 2) + length(traits))
})
