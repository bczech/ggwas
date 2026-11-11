make_genes <- function() {
  GenomicRanges::GRanges(
    c("chr1:1000000-2000000:+", "chr1:5000000-6000000:-",
      "chr1:8000000-9000000:+", "chr2:3000000-4000000:+"),
    gene_name = c("GeneA", "GeneB", "GeneC", "GeneD")
  )
}

track_genes <- function(p) {
  layer <- Filter(function(l) inherits(l$geom, "GeomTextRepel"), p$layers)[[1]]
  sort(layer$data$gene)
}

test_that("gene_track draws the genes inside the region", {
  p <- gene_track(make_genes(), region = "chr1:1-10000000")
  expect_s3_class(p, "gg")
  expect_equal(track_genes(p), c("GeneA", "GeneB", "GeneC"))
})

test_that("gene_track accepts a GRanges region and filters to it", {
  region <- GenomicRanges::GRanges("chr1:4000000-7000000")
  p <- gene_track(make_genes(), region)
  expect_equal(track_genes(p), "GeneB")
})

test_that("gene_track matches seqlevels with or without the chr prefix", {
  genes <- make_genes()
  GenomeInfoDb::seqlevelsStyle(genes) <- "NCBI"
  p <- gene_track(genes, "chr1:1-10000000")
  expect_equal(track_genes(p), c("GeneA", "GeneB", "GeneC"))
})

test_that("gene_track handles an empty region", {
  p <- gene_track(make_genes(), "chr3:1-10000000")
  expect_s3_class(p, "gg")
  expect_length(Filter(function(l) inherits(l$geom, "GeomTextRepel"), p$layers), 0)
})

test_that("gene_track falls back to gene_id and names for labels", {
  genes <- GenomicRanges::GRanges("chr1:1000000-2000000", gene_id = "ENSG1")
  expect_equal(track_genes(gene_track(genes, "chr1:1-3000000")), "ENSG1")
  genes <- GenomicRanges::GRanges("chr1:1000000-2000000")
  names(genes) <- "named"
  expect_equal(track_genes(gene_track(genes, "chr1:1-3000000")), "named")
})

test_that("gene_track keeps the longest genes when over max_genes", {
  starts <- seq(1e6, 100e6, length.out = 100)
  genes <- GenomicRanges::GRanges(
    "chr1", IRanges::IRanges(starts, starts + seq_len(100) * 1e3),
    gene_name = paste0("Gene", 1:100)
  )
  p <- gene_track(genes, "chr1:1-110000000", max_genes = 10)
  expect_setequal(track_genes(p), paste0("Gene", 91:100))
})

test_that("gene_track draws exons from a GRangesList", {
  genes <- make_genes()
  names(genes) <- genes$gene_name
  exons <- GenomicRanges::GRangesList(
    GeneA = GenomicRanges::GRanges(c("chr1:1000000-1100000", "chr1:1500000-1700000")),
    GeneB = GenomicRanges::GRanges("chr1:5000000-5200000")
  )
  p <- gene_track(genes, "chr1:1-10000000", exons = exons)
  rect <- Filter(function(l) inherits(l$geom, "GeomRect"), p$layers)[[1]]
  expect_equal(nrow(rect$data), 3L)
})

test_that("gene_track rejects data.frames and bad regions", {
  df <- data.frame(chr = 1, start = 1e6, end = 2e6, gene = "A")
  expect_error(gene_track(df, "chr1:1-3000000"), "GRanges")
  expect_error(gene_track(make_genes(), "not a region"), "valid range")
  expect_error(gene_track(make_genes(), make_genes()), "length 1")
})

test_that("gene_track takes genes and exons from a TxDb", {
  skip_if_not_installed("TxDb.Hsapiens.UCSC.hg38.knownGene")
  txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene
  # TP53 (Entrez 7157) on chr17
  p <- gene_track(txdb, "chr17:7660000-7690000", exons = TRUE)
  expect_true("7157" %in% track_genes(p))
})

test_that("gene_track takes gene symbols from an EnsDb", {
  skip_if_not_installed("EnsDb.Hsapiens.v86")
  edb <- EnsDb.Hsapiens.v86::EnsDb.Hsapiens.v86
  p <- gene_track(edb, "chr17:7660000-7690000")
  expect_true("TP53" %in% track_genes(p))
})
