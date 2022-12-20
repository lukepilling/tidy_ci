# tidy_ci
Function to run `broom::tidy()` and calculate CIs

By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default. When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE

This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
 - Excludes intercept by default for tidier output - can be included at users request
 - Provides negative log10 p-values (if input is class `glm` or `coxph` -- user can provide sample size `n=#` to override)
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

## A tibble: 4 x 8
#  term                       estimate std.error statistic   p.value conf.low conf.high neglog10p
#  <chr>                         <dbl>     <dbl>     <dbl>     <dbl>    <dbl>     <dbl>     <dbl>
#1 age                          0.0196  0.000847     23.1  4.72e-118   0.0179    0.0212     117. 
#2 sex                          0.703   0.0137       51.4  0           0.676     0.729      574. 
#3 as.factor(smoking_status)1   0.630   0.0149       42.3  0           0.601     0.659      390. 
#4 as.factor(smoking_status)2  -0.203   0.0228       -8.91 5.28e- 19  -0.248    -0.159       18.3

fit_logistic = glm(current_smoker_vs_never ~ age + sex + bmi, data = d, family = binomial(link="logit"))
fit_logistic |> tidy_ci(exp = TRUE)

## A tibble: 3 x 8
#  term  estimate std.error statistic   p.value conf.low conf.high neglog10p
#  <chr>    <dbl>     <dbl>     <dbl>     <dbl>    <dbl>     <dbl>     <dbl>
#1 age      0.983  0.000584    -29.2  7.19e-188    0.982     0.984     187. 
#2 sex      1.70   0.00962      55.4  0            1.67      1.74      665. 
#3 bmi      0.991  0.00103      -8.44 3.08e- 17    0.989     0.993      16.5

fit_coxph = coxph(Surv(time_to_event, diagnosis_bin) ~ age + sex + bmi + as.factor(smoking_status), data = d)
fit_coxph |> tidy_ci(exp = TRUE)

## A tibble: 5 x 8
#  term                       estimate std.error statistic  p.value conf.low conf.high neglog10p
#  <chr>                         <dbl>     <dbl>     <dbl>    <dbl>    <dbl>     <dbl>     <dbl>
#1 age                           0.995  0.000837     -6.56 5.28e-11    0.993     0.996     1.02 
#2 sex                           1.04   0.0109        3.66 2.52e- 4    1.02      1.06      0.770
#3 bmi                           0.994  0.00100      -6.50 7.92e-11    0.992     0.995     1.01 
#4 as.factor(smoking_status)1    1.04   0.0120        3.26 1.13e- 3    1.02      1.06      0.722
#5 as.factor(smoking_status)2    1.03   0.0149        2.16 3.08e- 2    1.00      1.06      0.559

```
