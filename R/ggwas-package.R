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
#' By default, ggwas uses human chromosome conventions where chromosome
#' 23 is labeled "X", 24 is "Y", etc. For non-human organisms or when
#' chromosomes should be displayed as plain numbers, this mapping can
#' be customized or disabled.
#'
#' @param map A named integer vector mapping labels to integers, e.g.
#'   `c(X = 23L, Y = 24L)`. Pass `NULL` to disable all sex chromosome
#'   mapping (chromosomes displayed as plain numbers).
#' @return The previous mapping (invisibly).
#' @export
#' @examples
#' # Default: human (23 -> X, 24 -> Y, 25 -> XY, 26 -> MT)
#' set_sex_chr_map()
#'
#' # Disable: all chromosomes shown as numbers
#' set_sex_chr_map(NULL)
#'
#' # Mouse: 20 -> X, 21 -> Y
#' set_sex_chr_map(c(X = 20L, Y = 21L))
#'
#' # Restore default
#' set_sex_chr_map()
set_sex_chr_map <- function(map = .default_sex_chr_map) {
  prev <- getOption("ggwas.sex_chr_map", default = .default_sex_chr_map)
  options(ggwas.sex_chr_map = map)
  invisible(prev)
}
