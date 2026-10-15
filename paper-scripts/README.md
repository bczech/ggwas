# Reproducibility scripts

Scripts that reproduce the figure and the benchmark in the ggwas manuscript.
These files are kept in the repository but excluded from the built package (see
`.Rbuildignore`).

## Data

All scripts use the GIANT 2022 height GWAS summary statistics (Yengo et al. 2022,
*Nature* 610:704-712), European ancestry. Download the file from the GIANT
consortium and place it at `data/giant_height_eur.txt.gz` relative to the script
you run:

https://portals.broadinstitute.org/collaboration/giant/index.php/GIANT_consortium_data_files

The scripts expect the standard GIANT column order (SNPID, RSID, CHR, POS,
effect/other allele, effect-allele frequency, BETA, SE, P, N).

## Figure

```sh
Rscript generate_figure1.R        # writes figures/figure1.png and figure1.pdf
Rscript generate_supplementary.R  # writes figures/supplementary_figure1.pdf + panels
```

## Benchmark (Table 1)

`run_bench.sh` renders a Manhattan plot with each tool (qqman, CMplot, topr,
ggwas) across variant counts and records the median of five runs plus peak
memory. Peak RSS is read from `/usr/bin/time -l` (macOS; on Linux use
`/usr/bin/time -v` and the "Maximum resident set size" line).

```sh
cd bench
bash run_bench.sh    # writes results.csv
```

`results.csv` holds a run with ggwas 0.99.9 made on 15 October 2026 (R 4.5.1,
qqman 0.1.9, CMplot 4.5.1, topr 2.0.4, ggplot2 4.0.3, data.table 1.18.4; Apple
M3 Pro, 18 GB). Table 1 in the submitted manuscript comes from an earlier run in
July 2026. Most cells differ by less than 10% and the tools rank the same at
every size.

## Session

Results depend on the installed versions of qqman, CMplot, topr, and ggwas.
Record them with `sessionInfo()` when reproducing.

Run the benchmark on mains power. On a MacBook running on battery in low power
mode, every tool was 1.5 to 1.9 times slower.
