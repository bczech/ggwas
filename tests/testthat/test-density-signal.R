test_that("density_signal_plot returns ggplot", {
  plt <- density_signal_plot(example_gwas, bin_size = 5e6)
  expect_s3_class(plt, "ggplot")
})

test_that("density_signal_plot uses chromosome lengths from a Seqinfo", {
  si <- GenomeInfoDb::Seqinfo(paste0("chr", 1:2),
                              seqlengths = c(248956422, 242193529))
  plt <- density_signal_plot(example_gwas, bin_size = 5e6, seqinfo = si,
                             chromosomes = 1:2)
  expect_s3_class(plt, "ggplot")
  expect_setequal(unique(plt$data$CHR), 1:2)
})

test_that("density_signal_plot works with chromosome subset", {
  plt <- density_signal_plot(example_gwas, bin_size = 5e6, chromosomes = 1:5)
  expect_setequal(unique(plt$data$CHR), 1:5)
})
