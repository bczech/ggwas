#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data .env %||%
#' @importFrom data.table fread
#' @importFrom stats median qchisq pchisq qbeta
#' @importFrom ggplot2 ggplot aes geom_point geom_hline geom_abline geom_segment geom_rect geom_tile geom_ribbon labs theme element_text element_blank element_line scale_x_continuous scale_y_continuous scale_color_manual scale_color_viridis_c scale_fill_manual scale_fill_identity scale_fill_viridis_c coord_cartesian annotation_custom guides guide_legend
#' @importFrom scales comma
#' @importFrom cli cli_inform cli_warn cli_abort
NULL

#' Configure sex chromosome mapping
#'
#' ggwas stores chromosomes as integer codes. By default it uses human
#' conventions, where chromosome 23 is labeled "X", 24 is "Y", 25 is "XY" and
#' 26 is "MT". For other organisms, pass the genome's `Seqinfo` object
#' (\pkg{GenomeInfoDb}) and the codes are taken from its sequence names:
#' numbered chromosomes keep their number, and named ones (X, Y, Z, W, MT,
#' ...) are numbered after the last autosome, in `Seqinfo` order. Unplaced
#' scaffolds are ignored.
#'
#' @param map A `Seqinfo` object, or any object that has one (`TxDb`,
#'   `EnsDb`, `BSgenome`); or a named integer vector mapping labels to
#'   integers, e.g. `c(X = 20L, Y = 21L)`. Pass `NULL` to disable the
#'   mapping (chromosomes displayed as plain numbers).
#' @return The previous mapping (invisibly).
#' @export
#' @examples
#' # Mouse (GRCm39): 19 autosomes, then X, Y and MT
#' mouse <- GenomeInfoDb::Seqinfo(c(1:19, "X", "Y", "MT"), genome = "GRCm39")
#' old <- set_sex_chr_map(mouse)
#' getOption("ggwas.sex_chr_map")
#'
#' # Chicken: Z and W follow the last numbered chromosome
#' chicken <- GenomeInfoDb::Seqinfo(c(1:39, "Z", "W", "MT"))
#' set_sex_chr_map(chicken)
#'
#' # Disable: all chromosomes shown as numbers
#' set_sex_chr_map(NULL)
#'
#' # Restore the previous (here the human default) mapping
#' set_sex_chr_map(old)
set_sex_chr_map <- function(map = .default_sex_chr_map) {
  prev <- getOption("ggwas.sex_chr_map", default = .default_sex_chr_map)
  if (!is.null(map) && !is.numeric(map)) {
    si <- if (methods::is(map, "Seqinfo")) {
      map
    } else {
      tryCatch(GenomeInfoDb::seqinfo(map), error = function(e) NULL)
    }
    if (is.null(si)) {
      cli_abort("{.arg map} must be a {.cls Seqinfo} object, a named integer vector or NULL.")
    }
    map <- .sex_map_from_seqinfo(si)
  }
  if (is.null(map)) {
    # An empty map, not NULL: options(x = NULL) would drop the option and
    # chr_to_int() would fall back to the human default.
    map <- stats::setNames(integer(), character())
  }
  if (length(map) > 0 && (is.null(names(map)) || any(!nzchar(names(map))))) {
    cli_abort("{.arg map} must be named, e.g. {.code c(X = 20L, Y = 21L)}.")
  }
  options(ggwas.sex_chr_map = map)
  invisible(prev)
}
