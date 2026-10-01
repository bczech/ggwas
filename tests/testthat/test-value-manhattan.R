make_value_df <- function() {
  set.seed(1)
  data.frame(
    chr = rep(1:5, each = 40),
    bp = as.integer(runif(200, 1, 2e8)),
    score = round(runif(200, 0, 1e5)),
    gene = paste0("g", 1:200)
  )
}

test_that("value_manhattan returns a ggplot", {
  plt <- value_manhattan(make_value_df(), value = "score")
  expect_s3_class(plt, "ggplot")
})

test_that("value_manhattan errors without value", {
  expect_error(value_manhattan(make_value_df()), "value")
})

test_that("value_manhattan errors on unknown value column", {
  expect_error(value_manhattan(make_value_df(), value = "nope"), "not found")
})

test_that("value_manhattan auto-detects chr and bp", {
  df <- make_value_df()
  names(df)[1:2] <- c("CHR", "POS")
  plt <- value_manhattan(df, value = "score")
  expect_s3_class(plt, "ggplot")
})

test_that("value_manhattan y-axis title defaults to the value column", {
  plt <- value_manhattan(make_value_df(), value = "score")
  expect_identical(plt$labels$y, "score")
  plt2 <- value_manhattan(make_value_df(), value = "score",
                          y_label = "ranking diff")
  expect_identical(plt2$labels$y, "ranking diff")
})

test_that("threshold adds horizontal lines", {
  base <- value_manhattan(make_value_df(), value = "score")
  thr <- value_manhattan(make_value_df(), value = "score",
                         threshold = c(50000, 90000))
  n_hline <- function(p) sum(vapply(p$layers,
    function(l) inherits(l$geom, "GeomHline"), logical(1)))
  expect_equal(n_hline(thr) - n_hline(base), 2)
})

test_that("label_top_n adds a text layer and needs a label column", {
  plt <- value_manhattan(make_value_df(), value = "score",
                         label = "gene", label_top_n = 5)
  has_text <- any(vapply(plt$layers,
    function(l) inherits(l$geom, "GeomTextRepel"), logical(1)))
  expect_true(has_text)
  expect_error(
    value_manhattan(make_value_df(), value = "score", label_top_n = 5),
    "label"
  )
})

test_that("negative values draw a zero line", {
  df <- make_value_df()
  df$score <- df$score - 50000
  plt <- value_manhattan(df, value = "score")
  expect_s3_class(plt, "ggplot")
  has_hline <- any(vapply(plt$layers,
    function(l) inherits(l$geom, "GeomHline"), logical(1)))
  expect_true(has_hline)
})
