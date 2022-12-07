
## Luke Pilling -- 2022.12.07

## By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default.
## For large datasets (i.e., UK Biobank) this takes a long time and does not meaningfully (?) alter the CIs compared to simply calculating via the SEs.
## This wrapper function `tidy_ci()` runs `broom::tidy()` and returns the result, plus CIs calculated as 95%/SEs. Much quicker
## Does the exponentiate function after CI calc 
## Also exclude intercept for tidier output - can be included

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
