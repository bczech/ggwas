library(ggwas)
library(ggplot2)
library(data.table)
library(patchwork)

# --- Load Height GWAS --------------------------------------------------------

height <- fread("data/giant_height_eur.txt.gz")
setnames(height, c("SNPID", "RSID", "CHR", "POS", "EA", "OA", "EAF",
  "BETA", "SE", "P_STR", "N"))

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
  beta = "BETA", se = "SE", a1 = "EA", a2 = "OA",
  af = "EAF", log_p = TRUE
)

# Create second trait (subsample with shifted effects for multi-trait demos)
set.seed(123)
idx2 <- sample(nrow(height), nrow(height))
trait2 <- height[idx2]
trait2[, BETA := BETA * runif(.N, 0.5, 1.5) + rnorm(.N, 0, 0.005)]
trait2[, NEGLOG10P := pmax(0, NEGLOG10P * runif(.N, 0.3, 1.2))]
trait2_gwas <- as_gwas_data(trait2,
  chr = "CHR", bp = "POS", snp = "RSID", p = "NEGLOG10P",
  beta = "BETA", se = "SE", a1 = "EA", a2 = "OA",
  af = "EAF", log_p = TRUE
)

base_size <- 8

# --- S1: Manhattan plot ------------------------------------------------------

s1 <- manhattan_plot(height_gwas, point_size = 0.3, label_top_n = 5) +
  ggtitle("Manhattan plot") + theme_nature(base_size = base_size)

# --- S2: QQ plot -------------------------------------------------------------

s2 <- qq_plot(height_gwas, show_lambda = TRUE, ci = 0.95, point_size = 0.4) +
  ggtitle("QQ plot") + theme_nature(base_size = base_size)

# --- S3: Miami plot ----------------------------------------------------------

s3 <- miami_plot(height_gwas, trait2_gwas,
  top_title = "Height (Yengo 2022)", bottom_title = "Height (permuted)") +
  ggtitle("Miami plot") + theme_nature(base_size = base_size)

# --- S4: Locus zoom ----------------------------------------------------------

# GDF5 locus on chr20 (strongest height signal)
s4 <- locus_plot(height_gwas, region_chr = 20,
  region_start = 33.5e6, region_end = 34.5e6) +
  ggtitle("Locus zoom (GDF5, chr20)") + theme_nature(base_size = base_size)

# --- S5: Circular Manhattan --------------------------------------------------

# circular_manhattan already sets theme_void internally; applying theme_nature
# on top of it re-adds the cartesian angle/radius axes, so only tweak the title.
s5 <- circular_manhattan(height_gwas, point_size = 0.15) +
  ggtitle("Circular Manhattan") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold",
                                  size = base_size + 2))

# --- S6: Enrichment Manhattan ------------------------------------------------

annotations <- data.frame(
  chr = c(1, 2, 3, 3, 5, 6, 7, 9, 11, 12, 15, 17, 18, 20),
  start = c(145e6, 50e6, 50e6, 135e6, 170e6, 25e6, 85e6, 90e6,
            60e6, 60e6, 80e6, 25e6, 15e6, 30e6),
  end =   c(155e6, 60e6, 60e6, 145e6, 180e6, 35e6, 95e6, 100e6,
            70e6, 70e6, 90e6, 35e6, 25e6, 40e6),
  category = c("Enhancer", "eQTL", "Gene body", "Enhancer", "Gene body",
               "MHC", "eQTL", "Gene body", "Enhancer", "Gene body",
               "eQTL", "Gene body", "Enhancer", "Gene body")
)

s6 <- enrichment_manhattan(height_gwas, annotations = annotations) +
  ggtitle("Enrichment Manhattan") + theme_nature(base_size = base_size)

# --- S7: Multi-trait Manhattan -----------------------------------------------

s7 <- multitrait_manhattan(Height = height_gwas, `Height (perm)` = trait2_gwas,
  highlight_shared = TRUE, point_size = 0.3) +
  ggtitle("Multi-trait Manhattan") + theme_nature(base_size = base_size)

# --- S8: Genome-wide heatmap -------------------------------------------------

s8 <- pvalue_heatmap(height_gwas, palette = "magma") +
  ggtitle("Genome-wide p-value heatmap") + theme_nature(base_size = base_size)

# --- S9: Effect-size volcano -------------------------------------------------

# A handful of rare variants carry very large effects and would stretch the
# x-axis into a spike, so clip it to the bulk of the distribution.
beta_lim <- stats::quantile(abs(height_gwas$BETA), 0.999, na.rm = TRUE)
s9 <- volcano_plot(height_gwas, label_top_n = 5) +
  coord_cartesian(xlim = c(-beta_lim, beta_lim)) +
  ggtitle("Effect-size volcano") + theme_nature(base_size = base_size)

