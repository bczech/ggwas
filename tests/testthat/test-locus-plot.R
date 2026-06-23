test_that("locus_plot works as expected", {
  df <- data.frame(
    CHR = rep(1, 100),
    BP = seq(1000, 100000, length.out = 100),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  plt <- locus_plot(df, region_chr = 1, region_start = 1000, region_end = 100000)
  expect_s3_class(plt, "ggplot")
})

test_that("locus_plot works with lead_snp", {
  df <- data.frame(
    CHR = rep(1, 100),
    BP = seq(1e6, 10e6, length.out = 100),
    P = c(1e-10, runif(99)),
    SNP = paste0("rs", 1:100)
  )
  plt <- locus_plot(df, lead_snp = "rs1", flank = 5e6)
  expect_s3_class(plt, "ggplot")
})

test_that("locus_plot works with LD coloring", {
  df <- data.frame(
    CHR = rep(1, 50),
    BP = seq(1e6, 5e6, length.out = 50),
    P = runif(50),
    SNP = paste0("rs", 1:50)
  )
  ld <- stats::setNames(runif(50), paste0("rs", 1:50))
  plt <- locus_plot(df, region_chr = 1, region_start = 1e6,
                    region_end = 5e6, ld = ld)
  expect_s3_class(plt, "ggplot")
})

test_that("locus_plot works with gene_data", {
  df <- data.frame(
    CHR = rep(1, 50),
    BP = seq(1e6, 5e6, length.out = 50),
    P = runif(50), SNP = paste0("rs", 1:50)
  )
  genes <- data.frame(
    chr = 1, start = 2e6, end = 3e6, gene = "GENE1", strand = "+"
  )
  plt <- locus_plot(df, region_chr = 1, region_start = 1e6,
                    region_end = 5e6, gene_data = genes)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})
