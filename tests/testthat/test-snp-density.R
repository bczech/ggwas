hg38_chr1_2 <- function() {
  GenomeInfoDb::Seqinfo(c("chr1", "chr2"),
                        seqlengths = c(248956422, 242193529), genome = "hg38")
}

test_that("snp_density heatmap infers chromosome lengths from the data", {
  plt <- snp_density(example_gwas, bin_size = 5e6)
  expect_s3_class(plt, "ggplot")
  chr1_max <- max(example_gwas$BP[example_gwas$CHR == 1])
  bins <- plt$data[plt$data$CHR == 1, ]
  expect_lte(max(bins$bin), chr1_max)
})

test_that("snp_density uses lengths from a Seqinfo", {
  df <- example_gwas[example_gwas$CHR %in% 1:2, ]
  plt <- snp_density(df, bin_size = 5e6, seqinfo = hg38_chr1_2())
  bins <- plt$data[plt$data$CHR == 1, ]
  expect_equal(max(bins$bin), floor(248956422 / 5e6) * 5e6)
})

test_that("snp_density takes the Seqinfo of a TxDb", {
  skip_if_not_installed("TxDb.Hsapiens.UCSC.hg38.knownGene")
  txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene::TxDb.Hsapiens.UCSC.hg38.knownGene
  plt <- snp_density(example_gwas, bin_size = 5e6, seqinfo = txdb)
  expect_s3_class(plt, "ggplot")
})

test_that("snp_density draws centromeres only when given", {
  cen <- GenomicRanges::GRanges(c("chr1:122026460-124932724",
                                  "chr2:92188146-94090557"))
  n_seg <- function(p) sum(vapply(p$layers,
    function(l) inherits(l$geom, "GeomSegment"), logical(1)))
  with_cen <- snp_density(example_gwas, style = "points", centromeres = cen)
  without <- snp_density(example_gwas, style = "points")
  hidden <- snp_density(example_gwas, style = "points", centromeres = cen,
                        show_centromeres = FALSE)
  expect_equal(n_seg(with_cen) - n_seg(without), 1)
  expect_equal(n_seg(hidden), n_seg(without))
})

test_that("snp_density point styles and palettes work", {
  for (by in c("density", "significance", "uniform")) {
    expect_s3_class(snp_density(example_gwas, style = "points", color_by = by),
                    "ggplot")
  }
  expect_s3_class(snp_density(example_gwas, bin_size = 5e6, palette = "magma"),
                  "ggplot")
})

test_that("snp_density rejects bad seqinfo and centromeres", {
  expect_error(snp_density(example_gwas, seqinfo = data.frame(chr = 1)),
               "Seqinfo")
  expect_error(snp_density(example_gwas, centromeres = data.frame(chr = 1)),
               "GRanges")
})
