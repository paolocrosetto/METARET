********************************************************************************
************* Does Inequality Impede Risk Management? Replication **************
********************************************************************************

** Update File path to Replicate
cd "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Manuscript\Solo 2 Submissions\JRI Submission\Final Submission\Gallenstein_JRI_InequalityImpedesRiskManegement_Code&Data"



***************** Table 1: Descriptive Statistics *********************

use InequalityImpedeRiskManagement_data.dta, clear
duplicates drop idno, force
replace Comp = Comp/4
sum Age HHsize DepRatio fem HHhead noedu Leader farmer cattle land savings loan InsExp friend Rel need givemoney ask Comp 




******************** Table 3: Impact on Offers ***********************

use InequalityImpedeRiskManagement_data.dta, clear
xtset idno
*Model 1
xtreg tot_SAper In if T_I==0 & Offer==1, fe vce(cluster idno)
*Model 2
xtreg tot_SAper In WhIn if T_I==0 & Offer==1, fe vce(cluster idno)
test (-In)=WhIn
*Model 3
xtreg WB_SAper In WhIn if T_I==0 & Offer==1, fe vce(cluster idno)
test (-In)=WhIn
*Model 4
xtreg BW_SAper In WhIn if T_I==0 & Offer==1, fe vce(cluster idno)
test (-In)=WhIn





************** Table 4: Impact on Accept and Insurance *****************

use InequalityImpedeRiskManagement_data.dta, clear

** Insurance **
use InequalityImpedeRiskManagement_data.dta, clear
xtset idno
*Model 1
xtreg Ins In if T_I==1 & Offer==1, fe vce(cluster idno)
*Model 2
xtreg Ins In WhIn if T_I==1 & Offer==1, fe vce(cluster idno)
test (-In)=WhIn

** Acceptance **
xtset idno
*Model 3
xtreg accept In if T_I==0 & Offer==0, fe vce(cluster idno)
*Model 4
xtreg accept In WhIn if T_I==0 & Offer==0, fe vce(cluster idno)
test (-In)=WhIn
*Model 5
gen SF = WB_SAper*InEndow
gen FS = BW_SAper*InEndow
xtreg accept In WhIn SF FS if T_I==0 & Offer==0, fe vce(cluster idno)
test (-In)=WhIn



********************************************************************************
********** Tables 5, 6, A.2, A.4, & A.5: Asymmetric Fairness Views *************
********************************************************************************


**** Exporting Data for Structural Estimation ****
** Equality Treatment **
use InequalityImpedeRiskManagement_data.dta, clear
sort idno
drop if InEndow!=6 | WB_SAper==. | BW_SAper==. | Offer!=1 | T_I==1
keep InEndow WB_SAper BW_SAper idno
order InEndow WB_SAper BW_SAper idno
** UPDATE FILE PATH FOR REPLICATION **
export excel using "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Manuscript\Solo 2 Submissions\JRI Submission\Final Submission\Gallenstein_JRI_InequalityImpedesRiskManegement_Code&Data\EqualityOfferC.xls", sheetreplace nolabel

** Inequality Treatment **
use InequalityImpedeRiskManagement_data.dta, clear
sort idno
drop if InEndow==6 | WB_SAper==. | BW_SAper==. | Offer!=1 | T_I==1
keep InEndow WB_SAper BW_SAper idno
order InEndow WB_SAper BW_SAper idno
** UPDATE FILE PATH FOR REPLICATION **
export excel using "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Manuscript\Solo 2 Submissions\JRI Submission\Final Submission\Gallenstein_JRI_InequalityImpedesRiskManegement_Code&Data\InequalityOfferC.xls", sheetreplace nolabel



***** Structural Labeling 1 *****

* Equality Treatment

** UPDATE FILE PATH FOR REPLICATION **
** THIS DATA IS OUTPUT FROM THE MATLAB FILE **
import excel "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Data Analysis\EQ_probdata_CRRA.xlsx", sheet("Sheet1") firstrow clear
save Equality_probdata.dta, replace
rename FV_prob_5 idno
rename FV_prob_1 FVprob_e
rename FV_prob_2 FVprob_l
gen FVeEQ=(FVprob_e>FVprob_l)
gen FVlEQ=(FVprob_l>=FVprob_e)
keep idno FVeEQ FVlEQ 
duplicates drop idno, force
save FVeq_matchingdata2, replace 

* Inequality Treatment 

