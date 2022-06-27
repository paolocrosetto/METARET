** Replication: Belief Elicitation with Quadratic and Binarized Scoring Rules **

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/


** DO file for data analysis in paper **

********************************************************************************

*** NOTE: Update directory first ***

/*
Data files:
use "Data\belief_elicitation-paper.dta", clear
use "Data\belief_elicitation-paper-long.dta", clear
*/

cap mkdir "Tables"
cap mkdir "Graphs"
cap mkdir "Logs"

********************************************************************************

********** Table A1 **********

use "Data\belief_elicitation-paper.dta", clear
estpost tabstat surveyAge surveyFemale surveyEconomics surveyPG surveyBirthAus surveyPastExp surveyMathStudy RGRiskyTotal ///
	, by(orderBQ) statistics(mean semean) columns(statistics)
esttab using "Tables\summary-demographics", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber csv title("Summary statistics") label replace

* test of demographic differences
mvtest means surveyAge surveyFemale surveyEconomics surveyPG surveyBirthAus surveyPastExp surveyMathStudy RGRiskyTotal, by(orderBQ) heterogeneous
mvreg surveyAge surveyFemale surveyEconomics surveyPG surveyBirthAus surveyPastExp surveyMathStudy RGRiskyTotal = i.orderBQ

********** Figure A1 **********

graph bar (count), over(RGRiskyTotal, gap(2) label(labsize(medlarge))) ///
	yscale(range(0 40)) ylabel(0(10)40, labsize(medlarge) angle(horizontal)) ytitle("# subjects", size(medlarge)) ///
	b1title("# risky decisions", size(medlarge)) ///
	bar(1, fcolor(gs6) lcolor(gs12)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Graphs\risk-hist.png", replace
window manage close graph _all

graph bar (count), ///
	over(RiskPref, gap(20) label(labsize(medium))) ///
	over(orderBQ, gap(100) label(labsize(medlarge))) blabel(bar, format(%9.0f) size(medium)) ///
	yscale(range(0 40)) ylabel(0(10)40, labsize(medlarge) angle(horizontal)) ytitle("# subjects", size(medlarge)) ///
	bar(1, fcolor(gs6) lcolor(gs12)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Graphs\risk-preferences.png", replace
window manage close graph _all


********** Figure 1 **********

use "Data\belief_elicitation-paper-long.dta", clear
// flip the beliefs so that all the priors are to the left of 0.5
replace Belief=1-Belief if PriorRed>0.5
// prior !=50
foreach x of numlist 1/3 {
preserve
keep if Exp==1
keep if RiskPref==`x' & PriorDist!=0

if `x'==1{
local x0="Risk-averse"
}
if `x'==2{
local x0="Risk-neutral"
}
if `x'==3{
local x0="Risk-loving"
}

disp("Prior Not = 0.50, `x0' subjects")
twoway (histogram Belief if mechB==1, width(0.05) start(0) percent fcolor(black) fintensity(50) lcolor(white)) ///
	(histogram Belief if mechQ==1, width(0.05) start(0) percent fcolor(none) lcolor(black)), ///
	legend(order(1 "BSR" 2 "QSR")) ///
	yscale(range(0 40)) ylabel(0(10)45, labsize(medlarge) angle(horizontal)) ytitle("% observations", size(medlarge)) ///
	xscale(range(0 1)) xlabel(0(0.2)1, labsize(medlarge) angle(horizontal)) xtitle("Reported Belief", size(medlarge)) ///
	xline(0.50, lcolor(black) lpattern(solid) lwidth(medthick)) ///
	/// xline(0.10, lcolor(black) lpattern(dash) lwidth(medthick)) ///
	/// xline(0.25, lcolor(black) lpattern(dash) lwidth(medthick)) ///
	graphregion(color(white)) bgcolor(white)
	
graph export "Graphs\belief-hist-risk-part1-priorNot50-pref`x'.png", replace
window manage close graph _all

// KS test of differences
ksmirnov Belief, by(mechQ) exact

restore
}

********** Figure A2 **********

