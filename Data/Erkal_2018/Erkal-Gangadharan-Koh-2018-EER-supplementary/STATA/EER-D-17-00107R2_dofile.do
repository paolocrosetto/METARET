** Monetary and non-monetary incentives in real-effort tournaments **

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/


** DO file: Replication **
** NOTE: Compatible with STATA15 and above **

*******************************************************************************

** Initialisation **

clear all
set more off

cap log close _all

cd "C:\Users\BoonHan\Dropbox\Uni - Research\Own Research\Real-Effort Tasks\Drafts\EER_Accepted_Version\STATA" // need to change this path accordingly
use "EER-D-17-00107_data.dta", clear

cap mkdir "Logs"
cap mkdir "Graphs"
cap mkdir "Tables"

*******************************************************************************
*** SUMMARY STATISTICS ********************************************************
*******************************************************************************

tabstat Participate0 EffortMin0, by(Treatment) statistics(mean count max min sd semean median) columns(statistics) varwidth(16) format(%8.2f) nototal
qui estpost tabstat Participate0 EffortMin0, by(Treatment) statistics(mean count max min sd semean median) columns(statistics) nototal
esttab using "Tables\summary", main(mean %8.2f) aux(sd %8.2f) nostar unstack nonote nomtitle nonumber csv title("Summary statistics") brackets replace wide

*******************************************************************************
*** GRAPHS ********************************************************************
*******************************************************************************

foreach t in "B" "BL" "BH" "ED" "P" "A1A2" "A1A2L" "A1A2H" "S" "20Min" "EC" {
local x "Treat`t'"
histogram EffortRaw if `x'==1, ///
	width(5) start(0) fraction ///
	yscale(range(0 0.9)) xscale(range(0 60)) xtitle("Effort") ytitle(Proportion of participants) ///
	ylabel(0(0.2)0.9) xlabel(0(25)75) ///
	color(gs4) ///
	subtitle("Treatment `t'") ///
	graphregion(color(white)) bgcolor(white)
graph export "Graphs\Effort-`x'.tif", replace
}
window manage close graph

*******************************************************************************
*** EXPERIMENT 1 **************************************************************
*******************************************************************************

preserve
keep if Exp1==1

*******************************************************************************

log using "Logs\exp1.log", replace name(logexp1)

* Fisher's exact *
tab Treatment Participate0 if TreatB==1 | TreatBL==1, exact
tab Treatment Participate0 if TreatB==1 | TreatBH==1, exact
tab Treatment Participate0 if TreatBL==1 | TreatBH==1, exact

* Kolmogorov-Smirnoff test *
ksmirnov EffortMin if TreatB==1 | TreatBL==1, by(Treatment) exact
ksmirnov EffortMin if TreatB==1 | TreatBH==1, by(Treatment) exact
ksmirnov EffortMin if TreatBL==1 | TreatBH==1, by(Treatment) exact

* Wilcoxon rank-sum test *
ranksum EffortMin0 if TreatB==1 | TreatBL==1, by(Treatment)
ranksum EffortMin0 if TreatB==1 | TreatBH==1, by(Treatment)
ranksum EffortMin0 if TreatBL==1 | TreatBH==1, by(Treatment)

log close logexp1

*******************************************************************************

* OLS Regression *

label var RiskInvestPerc "% invested in Risk Task"
label var Age "Age"
label var Female "Female"
label var Economics "Economics major"
label var ugrad "Undergraduate student"
label var pgrad "Graduate student"
label var Australian "Australian"
label var PrevExperiments "# prev experiments"
local depvar "Participate0 EffortMin0"
local covariates "RiskInvestPerc Age i.Female i.Economics i.ugrad i.pgrad i.Australian PrevExperiments"
local treatments "i.TreatBL i.TreatBH"

