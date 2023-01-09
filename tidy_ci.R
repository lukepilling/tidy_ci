
## Luke Pilling -- v0.20230109

# Function to run `broom::tidy()` and calculate CIs

# By default the (amazing) `broom` package uses the `confint()` function to calculate CIs. For GLMs this calculates confidence intervals via profile likelihood by default. When using large datasets this takes a long time and does not meaningfully alter the CIs compared to simply calculating using 1.96*SE

# This function `tidy_ci()` runs `broom::tidy()` and returns the tidy estimates with CIs calculated as EST +/- 1.96*SE

# Also does a few other nice/useful things to the output: hides the intercept by default, calculates -log10 p-values, and automatically detects logistic/CoxPH/CRR models and exponentiates the estimates

# Options:
#  `ci` {default=TRUE} calculate CIs using 1.96*SE method
#  `intercept` {default=FALSE} Exclude intercept for tidier output
#  `neglog10p` {default=TRUE} Provides negative log10 p-values (if input is class `glm` or `coxph` or `crr` -- user can provide sample size `n=#` to override)
#  `exp` {default=FALSE} exponentiate estimate and CIs -- also see `check_family`
#  `check_family` {default=TRUE} set `exp=TRUE` if `glm(family=binomial)` or `survival::coxph()` or `cmprsk::crr()` was performed
#  `n` {default=NA} the N for `neglog10p` is extracted automatically for `glm` or `coxph` objects - override here if required
#  `...` Other `tidy()` options 

# Not tested for models other than `glm()` and `survival::coxph()` where it seems to work very well and produces consistent CIs. Also works well for `cmprsk::crr()`

## Examples

#library(tidyverse)
#library(broom)
#source("https://raw.githubusercontent.com/lukepilling/tidy_ci/main/tidy_ci.R")

#fit_linear = glm(bmi ~ age + sex + as.factor(smoking_status), data = d)
#tidy_ci(fit_linear)

#fit_logistic = glm(current_smoker_vs_never ~ age + sex + bmi, data = d, family = binomial(link="logit"))
#tidy_ci(fit_logistic)   # detect model and exponentiate automatically
#tidy_ci(fit_logistic, check_family=FALSE)  # override auto checking to get untransformed estimates

#fit_coxph = coxph(Surv(time_to_event, diagnosis_bin) ~ age + sex + bmi + as.factor(smoking_status), data = d)
#tidy_ci(fit_coxph)

require(dplyr)
require(broom)

tidy_ci = function(x = stop("Provide a model fit object"), 
		   ci = TRUE, 
		   exp = FALSE, 
		   intercept = FALSE, 
		   neglog10p = TRUE, 
		   check_family = TRUE,
		   n = NA, 
		   conf.int = FALSE,     ## tidy() option
		   exponentiate = FALSE, ## tidy() option
		   ...) {
	
	## use `tidy()` CI/exp method?  Only if not using the other
	if (ci) conf.int = FALSE
	if (exp) exponentiate = FALSE

	## get tidy output -- do not use `broom` CIs or Exponentiate options by default
	ret = broom::tidy(x, conf.int = conf.int, exponentiate = exponentiate, ...)
	
	## get CIs based on 1.96*SE?
	if (ci)  ret = ret |> dplyr::mutate(conf.low=estimate-(1.96*std.error), conf.high=estimate+(1.96*std.error))
	
	## get -log10 p-value?
	if (neglog10p & !exponentiate)  {
		if (is.na(n) & "glm" %in% class(x))  n = length(x$y)
		if (is.na(n) & "coxph" %in% class(x))  n = x$n
		if (is.na(n) & "crr" %in% class(x))  n = x$n
		if (is.na(n) & "tidycrr" %in% class(x))  n = x$cmprsk$n
		if (is.na(n)) cat("To calculate -log10 p-values provide the sample size `n`\n")
		if (!is.na(n)) ret = ret |> dplyr::mutate(neglog10p=-1*(pt(abs(estimate/std.error),df=!!n,lower.tail=F,log.p=T) + log(2))/log(10))
	}
	
	## exponentiate estimate and CIs?
	if (check_family & !exp & !exponentiate)  {
		if ("glm" %in% class(x)) {
			if (x$family$family == "binomial") {
				exp = TRUE
				cat("Detected logistic model :. estimate=exp(linear predictor)\n")
			}
		}
		if (any(c("coxph") %in% class(x)))  {
			exp = TRUE
			cat("Detected CoxPH model :. estimate=exp(linear predictor)\n")
		}
		if (any(c("crr","tidycrr") %in% class(x)))  {
			exp = TRUE
			cat("Detected CRR model :. estimate=exp(linear predictor)\n")
		}
	}
	if (exp) ret = ret |> dplyr::mutate(estimate=exp(estimate))
	if (exp & ci) ret = ret |> dplyr::mutate(conf.low=exp(conf.low), conf.high=exp(conf.high))
	
	## exclude intercept?
	if (!intercept) ret = ret |> dplyr::filter(term!="(Intercept)")
	
	## return object
	ret
	
}
