test_that("snp_density heatmap returns ggplot", {
  plt <- snp_density(example_gwas, bin_size = 5e6)
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density heatmap works with chr_info_human", {
  plt <- snp_density(example_gwas, bin_size = 5e6, chr_info = chr_info_human())
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density heatmap works with different palettes", {
  plt <- snp_density(example_gwas, bin_size = 5e6, palette = "magma")
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density points style returns ggplot", {
  plt <- snp_density(example_gwas, style = "points")
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density points with significance coloring", {
  plt <- snp_density(example_gwas, style = "points",
    color_by = "significance", chr_info = chr_info_human())
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density points with uniform coloring", {
  plt <- snp_density(example_gwas, style = "points", color_by = "uniform")
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density points with density coloring", {
  plt <- snp_density(example_gwas, style = "points", color_by = "density")
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density without centromeres", {
  plt <- snp_density(example_gwas, bin_size = 5e6,
    chr_info = chr_info_human(), show_centromeres = FALSE)
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density infers chr lengths without chr_info", {
  plt <- snp_density(example_gwas, bin_size = 5e6, chr_info = NULL)
  expect_s3_class(plt, "ggplot")
})