# --- S10: Summary dashboard --------------------------------------------------

s10 <- gwas_summary(height_gwas) +
  plot_annotation(title = "Summary dashboard",
    theme = theme(plot.title = element_text(size = base_size + 2)))

# --- S11: PheWAS plot --------------------------------------------------------

phewas_data <- data.frame(
  phenotype = c(
    "Standing height", "Sitting height", "Trunk length",
    "Leg length", "Arm span", "Birth length",
    "BMI", "Body fat %", "Waist circ.", "Hip circ.",
    "Weight", "Lean mass",
    "Bone density (femur)", "Bone density (spine)", "Fracture risk",
    "Grip strength", "Peak height velocity",
    "Heel ultrasound",
    "Age at menarche", "Age at voice break",
    "FEV1", "FVC", "Peak flow",
    "CAD", "T2D", "Blood pressure (sys)",
    "IGF-1 levels"
  ),
  p = c(
    1e-300, 1e-180, 1e-90, 1e-120, 1e-85, 1e-25,
    1e-8, 0.002, 0.1, 0.05, 1e-15, 1e-5,
    1e-12, 1e-10, 0.01, 1e-6, 1e-20, 1e-8,
    1e-15, 1e-10,
    1e-30, 1e-25, 1e-18,
    0.5, 0.3, 0.08,
    1e-40
  ),
  category = c(
    rep("Anthropometric", 6), rep("Body composition", 6),
    rep("Musculoskeletal", 6),
    rep("Puberty/Growth", 2), rep("Lung function", 3),
    rep("Cardiometabolic", 3), "Biomarker"
  ),
  beta = c(
    0.45, 0.35, 0.28, 0.30, 0.25, 0.12,
    -0.03, -0.01, 0.005, 0.003, 0.08, 0.04,
    0.05, 0.04, -0.01, 0.03, 0.10, 0.04,
    -0.06, -0.05,
    0.15, 0.13, 0.10,
    0.002, -0.003, 0.005,
    0.20
  )
)

s11 <- phewas_plot(phewas_data, point_size = 2, label_top_n = 5) +
  ggtitle("PheWAS plot") + theme_nature(base_size = base_size)

# --- S12: Colocalization plot ------------------------------------------------

# Simulate eQTL data for GDF5 region
set.seed(42)
gdf5_region <- height[CHR == 20 & POS >= 33.5e6 & POS <= 34.5e6]
eqtl_data <- data.frame(
  CHR = gdf5_region$CHR,
  BP = gdf5_region$POS,
  SNP = gdf5_region$RSID,
  P = pmin(1, 10^(-gdf5_region$NEGLOG10P * runif(nrow(gdf5_region), 0.3, 0.9))),
  BETA = gdf5_region$BETA * runif(nrow(gdf5_region), 0.5, 1.5)
)

s12 <- coloc_plot(height_gwas, eqtl_data,
  region_chr = 20, region_start = 33.5e6, region_end = 34.5e6,
  top_title = "GWAS (Height)", bottom_title = "eQTL (GDF5)") +
  ggtitle("Colocalization plot") + theme_nature(base_size = base_size)

# --- S13: Fine-mapping plot --------------------------------------------------

set.seed(42)
fm_region <- height[CHR == 3 & POS >= 140.5e6 & POS <= 141.5e6]
# Perturbed signal kept in -log10 units (finite); underflow floored so the
# peak stays on-plot instead of becoming -log10(0) = Inf.
neglog <- fm_region$NEGLOG10P * runif(nrow(fm_region), 0.2, 1.0)
fm_p <- pmax(.Machine$double.xmin, pmin(1, 10^(-neglog)))
# PIP tracks the signal (a single credible set at the peak), so the labeled
# high-PIP variant is the actual lead, not a random low SNP.
pip <- (neglog / max(neglog))^4 * runif(nrow(fm_region), 0.6, 1.0)
fm_data <- data.frame(
  CHR = fm_region$CHR,
  BP = fm_region$POS,
  SNP = fm_region$RSID,
  P = fm_p,
  PIP = pmin(0.99, pip),
  CS = ifelse(pip > 0.1, 1L, NA_integer_)
)
lead_idx <- which.max(pip)
fm_data$PIP[lead_idx] <- 0.95
fm_data$CS[lead_idx] <- 1L

