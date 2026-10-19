*********************************************************
* Analysis Do-File for Ergin, Gürdal, Kuzubas(2025)*******
*********************************************************

*** Load the Stata file - Experiment Data *******************
*** (1) Fork Game  ******************************************
*** (2) Our replication of Bleichrodt and Bruggen (2022)*****
*** (3) Our replication of Noussair et al. (2014) ***********

clear
set more off

use Bleichrodt_experiment_data.dta

append using Trautmann_experiment_data.dta

append using Fork_experiment_data.dta


*** Generate Experiment ID - Codes **********


egen newid=group(id)
order newid


*** Generate the variable sum_choice = total number of choices by treatment
*** and generate total number of choices for each treatment

bysort newid treatment: egen sum_choice=sum(ch)

gen choice_risk=sum_choice if treatment=="Risk"
gen choice_pru=sum_choice if treatment=="Prudence"
gen choice_temp=sum_choice if treatment=="Temperance"

sort newid treatment round

save experiment_data_all_rounds.dta, replace


*** Aggregating participant observations 


collapse (mean) choice_risk choice_pru choice_temp ms, by(newid id oyun game demo_age demo_gpa demo_preexp ///
demo_sex demo_dep demo_econcourses demo_difficulty demo_sure gps_general_risk ///
gps_future_benefit gps_punish_self gps_punish_others gps_good_cause ///
gps_describe_favor gps_describe_revenge gps_describe_intentions gps_describe_math /// 
gps_describe_postpone gps_stair_risk gps_gift gps_donation gps_stair_patience treatment_order)

*** Defining categorical variables and standardization of GPS variables

gen female = 0
replace female = 1 if demo_sex ==0

*** Risk 

egen risk_std = std( gps_general_risk)
egen stairrisk_std = std(gps_stair_risk)
gen risk = 0.4729985 * risk_std + 0.5270015 * stairrisk_std 

*** Patience 
egen gelecekfayda_std = std(gps_future_benefit)
egen stairpatience_std = std(gps_stair_patience)
gen patience = 0.7115185 * stairpatience_std + 0.2884815 * gelecekfayda_std 

*** Positive Reciprocity
egen d1_std = std(gps_describe_favor)
egen gift_std = std( gps_gift)
gen pos_reciprocity = 0.4847038 * d1_std + 0.5152962 * gift_std

*** Trust

egen d3_std = std(gps_describe_intentions)
gen trust = d3_std

***Negative Reciprocity
egen cezakendi_std = std(gps_punish_self)
egen cezabaskasi_std = std(gps_punish_others)
egen d2_std = std(gps_describe_revenge)
gen neg_reciprocity = 0.6261938/2 * cezakendi_std + 0.6261938/2 * cezabaskasi_std + 0.3738062* d2_std

***Altruism

egen donation_std = std( gps_donation)
egen hayir_std = std(gps_good_cause)
gen altruism = 0.6350048 * hayir_std + 0.3649952 * donation_std

*** Math Skill
egen d4_std = std(gps_describe_math)
gen math_skill = d4_std

save aggregate_experiment_data.dta, replace

*********************************************
*** Table 1 - Choices - Fork Game ***********
*********************************************

sum choice_risk if game=="Fork", d
sum choice_pru if game=="Fork",d
sum choice_temp if game=="Fork",d

signrank choice_risk =6 if game=="Fork"
signrank choice_pru =6 if game=="Fork"
signrank choice_temp =6 if game=="Fork"


**********************************************************
****** Figure 12 - Histogram of Choices - Fork Game*******
**********************************************************

set scheme s1mono 
hist choice_risk if game=="Fork", percent discrete gap(25)
hist choice_pru if game=="Fork", percent discrete gap(25)
hist choice_temp if game=="Fork", percent discrete gap(25)

******************************* ***********
*** Table 2 - Correlations - Fork Game ****
*******************************************
spearman choice_risk choice_pru choice_temp if game=="Fork", stats(rho p)

