test_that("chr_info_human returns 22 chromosomes with centromeres", {
  ci <- chr_info_human()
  expect_equal(nrow(ci), 22)
  expect_true(all(c("chr", "length", "centromere_start", "centromere_end") %in% names(ci)))
  expect_true(all(ci$centromere_start < ci$centromere_end))
  expect_true(all(ci$centromere_end < ci$length))
})

test_that("chr_info_mouse returns 19 chromosomes", {
  ci <- chr_info_mouse()
  expect_equal(nrow(ci), 19)
  expect_true(all(ci$chr == 1:19))
})

test_that("chr_info_cattle returns 29 chromosomes", {
  ci <- chr_info_cattle()
  expect_equal(nrow(ci), 29)
  expect_true(all(ci$chr == 1:29))
})

test_that("chr_info_human rejects unknown builds", {
  expect_error(chr_info_human(build = "hg19"))
})

test_that("chr_info_mouse rejects unknown builds", {
  expect_error(chr_info_mouse(build = "mm10"))
})

test_that("chr_info_cattle rejects unknown builds", {
  expect_error(chr_info_cattle(build = "UMD3.1"))
})