s13 <- finemapping_plot(fm_data,
  region_chr = 3, region_start = 140.5e6, region_end = 141.5e6,
  label_pip_above = 0.5) +
  ggtitle("Fine-mapping (ZBTB38 locus)") + theme_nature(base_size = base_size)

# --- S14: Genetic correlation matrix -----------------------------------------

traits <- c("Height", "BMI", "WHR", "Birth weight",
            "Bone density", "FEV1", "IGF-1",
            "Menarche", "CAD", "T2D")
n_t <- length(traits)
rg_mat <- matrix(1, n_t, n_t, dimnames = list(traits, traits))
rg_mat["Height","BMI"] <- rg_mat["BMI","Height"] <- -0.09
rg_mat["Height","WHR"] <- rg_mat["WHR","Height"] <- -0.17
rg_mat["Height","Birth weight"] <- rg_mat["Birth weight","Height"] <- 0.58
rg_mat["Height","Bone density"] <- rg_mat["Bone density","Height"] <- 0.33
rg_mat["Height","FEV1"] <- rg_mat["FEV1","Height"] <- 0.36
rg_mat["Height","IGF-1"] <- rg_mat["IGF-1","Height"] <- 0.43
rg_mat["Height","Menarche"] <- rg_mat["Menarche","Height"] <- 0.12
rg_mat["Height","CAD"] <- rg_mat["CAD","Height"] <- -0.11
rg_mat["Height","T2D"] <- rg_mat["T2D","Height"] <- -0.15
rg_mat["BMI","WHR"] <- rg_mat["WHR","BMI"] <- 0.49
rg_mat["BMI","Birth weight"] <- rg_mat["Birth weight","BMI"] <- 0.11
rg_mat["BMI","Bone density"] <- rg_mat["Bone density","BMI"] <- 0.07
rg_mat["BMI","FEV1"] <- rg_mat["FEV1","BMI"] <- -0.13
rg_mat["BMI","IGF-1"] <- rg_mat["IGF-1","BMI"] <- -0.06
rg_mat["BMI","Menarche"] <- rg_mat["Menarche","BMI"] <- -0.34
rg_mat["BMI","CAD"] <- rg_mat["CAD","BMI"] <- 0.28
rg_mat["BMI","T2D"] <- rg_mat["T2D","BMI"] <- 0.55
rg_mat["WHR","Birth weight"] <- rg_mat["Birth weight","WHR"] <- -0.10
rg_mat["WHR","Bone density"] <- rg_mat["Bone density","WHR"] <- -0.05
rg_mat["WHR","FEV1"] <- rg_mat["FEV1","WHR"] <- -0.18
rg_mat["WHR","IGF-1"] <- rg_mat["IGF-1","WHR"] <- -0.12
rg_mat["WHR","Menarche"] <- rg_mat["Menarche","WHR"] <- -0.15
rg_mat["WHR","CAD"] <- rg_mat["CAD","WHR"] <- 0.32
rg_mat["WHR","T2D"] <- rg_mat["T2D","WHR"] <- 0.42
rg_mat["Birth weight","Bone density"] <- rg_mat["Bone density","Birth weight"] <- 0.15
rg_mat["Birth weight","FEV1"] <- rg_mat["FEV1","Birth weight"] <- 0.20
rg_mat["Birth weight","IGF-1"] <- rg_mat["IGF-1","Birth weight"] <- 0.25
rg_mat["Birth weight","Menarche"] <- rg_mat["Menarche","Birth weight"] <- 0.05
rg_mat["Birth weight","CAD"] <- rg_mat["CAD","Birth weight"] <- 0.10
rg_mat["Birth weight","T2D"] <- rg_mat["T2D","Birth weight"] <- 0.08
rg_mat["Bone density","FEV1"] <- rg_mat["FEV1","Bone density"] <- 0.09
rg_mat["Bone density","IGF-1"] <- rg_mat["IGF-1","Bone density"] <- 0.12
rg_mat["Bone density","Menarche"] <- rg_mat["Menarche","Bone density"] <- 0.10
rg_mat["Bone density","CAD"] <- rg_mat["CAD","Bone density"] <- -0.04
rg_mat["Bone density","T2D"] <- rg_mat["T2D","Bone density"] <- -0.02
rg_mat["FEV1","IGF-1"] <- rg_mat["IGF-1","FEV1"] <- 0.15
rg_mat["FEV1","Menarche"] <- rg_mat["Menarche","FEV1"] <- 0.08
rg_mat["FEV1","CAD"] <- rg_mat["CAD","FEV1"] <- -0.10
rg_mat["FEV1","T2D"] <- rg_mat["T2D","FEV1"] <- -0.12
rg_mat["IGF-1","Menarche"] <- rg_mat["Menarche","IGF-1"] <- 0.08
rg_mat["IGF-1","CAD"] <- rg_mat["CAD","IGF-1"] <- -0.05
rg_mat["IGF-1","T2D"] <- rg_mat["T2D","IGF-1"] <- -0.09
rg_mat["Menarche","CAD"] <- rg_mat["CAD","Menarche"] <- -0.05
rg_mat["Menarche","T2D"] <- rg_mat["T2D","Menarche"] <- -0.20
rg_mat["CAD","T2D"] <- rg_mat["T2D","CAD"] <- 0.38

