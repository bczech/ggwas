test_that("annotate_genes works as expected", {
  df <- data.frame(
    CHR = c(1, 1, 2), BP = c(1.5e6, 50e6, 51e6),
    P = c(1e-9, 0.5, 1e-8), SNP = c("rs1", "rs2", "rs3")
  )
  genes <- data.frame(
    chr = c(1, 2), start = c(1e6, 50e6),
    end = c(2e6, 52e6), gene = c("GENE_A", "GENE_B")
  )
  result <- annotate_genes(df, genes, p_threshold = 1e-5)
  expect_true("nearest_gene" %in% names(result))
  expect_equal(result$nearest_gene[result$SNP == "rs1"], "GENE_A")
  expect_equal(result$nearest_gene[result$SNP == "rs3"], "GENE_B")
})

test_that("annotate_genes respects max_distance", {
  df <- data.frame(CHR = 1, BP = 100e6, P = 1e-9, SNP = "rs1")
  genes <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "FAR_GENE")
  result <- annotate_genes(df, genes, max_distance = 1e6)
  expect_true(is.na(result$nearest_gene[1]))
})

test_that("manhattan_genes works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = c(1e-9, runif(149)),
    SNP = paste0("rs", 1:150)
  )
  genes <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "TEST_GENE")
  plt <- manhattan_genes(df, genes = genes, gene_p_threshold = 0.01)
  expect_s3_class(plt, "ggplot")
})
