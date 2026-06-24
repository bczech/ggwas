test_that("density_signal_plot returns ggplot", {
  plt <- density_signal_plot(example_gwas, bin_size = 5e6)
  expect_s3_class(plt, "ggplot")
})

test_that("density_signal_plot works with chr_info", {
  plt <- density_signal_plot(example_gwas, bin_size = 5e6,
    chr_info = chr_info_human())
  expect_s3_class(plt, "ggplot")
})

test_that("density_signal_plot works with chromosome subset", {
  plt <- density_signal_plot(example_gwas, bin_size = 5e6,
    chromosomes = 1:5)
  expect_s3_class(plt, "ggplot")
})