s14 <- genetic_correlation(rg_mat, cluster = TRUE) +
  ggtitle("Genetic correlation matrix") + theme_nature(base_size = base_size)

# --- S15: Architecture plot --------------------------------------------------

# Clip |beta| so the polygenic smear of small effects is visible instead of
# being flattened by a few large-effect rare variants.
absbeta_lim <- stats::quantile(abs(height_gwas$BETA), 0.999, na.rm = TRUE)
s15 <- architecture_plot(height_gwas) +
  coord_cartesian(ylim = c(0, absbeta_lim)) +
  ggtitle("Genetic architecture (MAF vs effect size)") +
  theme_nature(base_size = base_size)

# --- S16: SNP density karyogram ----------------------------------------------

s16 <- snp_density(height_gwas, chr_info = chr_info_human()) +
  ggtitle("SNP density karyogram (heatmap)") + theme_nature(base_size = base_size)

# --- S17: Density vs signal comparison ---------------------------------------

s17 <- density_signal_plot(height_gwas, chr_info = chr_info_human()) +
  ggtitle("Density vs signal") + theme_nature(base_size = base_size)

# --- S18: Forest plot --------------------------------------------------------

lead <- as.data.frame(height_gwas)
lead <- lead[!is.na(lead$SE) & !is.na(lead$BETA), ]
lead <- lead[order(lead$P), ]
lead <- utils::head(lead[!duplicated(lead$CHR), ], 12)

s18 <- forest_plot(lead, effect = "BETA", se = "SE", label = "SNP",
  order_by = "effect") +
  ggtitle("Forest plot (lead variants)") + theme_nature(base_size = base_size)

# --- S19: Effect comparison --------------------------------------------------

set.seed(7)
sub_idx <- sample(nrow(height), 40000)
s19 <- effect_compare_plot(
  as.data.frame(height_gwas)[sub_idx, ], trait2_gwas,
  labels = c("Height", "Height (permuted)"),
  p_threshold = 5e-8, label_top_n = 5) +
  ggtitle("Effect comparison") + theme_nature(base_size = base_size)

# --- S20: Trumpet plot -------------------------------------------------------

s20 <- trumpet_plot(height_gwas,
  n = as.integer(stats::median(height$N, na.rm = TRUE)),
  label_top_n = 5) +
  ggtitle("Trumpet plot (power contours)") + theme_nature(base_size = base_size)

# --- Save individual panels as multi-page PDF --------------------------------

plots <- list(s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15,
  s16, s17, s18, s19, s20)
titles <- c("Manhattan", "QQ", "Miami", "Locus zoom", "Circular Manhattan",
  "Enrichment Manhattan", "Multi-trait Manhattan", "Genome-wide heatmap",
  "Effect-size volcano", "Summary dashboard", "PheWAS", "Colocalization",
  "Fine-mapping", "Genetic correlation", "Architecture",
  "SNP density", "Density vs signal", "Forest plot", "Effect comparison",
  "Trumpet plot")

dir.create("figures/supplementary", showWarnings = FALSE)
for (i in seq_along(plots)) {
  fname <- sprintf("figures/supplementary/S%02d_%s", i,
    gsub("[^a-zA-Z0-9]", "_", tolower(titles[i])))
  ggsave(paste0(fname, ".png"), plots[[i]],
    width = 180, height = 130, units = "mm", dpi = 300)
}

# Also combine into single multi-page PDF (rasterized for size)
png_files <- sprintf("figures/supplementary/S%02d_%s.png",
  seq_along(titles), gsub("[^a-zA-Z0-9]", "_", tolower(titles)))
pdf("figures/supplementary_figure1.pdf", width = 7.1, height = 5.1)
for (f in png_files) {
  img <- png::readPNG(f)
  grid::grid.raster(img)
  if (f != tail(png_files, 1)) grid::grid.newpage()
}
dev.off()

message("Supplementary figure generated: figures/supplementary_figure1.pdf")
message(length(plots), " panels saved.")
