test_that("finemapping_plot works as expected", {
  df <- data.frame(
    CHR = rep(1, 100), BP = seq(1e6, 50e6, length.out = 100),
    P = runif(100), SNP = paste0("rs", 1:100),
    PIP = runif(100)^4,
    credible_set = c(rep(1L, 5), rep(NA_integer_, 95))
  )
  df$PIP[1] <- 0.9
  plt <- finemapping_plot(df, region = "chr1:1000000-50000000")
  expect_s3_class(plt, "ggplot")
  expect_true(all(plt$data$BP >= 1e6 & plt$data$BP <= 50e6))
})

test_that("finemapping_plot works without credible sets", {
  df <- data.frame(
    CHR = rep(1, 50), BP = seq(1e6, 30e6, length.out = 50),
    P = runif(50), SNP = paste0("rs", 1:50),
    PIP = runif(50)^3
  )
  plt <- finemapping_plot(df, region = GenomicRanges::GRanges("chr1:1000000-30000000"))
  expect_s3_class(plt, "ggplot")
})

test_that("finemapping_plot label_pip_above works as expected", {
  df <- data.frame(
    CHR = rep(1, 50), BP = seq(1e6, 30e6, length.out = 50),
    P = runif(50), SNP = paste0("rs", 1:50),
    PIP = runif(50)^3, credible_set = c(rep(1L, 3), rep(2L, 2), rep(NA_integer_, 45))
  )
  df$PIP[1] <- 0.95
  plt <- finemapping_plot(df, region = "chr1:1000000-30000000",
                          label_pip_above = 0.5)
  expect_s3_class(plt, "ggplot")
})

test_that("finemapping_plot centres on a lead SNP", {
  df <- data.frame(
    CHR = rep(1, 50), BP = seq(1e6, 30e6, length.out = 50),
    P = runif(50), SNP = paste0("rs", 1:50), PIP = runif(50)
  )
  plt <- finemapping_plot(df, lead_snp = "rs25", flank = 2e6)
  lead_bp <- df$BP[25]
  expect_true(all(abs(plt$data$BP - lead_bp) <= 2e6))
  expect_error(finemapping_plot(df), "region")
  expect_error(finemapping_plot(df, lead_snp = "nope"), "not found")
})
