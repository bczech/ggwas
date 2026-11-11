test_that("calc_lambda returns 1 for uniform p-values", {
  set.seed(42)
  p <- runif(10000)
  lambda <- calc_lambda(p)
  expect_equal(lambda, 1, tolerance = 0.1)
})

test_that("calc_lambda detects inflation", {
  set.seed(42)
  p <- runif(10000)^2
  lambda <- calc_lambda(p)
  expect_gt(lambda, 1)
})

test_that("chr_to_int handles various formats", {
  expect_equal(chr_to_int("chr1"), 1L)
  expect_equal(chr_to_int("X"), 23L)
  expect_equal(chr_to_int("chrMT"), 26L)
  expect_equal(chr_to_int("22"), 22L)
})

test_that("int_to_chr converts back correctly", {
  expect_equal(int_to_chr(1), "1")
  expect_equal(int_to_chr(23), "X")
  expect_equal(int_to_chr(26), "MT")
})

test_that("detect_columns finds standard names", {
  header <- c("CHR", "BP", "SNP", "P", "BETA", "SE")
  result <- detect_columns(header)
  expect_equal(result$CHR, "CHR")
  expect_equal(result$BP, "BP")
  expect_equal(result$P, "P")
})

test_that("detect_columns finds alternative names", {
  header <- c("#CHROM", "POS", "ID", "PVALUE", "EFFECT")
  result <- detect_columns(header)
  expect_equal(result$CHR, "#CHROM")
  expect_equal(result$BP, "POS")
})

test_that("add_cumulative_bp adds BP_CUM column", {
  df <- data.frame(CHR = c(1, 1, 2, 2), BP = c(100, 200, 100, 200), P = 0.5)
  result <- add_cumulative_bp(df)
  expect_true("BP_CUM" %in% names(result))
  expect_true(!is.null(attr(result, "chr_info")))
})

test_that("set_sex_chr_map derives codes from a Seqinfo", {
  old <- set_sex_chr_map(
    GenomeInfoDb::Seqinfo(c(1:19, "X", "Y", "MT", "JH584299.1"))
  )
  on.exit(set_sex_chr_map(old))
  expect_equal(getOption("ggwas.sex_chr_map"), c(X = 20L, Y = 21L, MT = 22L))
  expect_equal(chr_to_int("chrX"), 20L)
  expect_equal(int_to_chr(21L), "Y")
})

test_that("set_sex_chr_map maps UCSC chrM to MT", {
  old <- set_sex_chr_map(GenomeInfoDb::Seqinfo(c(paste0("chr", 1:22),
                                                  "chrX", "chrY", "chrM")))
  on.exit(set_sex_chr_map(old))
  expect_equal(chr_to_int(c("chrM", "MT")), c(25L, 25L))
})

test_that("set_sex_chr_map(NULL) really disables the mapping", {
  old <- set_sex_chr_map(NULL)
  on.exit(set_sex_chr_map(old))
  expect_equal(int_to_chr(23L), "23")
  expect_error(set_sex_chr_map("X"), "Seqinfo")
})
