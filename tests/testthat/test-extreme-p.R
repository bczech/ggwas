# P-values below the double range (about 5e-324) are stored as 0 in R. These
# tests check that their exact -log10(p) is kept and used (issue #2).

extreme_df <- function() {
  data.frame(
    CHR = c(1, 1, 2, 2, 3),
    BP = c(1e6, 2e6, 1e6, 2e6, 1e6),
    LOG10P = c(400, 0.3, 8, 1, 2),
    SNP = paste0("rs", 1:5)
  )
}

test_that(".parse_p reads p-values below the double range from text", {
  out <- .parse_p(c("0.5", "1e-400", "2.5E-1000", "3e-8", "0", NA))
  expect_equal(out$p, c(0.5, 0, 0, 3e-8, 0, NA))
  expect_equal(out$logp,
               c(-log10(0.5), 400, 1000 - log10(2.5), -log10(3e-8), Inf, NA))
  expect_equal(.parse_p(c(0.01, 1))$logp, c(2, 0))
})

test_that(".format_p writes p-values below the double range", {
  expect_equal(.format_p(c(0, 1e-8), c(400, 8)), c("1.00e-400", "1.00e-08"))
  expect_equal(.format_p(0, 400 - log10(2.5)), "2.50e-400")
  # 9.999e-401 rounds up to the next power of ten
  expect_equal(.format_p(0, 401 - log10(9.999)), "1.00e-400")
})

test_that("as_gwas_data keeps -log10(p) given with log_p = TRUE", {
  expect_no_warning(
    gd <- as_gwas_data(extreme_df(), p = "LOG10P", log_p = TRUE)
  )
  expect_equal(gd$P, 10^-c(400, 0.3, 8, 1, 2))
  expect_equal(gd$LOG10P, c(400, 0.3, 8, 1, 2))
  expect_equal(.neglog10p(gd), c(400, 0.3, 8, 1, 2))
})

test_that("as_gwas_data keeps an auto-detected LOG10P column exact", {
  gd <- suppressMessages(as_gwas_data(extreme_df()))
  expect_equal(.neglog10p(gd), c(400, 0.3, 8, 1, 2))
})

test_that("as_gwas_data fills P = 0 from a LOG10P column next to P", {
  df <- extreme_df()
  df$P <- 10^-df$LOG10P
  expect_no_warning(gd <- as_gwas_data(df, p = "P"))
  expect_equal(.neglog10p(gd), c(400, 0.3, 8, 1, 2))
})

test_that("read_gwas_table reads p-values like 1e-400 exactly", {
  f <- tempfile(fileext = ".tsv")
  writeLines(c("CHR\tBP\tSNP\tP", "1\t100\trs1\t1e-400", "1\t200\trs2\t0.5",
               "2\t300\trs3\t3e-8"), f)
  expect_no_warning(gd <- suppressMessages(read_gwas_table(f)))
  expect_equal(.neglog10p(gd), c(400, -log10(0.5), -log10(3e-8)))
})

test_that("p = 0 without an exact value warns and is left out of plots", {
  df <- data.frame(CHR = 1, BP = c(100, 200), P = c(0, 0.5))
  expect_warning(gd <- as_gwas_data(df), "exactly 0")
  expect_false("LOG10P" %in% names(gd))
  expect_equal(.drawable_p(gd), c(FALSE, TRUE))
})

test_that("data without extreme p-values gets no LOG10P column", {
  gd <- as_gwas_data(data.frame(CHR = 1, BP = 1:3, P = c(0.1, 1e-300, 1)))
  expect_false("LOG10P" %in% names(gd))
  expect_equal(.neglog10p(gd), c(1, 300, 0))
})

test_that("plots and tables use the exact -log10(p)", {
  gd <- as_gwas_data(extreme_df(), p = "LOG10P", log_p = TRUE)

  plt <- manhattan_plot(gd)
  expect_equal(max(plt$data$LOG10P), 400)
  expect_equal(nrow(plt$data), 5)

  expect_equal(max(qq_plot(gd)$data$observed), 400)
  expect_equal(max(volcano_plot(transform(gd, BETA = 0.1))$data$LOG10P), 400)
  expect_equal(max(circular_manhattan(gd)$data$LOG10P, na.rm = TRUE), 400)
  expect_equal(max(miami_plot(gd, gd)$data$LOG10P), 400)

  hits <- top_hits(gd, p_threshold = 5e-8)
  expect_equal(hits$SNP[1], "rs1")
  expect_equal(hits$P_formatted[1], "1.00e-400")

  expect_output(print(gd), "Min p-value: 1.00e-400")
  expect_equal(summary(gd)$min_p_label, "1.00e-400")
})

test_that("the most significant variant is ranked first, ties at P = 0 broken", {
  gd <- as_gwas_data(data.frame(CHR = 1, BP = 1:3, LOG10P = c(350, 400, 5)),
                     p = "LOG10P", log_p = TRUE)
  expect_equal(.order_by_p(gd), c(2L, 1L, 3L))
})

test_that("downsampling keeps variants below the double range", {
  set.seed(1)
  n <- 5000
  df <- data.frame(CHR = rep(1:2, each = n / 2), BP = rep(seq_len(n / 2), 2),
                   LOG10P = -log10(runif(n)))
  df$LOG10P[1] <- 400
  gd <- as_gwas_data(df, p = "LOG10P", log_p = TRUE)
  ds <- smart_downsample(gd, target_n = 500)
  expect_true(400 %in% ds$LOG10P)
})

test_that("multitrait_manhattan combines traits with and without LOG10P", {
  gd1 <- as_gwas_data(extreme_df(), p = "LOG10P", log_p = TRUE)
  gd2 <- as_gwas_data(transform(extreme_df()[, c("CHR", "BP", "SNP")],
                                P = c(0.5, 0.1, 1e-9, 0.2, 0.3)))
  plt <- multitrait_manhattan(list(a = gd1, b = gd2))
  expect_equal(max(plt$data$LOG10P), 400)
})

test_that(".as_number turns non-numbers into NA without a warning", {
  expect_no_warning(out <- .as_number(c("1.5", " 2e-3 ", "NA", "abc", "", "-1", "Inf", "1.", ".5")))
  expect_equal(out, c(1.5, 2e-3, NA, NA, NA, -1, Inf, 1, 0.5))
  expect_equal(.as_number(factor(c("0.1", "x"))), c(0.1, NA))
})