** UPDATE FILE PATH FOR REPLICATION **
** THIS DATA IS OUTPUT FROM THE MATLAB FILE **
import excel "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Data Analysis\IN_probdata_CRRA.xlsx", sheet("Sheet1") firstrow clear
save Inequality_probdata.dta, replace
rename FV_prob_7 idno
rename FV_prob_1 FVprob_e
rename FV_prob_2 FVprob_p
rename FV_prob_3 FVprob_l
gen FVe=(FVprob_e>FVprob_l & FVprob_e>FVprob_p)
gen FVl=(FVprob_l>FVprob_e & FVprob_l>FVprob_p)
gen FVp=(FVprob_p>FVprob_e & FVprob_p>FVprob_l)
keep idno FVe FVl FVp
duplicates drop idno, force
save FVeq_matchingdata, replace 

* Merging Together Labeling predictions from Equality and Inequality Treatments
use FVeq_matchingdata, clear
merge 1:1 idno using FVeq_matchingdata2
drop _merge
sort idno
save FVeq_matchingdata_fulldata_3FVs, replace

* Merging Matches into Risk Sharing Data *
use InequalityImpedeRiskManagement_data.dta, clear
merge m:1 idno using FVeq_matchingdata_fulldata_3FVs.dta
drop _merge
bysort grpid: egen symFV1=mean(FVe) if In==1
bysort grpid: egen symFV2=mean(FVl) if In==1
bysort grpid: egen symFV3=mean(FVp) if In==1
gen AsymFV=(symFV1!=1 & symFV2!=1 & symFV3!=1)  
drop symFV1 symFV2 symFV3 
tab Asym, miss
bysort grpid: egen symFV1=mean(FVeEQ) if In==0
bysort grpid: egen symFV2=mean(FVlEQ) if In==0
gen asymFVEQ=(symFV1!=1 & symFV2!=1)  
drop symFV1 symFV2 
tab asymFVEQ, miss
replace Asym=asymFVEQ if InEndow==6
gen InA = In*Asym

** Table 5 Panel A **
ttest FVe if In==1 & Offer==1 & T_I==0, by(InEndow) 
ttest FVp if In==1 & Offer==1 & T_I==0, by(InEndow) 
ttest FVl if In==1 & Offer==1 & T_I==0, by(InEndow) 
** Table 6 Model 1 **
xtset idno
xtreg accept In Asym InA if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)
** Table A.4 Row 1 **
ttest Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, by(In) 
** Table A.5 Model 1 **
xtset idno
xtreg accept Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)


***** Structural Labeling 2 *****

* Equality Treatment

** UPDATE FILE PATH FOR REPLICATION **
** THIS DATA IS OUTPUT FROM THE MATLAB FILE **
import excel "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Data Analysis\EQ_probdata_CRRA.xlsx", sheet("Sheet1") firstrow clear
save Equality_probdata.dta, replace
rename FV_prob_5 idno
rename FV_prob_3 FVprob_e
rename FV_prob_4 FVprob_l
gen FVeEQ=(FVprob_e>FVprob_l)
gen FVlEQ=(FVprob_l>=FVprob_e)
keep idno FVeEQ FVlEQ 
duplicates drop idno, force
save FVeq_matchingdata2, replace 

* Inequality Treatment 

** UPDATE FILE PATH FOR REPLICATION **
** THIS DATA IS OUTPUT FROM THE MATLAB FILE **
import excel "C:\Users\galle\Dropbox\Research\Working Papers\Inequality and Fairness Views\Data Analysis\IN_probdata_CRRA.xlsx", sheet("Sheet1") firstrow clear
save Inequality_probdata.dta, replace
rename FV_prob_7 idno
rename FV_prob_4 FVprob_e
rename FV_prob_5 FVprob_p
rename FV_prob_6 FVprob_l
gen FVe=(FVprob_e>FVprob_l & FVprob_e>FVprob_p)
gen FVl=(FVprob_l>FVprob_e & FVprob_l>FVprob_p)
gen FVp=(FVprob_p>FVprob_e & FVprob_p>FVprob_l)
keep idno FVe FVl FVp
duplicates drop idno, force
save FVeq_matchingdata, replace 

* Merging Together Labeling predictions from Equality and Inequality Treatments
use FVeq_matchingdata, clear
merge 1:1 idno using FVeq_matchingdata2
drop _merge
sort idno
save FVeq_matchingdata_fulldata_3FVs, replace

* Merging Matches into Risk Sharing Data *
use InequalityImpedeRiskManagement_data.dta, clear
merge m:1 idno using FVeq_matchingdata_fulldata_3FVs.dta
drop _merge
bysort grpid: egen symFV1=mean(FVe) if In==1
bysort grpid: egen symFV2=mean(FVl) if In==1
bysort grpid: egen symFV3=mean(FVp) if In==1
gen AsymFV=(symFV1!=1 & symFV2!=1 & symFV3!=1)  
drop symFV1 symFV2 symFV3 
tab Asym, miss
bysort grpid: egen symFV1=mean(FVeEQ) if In==0
bysort grpid: egen symFV2=mean(FVlEQ) if In==0
gen asymFVEQ=(symFV1!=1 & symFV2!=1)  
drop symFV1 symFV2 
tab asymFVEQ, miss
replace Asym=asymFVEQ if InEndow==6
gen InA = In*Asym

