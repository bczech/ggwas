test_that("gwas_palette returns colors", {
  expect_length(gwas_palette("default"), 2)
  expect_length(gwas_palette("nature"), 10)
  expect_length(gwas_palette("brewer_set1"), 9)
  expect_length(gwas_palette("colorblind", n = 5), 5)
})

test_that("gwas_palettes lists all palettes", {
  pals <- gwas_palettes()
  expect_true(length(pals) >= 10)
  expect_true("nature" %in% pals)
})

test_that("gwas_preset returns correct structure", {
  p <- gwas_preset("publication")
  expect_true(is.list(p))
  expect_true(all(c("theme", "colors", "point_size") %in% names(p)))
})

test_that("theme_nature returns ggplot theme", {
  th <- theme_nature()
  expect_s3_class(th, "theme")
})

test_that("theme_science returns ggplot theme", {
  th <- theme_science()
  expect_s3_class(th, "theme")
})

test_that("theme_plos returns ggplot theme", {
  th <- theme_plos()
  expect_s3_class(th, "theme")
})

test_that("theme_cell returns ggplot theme", {
  th <- theme_cell()
  expect_s3_class(th, "theme")
})

test_that("theme_presentation returns ggplot theme", {
  th <- theme_presentation()
  expect_s3_class(th, "theme")
})

test_that("theme_poster returns ggplot theme", {
  th <- theme_poster()
  expect_s3_class(th, "theme")
})

test_that("enrichment_manhattan returns ggplot", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 100e6, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
  annot <- data.frame(
    chr = c(1, 2),
    start = c(10e6, 40e6),
    end = c(20e6, 50e6),
    category = c("Gene", "Enhancer")
  )
  plt <- enrichment_manhattan(df, annotations = annot)
  expect_s3_class(plt, "ggplot")
})

test_that("enrichment_manhattan handles list of annotations", {
  df <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100)
  )
  annot_list <- list(
    Genes = data.frame(chr = 1, start = 5e6, end = 15e6),
    eQTL = data.frame(chr = 2, start = 10e6, end = 20e6)
  )
  plt <- enrichment_manhattan(df, annotations = annot_list)
  expect_s3_class(plt, "ggplot")
})

test_that("multitrait_manhattan returns ggplot", {
  df1 <- data.frame(
    CHR = rep(1:2, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 2),
    P = runif(100),
    SNP = paste0("rs", 1:100)
  )
  df2 <- df1
  df2$P <- runif(100)^2
  plt <- multitrait_manhattan(Trait1 = df1, Trait2 = df2)
  expect_s3_class(plt, "ggplot")
})

test_that("gwas_summary returns patchwork", {
  df <- data.frame(
    CHR = rep(1:3, each = 100),
    BP = rep(seq(1e6, 100e6, length.out = 100), 3),
    P = runif(300),
    SNP = paste0("rs", 1:300)
  )
  plt <- gwas_summary(df)
  expect_true(inherits(plt, "patchwork") || inherits(plt, "ggplot"))
})

test_that("circular_manhattan returns ggplot", {
  df <- data.frame(
    CHR = rep(1:5, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 5),
    P = runif(250),
    SNP = paste0("rs", 1:250)
  )
  plt <- circular_manhattan(df)
  expect_s3_class(plt, "ggplot")
})

test_that("circular_manhattan handles multi-ring", {
  df1 <- data.frame(
    CHR = rep(1:3, each = 30),
    BP = rep(seq(1e6, 30e6, length.out = 30), 3),
    P = runif(90)
  )
  df2 <- df1
  df2$P <- runif(90)^2
  plt <- circular_manhattan(list(Trait1 = df1, Trait2 = df2))
  expect_s3_class(plt, "ggplot")
})

test_that("scale_color_gwas returns ggplot scale", {
  s <- scale_color_gwas("nature")
  expect_s3_class(s, "Scale")
})

test_that("manhattan_plot works with palette argument via colors", {
  df <- data.frame(
    CHR = rep(1:3, each = 50),
    BP = rep(seq(1e6, 50e6, length.out = 50), 3),
    P = runif(150)
  )
  plt <- manhattan_plot(df, colors = gwas_palette("vibrant"))
  expect_s3_class(plt, "ggplot")
})