**********************************************************************
*** Figure 13 - Prudence/Temperance by Risk-Averse Choices - Fork Game
**********************************************************************

graph bar choice_pru if game=="Fork", over(choice_risk)
graph bar choice_temp if game=="Fork", over(choice_risk)


****************************************************************************
*** Table 3 - Prudence and Temperance by Risk-averison Quantiles 
****************************************************************************
*xtile requires egenmore package

bysort game: egen risk_quantile = xtile(choice_risk), nq(4)

bysort risk_quantile: sum choice_pru if game=="Fork"
bysort risk_quantile: signrank choice_pru =6 if game=="Fork"

bysort risk_quantile: sum choice_temp if game=="Fork"
bysort risk_quantile: signrank choice_temp =6 if game=="Fork"

***********************************************************
*** Table 4 - Summary Statistics  (Tables 10 and 11)*******
***********************************************************


bysort game: sum demo_age female demo_gpa demo_preexp ///
demo_econ demo_difficulty demo_sure ///
gps_general_risk gps_stair_risk gps_stair_patience gps_future_benefit  ///
gps_gift  gps_punish_self gps_punish_others  ///
gps_good_cause gps_donation gps_describe_favor gps_describe_revenge ///
gps_describe_intentions gps_describe_math gps_describe_postpone


*************************************************
*** Table 5 - Panel Logit Regressions - Fork Game 
*************************************************

clear 
use experiment_data_all_rounds.dta

**Defining categorical variables and standardizaiton of GPS variables
gen female = 0
replace female = 1 if demo_sex ==0

*** Risk variable

egen risk_std = std( gps_general_risk)
egen stairrisk_std = std(gps_stair_risk)
gen risk = 0.4729985 * risk_std + 0.5270015 * stairrisk_std 

***Patience variable
egen gelecekfayda_std = std(gps_future_benefit)
egen stairpatience_std = std(gps_stair_patience)
gen patience = 0.7115185 * stairpatience_std + 0.2884815 * gelecekfayda_std 

***Positive Reciprocity
egen d1_std = std(gps_describe_favor)
egen gift_std = std( gps_gift)
gen pos_reciprocity = 0.4847038 * d1_std + 0.5152962 * gift_std

*** Trust

egen d3_std = std(gps_describe_intentions)
gen trust = d3_std


***Negative Reciprocity
egen cezakendi_std = std(gps_punish_self)
egen cezabaskasi_std = std(gps_punish_others)
egen d2_std = std(gps_describe_revenge)
gen neg_reciprocity = 0.6261938/2 * cezakendi_std + 0.6261938/2 * cezabaskasi_std + 0.3738062* d2_std

***Altruism

egen donation_std = std( gps_donation)
egen hayir_std = std(gps_good_cause)
gen altruism = 0.6350048 * hayir_std + 0.3649952 * donation_std

*** Math Skill
egen d4_std = std(gps_describe_math)
gen math_skill = d4_std

save xtlogitfinal.dta,replace

**************************************************************
*** Panel Logit Regresion for the Risk Task - Table 5 Column (1)
**************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Risk"&game=="Fork"


xtset newid round

xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

*************************************************************************
*** Panel Logit Regresion for the Prudence Task Table 5 - Column (2a)-(2b)
*************************************************************************
clear
use xtlogitfinal.dta


*** Calculating the Risk Ratio for the Prudence Task - Table 5 - Column (2a)-(2b)
gen pru_right=w-k if treatment=="Prudence"
gen expected_pru=0.5*w + 0.5*pru_right
gen risk_ratio= (e /expected_pru)*100

keep if treatment=="Prudence"&game=="Fork"

xtset newid round

