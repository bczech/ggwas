test_that("annotate_genes adds nearest_gene column", {
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

test_that("manhattan_genes returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = c(1e-9, runif(149)),
    SNP = paste0("rs", 1:150)
  )
  genes <- data.frame(
    chr = 1, start = 1e6, end = 2e6, gene = "TEST_GENE"
  )
  plt <- manhattan_genes(df, genes = genes, gene_p_threshold = 0.01)
  expect_s3_class(plt, "ggplot")
})

test_that("top_hits returns data.frame", {
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

test_that("top_hits with gene annotation works", {
  df <- data.frame(
    CHR = 1, BP = 1.5e6, P = 1e-9, SNP = "rs1",
    BETA = 0.5, SE = 0.1
  )
  genes <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "MY_GENE")
  result <- top_hits(df, p_threshold = 1e-5, genes = genes)
  expect_equal(result$nearest_gene[1], "MY_GENE")
})

test_that("highlight_regions returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = runif(150)
  )
  plt <- manhattan_plot(df)
  regions <- data.frame(chr = 1, start = 5e6, end = 20e6, label = "Test")
  result <- highlight_regions(plt, regions)
  expect_s3_class(result, "ggplot")
})

test_that("print.gwas_hits produces output", {
  df <- data.frame(
    CHR = 1, BP = 1e6, P = 1e-9, SNP = "rs1"
  )
  result <- top_hits(df, p_threshold = 1e-5)
  expect_output(print(result), "Top")
})
