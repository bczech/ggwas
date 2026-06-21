set.seed(42)

n_snps <- 5000
chrs <- sample(1:22, n_snps, replace = TRUE, prob = rep(1, 22))
bps <- integer(n_snps)

chr_lengths <- c(
  248956422, 242193529, 198295559, 190214555, 181538259,
  170805979, 159345973, 145138636, 138394717, 133797422,
  135086622, 133275309, 114364328, 107043718, 101991189,
  90338345, 83257441, 80373285, 58617616, 64444167,
  46709983, 50818468
)

for (i in seq_len(n_snps)) {
  bps[i] <- sample.int(chr_lengths[chrs[i]], 1)
}

pvals <- runif(n_snps)^3
n_sig <- 15
sig_idx <- sample(n_snps, n_sig)
pvals[sig_idx] <- 10^(-runif(n_sig, 5, 12))

betas <- rnorm(n_snps, 0, 0.05)
betas[sig_idx] <- rnorm(n_sig, 0, 0.3)

afs <- runif(n_snps, 0.01, 0.5)

example_gwas <- data.frame(
 CHR = chrs,
 BP = bps,
 SNP = paste0("rs", sample(1e6:9e6, n_snps)),
 P = pvals,
 BETA = round(betas, 5),
 SE = round(abs(betas / qnorm(pvals / 2)), 5),
 A1 = sample(c("A", "C", "G", "T"), n_snps, replace = TRUE),
 A2 = sample(c("A", "C", "G", "T"), n_snps, replace = TRUE),
 AF = round(afs, 4)
)

class(example_gwas) <- c("gwas_data", "data.frame")
usethis::use_data(example_gwas, overwrite = TRUE)
