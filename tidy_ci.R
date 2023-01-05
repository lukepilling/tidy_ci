
## Luke Pilling -- 2022.12.20

# Function to run `broom::tidy()` and calculate CIs

# By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default. When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE

# This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE
#  - Excludes intercept by default for tidier output - can be included at users request
#  - Provides negative log10 p-values (if input is class `glm` or `coxph` -- user can provide sample size `n=#` to override)
#  - If `exp=TRUE` then estimate and CIs are exponentiated after CI calculation
#  - Other `tidy()` options can be passed

# Not tested for models other than `glm()` and `survival::coxph()` where it seems to work very well and produces consistent CIs.

## Examples

#library(tidyverse)
#library(broom)
#source("https://raw.githubusercontent.com/lukepilling/tidy_ci/main/tidy_ci.R")

#fit_linear = glm(bmi ~ age + sex + as.factor(smoking_status), data = d)
#fit_linear |> tidy_ci()

#fit_logistic = glm(current_smoker_vs_never ~ age + sex + bmi, data = d, family = binomial(link="logit"))
#fit_logistic |> tidy_ci(exp = TRUE)

#fit_coxph = coxph(Surv(time_to_event, diagnosis_bin) ~ age + sex + bmi + as.factor(smoking_status), data = d)
#fit_coxph |> tidy_ci(exp = TRUE)

require(dplyr)
require(broom)

tidy_ci = function(x = stop("Provide a model fit object"), ci = TRUE, exp = FALSE, intercept = FALSE, get_neglog10p = TRUE, n = NA, ...) {
	
	## get tidy output -- do not use `broom` CIs or Exponentiate options
	ret = tidy(x, conf.int = FALSE, exponentiate = FALSE, ...)
	
	## get CIs based on 1.96*SE
	if (ci)  ret = ret |> mutate(conf.low=estimate-(1.96*std.error), conf.high=estimate+(1.96*std.error))
	
	## get -log10 p-value
	if (get_neglog10p)  {
		if (is.na(n) & "glm" %in% class(x))  n = length(x$y)
		if (is.na(n) & "coxph" %in% class(x))  n = x$n
		if (is.na(n)) cat("To calculate -log10 p-values provide the sample size `n`\n")
		if (!is.na(n)) ret = ret |> mutate(neglog10p=-1*(pt(abs(estimate/std.error),df=!!n,lower.tail=F,log.p=T) + log(2))/log(10))
	}
	
	## exponentiate if required
	if (exp) ret = ret |> mutate(estimate=exp(estimate), conf.low=exp(conf.low), conf.high=exp(conf.high))
	
	## exclude intercept?
	if (!intercept) ret = ret |> filter(term!="(Intercept)")
	
	## return object
	ret
	
}
