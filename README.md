# tidy_ci
Function to run `broom::tidy()` and calculate CIs

By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default. When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE

This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
 - Exponentiates estimate and CIs (after CI calculation)
 - Also excludse intercept by default for tidier output - can be included at users request

Load using: `source("https://raw.githubusercontent.com/lukepilling/tidy_ci/main/tidy_ci.R")`
