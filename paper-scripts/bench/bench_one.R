#!/usr/bin/env Rscript
# Benchmark one (tool, size) cell: median render-to-file time over N reps.
# Peak RSS is captured by the calling /usr/bin/time -l wrapper.
# Usage: Rscript bench_one.R <tool> <size> <data_path>

suppressPackageStartupMessages({
  library(data.table)
})

args <- commandArgs(trailingOnly = TRUE)
tool <- args[[1]]
size <- as.integer(args[[2]])
data_path <- args[[3]]
reps <- 5L

# --- Load + clean once (not timed) ------------------------------------------
d <- fread(data_path, showProgress = FALSE)
setnames(d, c("SNPID", "RSID", "CHR", "POS", "EFFECT_ALLELE",
  "OTHER_ALLELE", "EFFECT_ALLELE_FREQ", "BETA", "SE", "P", "N"))
# P can be read as character (extreme values like 1e-1151); coerce first
d[, P := suppressWarnings(as.numeric(P))]
d <- d[CHR %in% 1:22 & !is.na(POS) & !is.na(P)]
# Clamp p-values into (0, 1) so every tool can compute a finite -log10(P)
d[, P := pmin(pmax(P, 1e-300), 1 - 1e-12)]
d <- d[, .(SNP = RSID, CHR = as.integer(CHR), POS = as.integer(POS),
           P = as.numeric(P), BETA = as.numeric(BETA))]

# Deterministic nested subsample: same rows for every tool at a given size
set.seed(1)
ord <- sample.int(nrow(d))
n <- min(size, nrow(d))
df <- as.data.frame(d[ord[seq_len(n)]])

tf <- tempfile(fileext = ".png")

# --- Per-tool render function (build plot + write file) ----------------------
render <- switch(tool,
  qqman = function() {
    grDevices::png(tf, width = 1200, height = 600, res = 100)
    qqman::manhattan(df, chr = "CHR", bp = "POS", p = "P", snp = "SNP")
    grDevices::dev.off()
  },
  CMplot = function() {
    cm <- data.frame(SNP = df$SNP, Chromosome = df$CHR,
                     Position = df$POS, trait1 = df$P)
    CMplot::CMplot(cm, plot.type = "m", file = "png", file.output = TRUE,
      dpi = 100, verbose = FALSE, file.name = "cmbench", width = 12, height = 6)
  },
  topr = function() {
    tp <- data.frame(CHROM = df$CHR, POS = df$POS, P = df$P)
    p <- topr::manhattan(tp, verbose = FALSE)
    ggplot2::ggsave(tf, p, width = 12, height = 6, dpi = 100)
  },
  ggwas = function() {
    g <- ggwas::as_gwas_data(df, chr = "CHR", bp = "POS", snp = "SNP",
                             p = "P", beta = "BETA")
    p <- ggwas::manhattan_plot(g)
    ggplot2::ggsave(tf, p, width = 12, height = 6, dpi = 100)
  },
  stop("unknown tool: ", tool)
)

# Warm-up (load namespaces, JIT), not timed
invisible(tryCatch(render(), error = function(e) message("warmup error: ", conditionMessage(e))))

times <- rep(NA_real_, reps)
for (i in seq_len(reps)) {
  gc(FALSE)
  times[i] <- tryCatch(
    system.time(render())[["elapsed"]],
    error = function(e) { message("rep error: ", conditionMessage(e)); NA_real_ }
  )
}

cat(sprintf("RESULT,%s,%d,%.3f,%.3f,%.3f\n",
  tool, n, median(times, na.rm = TRUE),
  min(times, na.rm = TRUE), max(times, na.rm = TRUE)))
