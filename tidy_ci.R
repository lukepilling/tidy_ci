
## Luke Pilling -- 2022.12.07

## By default the (amazing) `broom` package uses the `confint()` function to calculate CIs
## For GLMs this calculates confidence intervals via profile likelihood by default
## When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE
## This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
##  - Exponentiates estimate and CIs (after CI calculation)
##  - Also excludse intercept by default for tidier output - can be included at users request

require(broom)

tidy_ci = function(x, ci = TRUE, exp = FALSE, intercept = FALSE, get_neglog10p = TRUE, n = NA, ...) {
	conf.int = FALSE
	exponentiate = FALSE
	ret = tidy(x, ...)
	if (ci)  ret = ret |> mutate(conf.low=estimate-(1.96*std.error), conf.high=estimate+(1.96*std.error))
	if (get_neglog10p)  {
		if (is.na(n) & "glm" %in% class(x))  n = length(x$y)
		if (is.na(n) & "coxph" %in% class(x))  n = x$n
		if (is.na(n)) cat("To calculate -log10 p-values provide the sample size `n`\n")
		if (!is.na(n)) ret = ret |> mutate(neglog10p=-1*(pt(abs(estimate/std.error),df=!!n,lower.tail=F,log.p=T) + log(2))/log(10))
	}
	if (exp) ret = ret |> mutate(estimate=exp(estimate), conf.low=exp(conf.low), conf.high=exp(conf.high))
	if (!intercept) ret = ret |> filter(term!="(Intercept)")

	ret
}
