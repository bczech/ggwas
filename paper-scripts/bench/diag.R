suppressPackageStartupMessages({library(data.table); library(ggwas)})
d <- fread("../data/giant_height_eur.txt.gz", showProgress=FALSE)
setnames(d, c("SNPID","RSID","CHR","POS","EA","OA","EAF","BETA","SE","P","N"))
d[, P := suppressWarnings(as.numeric(P))]
d <- d[CHR %in% 1:22 & !is.na(POS) & !is.na(P)]
d[, P := pmin(pmax(P,1e-300),1-1e-12)]
d <- d[, .(SNP=RSID, CHR=as.integer(CHR), BP=as.integer(POS), P=as.numeric(P))]
set.seed(1); ord <- sample.int(nrow(d))
for (n in c(500000, 1000000, nrow(d))) {
  df <- as.data.frame(d[ord[seq_len(min(n,nrow(d)))]])
  keep <- sum(df$P < 1e-3)
  t_ds <- system.time(ds <- ggwas:::smart_downsample(df, target_n=200000))["elapsed"]
  cat(sprintf("n=%-8d  keep(p<1e-3)=%-7d  branch=%s  n_after=%-7d  downsample_time=%.2fs\n",
     min(n,nrow(d)), keep, ifelse(keep>=200000,"SHORT-CIRCUIT","WEIGHTED-SAMPLE"), nrow(ds), t_ds))
}