local replace replace
foreach x of local depvar{
reg `x' `treatments' `covariates'
lincom 1.TreatBH-1.TreatBL
local est = round(r(estimate),.001)
local serror = round(r(se),.001)
local tstat = round(r(estimate)/r(se),.001)
local pval = round(tprob(r(df), abs(`tstat')),.001)

outreg2 using "Tables\exp1-reg", ///
	adds(Test BH=BL,`est',serror,`serror',p-val,`pval') ///
	label alpha(0.01, 0.05, 0.10) ctitle(`x', OLS) bdec(3) sdec(3) `replace' word
	
local replace append
}

* Quantile regression *

local replace replace
qreg EffortMin0 `treatments' `covariates'
lincom 1.TreatBH-1.TreatBL
local est = round(r(estimate),.001)
local serror = round(r(se),.001)
local tstat = round(r(estimate)/r(se),.001)
local pval = round(tprob(r(df), abs(`tstat')),.001)

outreg2 using "Tables\exp1-reg", ///
	adds(Test BH=BL,`est',serror,`serror',p-val,`pval') ///
	label alpha(0.01, 0.05, 0.10) ctitle(EffortMin0, Quantile) bdec(3) sdec(3) append word

*******************************************************************************
restore

*******************************************************************************
*** EXPERIMENT 2 **************************************************************
*******************************************************************************

preserve
keep if Exp2==1

*******************************************************************************

log using "Logs\exp2.log", replace name(logexp2)

* Fisher's exact *
tab Treatment Participate0 if TreatB==1 | TreatED==1, exact
tab Treatment Participate0 if TreatB==1 | TreatP==1, exact
tab Treatment Participate0 if TreatB==1 | TreatA1A2==1, exact

* Kolmogorov-Smirnoff test *
ksmirnov EffortMin if TreatB==1 | TreatED==1, by(Treatment) exact
ksmirnov EffortMin if TreatB==1 | TreatP==1, by(Treatment) exact
ksmirnov EffortMin if TreatB==1 | TreatA1A2==1, by(Treatment) exact

* Wilcoxon rank-sum test *
ranksum EffortMin0 if TreatB==1 | TreatED==1, by(Treatment)
ranksum EffortMin0 if TreatB==1 | TreatP==1, by(Treatment)
ranksum EffortMin0 if TreatB==1 | TreatA1A2==1, by(Treatment)

log close logexp2

*******************************************************************************

* OLS Regression *

label var RiskInvestPerc "% invested in Risk Task"
label var Age "Age"
label var Female "Female"
label var Economics "Economics major"
label var ugrad "Undergraduate student"
label var pgrad "Graduate student"
label var Australian "Australian"
label var PrevExperiments "# prev experiments"
local depvar "Participate0 EffortMin0"
local covariates "RiskInvestPerc Age i.Female i.Economics i.ugrad i.pgrad i.Australian PrevExperiments"
local treatments "i.TreatED i.TreatP i.TreatA1A2"

local replace replace
foreach x of local depvar{
reg `x' `treatments' `covariates'
outreg2 using "Tables\exp2-reg", ///
	label alpha(0.01, 0.05, 0.10) ctitle(`x', OLS) bdec(3) sdec(3) `replace' word
	
local replace append
}

* Quantile regression *

local replace replace
qreg EffortMin0 `treatments' `covariates'
outreg2 using "Tables\exp2-reg", ///
	label alpha(0.01, 0.05, 0.10) ctitle(EffortMin0, Quantile) bdec(3) sdec(3) append word

*******************************************************************************
restore

*******************************************************************************
*** EXPERIMENT 2 (APPENDIX) ***************************************************
*******************************************************************************

preserve
keep if Exp2A==1

*******************************************************************************

log using "Logs\exp2A.log", replace name(logexp2A)

* Fisher's exact *
tab Treatment Participate0 if TreatB==1 | TreatS==1, exact
tab Treatment Participate0 if TreatB==1 | Treat20Min==1, exact
tab Treatment Participate0 if TreatB==1 | TreatEC==1, exact
tab Treatment Participate0 if TreatA1A2==1 | TreatEC==1, exact

* Kolmogorov-Smirnoff test *
ksmirnov EffortMin if TreatB==1 | Treat20Min==1, by(Treatment) exact

* Wilcoxon rank-sum test *
ranksum EffortMin0 if TreatB==1 | Treat20Min==1, by(Treatment)

log close logexp2A

*******************************************************************************

* OLS Regression *

label var RiskInvestPerc "% invested in Risk Task"
label var Age "Age"
label var Female "Female"
label var Economics "Economics major"
label var ugrad "Undergraduate student"
label var pgrad "Graduate student"
label var Australian "Australian"
label var PrevExperiments "# prev experiments"
local depvar "Participate0 EffortMin0"
local covariates "RiskInvestPerc Age i.Female i.Economics i.ugrad i.pgrad i.Australian PrevExperiments"
local treatments "i.TreatED i.TreatP i.TreatA1A2 i.Treat20Min i.TreatS i.TreatEC"

replace EffortMin0=. if TreatS==1 | TreatEC==1

local replace replace
foreach x of local depvar{
reg `x' `treatments' `covariates'
outreg2 using "Tables\exp2A-reg", ///
	label alpha(0.01, 0.05, 0.10) ctitle(`x', OLS) bdec(3) sdec(3) `replace' word
	
local replace append
}

* Quantile regression *

local replace replace
qreg EffortMin0 `treatments' `covariates'
outreg2 using "Tables\exp2A-reg", ///
	label alpha(0.01, 0.05, 0.10) ctitle(EffortMin0, Quantile) bdec(3) sdec(3) append word

*******************************************************************************
restore

*******************************************************************************
*** EXPERIMENT 3 **************************************************************
*******************************************************************************

preserve
keep if Exp3==1

*******************************************************************************

log using "Logs\exp3.log", replace name(logexp3)

* Fisher's exact *
tab Treatment Participate0 if TreatA1A2==1 | TreatA1A2L==1, exact
tab Treatment Participate0 if TreatA1A2==1 | TreatA1A2H==1, exact
tab Treatment Participate0 if TreatA1A2L==1 | TreatA1A2H==1, exact

* Kolmogorov-Smirnoff test *
ksmirnov EffortMin if TreatA1A2==1 | TreatA1A2L==1, by(Treatment) exact
ksmirnov EffortMin if TreatA1A2==1 | TreatA1A2H==1, by(Treatment) exact
ksmirnov EffortMin if TreatA1A2L==1 | TreatA1A2H==1, by(Treatment) exact

* Wilcoxon rank-sum test *
ranksum EffortMin0 if TreatA1A2==1 | TreatA1A2L==1, by(Treatment)
ranksum EffortMin0 if TreatA1A2==1 | TreatA1A2H==1, by(Treatment)
ranksum EffortMin0 if TreatA1A2L==1 | TreatA1A2H==1, by(Treatment)

log close logexp3

*******************************************************************************

* OLS Regression *

label var RiskInvestPerc "% invested in Risk Task"
label var Age "Age"
label var Female "Female"
label var Economics "Economics major"
label var ugrad "Undergraduate student"
label var pgrad "Graduate student"
label var Australian "Australian"
label var PrevExperiments "# prev experiments"
local depvar "Participate0 EffortMin0"
local covariates "RiskInvestPerc Age i.Female i.Economics i.ugrad i.pgrad i.Australian PrevExperiments"
local treatments "i.TreatA1A2L i.TreatA1A2H"

local replace replace
foreach x of local depvar{
reg `x' `treatments' `covariates'
lincom 1.TreatA1A2H-1.TreatA1A2L
local est = round(r(estimate),.001)
local serror = round(r(se),.001)
local tstat = round(r(estimate)/r(se),.001)
local pval = round(tprob(r(df), abs(`tstat')),.001)

outreg2 using "Tables\exp3-reg", ///
	adds(Test A1A2-H=A1A2-L,`est',serror,`serror',p-val,`pval') ///
	label alpha(0.01, 0.05, 0.10) ctitle(`x', OLS) bdec(3) sdec(3) `replace' word
	
local replace append
}

* Quantile regression *

local replace replace
qreg EffortMin0 `treatments' `covariates'
lincom 1.TreatA1A2H-1.TreatA1A2L
local est = round(r(estimate),.001)
local serror = round(r(se),.001)
local tstat = round(r(estimate)/r(se),.001)
local pval = round(tprob(r(df), abs(`tstat')),.001)

outreg2 using "Tables\exp3-reg", ///
	adds(Test A1A2-H=A1A2-L,`est',serror,`serror',p-val,`pval') ///
	label alpha(0.01, 0.05, 0.10) ctitle(EffortMin0, Quantile) bdec(3) sdec(3) append word

*******************************************************************************
restore