** Table 5 Panel B **
ttest FVe if In==1 & Offer==1 & T_I==0, by(InEndow) 
ttest FVp if In==1 & Offer==1 & T_I==0, by(InEndow) 
ttest FVl if In==1 & Offer==1 & T_I==0, by(InEndow) 
** Table 6 Model 2 **
xtset idno
xtreg accept In Asym InA if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)
** Table A.4 Row 2 **
ttest Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, by(In) 
** Table A.5 Model 2 **
xtset idno
xtreg accept Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)


******** Observational Labeling *********

*** Observational Labeling 1 ***
use InequalityImpedeRiskManagement_data.dta, clear
gen view = 1 if Offer==1 & T_I==0
replace view = 1 if WB_SAper>=0.5 & BW_SAper<=0.5 & Offer==1 & T_I==0 & InEndow==6
replace view = 1 if WB_SAper<=0.5 & BW_SAper<=0.5 & Offer==1 & T_I==0 & InEndow==6
replace view = 1 if WB_SAper>=0.5 & BW_SAper>=0.5 & Offer==1 & T_I==0 & InEndow==6
replace view = 2 if WB_SAper<0.5 & BW_SAper<0.5 & Offer==1 & T_I==0 & InEndow==4
replace view = 2 if WB_SAper<=0.5 & BW_SAper<0.5 & Offer==1 & T_I==0 & InEndow==4
replace view = 2 if WB_SAper<0.5 & BW_SAper<=0.5 & Offer==1 & T_I==0 & InEndow==4
replace view = 2 if WB_SAper>0.5 & BW_SAper>0.5 & Offer==1 & T_I==0 & InEndow==8
replace view = 2 if WB_SAper>=0.5 & BW_SAper>0.5 & Offer==1 & T_I==0 & InEndow==8
replace view = 2 if WB_SAper>0.5 & BW_SAper>=0.5 & Offer==1 & T_I==0 & InEndow==8
replace view = 3 if WB_SAper>0.5 & BW_SAper<0.5 & Offer==1 & T_I==0
replace view = 1 if WB_SAper==0.5 & BW_SAper==0.5 & Offer==1 & T_I==0
label variable view "1-equal, 2-prop, 3-liber"
* symmetric FVs would be when in pairs of 1&2, 3&3, 4&4, 5&5
bysort idno In: egen i_lab = mean(view) 
bysort grpid In: egen grp_lab = sum(view)
gen j_lab = grp_lab-i_lab
gen Asym = 1
replace Asym = 0 if i_lab==j_lab
gen InA = In*Asym

** Table 5 Panel C **
gen view1 = (i_lab==1)
gen view2 = (i_lab==2)
gen view3 = (i_lab==3)
ttest view1 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view2 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view3 if T_I==0 & Offer==1 & In==1, by(InEndow)
** Table 6 Model 3 **
xtset idno
xtreg accept In Asym InA if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)
** Table A.4 Row 3 **
ttest Asym if T_I==0 & Offer==1, by(In)
** Table A.5 Model 3**
xtset idno
xtreg accept Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)


*** Observational Labeling 2 *** 
use InequalityImpedeRiskManagement_data.dta, clear
gen view = 5 if Offer==1 & T_I==0
replace view = 1 if WB_SAper>=0.5 & BW_SAper>=0.5 & Offer==1 & T_I==0 
replace view = 2 if WB_SAper<=0.5 & BW_SAper<=0.5 & Offer==1 & T_I==0
replace view = 3 if WB_SAper==0.5 & BW_SAper==0.5 & Offer==1 & T_I==0
replace view = 4 if WB_SAper>0.5 & BW_SAper<0.5 & Offer==1 & T_I==0
replace view = 5 if WB_SAper<0.5 & BW_SAper>0.5 & Offer==1 & T_I==0
tab view if Offer==1 & T_I==0, miss
label variable view "1-selfish, 2-generous, 3-egal, 4- liber, 5-sharer"
* symmetric FVs would be when in pairs of 1&2, 3&3, 4&4, 5&5
bysort idno In: egen i_lab = mean(view) 
bysort grpid In: egen grp_lab = sum(view)
gen j_lab = grp_lab-i_lab
gen Asym = 1
replace Asym = 0 if (i_lab==1 & j_lab==2) | (i_lab==2 & j_lab==1) | (i_lab==3 & j_lab==3) | (i_lab==4 & j_lab==4) | (i_lab==5 & j_lab==5)
gen InA = In*Asym

