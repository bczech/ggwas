make_enrich_df <- function() {
  data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 100e6, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
}

# Data of the annotated-points layer (the one coloured by annotation).
fg_data <- function(plt) {
  for (l in plt$layers) {
    if ("annotation" %in% names(l$data) && any(!is.na(l$data$annotation))) {
      return(l$data)
    }
  }
  data.frame(annotation = character())
}

annotated_snps <- function(plt) {
  table(as.character(fg_data(plt)$annotation))
}

test_that("enrichment_manhattan marks variants inside GRanges regions", {
  df <- make_enrich_df()
  annot <- GenomicRanges::GRanges(
    c("chr1:10000000-20000000", "chr2:40000000-50000000"),
    category = c("Gene", "Enhancer")
  )
  plt <- enrichment_manhattan(df, annotations = annot, downsample = FALSE)
  expect_s3_class(plt, "ggplot")
  expected_gene <- sum(df$CHR == 1 & df$BP >= 10e6 & df$BP <= 20e6)
  expected_enh <- sum(df$CHR == 2 & df$BP >= 40e6 & df$BP <= 50e6)
  counts <- annotated_snps(plt)
  expect_equal(as.integer(counts[["Gene"]]), expected_gene)
  expect_equal(as.integer(counts[["Enhancer"]]), expected_enh)
})

test_that("enrichment_manhattan takes categories from a GRangesList", {
  df <- make_enrich_df()
  annot <- GenomicRanges::GRangesList(
    Genes = GenomicRanges::GRanges("chr1:5000000-15000000"),
    eQTL = GenomicRanges::GRanges("chr2:10000000-20000000")
  )
  plt <- enrichment_manhattan(df, annotations = annot, downsample = FALSE)
  expect_setequal(names(annotated_snps(plt)), c("Genes", "eQTL"))

  as_list <- list(Genes = annot[[1]], eQTL = annot[[2]])
  plt2 <- enrichment_manhattan(df, annotations = as_list, downsample = FALSE)
  expect_equal(annotated_snps(plt2), annotated_snps(plt))
})

test_that("enrichment_manhattan gives overlapping variants the first category", {
  df <- data.frame(CHR = 1, BP = 5e6, P = 1e-3, SNP = "rs1")
  annot <- GenomicRanges::GRanges(
    c("chr1:1000000-10000000", "chr1:4000000-6000000"),
    category = c("First", "Second")
  )
  plt <- enrichment_manhattan(df, annotations = annot, downsample = FALSE)
  expect_equal(as.character(fg_data(plt)$annotation), "First")
})

test_that("enrichment_manhattan labels default to one category without a column", {
  annot <- GenomicRanges::GRanges("chr1:1000000-50000000")
  plt <- enrichment_manhattan(example_gwas, annotations = annot, label_top_n = 3)
  expect_equal(names(annotated_snps(plt)), "Annotated")
})

test_that("enrichment_manhattan rejects data.frames and unnamed lists", {
  annot <- data.frame(chr = 1, start = 1e6, end = 50e6, category = "Gene")
  expect_error(enrichment_manhattan(example_gwas, annotations = annot), "GRanges")
  unnamed <- GenomicRanges::GRangesList(GenomicRanges::GRanges("chr1:1-10"))
  expect_error(enrichment_manhattan(example_gwas, annotations = unnamed), "names")
})

test_that("enrichment_manhattan downsamples only background points", {
  df <- make_enrich_df()
  annot <- GenomicRanges::GRanges("chr1:10000000-20000000", category = "Gene")
  plt <- enrichment_manhattan(df, annotations = annot, downsample_n = 50)
  n_annot <- sum(df$CHR == 1 & df$BP >= 10e6 & df$BP <= 20e6)
  expect_equal(as.integer(annotated_snps(plt)[["Gene"]]), n_annot)
})
