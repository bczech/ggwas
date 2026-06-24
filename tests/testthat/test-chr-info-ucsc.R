test_that("chr_info_ucsc parses chromInfo and gap correctly", {
  chrom_dir <- withr::local_tempdir()

  chrom_data <- "chr1\t100000000\t/path\nchr2\t80000000\t/path\nchr3\t60000000\t/path\nchrX\t50000000\t/path"
  chrom_gz <- file.path(chrom_dir, "chromInfo.txt.gz")
  con <- gzfile(chrom_gz, "w"); writeLines(chrom_data, con); close(con)

  gap_data <- "585\tchr1\t10000000\t12000000\t1\tN\t2000000\tcentromere\tno\n586\tchr2\t5000000\t6000000\t1\tN\t1000000\tcentromere\tno\n587\tchr3\t3000000\t4000000\t1\tN\t1000000\tcentromere\tno"
  gap_gz <- file.path(chrom_dir, "gap.txt.gz")
  con <- gzfile(gap_gz, "w"); writeLines(gap_data, con); close(con)

  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      src <- if (grepl("chromInfo", url)) chrom_gz else gap_gz
      file.copy(src, destfile, overwrite = TRUE)
      invisible(0)
    },
    .package = "utils"
  )

  result <- chr_info_ucsc("mock_genome")
  expect_equal(nrow(result), 3)
  expect_equal(result$chr, 1:3)
  expect_equal(result$length, c(100000000, 80000000, 60000000))
  expect_equal(result$centromere_start, c(10000000, 5000000, 3000000))
  expect_equal(result$centromere_end, c(12000000, 6000000, 4000000))
})

test_that("chr_info_ucsc works without gap table", {
  chrom_dir <- withr::local_tempdir()

  chrom_data <- "chr1\t100000000\t/path\nchr2\t80000000\t/path"
  chrom_gz <- file.path(chrom_dir, "chromInfo.txt.gz")
  con <- gzfile(chrom_gz, "w"); writeLines(chrom_data, con); close(con)

  call_count <- 0L
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      call_count <<- call_count + 1L
      if (grepl("chromInfo", url)) {
        file.copy(chrom_gz, destfile, overwrite = TRUE)
        invisible(0)
      } else {
        stop("not found")
      }
    },
    .package = "utils"
  )

  result <- chr_info_ucsc("mock_genome")
  expect_equal(nrow(result), 2)
  expect_true(all(is.na(result$centromere_start)))
})

test_that("chr_info_ucsc includes non-autosomal when requested", {
  chrom_dir <- withr::local_tempdir()

  chrom_data <- "chr1\t100000000\t/path\nchrX\t50000000\t/path"
  chrom_gz <- file.path(chrom_dir, "chromInfo.txt.gz")
  con <- gzfile(chrom_gz, "w"); writeLines(chrom_data, con); close(con)

  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      if (grepl("chromInfo", url)) {
        file.copy(chrom_gz, destfile, overwrite = TRUE)
        invisible(0)
      } else {
        stop("not found")
      }
    },
    .package = "utils"
  )

  result <- chr_info_ucsc("mock_genome", autosomes_only = FALSE)
  expect_equal(nrow(result), 2)
  expect_true("X" %in% result$chr)
})

test_that("chr_info_ucsc errors on failed download", {
  local_mocked_bindings(
    download.file = function(url, destfile, ...) stop("connection refused"),
    .package = "utils"
  )

  expect_error(chr_info_ucsc("fake_genome"), "Failed to download")
})