***Column (2a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (2b)
xtlogit choice risk_ratio female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

******************************************************************************************
*** Panel Logit Regresion for the Temperance Task -  Table 5 - Columns (3a), (3b) and (3c)
******************************************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Temperance"&game=="Fork"

xtset newid round

*** Generate background risk variable

gen background_risk=.
replace background_risk=e_1 if e_1>e_2
replace background_risk=e_2 if e_2>e_1
replace background_risk=e_1 if e_1==e_2

*** Generate Risk ratio
gen ratio=.
replace ratio=e_1/w if e_1<e_2
replace ratio=e_2/w if e_2<e_1
replace ratio=e_1/w if e_1==e_2
gen ratio_perc=100*ratio

***Column (3a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (3b)
xtlogit choice ratio_perc female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)


margins, dydx(*) atmeans


***Column (3c)
xtlogit choice ratio_perc background_risk female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans


****************************************************************
*** Table 6 - Choices - Fork Game
****************************************************************
clear
use aggregate_experiment_data.dta


sum choice_risk if game=="Fork"
sum choice_pru if game=="Fork"
sum choice_temp if game=="Fork"

signrank choice_risk =6 if game=="Fork"
signrank choice_pru =6 if game=="Fork"
signrank choice_temp =6 if game=="Fork"


****************************************************************
*** Table 6 - Choices - Replication of Bleichrodt Bruggen (2022)
****************************************************************

sum choice_risk if game=="Bleichrodt"
sum choice_pru if game=="Bleichrodt"
sum choice_temp if game=="Bleichrodt"

signrank choice_risk =6 if game=="Bleichrodt"
signrank choice_pru =6 if game=="Bleichrodt"
signrank choice_temp =6 if game=="Bleichrodt"


***************************************************************
*** Table 6 - Choices - Replication of Noussair et al. (2014)
***************************************************************

sum choice_risk if game=="Trautmann"
sum choice_pru if game=="Trautmann"
sum choice_temp if game=="Trautmann"

signrank choice_risk =6 if game=="Trautmann"
signrank choice_pru =6 if game=="Trautmann"
signrank choice_temp =6 if game=="Trautmann"


**************************************************
*****  Figure 14 - Histogram of Choices ***********
**************************************************

*** Fork Game ***
set scheme s1mono 
hist choice_risk if game=="Fork",percent discrete gap(25)
hist choice_pru if game=="Fork", percent discrete gap(25)
hist choice_temp if game=="Fork", percent discrete gap(25)


*** Replication of Bleichrodt and Bruggen (2022)


hist choice_risk if game=="Bleichrodt", percent discrete gap(25)
hist choice_pru if game=="Bleichrodt", percent discrete gap(25)
hist choice_temp if game=="Bleichrodt", percent discrete gap(25)


*** Replication of Noussair et al. (2014)***

hist choice_risk if game=="Trautmann", percent discrete gap(25)
hist choice_pru if game=="Trautmann", percent discrete gap(25)
hist choice_temp if game=="Trautmann", percent discrete gap(25)


*******************************************************************************
****** Table 7 - Comparions of risk, prudent and temperate choices across tasks
*******************************************************************************

ranksum choice_risk if game=="Bleichrodt"|game=="Trautmann", by(game)
ranksum choice_pru if game=="Bleichrodt"|game=="Trautmann", by(game)
ranksum choice_temp if game=="Bleichrodt"|game=="Trautmann", by(game)

ranksum choice_risk if game=="Bleichrodt"|game=="Fork", by(game)
ranksum choice_pru if game=="Bleichrodt"|game=="Fork", by(game)
ranksum choice_temp if game=="Bleichrodt"|game=="Fork", by(game)

ranksum choice_risk if game=="Trautmann"|game=="Fork", by(game)
ranksum choice_pru if game=="Trautmann"|game=="Fork", by(game)
ranksum choice_temp if game=="Trautmann"|game=="Fork", by(game)


****************************************************************
*** Table 8 - Difficulty and Time (Round) Comparison ***********
****************************************************************
bysort game: sum demo_difficulty 
bysort game: sum ms

ranksum demo_difficulty if game=="Bleichrodt"|game=="Trautmann", by(game)
ranksum demo_difficulty if game=="Bleichrodt"|game=="Fork", by(game)
ranksum demo_difficulty if game=="Fork"|game=="Trautmann", by(game)

ranksum ms if game=="Bleichrodt"|game=="Trautmann", by(game)
ranksum ms if game=="Bleichrodt"|game=="Fork", by(game)
ranksum ms if game=="Fork"|game=="Trautmann", by(game)
 

 
**********************************************************
*** Table 9 - Average round time by treatment ************
**********************************************************

clear 
use experiment_data_all_rounds.dta

collapse (mean) ms, by(newid id oyun game treatment)

bysort game treatment: sum ms


***********************************************************
*****  Figure 15 - Average Round Time by Treatment and Game
***********************************************************


set scheme s1mono

gen ms_seconds=ms/1000

gen treatment_order = .
replace treatment_order = 1 if treatment == "Risk"
replace treatment_order = 2 if treatment == "Prudence"
replace treatment_order = 3 if treatment == "Temperance"

graph bar ms_seconds, over(game, label(angle(45))) over(treatment, sort(treatment_order)) asyvars ///
    legend(order(1 "Bleichrodt" 2 "Fork" 3 "Trautmann")) ///
    ytitle("Decision Time (ms)") title("Average RoundTime by Treatment and Game")


*************************************************************************
*** Match treatments with the treatments in Bleichrodt and Bruggen (2022)
*************************************************************************

clear 
use experiment_data_all_rounds.dta 


******************
*** Risk *********
******************
gen bleichrodt_id=.
replace bleichrodt_id = 1 if treatment=="Risk" & w == 16 & k == 8 & d == 7
replace bleichrodt_id = 2 if treatment=="Risk" & w == 14 & k == 7 & d == 5
replace bleichrodt_id = 3 if treatment=="Risk" & w == 16 & k == 7 & d == 5
replace bleichrodt_id = 4 if treatment=="Risk" & w == 13 & k == 6 & d == 4
replace bleichrodt_id = 5 if treatment=="Risk" & w == 8 & k == 4 & d == 3
replace bleichrodt_id = 6 if treatment=="Risk" & w == 10 & k == 5 & d == 3
replace bleichrodt_id = 7 if treatment=="Risk" & w == 10 & k == 4 & d == 3
replace bleichrodt_id = 8 if treatment=="Risk" & w == 12 & k == 5 & d == 3
replace bleichrodt_id = 9 if treatment=="Risk" & w == 11 & k == 5 & d == 3
replace bleichrodt_id = 10 if treatment=="Risk" & w == 12 & k == 4 & d == 3
replace bleichrodt_id = 11 if treatment=="Risk" & w == 14 & k == 6 & d == 5
replace bleichrodt_id = 12 if treatment=="Risk" & w == 12 & k == 6 & d == 5

******************
*** Prudence
******************
replace bleichrodt_id = 1 if treatment=="Prudence" & w == 11 & k == 7 & e == 3
replace bleichrodt_id = 2 if treatment=="Prudence" & w == 9 & k == 6 & e == 2
replace bleichrodt_id = 3 if treatment=="Prudence" & w == 8 & k == 3 & e == 4
replace bleichrodt_id = 4 if treatment=="Prudence" & w == 10 & k == 5 & e == 3
replace bleichrodt_id = 5 if treatment=="Prudence" & w == 8 & k == 5 & e == 1
replace bleichrodt_id = 6 if treatment=="Prudence" & w == 9 & k == 4 & e == 4
replace bleichrodt_id = 7 if treatment=="Prudence" & w == 12 & k == 6 & e == 5
replace bleichrodt_id = 8 if treatment=="Prudence" & w == 10 & k == 4 & e == 5
replace bleichrodt_id = 9 if treatment=="Prudence" & w == 10 & k == 5 & e == 4
replace bleichrodt_id = 10 if treatment=="Prudence" & w == 6 & k == 2 & e == 3
replace bleichrodt_id = 11 if treatment=="Prudence" & w == 6 & k == 4 & e == 1
replace bleichrodt_id = 12 if treatment=="Prudence" & w == 6 & k == 3 & e == 2

*******************
*** Temperance
*******************

replace bleichrodt_id = 1 if treatment=="Temperance" & w == 7 & (e_1 == 4 & e_2 == 2 | e_1 == 2 & e_2 == 4)
replace bleichrodt_id = 2 if treatment=="Temperance" & w == 7 & (e_1 == 3 & e_2 == 3)
replace bleichrodt_id = 3 if treatment=="Temperance" & w == 5 & (e_1 == 2 & e_2 == 1 | e_1 == 1 & e_2 == 2)
replace bleichrodt_id = 4 if treatment=="Temperance" & w == 5 & (e_1 == 1 & e_2 == 3 | e_1 == 3 & e_2 == 1)
replace bleichrodt_id = 5 if treatment=="Temperance" & w == 8 & (e_1 == 3 & e_2 == 2 | e_1 == 2 & e_2 == 3)
replace bleichrodt_id = 6 if treatment=="Temperance" & w == 9 & (e_1 == 2 & e_2 == 6 | e_1 == 6 & e_2 == 2)
replace bleichrodt_id = 7 if treatment=="Temperance" & w == 8 & (e_1 == 4 & e_2 == 3 | e_1 == 3 & e_2 == 4)
replace bleichrodt_id = 8 if treatment=="Temperance" & w == 8 & (e_1 == 5 & e_2 == 2 | e_1 == 2 & e_2 == 5)
replace bleichrodt_id = 9 if treatment=="Temperance" & w == 10 & (e_1 == 6 & e_2 == 3 | e_1 == 3 & e_2 == 6)
replace bleichrodt_id = 10 if treatment=="Temperance" & w == 10 & (e_1 == 5 & e_2 == 4 | e_1 == 4 & e_2 == 5)
replace bleichrodt_id = 11 if treatment=="Temperance" & w == 8 & (e_1 == 1 & e_2 == 6 | e_1 == 6 & e_2 == 1)
replace bleichrodt_id = 12 if treatment=="Temperance" & w == 5 & (e_1 == 2 & e_2 == 2)

save experiment_rounds_Bleichrodt_id.dta, replace



*****************************************************************************
*** Choices in each Task in Risk Aversion, Prudence and Temperance Treatments
******************************************************************************

clear

use experiment_rounds_Bleichrodt_id.dta


bysort game treatment bleichrodt_id: gen total_choices=_N
bysort game treatment bleichrodt_id: egen choice_aux=sum(choice)	

gen choices_frac=choice_aux/total_choices

collapse choices_frac, by(game treatment bleichrodt_id)

gen choices_perc=choices_frac*100

**********************************************************
**** Percentage of Choices in Tables 12, 13 and 14 *******
**********************************************************

by game treatment bleichrodt_id: sum choices_perc


*******************************************************************
**** Figure 16 - Percentage of Risk-Averse Choices by Game and Task
*******************************************************************

set scheme s1mono

graph bar choices_perc if treatment=="Risk", over(bleichrodt_id) over(game)

*******************************************************************
**** Figure 17 - Percentage of Prudent Choices by Game and Task
*******************************************************************

graph bar choices_perc if treatment=="Prudence", over(bleichrodt_id) over(game)

*******************************************************************
**** Figure 18 - Percentage of Temperate Choices by Game and Task
*******************************************************************

graph bar choices_perc if treatment=="Temperance", over(bleichrodt_id) over(game)




***********************************************************************************
*** Table 15 - Panel Logit Regressions - Replication of Bleichrodt and Bruggen (2022)
***********************************************************************************


*****************************************************************
*** Panel Logit Regresion for the Risk Task - Table 15 Column (1)
*****************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Risk"&game=="Bleichrodt"


xtset newid round

xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

*************************************************************************
*** Panel Logit Regresion for the Prudence Task Table 15 - Column (2a)-(2b)
*************************************************************************
clear
use xtlogitfinal.dta


*** Calculating the Risk Ratio for the Prudence Task - Table 15 - Column (2a)-(2b)
gen pru_right=w-k if treatment=="Prudence"
gen expected_pru=0.5*w + 0.5*pru_right
gen risk_ratio= (e /expected_pru)*100

keep if treatment=="Prudence"&game=="Bleichrodt"

xtset newid round

***Column (2a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (2b)
xtlogit choice risk_ratio female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

******************************************************************************************
*** Panel Logit Regresion for the Temperance Task -  Table 15 - Columns (3a), (3b) and (3c)
******************************************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Temperance"&game=="Bleichrodt"

xtset newid round

*** Generate background risk variable

gen background_risk=.
replace background_risk=e_1 if e_1>e_2
replace background_risk=e_2 if e_2>e_1
replace background_risk=e_1 if e_1==e_2

*** Generate Risk ratio
gen ratio=.
replace ratio=e_1/w if e_1<e_2
replace ratio=e_2/w if e_2<e_1
replace ratio=e_1/w if e_1==e_2
gen ratio_perc=100*ratio

***Column (3a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (3b)
xtlogit choice ratio_perc female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)


margins, dydx(*) atmeans


***Column (3c)
xtlogit choice ratio_perc background_risk female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans


***********************************************************************************
*** Table 16 - Panel Logit Regressions - Replication of Noussair et al. (2014) 
***********************************************************************************


*****************************************************************
*** Panel Logit Regresion for the Risk Task - Table 16 Column (1)
*****************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Risk"&game=="Trautmann"


xtset newid round

xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

*************************************************************************
*** Panel Logit Regresion for the Prudence Task Table 16 - Column (2a)-(2b)
*************************************************************************
clear
use xtlogitfinal.dta


*** Calculating the Risk Ratio for the Prudence Task - Table 16 - Column (2a)-(2b)
gen pru_right=w-k if treatment=="Prudence"
gen expected_pru=0.5*w + 0.5*pru_right
gen risk_ratio= (e /expected_pru)*100

keep if treatment=="Prudence"&game=="Trautmann"

xtset newid round

***Column (2a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (2b)
xtlogit choice risk_ratio female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

******************************************************************************************
*** Panel Logit Regresion for the Temperance Task -  Table 16 - Columns (3a), (3b) and (3c)
******************************************************************************************
clear
use xtlogitfinal.dta

keep if treatment=="Temperance"&game=="Trautmann"

xtset newid round

*** Generate background risk variable

gen background_risk=.
replace background_risk=e_1 if e_1>e_2
replace background_risk=e_2 if e_2>e_1
replace background_risk=e_1 if e_1==e_2

*** Generate Risk ratio
gen ratio=.
replace ratio=e_1/w if e_1<e_2
replace ratio=e_2/w if e_2<e_1
replace ratio=e_1/w if e_1==e_2
gen ratio_perc=100*ratio

***Column (3a)
xtlogit choice female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans

***Column (3b)
xtlogit choice ratio_perc female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)


margins, dydx(*) atmeans


***Column (3c)
xtlogit choice ratio_perc background_risk female demo_age demo_difficulty demo_gpa demo_preexp ///
demo_econ demo_sure risk patience trust ///
pos_reciprocity neg_reciprocity altruism math_skill, re vce(cluster newid)

margins, dydx(*) atmeans




***************************************************************************
*** Table 17-18 and 19 - Pairwise Comparison of Time for each Task and Game
***************************************************************************


*** First create our results dataset
clear
set obs 1
generate str20 treatment = ""
generate int bleichrodt_id = .
generate str20 game1 = ""
generate str20 game2 = ""
generate float mean1 = .
generate float mean2 = .
generate float z_stat = .
generate float p_value = .
generate int n1 = .  
generate int n2 = .

save "analysis_results.dta", replace

clear 
use experiment_rounds_Bleichrodt_id.dta



local total_rows = 0

*** Loop through each treatment
foreach t in "Risk" "Prudence" "Temperance" {
    di "Processing treatment: `t'"
    
    * Loop through each bleichrodt_id
    forvalues b = 1/12 {
        di "  Processing bleichrodt_id: `b'"
        
        foreach g1 in "Bleichrodt" "Fork" "Trautmann" {
            foreach g2 in "Bleichrodt" "Fork" "Trautmann" {
                if "`g1'" < "`g2'" {  // This ensures we only do each comparison once
                    * Count observations for this comparison
                    count if game == "`g1'" & treatment == "`t'" & bleichrodt_id == `b'
                    local n1 = r(N)
                    count if game == "`g2'" & treatment == "`t'" & bleichrodt_id == `b'
                    local n2 = r(N)
                    
                    if `n1' > 0 & `n2' > 0 {
                        * Calculate means for each game
                        quietly summarize ms if game == "`g1'" & treatment == "`t'" & bleichrodt_id == `b'
                        local mean1 = r(mean)
                        quietly summarize ms if game == "`g2'" & treatment == "`t'" & bleichrodt_id == `b'
                        local mean2 = r(mean)
                        
                        * Perform Wilcoxon rank-sum test
                        qui ranksum ms if (game == "`g1'" | game == "`g2'") & ///
                            treatment == "`t'" & bleichrodt_id == `b', by(game)
                        
                        * Store p-value from ranksum test
                        local p = 2*(1 - normal(abs(r(z))))
                        
                        * Create a new observation with results
                        preserve
                        clear
                        set obs 1
                        generate str20 treatment = "`t'"
                        generate int bleichrodt_id = `b'
                        generate str20 game1 = "`g1'"
                        generate str20 game2 = "`g2'"
                        generate float mean1 = `mean1'
                        generate float mean2 = `mean2'
                        generate float z_stat = r(z)
                        generate float p_value = `p'
                        generate int n1 = `n1'
                        generate int n2 = `n2'
                        
                        * Append to results file
                        append using "analysis_results.dta"
                        save "analysis_results.dta", replace
                        restore
                        
                        local total_rows = `total_rows' + 1
                    }
                }
            }
        }
    }
}

* Load results
use "analysis_results.dta", clear


* Drop the initial empty observation
drop if treatment == "" & _n == _N

* Format the results
format mean1 mean2 %9.2f
format z_stat p_value %9.3f

* Sort results by treatment, bleichrodt_id, and game pairs
sort treatment bleichrodt_id game1 game2

* Display full results
list treatment bleichrodt_id game1 game2 mean1 mean2 z_stat p_value n1 n2, ///
    separator(0) abbreviate(12)

* Format the results for Excel export
* First, format the numeric variables
format mean1 mean2 %9.2f
format z_stat p_value %9.3f

* Sort the data
sort treatment bleichrodt_id game1 game2

* Create Excel file with formatted columns
export excel treatment bleichrodt_id game1 game2 mean1 mean2 z_stat p_value n1 n2 ///
    using "pairwise_results.xlsx", ///
    firstrow(variables) replace


* Create variable labels
label variable treatment "Treatment"
label variable bleichrodt_id "Task ID"
label variable game1 "Game 1"
label variable game2 "Game 2"
label variable mean1 "Mean RT Game 1 (ms)"
label variable mean2 "Mean RT Game 2 (ms)"
label variable z_stat "Z-statistic"
label variable p_value "P-value"
label variable n1 "N Game 1"
label variable n2 "N Game 2"


export excel treatment bleichrodt_id game1 game2 mean1 mean2 z_stat p_value n1 n2 ///
    using "pairwise_results_labeled.xlsx", ///
    firstrow(varlabels) replace
	
	
	


