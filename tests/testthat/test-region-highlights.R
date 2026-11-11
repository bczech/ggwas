n_rects <- function(p) {
  sum(vapply(p$layers, function(l) inherits(l$geom, "GeomRect"), logical(1)))
}

test_that("highlight_regions adds one band per GRanges region", {
  plt <- manhattan_plot(example_gwas)
  regions <- GenomicRanges::GRanges(
    c("chr1:5000000-20000000", "chr6:25000000-35000000"),
    label = c("Region1", "MHC")
  )
  result <- highlight_regions(plt, regions)
  expect_s3_class(result, "ggplot")
  expect_equal(n_rects(result) - n_rects(plt), 2)
  texts <- Filter(function(l) inherits(l$geom, "GeomText"), result$layers)
  expect_setequal(vapply(texts, function(l) l$data$label, character(1)),
                  c("Region1", "MHC"))
})

test_that("highlight_regions draws borders and custom colors", {
  plt <- manhattan_plot(example_gwas)
  regions <- GenomicRanges::GRanges("chr1:5000000-20000000")
  result <- highlight_regions(plt, regions, color = "blue", alpha = 0.3,
                              border = TRUE)
  expect_equal(n_rects(result) - n_rects(plt), 2)
})

test_that("highlight_regions rejects a data.frame", {
  plt <- manhattan_plot(example_gwas)
  regions <- data.frame(chr = 1, start = 5e6, end = 20e6)
  expect_error(highlight_regions(plt, regions), "GRanges")
})
