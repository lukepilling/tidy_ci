# tidy_ci
Wrapper for `broom::tidy()` function to modify CI calculation behaviour

By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default.

For large datasets (i.e., UK Biobank) this takes a long time and does not meaningfully (?) alter the CIs compared to simply calculating via the SEs.

This wrapper function `tidy_ci` runs `broom::tidy()` and returns the result, plus CIs calculated as 95%/SEs. Much quicker

Does the exponentiate function after CI calc 

Also exclude intercept for tidier output - can be included
