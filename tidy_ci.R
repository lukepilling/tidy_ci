
## Luke Pilling -- 2022.12.07

## By default the (amazing) `broom` package uses the `confint()` function to calculate CIs
## For GLMs this calculates confidence intervals via profile likelihood by default
## When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE
## This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
##  - Exponentiates estimate and CIs (after CI calculation)
##  - Also excludse intercept by default for tidier output - can be included at users request

require(broom)

tidy_ci = function(x, ci = TRUE, exp = FALSE, intercept = FALSE, ...) {
	conf.int = FALSE
	exponentiate = FALSE
	ret = tidy(x, ...)
	if (ci)  ret = ret |> mutate(conf.low=estimate-(1.96*std.error), conf.high=estimate+(1.96*std.error))
	if (exp) ret = ret |> mutate(estimate=exp(estimate), conf.low=exp(conf.low), conf.high=exp(conf.high))
	if (!intercept) ret = ret |> filter(term!="(Intercept)")
	ret
}
