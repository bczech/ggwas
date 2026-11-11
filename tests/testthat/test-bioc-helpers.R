genes_ab <- function() {
  GenomicRanges::GRanges(
    c("chr1:1000000-2000000:+", "chr1:5000000-6000000:-"),
    gene_id = c("ID_A", "ID_B"), gene_name = c("GeneA", "GeneB")
  )
}

test_that("regions must be on a chromosome", {
  expect_error(gene_track(genes_ab(), "chrUn_KI270302v1:1-100"),
               "not a chromosome")
})

test_that("genes need names, IDs or a label column", {
  expect_error(gene_track(GenomicRanges::GRanges("chr1:1-100"), "chr1:1-200"),
               "Cannot find gene names")
})

test_that("exons = TRUE needs a TxDb or EnsDb", {
  expect_error(gene_track(genes_ab(), "chr1:1-10000000", exons = TRUE),
               "TxDb")
})

test_that("exons can be a GRanges with a gene_id column", {
  exons <- GenomicRanges::GRanges(
    c("chr1:1000000-1200000", "chr1:1800000-2000000", "chr1:5000000-5100000"),
    gene_id = c("ID_A", "ID_A", "ID_B")
  )
  p <- gene_track(genes_ab(), "chr1:1-10000000", exons = exons)
  rect <- Filter(function(l) inherits(l$geom, "GeomRect"), p$layers)[[1]]
  expect_equal(nrow(rect$data), 3L)
})

test_that("exons = TRUE reads exons from an EnsDb", {
  skip_if_not_installed("EnsDb.Hsapiens.v86")
  edb <- EnsDb.Hsapiens.v86::EnsDb.Hsapiens.v86
  p <- gene_track(edb, "chr17:7660000-7690000", exons = TRUE)
  expect_true(any(vapply(p$layers, function(l) inherits(l$geom, "GeomRect"),
                         logical(1))))
})

test_that("seqinfo must carry chromosome lengths", {
  no_len <- GenomeInfoDb::Seqinfo(c("chr1", "chr2"))
  expect_error(snp_density(example_gwas, seqinfo = no_len), "known lengths")
})

test_that("centromeres on non-chromosome sequences are ignored", {
  n_seg <- function(p) sum(vapply(p$layers,
    function(l) inherits(l$geom, "GeomSegment"), logical(1)))
  cen <- GenomicRanges::GRanges("chrUn_KI270302v1:1-100")
  plt <- snp_density(example_gwas, style = "points", centromeres = cen)
  base <- snp_density(example_gwas, style = "points")
  expect_equal(n_seg(plt), n_seg(base))
})

test_that("set_sex_chr_map handles genomes without named chromosomes", {
  old <- set_sex_chr_map(GenomeInfoDb::Seqinfo(as.character(1:5)))
  on.exit(set_sex_chr_map(old))
  expect_length(getOption("ggwas.sex_chr_map"), 0)
  expect_error(set_sex_chr_map(c(20L, 21L)), "must be named")
})

test_that("missing optional packages give an install hint", {
  expect_error(.require_pkg("notAnInstalledPkg123", "do this"),
               "BiocManager::install")
})