use "Data\belief_elicitation-paper-long.dta", clear
// flip the beliefs so that all the priors are to the left of 0.5
replace Belief=1-Belief if PriorRed>0.5
foreach x of numlist 1/3 {
preserve
keep if Exp==1
keep if RiskPref==`x' & PriorDist==0

if `x'==1{
local x0="Risk-averse"
}
if `x'==2{
local x0="Risk-neutral"
}
if `x'==3{
local x0="Risk-loving"
}

disp("Prior = `y0', `x0' subjects")
twoway (histogram Belief if mechB==1, width(0.05) start(0) percent fcolor(black) fintensity(50) lcolor(white)) ///
	(histogram Belief if mechQ==1, width(0.05) start(0) percent fcolor(none) lcolor(black)), ///
	legend(order(1 "BSR" 2 "QSR")) ///
	yscale(range(0 100)) ylabel(0(20)100, labsize(medlarge) angle(horizontal)) ytitle("% observations", size(medlarge)) ///
	xscale(range(0 1)) xlabel(0(0.2)1, labsize(medlarge) angle(horizontal)) xtitle("Reported Belief", size(medlarge)) ///
	xline(0.5, lcolor(black) lpattern(solid) lwidth(medthick)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Graphs\belief-hist-risk-part1-prior50-pref`x'.png", replace
window manage close graph _all

// KS test of differences
ksmirnov Belief, by(mechQ) exact

restore
}

********** Table 2 **********

use "Data\belief_elicitation-paper-long.dta", clear
* Prior = Not 0.50
preserve
keep if PriorDist!=0
local replace replace
foreach x of varlist mechB mechQ {
foreach y of numlist 1/3 {
// DIST
qui estpost tabstat Dist if `x'==1 & RiskPref==`y' & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-risk_pref", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1, p != 0.5, RiskPref = `y'") label `replace'
// NAD
qui estpost tabstat Error if `x'==1 & RiskPref==`y' & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-risk_pref", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (NAD), `x' , Part 1, p != 0.5, RiskPref = `y'") label append
local replace append
}
}
restore
* Prior = 0.50
preserve
keep if PriorDist==0
foreach x of varlist mechB mechQ {
foreach y of numlist 1/3 {
// DIST
qui estpost tabstat Dist if `x'==1 & RiskPref==`y' & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-risk_pref", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1, p = 0.5, RiskPref = `y'") label append
}
}
restore


// RANDOMIZATION TESTS
capture log close _all
log using "Logs\permutation_tests-part1-risk_pref.log", replace

set seed 1234
program drop _all
program CompareMeanDist, rclass
summarize Dist if Treat==1
scalar Mean1 = r(mean)
summarize Dist if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end
program CompareMeanError, rclass
summarize Error if Treat==1
scalar Mean1 = r(mean)
summarize Error if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end

// Prior = Not 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist!=0
display "******************************"
display "Prior = Not 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	keep if Exp==1
	replace Treat=.
	foreach y of numlist 1/3 {
	display "Part 1: Risk Pref = `y'"
	replace Treat=1 if mechB==1 & RiskPref==`y'
	replace Treat=2 if mechQ==1 & RiskPref==`y'
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	display "NAD"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanError
	replace Treat=.
	}
	restore
	
	* RA vs. RN vs. RL (within mechB, within mechQ, Part 1)
	set seed 1234
	local r=500000 // paper uses 500000 reps
	foreach x of varlist mechB mechQ {
	display "Mechanism: `x'"
	preserve
	keep if Exp==1 & `x'==1
	foreach y of numlist 1/2 {
	local z=`y'+1
	foreach w of numlist `z'/3 {
	display "Mechanism: `x'; Risk Pref (`y' vs. `w')"
	replace Treat=1 if RiskPref==`y'
	replace Treat=2 if RiskPref==`w'
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	display "NAD"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanError
	replace Treat=.
	}
	}
	restore
	}

// Prior = 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist==0
display "******************************"
display "Prior = 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	keep if Exp==1
	replace Treat=.
	foreach y of numlist 1/3 {
	display "Part 1: Risk Pref = `y'"
	replace Treat=1 if mechB==1 & RiskPref==`y'
	replace Treat=2 if mechQ==1 & RiskPref==`y'
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	replace Treat=.
	}
	restore
	
capture log close _all
	
********** Table A2 **********

