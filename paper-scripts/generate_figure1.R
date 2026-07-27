library(ggwas)
library(ggplot2)
library(data.table)
library(patchwork)

# --- Panel A & B & E: Height GWAS (Yengo et al. 2022, GIANT) ----------------

height <- fread("data/giant_height_eur.txt.gz")
setnames(height, c("SNPID", "RSID", "CHR", "POS", "EFFECT_ALLELE",
  "OTHER_ALLELE", "EFFECT_ALLELE_FREQ", "BETA", "SE", "P_STR", "N"))

# Parse extreme p-values (some as small as 1e-1151) to log10(P)
parse_log10p <- function(p_str) {
  p_num <- suppressWarnings(as.numeric(p_str))
  ifelse(!is.na(p_num) & p_num > 0, log10(p_num), {
    m <- regmatches(p_str, regexec("^([0-9.]+)[eE]([+-]?[0-9]+)$", p_str))
    vapply(seq_along(m), function(i) {
      if (length(m[[i]]) == 3) log10(as.numeric(m[[i]][2])) + as.numeric(m[[i]][3])
      else NA_real_
    }, numeric(1))
  })
}

height[, LOG10P := parse_log10p(P_STR)]
height[, NEGLOG10P := -LOG10P]
height <- height[!is.na(LOG10P) & !is.na(CHR)]

height_gwas <- as_gwas_data(height,
  chr = "CHR", bp = "POS", snp = "RSID", p = "NEGLOG10P",
  beta = "BETA", se = "SE", a1 = "EFFECT_ALLELE", a2 = "OTHER_ALLELE",
  af = "EFFECT_ALLELE_FREQ", log_p = TRUE
)

p_a <- manhattan_plot(height_gwas, point_size = 1.2, downsample_n = 100000,
    label_top_n = 3) +
  labs(tag = "A") +
  theme_nature(base_size = 7)

p_b <- qq_plot(height_gwas, show_lambda = TRUE, ci = 0.95, point_size = 0.4) +
  labs(tag = "B") +
  theme_nature(base_size = 7)

p_e <- pvalue_heatmap(height_gwas, palette = "magma") +
  labs(tag = "E") +
  theme_nature(base_size = 7)

# --- Panel C: Trumpet plot (effect size vs MAF with power contours) ----------
# The novel visualization: overlays statistical-power contours on the
# effect-versus-frequency relationship for the height GWAS.

p_c <- trumpet_plot(height_gwas,
    n = as.integer(stats::median(height$N, na.rm = TRUE)),
    label_top_n = 3, point_size = 0.6) +
  labs(tag = "C") +
  theme_nature(base_size = 7) +
  theme(legend.position = "right", legend.key.size = grid::unit(0.35, "cm"))

# --- Panel D + G: Locus zoom with gene track (HMGA2 region, chr12) -----------
# HMGA2 is a classic height-associated locus. The locus zoom (D) shows the
# regional association signal; the composable gene track (G) sits directly
# below it, sharing the same genomic axis.

gene_models <- data.frame(
  chr    = 12,
  start  = c(65.44e6, 65.55e6, 65.67e6, 66.22e6, 66.55e6),
  end    = c(65.52e6, 65.63e6, 65.98e6, 66.35e6, 66.60e6),
  gene   = c("WIF1", "LEMD3", "MSRB3", "HMGA2", "IRAK3"),
  strand = c("+", "-", "-", "+", "-")
)

region <- list(chr = 12, start = 65.3e6, end = 66.7e6)

p_d <- locus_plot(height_gwas,
    region_chr = region$chr, region_start = region$start,
    region_end = region$end, point_size = 1) +
  labs(tag = "D") +
  theme_nature(base_size = 7) +
  theme(axis.title.x = element_blank(), axis.text.x = element_blank(),
        axis.ticks.x = element_blank())

p_g <- gene_track(gene_models,
    region_chr = region$chr, region_start = region$start,
    region_end = region$end, highlight_genes = "HMGA2", label_size = 1.8) +
  labs(x = "Position on chr12 (Mb)") +
  theme_nature(base_size = 7) +
  theme(axis.title.y = element_blank(), axis.text.y = element_blank(),
        axis.ticks.y = element_blank(), panel.grid = element_blank())

# --- Compose Figure 1 -------------------------------------------------------

layout <- "
AAAAAAAAA
AAAAAAAAA
BBBCCCCCC
DDDDDEEEE
DDDDDEEEE
GGGGG####
"

fig1 <- p_a + p_b + p_c + p_d + p_e + p_g +
  plot_layout(design = layout, heights = c(1, 1, 1, 1, 1, 0.45)) +
  plot_annotation(theme = theme(plot.margin = margin(2, 2, 2, 2)))

ggsave("figures/figure1.png", fig1, width = 180, height = 235,
  units = "mm", dpi = 600, device = ragg::agg_png)
ggsave("figures/figure1.pdf", fig1, width = 180, height = 235,
  units = "mm", device = cairo_pdf)

message("Figure 1 generated successfully.")
