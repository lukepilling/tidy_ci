# tidy_ci
Function to run `broom::tidy()` and calculate CIs

By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default. When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE

This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
 - Excludes intercept by default for tidier output - can be included at users request
 - Provides negative log10 p-values (if input is class `glm` or `
 - If `exp=TRUE` then estimate and CIs are exponentiated after CI calculation
 - Other `tidy()` options can be passed

Not tested for models other than `glm()` and `survival::coxph()` where it seems to work very well and produces consistent CIs.

## Example

```
library(tidyverse)
library(broom)
source("https://raw.githubusercontent.com/lukepilling/tidy_ci/main/tidy_ci.R")

fit_linear = glm(bmi ~ age + sex + as.factor(smoking_status), data = d)
fit_linear |> tidy_ci()

fit_logistic = glm(ldl ~ age + sex + bmi, data = d, family = binominal(link="logit"))
fit_logistic |> tidy_ci(exp = TRUE)
```
