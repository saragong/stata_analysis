# Code Sample: Regression Analysis with Propensity Score Matching in Stata
The analysis in "run.do", part of a homework assignment for an advanced econometrics class, uses data from 
the National Supported Work Demonstration (NSW) and Current Population Survey (CPS) to look 
at the effect of a job training program on earnings. NSW data comes from an experiment (implemented in 1975) in which treated individuals were randomly assigned to a job training program, whereas CPS data is observational. The first question in this assignment explores the NSW experiment, while the second question replaces the control group from the NSW dataset with CPS data in order to study the endogeneity issues that arise in observational data, and how these might be addressed with propensity score matching.

Both datasets are contained in the file "nsw.dta". The observations for which "experimental" equals one correspond to the NSW dataset, and those for which it equals zero corresponds to the CPS dataset. The variables re74, re75, and re78 are measures of earnings in years 1974, 1975, and 1978 respectively. Note that the first two of these outcomes were measured prior to treatment assignment. The remaining variables in the data are controls.


