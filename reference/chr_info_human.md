# Human chromosome information (hg38)

Returns a data.frame with chromosome lengths and centromere positions
for the human genome (GRCh38/hg38). Useful as the `chr_info` argument in
[`snp_density()`](https://bczech.github.io/ggwas/reference/snp_density.md)
and
[`density_signal_plot()`](https://bczech.github.io/ggwas/reference/density_signal_plot.md)
for accurate ideogram rendering.

## Usage

``` r
chr_info_human(build = "hg38")
```

## Arguments

- build:

  Genome build. Currently only `"hg38"` is supported.

## Value

A data.frame with columns: `chr` (integer), `length`,
`centromere_start`, `centromere_end`.

## Examples

``` r
chr_info_human()
#>    chr    length centromere_start centromere_end
#> 1    1 248956422        122026460      124932724
#> 2    2 242193529         92188146       94090557
#> 3    3 198295559         90772459       93655574
#> 4    4 190214555         49708101       51743951
#> 5    5 181538259         46485901       50059807
#> 6    6 170805979         58553889       59829934
#> 7    7 159345973         58169654       61528020
#> 8    8 145138636         44033745       45877265
#> 9    9 138394717         43236168       45518558
#> 10  10 133797422         39686683       41593521
#> 11  11 135086622         51078349       54425074
#> 12  12 133275309         34769408       37185252
#> 13  13 114364328         16000000       18051248
#> 14  14 107043718         16000000       18173523
#> 15  15 101991189         17083675       19725254
#> 16  16  90338345         36311159       38280682
#> 17  17  83257441         22813680       26885980
#> 18  18  80373285         15460900       20861206
#> 19  19  58617616         24498981       27190874
#> 20  20  64444167         26436233       28033230
#> 21  21  46709983         10864561       12915808
#> 22  22  50818468         12954789       15054318
```
