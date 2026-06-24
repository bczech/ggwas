#' Human chromosome information (hg38)
#'
#' Returns a data.frame with chromosome lengths and centromere positions
#' for the human genome (GRCh38/hg38). Useful as the `chr_info` argument
#' in [snp_density()] and [density_signal_plot()] for accurate ideogram
#' rendering.
#'
#' @param build Genome build. Currently only `"hg38"` is supported.
#' @return A data.frame with columns: `chr` (integer), `length`,
#'   `centromere_start`, `centromere_end`.
#' @export
#' @examples
#' chr_info_human()
chr_info_human <- function(build = "hg38") {
  if (build != "hg38") {
    cli_abort("Only {.val hg38} build is currently supported.")
  }

  data.frame(
    chr = 1:22,
    length = c(
      248956422, 242193529, 198295559, 190214555, 181538259,
      170805979, 159345973, 145138636, 138394717, 133797422,
      135086622, 133275309, 114364328, 107043718, 101991189,
      90338345, 83257441, 80373285, 58617616, 64444167,
      46709983, 50818468
    ),
    centromere_start = c(
      122026460, 92188146, 90772459, 49708101, 46485901,
      58553889, 58169654, 44033745, 43236168, 39686683,
      51078349, 34769408, 16000000, 16000000, 17083675,
      36311159, 22813680, 15460900, 24498981, 26436233,
      10864561, 12954789
    ),
    centromere_end = c(
      124932724, 94090557, 93655574, 51743951, 50059807,
      59829934, 61528020, 45877265, 45518558, 41593521,
      54425074, 37185252, 18051248, 18173523, 19725254,
      38280682, 26885980, 20861206, 27190874, 28033230,
      12915808, 15054318
    )
  )
}
