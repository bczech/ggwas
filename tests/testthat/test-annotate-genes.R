make_genes <- function() {
  GenomicRanges::GRanges(
    c("chr1:1000000-2000000", "chr2:50000000-52000000"),
    gene_name = c("GENE_A", "GENE_B")
  )
}

test_that("annotate_genes assigns the nearest gene and its distance", {
  df <- data.frame(
    CHR = c(1, 1, 2), BP = c(1.5e6, 50e6, 52.1e6),
    P = c(1e-9, 0.5, 1e-8), SNP = c("rs1", "rs2", "rs3")
  )
  result <- annotate_genes(df, make_genes(), p_threshold = 1e-5)
  expect_s3_class(result, "gwas_data")
  expect_equal(result$nearest_gene, c("GENE_A", NA, "GENE_B"))
  # rs1 lies inside GENE_A; rs3 is 99,999 bp past the end of GENE_B
  expect_equal(result$gene_distance, c(0, NA, 99999))
  expect_false(".row" %in% names(result))
})

test_that("annotate_genes respects max_distance", {
  df <- data.frame(CHR = 1, BP = 100e6, P = 1e-9, SNP = "rs1")
  result <- annotate_genes(df, make_genes(), max_distance = 1e6)
  expect_true(is.na(result$nearest_gene[1]))
})

test_that("annotate_genes ignores chromosomes without genes", {
  df <- data.frame(CHR = 5, BP = 1e6, P = 1e-9, SNP = "rs1")
  result <- annotate_genes(df, make_genes())
  expect_true(is.na(result$nearest_gene))
})

test_that("annotate_genes rejects a data.frame of genes", {
  genes <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "A")
  expect_error(annotate_genes(example_gwas, genes), "GRanges")
})

test_that("manhattan_genes labels peaks with gene names", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = c(1e-9, runif(149)),
    SNP = paste0("rs", 1:150)
  )
  genes <- GenomicRanges::GRanges("chr1:1000000-2000000", gene_name = "TEST_GENE")
  plt <- manhattan_genes(df, genes = genes, gene_p_threshold = 1e-5)
  text <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), plt$layers)
  expect_equal(text[[length(text)]]$data$nearest_gene, "TEST_GENE")
})

test_that("manhattan_genes draws arrows with arrow = TRUE", {
  df <- data.frame(CHR = 1, BP = seq(1e6, 5e6, length.out = 20),
                   P = c(1e-9, rep(0.5, 19)), SNP = paste0("rs", 1:20))
  genes <- GenomicRanges::GRanges("chr1:900000-1100000", gene_name = "TEST")
  plt <- manhattan_genes(df, genes = genes, gene_p_threshold = 1e-5,
                         arrow = TRUE, label_face = "italic")
  has_arrow <- any(vapply(plt$layers, function(l) {
    inherits(l$geom, "GeomSegment") && !is.null(l$geom_params$arrow)
  }, logical(1)))
  expect_true(has_arrow)
})

test_that("annotate_genes returns no genes when nothing passes the threshold", {
  df <- data.frame(CHR = 1, BP = 1.5e6, P = 0.5, SNP = "rs1")
  result <- annotate_genes(df, make_genes(), p_threshold = 1e-8)
  expect_true(is.na(result$nearest_gene))
  expect_false(".row" %in% names(result))
})

test_that("manhattan_genes places labels over their peaks", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = 0.5,
    SNP = paste0("rs", 1:150)
  )
  df$P[df$SNP == "rs120"] <- 1e-12
  genes <- GenomicRanges::GRanges(
    paste0("chr3:", df$BP[120] - 1000, "-", df$BP[120] + 1000),
    gene_name = "CHR3_GENE"
  )
  plt <- manhattan_genes(df, genes = genes, gene_p_threshold = 1e-5)
  text <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), plt$layers)
  label <- text[[length(text)]]$data
  peak_x <- plt$data$BP_CUM[plt$data$SNP == "rs120"]
  expect_equal(unname(label$BP_CUM), peak_x)
})

# Peak on chr3 (rs120, p = 1e-12, BETA = 1, SE = 0.1) with a gene over it.
make_peak_data <- function() {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = 0.5, BETA = 0.3, SE = 0.1,
    SNP = paste0("rs", 1:150)
  )
  df$P[df$SNP == "rs120"] <- 1e-12
  df$BETA[df$SNP == "rs120"] <- 1
  df
}
peak_gene <- function(df) {
  GenomicRanges::GRanges(
    paste0("chr3:", df$BP[120] - 1000, "-", df$BP[120] + 1000),
    gene_name = "CHR3_GENE"
  )
}
gene_label_layer <- function(plt) {
  text <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), plt$layers)
  text[[length(text)]]
}

test_that("manhattan_genes labels are the same on every run", {
  df <- make_peak_data()
  layer <- gene_label_layer(manhattan_genes(df, genes = peak_gene(df)))
  expect_equal(layer$geom_params$seed, 42)
  expect_equal(layer$geom_params$max.overlaps, Inf)
})

test_that("manhattan_genes drops labels of chromosomes that are not plotted", {
  df <- make_peak_data()
  expect_no_warning(
    plt <- manhattan_genes(df, genes = peak_gene(df), chromosomes = 1:2)
  )
  expect_false(any(vapply(plt$layers, function(l) {
    inherits(l$geom, "GeomTextRepel")
  }, logical(1))))
})

test_that("manhattan_genes puts labels at the y of their point", {
  df <- make_peak_data()
  # y_truncate: the peak at 12 is drawn in the compressed band above 5
  plt <- manhattan_genes(df, genes = peak_gene(df), y_truncate = 5)
  label <- gene_label_layer(plt)$data
  peak <- plt$data[plt$data$SNP == "rs120", ]
  expect_equal(label$LOG10P_plot, peak$LOG10P_plot)
  expect_lt(peak$LOG10P_plot, 12)

  # y_metric = "beta_min": the peak is at |1| - 2 * 0.1 = 0.8
  plt <- manhattan_genes(df, genes = peak_gene(df), y_metric = "beta_min")
  label <- gene_label_layer(plt)$data
  expect_equal(label$LOG10P, 0.8)
})