use "Data\belief_elicitation-paper-long.dta", clear
replace PriorDist=100*PriorDist
keep if Exp==1
local ctrls "surveyAge i.surveyFemale i.surveyEconomics i.surveyPG i.surveyBirthAus surveyPastExp i.surveyMathStudy"

reg Dist ib2.RiskPref##i.mechQ i.PriorDist i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ+1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ+1.mechQ#3.RiskPref

lincom 1.RiskPref
lincom 1.RiskPref-3.RiskPref
lincom 3.RiskPref

lincom 1.RiskPref+1.mechQ#1.RiskPref
lincom (1.RiskPref+1.mechQ#1.RiskPref)-(3.RiskPref+1.mechQ#3.RiskPref)
lincom 3.RiskPref+1.mechQ#3.RiskPref

outreg2 using "Tables\reg-part1-risk_pref", label alpha(0.001, 0.01, 0.05) dec(3) ///
	replace excel ctitle("DIST, Part 1, Prior!=0.50") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(ib2.RiskPref i.mechQ i.mechQ##ib2.RiskPref)

reg Error ib2.RiskPref##i.mechQ i.PriorDist i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ+1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ+1.mechQ#3.RiskPref

lincom 1.RiskPref
lincom 1.RiskPref-3.RiskPref
lincom 3.RiskPref

lincom 1.RiskPref+1.mechQ#1.RiskPref
lincom (1.RiskPref+1.mechQ#1.RiskPref)-(3.RiskPref+1.mechQ#3.RiskPref)
lincom 3.RiskPref+1.mechQ#3.RiskPref

outreg2 using "Tables\reg-part1-risk_pref", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1, Prior!=0.50") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(ib2.RiskPref i.mechQ i.mechQ##ib2.RiskPref)

reg Dist ib2.RiskPref##i.mechQ i.PriorDist i.Round `ctrls' if PriorDist==0, vce(cluster ID)

lincom 1.mechQ+1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ+1.mechQ#3.RiskPref

lincom 1.RiskPref
lincom 1.RiskPref-3.RiskPref
lincom 3.RiskPref

lincom 1.RiskPref+1.mechQ#1.RiskPref
lincom (1.RiskPref+1.mechQ#1.RiskPref)-(3.RiskPref+1.mechQ#3.RiskPref)
lincom 3.RiskPref+1.mechQ#3.RiskPref

outreg2 using "Tables\reg-part1-risk_pref", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1, Prior=0.50") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(ib2.RiskPref i.mechQ i.mechQ##ib2.RiskPref)
	
********** Figure 2 **********

use "Data\belief_elicitation-paper-long.dta", clear
// flip the beliefs so that all the priors are to the left of 0.5
replace Belief=1-Belief if PriorRed>0.5
foreach x of numlist 50 10 25 {
preserve
keep if PriorDist==0.5-`x'/100 & Exp==1
if `x'==50 {
local x0="0.`x'"
local h0=85
local h1=20
}
if `x'!=50 {
local x1=100-`x'
local x0="0.`x' or 0.`x1'"
local h0=50
local h1=10
}

local xl=`x'/100

disp("Prior = `x0'")
twoway (histogram Belief if mechB==1, width(0.05) start(0) percent fcolor(black) fintensity(50) lcolor(white)) ///
	(histogram Belief if mechQ==1, width(0.05) start(0) percent fcolor(none) lcolor(black)), ///
	legend(order(1 "BSR" 2 "QSR")) ///
	yscale(range(0 `h0')) ylabel(0(`h1')`h0', labsize(medlarge) angle(horizontal)) ytitle("% observations", size(medlarge)) ///
	xscale(range(0 1)) xlabel(0(0.2)1, labsize(medlarge) angle(horizontal)) xtitle("Reported Belief", size(medlarge)) ///
	xline(0.5, lcolor(black) lpattern(solid) lwidth(medthick)) ///
	xline(`xl', lcolor(black) lpattern(dash) lwidth(medthick)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Graphs\belief-hist-exp1-prior`x'.png", replace
window manage close graph _all

// KS test of differences
ksmirnov Belief, by(mechQ) exact

restore
}

********** Table 3 **********

use "Data\belief_elicitation-paper-long.dta", clear
* Prior = Not 0.50
preserve
keep if PriorDist!=0
local replace replace
foreach x of varlist mechB mechQ {
// DIST
qui estpost tabstat Dist if `x'==1 & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-aggregate", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1, p != 0.5") label `replace'
// NAD
qui estpost tabstat Error if `x'==1 & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-aggregate", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (NAD), `x' , Part 1, p != 0.5") label append
local replace append
}
restore
* Prior = 0.50
preserve
keep if PriorDist==0
foreach x of varlist mechB mechQ {
// DIST
qui estpost tabstat Dist if `x'==1 & Exp==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-part1-aggregate", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1, p = 0.5") label append
}
restore


// RANDOMIZATION TESTS
capture log close _all
log using "Logs\permutation_tests-part1.log", replace

set seed 1234
program drop _all
program CompareMeanDist, rclass
summarize Dist if Treat==1
scalar Mean1 = r(mean)
summarize Dist if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end
program CompareMeanError, rclass
summarize Error if Treat==1
scalar Mean1 = r(mean)
summarize Error if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end

// Prior = Not 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist!=0
display "******************************"
display "Prior = Not 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	keep if Exp==1
	replace Treat=.
	display "Part 1:"
	replace Treat=1 if mechB==1
	replace Treat=2 if mechQ==1
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	display "NAD"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanError
	replace Treat=.
	restore
	

// Prior = 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist==0
display "******************************"
display "Prior = 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	keep if Exp==1
	replace Treat=.
	display "Part 1"
	replace Treat=1 if mechB==1
	replace Treat=2 if mechQ==1
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	replace Treat=.
	restore
	
capture log close _all

********** Table A5 **********

use "Data\belief_elicitation-paper-long.dta", clear
replace PriorDist=100*PriorDist
keep if Exp==1
local ctrls "surveyAge i.surveyFemale i.surveyEconomics i.surveyPG i.surveyBirthAus surveyPastExp i.surveyMathStudy"

reg Dist i.mechQ i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

outreg2 using "Tables\reg-part1-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	replace excel ctitle("DIST, Part 1, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Error i.mechQ i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

outreg2 using "Tables\reg-part1-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Dist i.mechQ 25.PriorDist i.mechQ#25.PriorDist i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#25.PriorDist

outreg2 using "Tables\reg-part1-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)
	
reg Error i.mechQ 25.PriorDist i.mechQ#25.PriorDist i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#25.PriorDist

outreg2 using "Tables\reg-part1-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Dist i.mechQ i.Round `ctrls' if PriorDist==0, vce(cluster ID)

outreg2 using "Tables\reg-part1-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1, p = 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

********** Table C1 **********

use "Data\belief_elicitation-paper-long.dta", clear
* Prior = Not 0.50
preserve
keep if PriorDist!=0
local replace replace
foreach x of varlist mechB mechQ {
// DIST
qui estpost tabstat Dist if `x'==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-pooled", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1 & 2, p != 0.5") label `replace'
// NAD
qui estpost tabstat Error if `x'==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-pooled", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (NAD), `x' , Part 1 & 2, p != 0.5") label append
local replace append
}
restore
* Prior = 0.50
preserve
keep if PriorDist==0
foreach x of varlist mechB mechQ {
// DIST
qui estpost tabstat Dist if `x'==1, statistics(mean semean n) columns(statistics)
esttab using "Tables\summary-pooled", main(mean %8.2f) aux(semean %8.2f) nostar unstack nonote nomtitle nonumber ///
	obslast csv title("Summary statistics (DIST), `x' , Part 1 & 2, p = 0.5") label append
}
restore


// RANDOMIZATION TESTS
capture log close _all
log using "Logs\permutation_tests-pooled.log", replace

set seed 1234
program drop _all
program CompareMeanDist, rclass
summarize Dist if Treat==1
scalar Mean1 = r(mean)
summarize Dist if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end
program CompareMeanError, rclass
summarize Error if Treat==1
scalar Mean1 = r(mean)
summarize Error if Treat==2
scalar Mean2 = r(mean)
return scalar DiffMean = Mean2-Mean1
end

// Prior = Not 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist!=0
display "******************************"
display "Prior = Not 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1 & 2)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	replace Treat=.
	display "Part 1:"
	replace Treat=1 if mechB==1
	replace Treat=2 if mechQ==1
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	display "NAD"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanError
	replace Treat=.
	restore
	

// Prior = 0.50
use "Data\belief_elicitation-paper-long.dta", clear
keep if PriorDist==0
display "******************************"
display "Prior = 0.50"
display "******************************"

egen IDTemp=group(ID mechB)
order IDTemp, first
collapse (mean) ID RiskPref Dist Error mechB mechQ orderBQ orderQB Exp, by(IDTemp)
gen Treat=.

display "Note: DiffMean = Mean(Treat=2) - Mean(Treat=1)"

	* mech-B vs. mech-Q (Part 1 & 2)
	
	set seed 1234
	local r=500000 // paper uses 500000 reps
	preserve
	replace Treat=.
	display "Part 1"
	replace Treat=1 if mechB==1
	replace Treat=2 if mechQ==1
	display "DIST"
	permute Treat Diff12=r(DiffMean), reps(`r') nodrop nodots nowarn: CompareMeanDist
	replace Treat=.
	restore
	
capture log close _all

********** Table C2 **********

use "Data\belief_elicitation-paper-long.dta", clear
replace PriorDist=100*PriorDist
replace Round=Round-5 if Round>5
local ctrls "surveyAge i.surveyFemale i.surveyEconomics i.surveyPG i.surveyBirthAus surveyPastExp i.surveyMathStudy"

reg Dist i.mechQ i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	replace excel ctitle("DIST, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Dist i.mechQ##i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#1.orderQB

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Error i.mechQ i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)
	
reg Error i.mechQ##i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#1.orderQB

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Dist i.mechQ i.orderQB i.Round `ctrls' if PriorDist==0, vce(cluster ID)

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p = 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

reg Dist i.mechQ##i.orderQB i.Round `ctrls' if PriorDist==0, vce(cluster ID)

lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#1.orderQB

outreg2 using "Tables\reg-pooled-aggregate", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p = 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

********** Table C3 **********

use "Data\belief_elicitation-paper-long.dta", clear
replace PriorDist=100*PriorDist
replace Round=Round-5 if Round>5
local ctrls "surveyAge i.surveyFemale i.surveyEconomics i.surveyPG i.surveyBirthAus surveyPastExp i.surveyMathStudy"

// Panel (a)
qui reg Dist i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	replace excel ctitle("DIST, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

qui reg Error i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

qui reg Dist i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.Round `ctrls' if PriorDist==0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p = 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

// Panels (b) and (c)
qui reg Dist i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.orderQB#ib2.RiskPref i.mechQ#i.orderQB i.mechQ#ib2.RiskPref#i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

lincom 1.mechQ + 1.mechQ#1.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#1.RiskPref
lincom 1.mechQ + 1.mechQ#1.orderQB
lincom 1.mechQ + 1.mechQ#3.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

qui reg Error i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.orderQB#ib2.RiskPref i.mechQ#i.orderQB i.mechQ#ib2.RiskPref#i.orderQB i.Round `ctrls' if PriorDist!=0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

lincom 1.mechQ + 1.mechQ#1.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#1.RiskPref
lincom 1.mechQ + 1.mechQ#1.orderQB
lincom 1.mechQ + 1.mechQ#3.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("NAD, Part 1 & 2, p != 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)

qui reg Dist i.mechQ i.orderQB ib2.RiskPref i.mechQ#ib2.RiskPref i.orderQB#ib2.RiskPref i.mechQ#i.orderQB i.mechQ#ib2.RiskPref#i.orderQB i.Round `ctrls' if PriorDist==0, vce(cluster ID)

lincom 1.mechQ + 1.mechQ#1.RiskPref
lincom 1.mechQ
lincom 1.mechQ + 1.mechQ#3.RiskPref

lincom 1.mechQ + 1.mechQ#1.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#1.RiskPref
lincom 1.mechQ + 1.mechQ#1.orderQB
lincom 1.mechQ + 1.mechQ#3.RiskPref + 1.mechQ#1.orderQB + 1.mechQ#1.orderQB#3.RiskPref

outreg2 using "Tables\reg-pooled-order", label alpha(0.001, 0.01, 0.05) dec(3) ///
	append excel ctitle("DIST, Part 1 & 2, p = 0.5") ///
	addtext("Control for round","Y") drop(i.Round) ///
	sortvar(i.mechQ)
