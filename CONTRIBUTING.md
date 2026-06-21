# Contributing to gwasplot

Thanks for your interest in contributing. Here's how to get started.

## Reporting bugs

Open an [issue](https://github.com/bczech/gwasplot/issues) with:

- A minimal reproducible example
- Output of `sessionInfo()`
- What you expected vs what happened

## Suggesting features

Open an issue with the "enhancement" label. Describe the use case — what
problem would the feature solve?

## Pull requests

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Add tests for new functionality (`tests/testthat/`)
4. Run `devtools::check()` — it must pass with no errors or warnings
5. Update documentation if needed (`roxygen2::roxygenise()`)
6. Submit a PR with a clear description of the change

## Code style

- Functions use `snake_case`
- All exported functions must have roxygen2 documentation
- Use `.data$column` in ggplot2 aes() calls (CRAN compliance)
- Prefer `cli_abort()` / `cli_warn()` / `cli_inform()` over `stop()` / `warning()` / `message()`

## Development setup

```r
# Install dev dependencies
pak::pak(".", dependencies = TRUE)

# Run tests
devtools::test()

# Build and check
devtools::check()

# Build vignettes
devtools::build_vignettes()
```

## Code of Conduct

Please note that gwasplot is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this
project you agree to abide by its terms.
