test_that("top_hits clumps and returns lead SNPs", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = c(1e-9, 1e-8, runif(148, 0.1, 1)),
    SNP = paste0("rs", 1:150)
  )
  result <- top_hits(df, p_threshold = 0.01)
  expect_s3_class(result, "gwas_hits")
  # rs1 and rs2 are 1 Mb apart, so they stay separate loci
  expect_equal(result$SNP, c("rs1", "rs2"))
  expect_true("cytoband" %in% names(result))
})

test_that("top_hits adds the nearest gene from GRanges", {
  df <- data.frame(
    CHR = 1, BP = 1.5e6, P = 1e-9, SNP = "rs1",
    BETA = 0.5, SE = 0.1
  )
  genes <- GenomicRanges::GRanges("chr1:1000000-2000000", gene_name = "MY_GENE")
  result <- top_hits(df, p_threshold = 1e-5, genes = genes)
  expect_equal(result$nearest_gene, "MY_GENE")
  expect_equal(result$gene_distance, 0L)
  expect_error(top_hits(df, genes = data.frame(chr = 1)), "GRanges")
})

test_that("print.gwas_hits prints a table", {
  df <- data.frame(CHR = 1, BP = 1e6, P = 1e-9, SNP = "rs1")
  result <- top_hits(df, p_threshold = 1e-5)
  expect_output(print(result), "Top 1 GWAS Hits")
})
