*Stata version
15.1
*** 
************************************************************************
* PART 0: TABLE OF CONTENTS
************************************************************************
clear

* SADHS 2016 analysis 

* Paper: van Wyk B, Roomaney RA. Patterns and Predictors of HIV Comorbidity among Adolescents and Young Adults in South Africa. International Journal of Environmental Research and Public Health. 2024 Apr 9;21(4):457.
* Creator: [Rifqah Roomaney, rifqah.roomaney@mrc.ac.za] 


************************************************************************
* PART 1: HOUSEKEEPING & INTRODUCTION
************************************************************************
set more off 

*Setting file path
global BASE "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS"

* SOURCE FILES DIRECTORIES
global DHS2016 "DHS\DHS2016\Dataset\ZA_2016_DHS_02032019_432_49143"

*Opening dataset
use "$BASE\1 My project\Data\DHS2016_subset_03052021.dta", replace

***************************************
*Start analysis
*****************************************
svyset psu[pweight=csweight], strata(stratum) vce(linearized) singleunit(certainty) 

**age categories
drop if age>=25
recode age(15/19= 1 "15-19") (20/24=2 "20-24")  , generate(age_cat)
tabstat age, stat (n, mean, median, sd, p25, p75, min, max)
tab age_cat

*HIV variable
recode hiv(0=0 "HIV negative") (1=1 "HIV positive"), generate(hiv1)

***Table 1 by HIV status***********************************************
summarize age, detail
by hiv1, sort : summarize age, detail   //summarize age by hiv
kwallis age, by(hiv)

tab gender hiv1 , col chi 
tab urban hiv1, col chi 
tab prov hiv1, col chi 
tab educat hiv1, col chi 
tab employed hiv1, col chi 
tab wealthindex hiv1, col chi 
tab bmi_cat hiv1, col chi
tab CURRSMOK hiv1, col chi
tab CURRALC hiv1, col chi


***Table 2*****************************************************

** Self reported disease tabulations 

svy linearized : proportion SELFDIAB, percent 
svy linearized : proportion SELFDIAB, over(hiv1) percent 

svy linearized : proportion SELFBRONCH, percent 
svy linearized : proportion SELFBRONCH, over(hiv1)percent 

svy linearized : proportion SELFHEART,  percent
svy linearized : proportion SELFHEART, over(hiv1)percent

svy linearized : proportion SELFCHOL,  percent
svy linearized : proportion SELFCHOL, over(hiv1)percent

svy linearized : proportion SELFSTROKE ,  percent
svy linearized : proportion SELFSTROKE, over(hiv1) percent

svy linearized : proportion SELFTB12,  percent
svy linearized : proportion SELFTB12, over(hiv1)percent

svy linearized : proportion hiv ,  percent
svy linearized : proportion hiv , over(hiv1)percent

svy linearized : proportion htn, percent
svy linearized : proportion htn , over(hiv1)percent

svy linearized : proportion anaemia , percent
svy linearized : proportion anaemia , over(hiv1)percent

svy linearized : proportion DIAB_MED , percent
svy linearized : proportion DIAB_MED , over(hiv1) percent

tab DIAB_MED hiv1

*biological and self-report
svy linearized : proportion diabetes , percent
svy linearized : proportion diabetes , over(hiv1)percent


  
**Table 3*********************************************
egen index_ex = rowtotal(diabetes htn anaemia  SELFBRONCH SELFHEART SELFCHOL SELFSTROKE SELFTB12 hiv) //Doesn't exclude missing data. Adds up "yes" responses for these diseases //try rowmean*9 / rowmissing to see how many missing
recode index_ex (3=2)(4=2) (5=2) 
label define Indexlabel_ex 0 "No disease" 1 "1 disease" 2 "2+ diseases" 
label values index_ex Indexlabel_ex
label variable index_ex "Number of diseases "


svy linearized : proportion index_ex, percent 
svy linearized : proportion index_ex , over(hiv1)percent
svy linearized, subpop(if hiv1==1) : tabulate index_ex, percent ci

***Table 4**********************************************

logistic hiv i.age_cat gender urban i.educat i.wealthindex employed i.bmi_cat CURRALC CURRSMOK



*****Latent class analys*******
*Please download LCA ado at https://www.latentclassanalysis.com/software/lca-stata-plugin/

use "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS\1 My project\Data\DHS2016_regression_18052021.dta", clear


cd C:\ado\plus\Release64-1.3.2-2002ph7\Release64-1.3.2 /*CHANGE THIS PATH TO MATCH THE FILE LOCATION ON YOUR MACHINE!*/

drop if mm_index==0

recode hiv 0=1 1=2
recode diabetes 0=1 1=2
recode htn 0=1 1=2
recode anaemia 0=1 1=2
recode SELFBRONCH 0=1 1=2
recode SELFHEART 0=1 1=2
recode SELFCHOL 0=1 1=2
recode SELFSTROKE 0=1 1=2
recode SELFTB12 0=1 1=2




doLCA hiv diabetes htn anaemia  SELFBRONCH SELFHEART SELFCHOL SELFSTROKE SELFTB12, ///
      nclass(5) ///
	  seed(100000) ///
	  seeddraws(100000) ///
	  categories(2 2 2 2 2 2 2 2 2)  ///
	  criterion(0.000001)  ///
	  rhoprior(1.0)
	  
return list
matrix list r(gamma)
matrix list r(gammaSTD)
matrix list r(rho)
//matrix list r(rhoSTD)

doLCA hiv diabetes htn anaemia  SELFBRONCH SELFHEART SELFCHOL SELFSTROKE SELFTB12, ///
      nclass(4) ///
	  seed(100000) ///
	  seeddraws(100000) ///
	  categories(2 2 2 2 2 2 2 2 2)  ///
	  criterion(0.000001)  ///
	  rhoprior(1.0)
	  
return list
matrix list r(gamma)
matrix list r(gammaSTD)
matrix list r(rho)
matrix list r(rhoSTD)

**option2

use "C:\Users\rroom\OneDrive - South African Medical Research Council\Documents\PhD\Phase 2\SURVEY DATASETS\1 My project\Data\DHS2016_regression_18052021.dta"

drop if mm_index==0

recode hiv 0=1 1=2
recode diabetes 0=1 1=2
recode htn 0=1 1=2
recode anaemia 0=1 1=2
recode SELFBRONCH 0=1 1=2
recode SELFHEART 0=1 1=2
recode SELFCHOL 0=1 1=2
recode SELFSTROKE 0=1 1=2
recode SELFTB12 0=1 1=2

recode urban 0=1 1=2
recode employed 0=1 1=2
recode bmi_cat 0=1 1=2 2=3 3=4 4=5 5=6
recode CURRALC 0=1 1=2
recode CURRSMOK 0=1 1=2


*drop _all
cd C:\ado\plus\Release64-1.3.2-2002ph7\Release64-1.3.2 
doLCA hiv diabetes htn anaemia  SELFBRONCH SELFHEART SELFCHOL SELFSTROKE SELFTB12,  ///
      nclass(5)					///
	  id(id)                 ///
	  maxiter(5000)  			///
	  groups (gender) 				///
	  groupnames("male female") ///
	  measurement("groups") 		///
	  covariates(CURRALC CURRSMOK) 	///
	  reference(1)				///
	  seed(123456789) 			///
	  seeddraws(100000) ///
	  categories(2 2 2 2 2 2 2 2 2 )	///
	  criterion(0.000001)  		///
	  rhoprior(1.0) ///
	  betaprior(1)
return list
matrix list r(gamma)
matrix list r(gammaSTD)	
