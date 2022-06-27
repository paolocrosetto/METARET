** Replication: Belief Elicitation with Quadratic and Binarized Scoring Rules **

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/


** DO file for cleaning dataset used for paper **

********************************************************************************

*** NOTE: Update directory first ***

********************************************************************************

** Create long version of data **

use "Data\belief_elicitation-paper.dta", clear

* Rename belief variables
foreach x of numlist 1/5 {
local y=`x'+5

rename PriorRedA`x' PriorRed`x'
rename PriorRedB`x' PriorRed`y'

rename PriorDistA`x' PriorDist`x'
rename PriorDistB`x' PriorDist`y'

rename BallRedA`x' BallRed`x'
rename BallRedB`x' BallRed`y'

rename BeliefA`x' Belief`x'
rename BeliefB`x' Belief`y'

rename BeliefScoreA`x' BeliefScore`x'
rename BeliefScoreB`x' BeliefScore`y'

rename BeliefPayoffA`x' BeliefPayoff`x'
rename BeliefPayoffB`x' BeliefPayoff`y'

rename BeliefCalcA`x' BeliefCalc`x'
rename BeliefCalcB`x' BeliefCalc`y'

rename DistA`x' Dist`x'
rename DistB`x' Dist`y'

rename ErrorA`x' Error`x'
rename ErrorB`x' Error`y'

}

// Reshape data
reshape long PriorRed PriorDist BallRed Belief BeliefScore BeliefPayoff BeliefCalc Dist Error, ///
	i(ID) j(Round)

label var Round "Exp: Round #"
label var PriorRed "Prior"
label var PriorDist "Distance of prior from 0.5"
label var BallRed "Red ball drawn"
label var Belief "Belief"
label var BeliefScore "Score"
label var BeliefPayoff "Payoff"
label var BeliefCalc "# times calculator used"
label var Dist "Distance of reported belief from 0.5"
label var Error "Negative absolute difference between belief and prior"

// Create treatment variable
gen mechB=.
gen mechQ=.
replace mechB=1 if orderBQ==1 & Round<=5
replace mechQ=0 if orderBQ==1 & Round<=5
replace mechB=0 if orderBQ==1 & Round>=6
replace mechQ=1 if orderBQ==1 & Round>=6
replace mechB=0 if orderBQ==0 & Round<=5
replace mechQ=1 if orderBQ==0 & Round<=5
replace mechB=1 if orderBQ==0 & Round>=6
replace mechQ=0 if orderBQ==0 & Round>=6
label var mechB "=1 if BSR"
label var mechQ "=1 if QSR"

label define BSRlbl 0 "mech-Q", replace
label define BSRlbl 1 "mech-B", add
label values mechB BSRlbl
label define QSRlbl 0 "mech-B", replace
label define QSRlbl 1 "mech-Q", add
label values mechQ QSRlbl

order mechB mechQ, before(orderBQ)

gen Exp=.
replace Exp=1 if Round<=5
replace Exp=2 if Round>=6
label var Exp "Experiment #"

order Exp, before(Round)

save "Data\belief_elicitation-paper-long.dta", replace
