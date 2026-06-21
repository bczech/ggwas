#' Genetic correlation matrix
#'
#' Heatmap of genetic correlations (rg) between traits, typically from
#' LD Score Regression (LDSC). Includes significance indicators and
#' hierarchical clustering of traits.
#'
#' @param rg_matrix A symmetric matrix of genetic correlations, or a
#'   data.frame with columns: trait1, trait2, rg, se, p.
#' @param p_matrix Optional matrix of p-values (same dimensions as rg_matrix).
#'   If `rg_matrix` is a data.frame with a `p` column, this is extracted
#'   automatically.
#' @param sig_threshold P-value threshold for significance markers.
#' @param sig_marker Character to mark significant correlations.
#' @param palette Color palette: "RdBu" (default), "PRGn", "PiYG", or
#'   a vector of colors.
#' @param cluster If TRUE, reorder traits by hierarchical clustering.
#' @param rg_range Range for the color scale (default c(-1, 1)).
#' @param cell_size Size of the text inside cells.
#' @param show_values Show rg values inside cells.
#' @param show_diagonal Show the diagonal (always 1.0).
#' @param title Plot title.
#' @return A ggplot object.
#' @export
#' @examples
#' # Simulated genetic correlation matrix
#' traits <- c("BMI", "Height", "WHR", "T2D", "CAD")
#' rg <- matrix(c(
#'   1.0,  -0.1,  0.6,  0.4,  0.2,
#'  -0.1,   1.0, -0.3, -0.1,  0.0,
#'   0.6,  -0.3,  1.0,  0.3,  0.15,
#'   0.4,  -0.1,  0.3,  1.0,  0.5,
#'   0.2,   0.0,  0.15, 0.5,  1.0
#' ), nrow = 5, dimnames = list(traits, traits))
#' genetic_correlation(rg)
genetic_correlation <- function(rg_matrix,
                                p_matrix = NULL,
                                sig_threshold = 0.05,
                                sig_marker = "*",
                                palette = "RdBu",
                                cluster = TRUE,
                                rg_range = c(-1, 1),
                                cell_size = 3.5,
                                show_values = TRUE,
                                show_diagonal = FALSE,
                                title = NULL) {

  if (is.data.frame(rg_matrix) && all(c("trait1", "trait2", "rg") %in% names(rg_matrix))) {
    df <- rg_matrix
    traits <- unique(c(df$trait1, df$trait2))
    mat <- matrix(NA, length(traits), length(traits),
                  dimnames = list(traits, traits))
    for (i in seq_len(nrow(df))) {
      mat[df$trait1[i], df$trait2[i]] <- df$rg[i]
      mat[df$trait2[i], df$trait1[i]] <- df$rg[i]
    }
    diag(mat) <- 1
    rg_matrix <- mat

    if ("p" %in% names(df) && is.null(p_matrix)) {
      p_mat <- matrix(NA, length(traits), length(traits),
                      dimnames = list(traits, traits))
      for (i in seq_len(nrow(df))) {
        p_mat[df$trait1[i], df$trait2[i]] <- df$p[i]
        p_mat[df$trait2[i], df$trait1[i]] <- df$p[i]
      }
      diag(p_mat) <- 0
      p_matrix <- p_mat
    }
  }

  if (cluster && nrow(rg_matrix) > 2) {
    rg_dist <- stats::as.dist(1 - abs(rg_matrix))
    hc <- stats::hclust(rg_dist, method = "complete")
    ord <- hc$order
    rg_matrix <- rg_matrix[ord, ord]
    if (!is.null(p_matrix)) p_matrix <- p_matrix[ord, ord]
  }

  traits <- rownames(rg_matrix)
  n <- length(traits)

  plot_df <- expand.grid(
    trait1 = factor(traits, levels = traits),
    trait2 = factor(traits, levels = rev(traits))
  )
  plot_df$rg <- NA_real_
  plot_df$p_val <- NA_real_

  for (i in seq_len(nrow(plot_df))) {
    t1 <- as.character(plot_df$trait1[i])
    t2 <- as.character(plot_df$trait2[i])
    plot_df$rg[i] <- rg_matrix[t1, t2]
    if (!is.null(p_matrix)) plot_df$p_val[i] <- p_matrix[t1, t2]
  }

  if (!show_diagonal) {
    diag_mask <- as.character(plot_df$trait1) == as.character(plot_df$trait2)
    plot_df$rg[diag_mask] <- NA
  }

  upper_mask <- match(as.character(plot_df$trait1), traits) >
    (n + 1 - match(as.character(plot_df$trait2), traits))
  plot_df$rg[upper_mask] <- NA

  plot_df$label <- ""
  show_idx <- !is.na(plot_df$rg)
  if (show_values) {
    plot_df$label[show_idx] <- sprintf("%.2f", plot_df$rg[show_idx])
  }
  if (!is.null(p_matrix)) {
    sig_idx <- show_idx & !is.na(plot_df$p_val) & plot_df$p_val < sig_threshold
    plot_df$label[sig_idx] <- paste0(plot_df$label[sig_idx], sig_marker)
  }

  if (is.character(palette) && length(palette) == 1) {
    pal_colors <- rev(RColorBrewer::brewer.pal(11, palette))
  } else {
    pal_colors <- palette
  }

  plt <- ggplot(plot_df, aes(x = .data$trait1, y = .data$trait2,
                              fill = .data$rg)) +
    geom_tile(color = "white", linewidth = 0.5) +
    ggplot2::scale_fill_gradientn(
      colors = pal_colors,
      limits = rg_range,
      na.value = "white",
      name = expression(r[g])
    ) +
    labs(x = NULL, y = NULL, title = title) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
      axis.text.y = element_text(size = 10),
      panel.grid = element_blank(),
      legend.position = "right"
    ) +
    ggplot2::coord_fixed()

  if (show_values || !is.null(p_matrix)) {
    plt <- plt + ggplot2::geom_text(
      aes(label = .data$label),
      size = cell_size, color = "black"
    )
  }

  plt
}