** Table 5 Panel D**
gen view1 = (i_lab==1)
gen view2 = (i_lab==2)
gen view3 = (i_lab==3)
gen view4 = (i_lab==4)
gen view5 = (i_lab==5)
ttest view1 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view2 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view3 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view4 if T_I==0 & Offer==1 & In==1, by(InEndow)
ttest view5 if T_I==0 & Offer==1 & In==1, by(InEndow)

** Table 6 Model 4**
xtset idno
xtreg accept In Asym InA if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)
** Table A.4 Row 4 **
ttest Asym if T_I==0 & Offer==1, by(In)
** Table A.5 Model 4 **
xtset idno
xtreg accept Asym if T_I==0 & Offer==0 & ptnrmatchflag!=1, fe vce(cluster idno)



******************** Table A.1: Balancing Test ************************
use InequalityImpedeRiskManagement_data.dta, clear
sort idno sesID
replace Comp=Comp/4
by idno: egen RICH=max(WhIn)
duplicates drop idno, force
ttest CRRA, by(RICH)
ttest Age, by(RICH)
ttest HHsize, by(RICH)
ttest DepRatio, by(RICH)
ttest fem, by(RICH)
ttest HHhead, by(RICH)
ttest noedu, by(RICH)
ttest Leader, by(RICH)
ttest farmer, by(RICH)
ttest cattle, by(RICH)
ttest land, by(RICH)
ttest savings, by(RICH)
ttest loan, by(RICH)
ttest InsExp, by(RICH)
ttest friend, by(RICH)
ttest Rel, by(RICH)
ttest need, by(RICH)
ttest givemoney, by(RICH)
ttest ask, by(RICH)
ttest Comp, by(RICH)


************* Table A.3: Heterogeneous Treatment Effects *****************
use InequalityImpedeRiskManagement_data.dta, clear
gen rich =(cattle>=1.97 & land>=4.23)
gen InR = In*rich
gen InC = In*cattle
gen InL = In*land
gen InRA = In*CRRA
gen InF = In*fem
gen InHH = In*HHsize
gen InRel = In*Rel
gen InFre = In*friend
gen InEd = In*noedu

xtset idno
xtreg tot_SAper In InR InRA InF InEd InHH InRel InFre if T_I==0 & Offer==1, fe vce(cluster idno)
xtreg accept In InR InRA InF InEd InHH InRel InFre if T_I==0 & Offer==0, fe vce(cluster idno)
xtreg Ins In InR InRA InF InEd InHH InRel InFre if T_I==1 & Offer==1, fe vce(cluster idno)



************* Table A.6 & A.7: Downward Rigidity Test *****************

use InequalityImpedeRiskManagement_data.dta, clear
gen InEqF = In*EqFirst
gen WhInEqF = WhIn*EqFirst
gen WhEqF = (In==8 & EqFirst==1)

* A.6 Risk Sharing Offers *
xtset idno
xtreg tot_SAper In WhIn if T_I==0 & Offer==1 & EqFirst==1, vce(cluster grpid)
xtreg tot_SAper In WhIn if T_I==0 & Offer==1 & EqFirst==0, fe vce(cluster grpid)
xtreg tot_SAper In WhIn InEqF WhInEqF WhEqF if T_I==0 & Offer==0, fe vce(cluster grpid)

* A.7 Acceptance Decisions *
xtset idno
xtreg accept In WhIn if T_I==0 & Offer==0 & EqFirst==1, fe vce(cluster grpid)
xtreg accept In WhIn if T_I==0 & Offer==0 & EqFirst==0, fe vce(cluster grpid)
xtreg accept In WhIn InEqF WhInEqF if T_I==0 & Offer==0, fe vce(cluster grpid)



************* Table A.8, A.9, & A.10: Order Effects *****************

use InequalityImpedeRiskManagement_data.dta, clear

gen InEqF = In*EqFirst
gen WhInEqF = WhIn*EqFirst
gen WhEqF = (In==8 & EqFirst==1)

* Total Self-Allocation, A.8 *
reg tot_SAper In if T_I==0 & Offer==1 & firstgame==1, robust
reg tot_SAper In WhIn if T_I==0 & Offer==1 & firstgame==1, robust
reg WB_SAper In WhIn if T_I==0 & Offer==1 & firstgame==1, robust
reg BW_SAper In WhIn if T_I==0 & Offer==1 & firstgame==1, robust

* Acceptance, A.9 *
gen Pr=(InEndow==4)
gen PrIn=Pr*In
reg accept In if T_I==0 & Offer==0 & firstgame==1, robust
reg accept In WhIn if T_I==0 & Offer==0 & firstgame==1, robust

* Insurance Decision, Table A.10 *
reg Ins In if T_I==1 & Offer==1 & firstgame==1, robust
reg Ins In WhIn if T_I==1 & Offer==1 & firstgame==1, robust

