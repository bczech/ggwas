test_that("enrichment_manhattan works as expected", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 100e6, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
  annot <- data.frame(
    chr = c(1, 2),
    start = c(10e6, 40e6),
    end = c(20e6, 50e6),
    category = c("Gene", "Enhancer")
  )
  plt <- enrichment_manhattan(df, annotations = annot)
  expect_s3_class(plt, "ggplot")
})

test_that("enrichment_manhattan handles list of annotations", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100)
  )
  annot_list <- list(
    Genes = data.frame(chr = 1, start = 5e6, end = 15e6),
    eQTL = data.frame(chr = 2, start = 10e6, end = 20e6)
  )
  plt <- enrichment_manhattan(df, annotations = annot_list)
  expect_s3_class(plt, "ggplot")
})

test_that("enrichment_manhattan label_top_n works as expected", {
  annot <- data.frame(chr = 1, start = 1e6, end = 50e6, category = "Gene")
  plt <- enrichment_manhattan(example_gwas, annotations = annot, label_top_n = 3)
  expect_s3_class(plt, "ggplot")
})

test_that("enrichment_manhattan palette works as expected", {
  annot <- data.frame(chr = 1, start = 1e6, end = 50e6, category = "Gene")
  plt <- enrichment_manhattan(example_gwas, annotations = annot, palette = "nature")
  expect_s3_class(plt, "ggplot")
})
