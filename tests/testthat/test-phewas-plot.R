test_that("phewas_plot works as expected", {
  phewas_data <- data.frame(
    phenotype = paste0("Pheno_", 1:30),
    p = 10^(-runif(30, 0, 8)),
    category = rep(c("Metabolic", "Immune", "Neuro"), 10),
    beta = rnorm(30, 0, 0.2)
  )
  plt <- phewas_plot(phewas_data)
  expect_s3_class(plt, "ggplot")
})

test_that("phewas_plot handles direction shapes", {
  phewas_data <- data.frame(
    phenotype = paste0("Pheno_", 1:20),
    p = 10^(-runif(20, 0, 6)),
    category = rep(c("A", "B"), 10),
    beta = rnorm(20)
  )
  plt <- phewas_plot(phewas_data, direction_shape = TRUE)
  expect_s3_class(plt, "ggplot")
})

test_that("phewas_plot without beta works as expected", {
  phewas_data <- data.frame(
    phenotype = paste0("P_", 1:15),
    p = 10^(-runif(15, 0, 6)),
    category = rep(c("A", "B", "C"), 5)
  )
  plt <- phewas_plot(phewas_data)
  expect_s3_class(plt, "ggplot")
})

test_that("phewas_plot palette name works as expected", {
  phewas_data <- data.frame(
    phenotype = paste0("P_", 1:15),
    p = 10^(-runif(15, 0, 6)),
    category = rep(c("A", "B", "C"), 5),
    beta = rnorm(15)
  )
  plt <- phewas_plot(phewas_data, colors = "nature")
  expect_s3_class(plt, "ggplot")
})

test_that("phewas_plot hidden categories works as expected", {
  phewas_data <- data.frame(
    phenotype = paste0("P_", 1:10),
    p = 10^(-runif(10, 0, 6)),
    category = rep(c("A", "B"), 5),
    beta = rnorm(10)
  )
  plt <- phewas_plot(phewas_data, show_categories = FALSE)
  expect_s3_class(plt, "ggplot")
})
