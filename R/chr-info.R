#' Chromosome information for common species
#'
#' Built-in chromosome lengths and centromere positions for human, mouse,
#' and cattle genomes. For other species, use [chr_info_ucsc()] to fetch
#' data from UCSC or supply a custom data.frame.
#'
#' @param build Genome build (default: latest).
#' @return A data.frame with columns: `chr` (integer), `length`,
#'   `centromere_start`, `centromere_end`.
#' @name chr_info
#' @examples
#' chr_info_human()
#' chr_info_mouse()
#' chr_info_cattle()
NULL

#' @rdname chr_info
#' @export
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

#' @rdname chr_info
#' @export
chr_info_mouse <- function(build = "mm39") {
  if (build != "mm39") {
    cli_abort("Only {.val mm39} build is currently supported.")
  }

  # GRCm39 / mm39 — all chromosomes are acrocentric
  # Centromere positions from UCSC gap table (uniform 110kb-3Mb)
  data.frame(
    chr = 1:19,
    length = c(
      195154279, 181755017, 159745316, 156860686, 151758149,
      149588044, 144995196, 130127694, 124359700, 130530862,
      121973369, 120092757, 120883175, 125139656, 104073951,
      98008968, 95294699, 90720763, 61420004
    ),
    centromere_start = rep(110000, 19),
    centromere_end = rep(3000000, 19)
  )
}

#' @rdname chr_info
#' @export
chr_info_cattle <- function(build = "ARS-UCD1.2") {
  if (!build %in% c("ARS-UCD1.2", "bosTau9")) {
    cli_abort("Only {.val ARS-UCD1.2} (bosTau9) build is currently supported.")
  }

  # ARS-UCD1.2 / bosTau9 — all autosomes are acrocentric
  # No centromere annotation in UCSC for this assembly
  data.frame(
    chr = 1:29,
    length = c(
      158534110, 136231102, 121005158, 120000601, 121191424,
      119458736, 112638659, 113384836, 105708250, 103308737,
      107310763, 87216183, 83472345, 82403003, 85007780,
      81013979, 73167244, 65820629, 63449741, 71974595,
      69862954, 60773035, 52498615, 62317253, 42350435,
      51992305, 45407902, 45636533, 51505224
    ),
    centromere_start = rep(NA_real_, 29),
    centromere_end = rep(NA_real_, 29)
  )
}

#' Fetch chromosome information from UCSC
#'
#' Downloads chromosome lengths and centromere positions from the UCSC
#' Genome Browser for any supported genome assembly. Requires internet
#' access.
#'
#' @param genome UCSC genome identifier, e.g. `"hg38"`, `"mm39"`,
#'   `"bosTau9"`, `"canFam6"`, `"susScr11"`, `"galGal6"`.
#' @param autosomes_only If TRUE (default), return only autosomal
#'   chromosomes (exclude X, Y, M, and unplaced scaffolds).
#' @return A data.frame with columns: `chr` (integer), `length`,
#'   `centromere_start`, `centromere_end`.
#' @export
#' @examples
#' \dontrun{
#' # Dog genome
#' dog <- chr_info_ucsc("canFam6")
#' snp_density(gwas, chr_info = dog)
#'
#' # Pig genome
#' pig <- chr_info_ucsc("susScr11")
#' }
chr_info_ucsc <- function(genome, autosomes_only = TRUE) {
  base_url <- paste0(
    "https://hgdownload.cse.ucsc.edu/goldenPath/",
    genome, "/database/"
  )

  .ucsc_download <- function(file) {
    dest <- tempfile(fileext = ".txt.gz")
    url <- paste0(base_url, file)
    ok <- tryCatch({
      utils::download.file(url, dest, quiet = TRUE, method = "auto")
      TRUE
    }, error = function(e) {
      url_http <- sub("^https://", "http://", url)
      tryCatch({
        utils::download.file(url_http, dest, quiet = TRUE, method = "auto")
        TRUE
      }, error = function(e2) FALSE)
    })
    if (!ok) return(NULL)
    dest
  }

  tmp_chrom <- .ucsc_download("chromInfo.txt.gz")
  if (is.null(tmp_chrom)) {
    cli_abort("Failed to download chromosome info for {.val {genome}}. Check the genome name.")
  }
  on.exit(unlink(tmp_chrom), add = TRUE)

  chrom <- utils::read.delim(tmp_chrom, header = FALSE,
    col.names = c("name", "length", "file"))
  chrom$file <- NULL

  if (autosomes_only) {
    auto_pattern <- "^chr([0-9]+)$"
    chrom <- chrom[grepl(auto_pattern, chrom$name), , drop = FALSE]
    chrom$chr <- as.integer(sub(auto_pattern, "\\1", chrom$name))
  } else {
    chrom$chr <- sub("^chr", "", chrom$name)
  }

  has_centromeres <- FALSE
  tmp_gap <- .ucsc_download("gap.txt.gz")
  tryCatch({
    if (is.null(tmp_gap)) stop("no gap table")
    on.exit(unlink(tmp_gap), add = TRUE)
    gap <- utils::read.delim(tmp_gap, header = FALSE)
    cen <- gap[gap$V8 == "centromere", , drop = FALSE]
    if (nrow(cen) > 0) {
      has_centromeres <- TRUE
      cen$chr_name <- cen$V2
      if (autosomes_only) {
        cen <- cen[grepl("^chr[0-9]+$", cen$chr_name), , drop = FALSE]
        cen$chr <- as.integer(sub("^chr", "", cen$chr_name))
      } else {
        cen$chr <- sub("^chr", "", cen$chr_name)
      }
      cen_agg <- stats::aggregate(
        cbind(V3, V4) ~ chr, data = cen,
        FUN = function(x) c(min(x), max(x))[ifelse(
          identical(deparse(sys.call()[[1]]), "min"), 1, 2)]
      )
      cen_min <- stats::aggregate(V3 ~ chr, data = cen, FUN = min)
      cen_max <- stats::aggregate(V4 ~ chr, data = cen, FUN = max)
      names(cen_min) <- c("chr", "centromere_start")
      names(cen_max) <- c("chr", "centromere_end")
      cen_merged <- merge(cen_min, cen_max, by = "chr")
    }
  }, error = function(e) {
    cli_inform("No gap table found for {.val {genome}}, centromere positions unavailable.")
  })

  result <- data.frame(
    chr = chrom$chr,
    length = chrom$length
  )

  if (has_centromeres && exists("cen_merged")) {
    result <- merge(result, cen_merged, by = "chr", all.x = TRUE)
  } else {
    result$centromere_start <- NA_real_
    result$centromere_end <- NA_real_
  }

  if (autosomes_only) {
    result$chr <- as.integer(result$chr)
    result <- result[order(result$chr), , drop = FALSE]
  }

  rownames(result) <- NULL
  result
}
