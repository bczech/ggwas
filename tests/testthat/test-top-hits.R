test_that("top_hits works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = c(1e-9, 1e-8, runif(148)),
    SNP = paste0("rs", 1:150)
  )
  result <- top_hits(df, p_threshold = 0.01)
  expect_s3_class(result, "gwas_hits")
  expect_true("cytoband" %in% names(result))
})

test_that("top_hits with gene annotation works as expected", {
  df <- data.frame(
    CHR = 1, BP = 1.5e6, P = 1e-9, SNP = "rs1",
    BETA = 0.5, SE = 0.1
  )
  genes <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "MY_GENE")
  result <- top_hits(df, p_threshold = 1e-5, genes = genes)
  expect_equal(result$nearest_gene[1], "MY_GENE")
})

test_that("print.gwas_hits works as expected", {
  df <- data.frame(CHR = 1, BP = 1e6, P = 1e-9, SNP = "rs1")
  result <- top_hits(df, p_threshold = 1e-5)
  expect_output(print(result), "Top")
})
