/* Code Sample: Regression Analysis with Propensity Score Matching in Stata
The analysis in "run.do", part of a homework assignment for an advanced econometrics class, uses data from 
the National Supported Work Demonstration (NSW) and Current Population Survey (CPS) to look 
at the effect of a job training program on earnings. NSW data comes from an experiment (implemented in 1975) in which treated individuals were randomly assigned to a job training program, whereas CPS data is observational. The first question in this assignment explores the NSW experiment, while the second question replaces the control group from the NSW dataset with CPS data in order to study the endogeneity issues that arise in observational data, and how these might be addressed with propensity score matching.

Both datasets are contained in the file "nsw.dta". The observations for which "experimental" equals one correspond to the NSW dataset, and those for which it equals zero corresponds to the CPS dataset. The variables re74, re75, and re78 are measures of earnings in years 1974, 1975, and 1978 respectively. Note that the first two of these outcomes were measured prior to treatment assignment. The remaining variables in the data are controls.
*/

* initialize
use nsw.dta, clear
net ins isvar, from(http://fmwww.bc.edu/RePEc/bocode/i) // install the package "isvar"
net ins propensity, from(http://personalpages.manchester.ac.uk/staff/mark.lunt) // install the package "propensity"

/* Question 1: Explore the experimental sample. */

d // describe

* run a naive linear regression of earnings on treatment and all controls, including pre-treatment outcomes
regress re78 treat re75 re74 age c.age#c.age education black hispanic married nodegree if experiment > 0

* run a regression of log earnings on treatment and all controls, including pre-treatment outcomes
gen lre78 = ln(re78 + 1) // generate transformed earnings variable
gen lre75 = ln(re75 + 1)
gen lre74 = ln(re74 + 1)
regress lre78 treat lre75 lre74 age c.age#c.age education black hispanic married nodegree if experiment > 0

* estimate and plot propensity scores to check randomization
logit treat re75 re74 age c.age#c.age education black hispanic married nodegree if experimental > 0
predict ps
#delimit ;
graph tw kdensity ps if [treat > 0 & experimental > 0] 
|| kdensity ps if [treat < 1 & experimental > 0], 
legend(label(1 "Treated") label(2 "Untreated"))
;
#delimit cr

/* Question 2: Replace the control group of the experimental sample with the observations in the CPS sample,
thus creating a setting with endogeneity. Repeat the previous analysis.
*/

gen nswcps = 0 // generate indicator variable to define new sample
replace nswcps = 1 if [experimental==1 & treat==1]
replace nswcps = 1 if [experimental==0]

* repeat the previous regressions
regress re78 treat re75 re74 age c.age#c.age education black hispanic married nodegree if nswcps > 0
regress lre78 treat lre75 lre74 age c.age#c.age education black hispanic married nodegree if nswcps > 0

* balance tests on pre-treatment outcomes and covariates 
reg re75 treat if [nswcps > 0]
reg re74 treat if [nswcps > 0]
reg age treat if [nswcps > 0]
reg education treat if [nswcps > 0]
reg black treat if [nswcps > 0]
reg hispanic treat if [nswcps > 0]
reg married treat if [nswcps > 0]
reg nodegree treat if [nswcps > 0]

* estimate and plot propensity scores
logit treat re75 re74 age c.age#c.age education black hispanic married nodegree if nswcps > 0
predict ps2
summarize ps2 if [nswcps > 0 & treat==1] // compare means
summarize ps2 if [nswcps > 0 & treat==0]
#delimit ;
graph tw kdensity ps2 if [nswcps > 0 & treat==1] 
|| kdensity ps2 if [nswcps > 0 & treat==0], 
legend(label(1 "Treated") label(2 "Untreated"))
;
#delimit cr

* perform propensity score matching, then repeat prior analysis using the matched sample
gmatch treat ps2 if [nswcps > 0], set(match)
reg re78 treat if [!missing(match)] // regression without controls
regress re78 treat re75 re74 age c.age#c.age education black hispanic married nodegree if [!missing(match)]
regress lre78 treat lre75 lre74 age c.age#c.age education black hispanic married nodegree if [!missing(match)]

* plot propensity scores to check the quality of the matching (with respect to observable covariates)
#delimit ;
graph tw kdensity ps2 if [!missing(match) & treat==1] 
|| kdensity ps2 if [!missing(match) & treat==0], 
legend(label(1 "Treated") label(2 "Untreated"))
;
#delimit cr
