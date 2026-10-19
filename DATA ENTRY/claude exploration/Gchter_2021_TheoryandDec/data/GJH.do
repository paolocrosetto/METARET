********************************************************
*Loss Aversion in Riskless and Risky Choices           *
*Simon Gächter, Eric J. Johnson and Andreas Herrmann   *
*Theory and Decision, 2021
*July 21, 2021                             *
********************************************************

***Opening Comment***
* The dataset GJH_data.dta contains only the basic variables. 
* See also the README file. 
* All other variables are derived as part of this do-file. 

****Analysis File using Stata 16.1***

use GJH_data.dta

***Section 3.1: Eliciting WTA and WTP between- and within-subjects***

label var respondent "unique participant id 1 to 660"
label var study "1 = between subjects, 2 = within-subjects"

***We only look at monotonic preferences, that is, preferences that exhibit only
***one switch in the respective choice list.
label var monotonic_wta "1 if only one switch point in choice list, 0 otherwise"
label var monotonic_wtp "1 if only one switch point in choice list, 0 otherwise"
label var monotonic "1 if only one switch point in either WTA or WTP (Study 1) or in both (Study 2), 0 otherwise"
***Footnote 6
tab monotonic if study==1
tab monotonic if study==2

** Result 1***
***We assume the "true" WTA and WTP are midpoints at the switchpoint 
***in the price lists:
label var wta "switch point of lowest price in the list at which seller is willing to sell"
label var wtp "switch point of highest price in the list at which buyer is willing to buy"
gen wta_mp = wta-0.25
gen wtp_mp = wtp+0.25

label var wta_mp "WTA midpoint calculated as WTA-0.25"
label var wtp_mp "WTP midpoint calculated as WTP+0.25"

sum wtp_mp if study==1&monotonic_wtp==1, d
sum wtp_mp if study==2&monotonic_wtp==1, d

sum wta_mp if study==1&monotonic_wta==1, d
sum wta_mp if study==2&monotonic_wta==1, d

***KS Test of differences in WTA between (Study 1) and within subjects (Study 2)
ksmirnov wta_mp if monotonic_wta==1, by(study)
ksmirnov wtp_mp if monotonic_wtp==1, by(study)

***Fig. 2****
***Fig. 2 and the related analysis uses the pooled dataset; 
***label variables:
label var studies_pooled "1 - Study 1: between-subjects; 2 - Study 2: within-subjects"
label var price_pooled "Elicited values in € - either WTA or WTP"
label var condition "1 - WTP-between; 2 - WTA-between; 3 - WTP-within; 4 - WTA-within"
label var study2_seq "0 - Study 1; Study 2: 1 - WTA-WTP; 2 - WTP-WTA"

***create pooled wta/wtp variable called price_pooled_midpoint:
gen price_pooled_midpoint = . 
replace price_pooled_midpoint = price_pooled + 0.25 if condition==1  
replace price_pooled_midpoint = price_pooled - 0.25 if condition==2  
replace price_pooled_midpoint = price_pooled + 0.25 if condition==3 
replace price_pooled_midpoint = price_pooled - 0.25 if condition==4 
label var price_pooled_midpoint "WTA or WTP midpoint in pooled data"

***plot Fig. 2
cdfplot price_pooled_midpoint, by(condition)

***Test for sequence effects in Study 2 (Sequence == 1 if sequence is WTA-WTP; 
***Sequence == 2 if sequence is WTP-WTA)
label var sequence "1 if WTA-WTP, 2 if WTP-WTA"
ksmirnov wta_mp if monotonic_wta==1&study==2, by(sequence)
ksmirnov wtp_mp if monotonic_wtp==1&study==2, by(sequence)

***Test of whether position in the sequence of Study 2 makes a difference
***compared to Study 1 
gen wtasecond = wta_mp if study==2&sequence==2&monotonic_wta==1
replace wtasecond = wta_mp if study==1&monotonic_wta==1

gen wtpsecond = wtp_mp if study==2&sequence==1&monotonic_wtp==1
replace wtpsecond = wtp_mp if study==1&monotonic_wtp==1

label var wtasecond "wta elicited after wtp "
label var wtpsecond "wtp elicited after wta"

ksmirnov wtasecond, by(study)
ksmirnov wtpsecond, by(study)

reg price_pooled_midpoint price_treatment i.study2_seq, r


***Section 3.2: Loss aversion in riskless choice***

***Result 2***
***Calculating aggregate-level lambda_riskless using midpoints***

***Study 1***
sum wta_mp if study==1&monotonic_wta==1, d
sum wtp_mp if study==1&monotonic_wtp==1, d
ttest price_pooled_midpoint if study==1, by(price_treatment)
ksmirnov price_pooled_midpoint if study==1, by(price_treatment)

***Study 2***
sum wta_mp if study==2&monotonic==1, d
sum wtp_mp if study==2&monotonic==1, d
ttest wta_mp = wtp_mp if study==2&monotonic==1

***Calculating individual-level lambda_riskless using midpoints***
gen lambda_rless_mp = wta_mp/wtp_mp if wtp>0
label var lambda_rless_mp "wta_mp/wtp_mp if wtp>0"

***Comparing Study 1 and Study 2 WTA/WTP ratios
ttest lambda_rless_mp=2 if monotonic==1

***Fig.3***
kdensity lambda_rless_mp if monotonic==1, xtitle("lambda_riskless (WTA/WTP)") xlabel(0 1 2 3 4 5 6 7 8 9 10 11) title("")

***calculate number of individuals with WTP>0
 tab wtp if monotonic==1&study==2

***Result 3***

tab lambda_rless_mp if monotonic==1&study==2
sum lambda_rless_mp if monotonic==1&study==2, d

***Accounting for diminishing sensitivity***

***assuming v(x)=x^0.88***
gen wta_mp088 = wta_mp^0.88 if study==2
label var wta_mp088 "wta_mp^0.88"

gen wtp_mp088 = wtp_mp^0.88 if study==2
label var wtp_mp088 "wtp_mp^0.88"

gen lambda_rless_mp088 = wta_mp088/wtp_mp088 if wtp>0
label var lambda_rless_mp088 "wta_mp088/wtp_mp088 if wtp>0"

sum lambda_rless_mp088 if monotonic==1&study==2,d

***assuming v(x)=x^0.95***

gen wta_mp095 = wta_mp^0.95 if study==2
label var wta_mp095 "wta_mp^0.95"

gen wtp_mp095 = wtp_mp^0.95 if study==2
label var wtp_mp095 "wtp_mp^0.95"

gen lambda_rless_mp095 = wta_mp095/wtp_mp095 if wtp>0
label var lambda_rless_mp095 "wta_mp095/wtp_mp095 if wtp>0"

sum lambda_rless_mp095 if monotonic==1&study==2,d

***correlation between WTA and WTP-WTA
reg wta_mp  wtp_mp  if monotonic==1&study==2,r

***Section 3.3: Loss aversion in risky choice***

***Table 1***
label var monotonic_lottery "1 if unique switch point in choice list, 0 otherwise"
tab monotonic_lottery
tab lotterychoice if monotonic_lottery==1
label var lotterychoice "1 rej all 2 acc #1 3 acc #1-#2 4 acc #1-#3 5 acc #1-#4 6 acc #1-#5 7 acc all"
label var lotteryrescaled "1 = accept all, ..., 7 = reject all"

***lambda_risky = w*(G^a/L^b)

***Assuming maximal implied loss and w=1,a=1,b=1 (Model 0)
gen lambda_max_risky=.
replace lambda_max_risky=3 if lotterychoice==2
replace lambda_max_risky=2 if lotterychoice==3
replace lambda_max_risky=1.50 if lotterychoice==4
replace lambda_max_risky=1.20 if lotterychoice==5
replace lambda_max_risky=1 if lotterychoice==6
label var lambda_max_risky "lambda_risky = w*(G^a/L^b) assuming L is maximal"

***Assuming loss is midpoint between loss accepted and loss rejected 

***w=1,a=1,b=1 (Model (a): lambda_mid_risky_a)
gen lambda_mid_risky_a=.
replace lambda_mid_risky_a=2.4 if lotterychoice==2
replace lambda_mid_risky_a=1.71 if lotterychoice==3
replace lambda_mid_risky_a=1.33 if lotterychoice==4
replace lambda_mid_risky_a=1.09 if lotterychoice==5
replace lambda_mid_risky_a=0.92 if lotterychoice==6
label var lambda_mid_risky_a "Model a: w=1,a=1,b=1"

***w=1,a=0.95,b=0.92 (Model (b): lambda_mid_risky_b)
gen lambda_mid_risky_b=.
replace lambda_mid_risky_b=2.36 if lotterychoice==2
replace lambda_mid_risky_b=1.73 if lotterychoice==3
replace lambda_mid_risky_b=1.37 if lotterychoice==4
replace lambda_mid_risky_b=1.14 if lotterychoice==5
replace lambda_mid_risky_b=0.98 if lotterychoice==6
label var lambda_mid_risky_b "Model b: w=1,a=0.95,b=0.92"

***w=0.86,a=1,b=1 (Model (c): lambda_mid_risky_c)
gen lambda_mid_risky_c=.
replace lambda_mid_risky_c=2.06 if lotterychoice==2
replace lambda_mid_risky_c=1.47 if lotterychoice==3
replace lambda_mid_risky_c=1.15 if lotterychoice==4
replace lambda_mid_risky_c=0.94 if lotterychoice==5
replace lambda_mid_risky_c=0.79 if lotterychoice==6
label var lambda_mid_risky_c "Model c: w=0.86,a=1,b=1"

***w=0.86,a=0.95,b=0.92 (Model (d): lambda_mid_risky_d)
gen lambda_mid_risky_d=.
replace lambda_mid_risky_d=2.03 if lotterychoice==2
replace lambda_mid_risky_d=1.49 if lotterychoice==3
replace lambda_mid_risky_d=1.18 if lotterychoice==4
replace lambda_mid_risky_d=0.98 if lotterychoice==5
replace lambda_mid_risky_d=0.74 if lotterychoice==6
label var lambda_mid_risky_d "Model d: w=0.86,a=0.95,b=0.92"

***Lambda_risky values in Table 1*****
sum lambda_max_risky if monotonic_lottery==1,d
sum lambda_mid_risky_a if monotonic_lottery==1,d
sum lambda_mid_risky_b if monotonic_lottery==1,d
sum lambda_mid_risky_c if monotonic_lottery==1,d
sum lambda_mid_risky_d if monotonic_lottery==1,d


***Section 3.4 Correlation of loss aversion in riskless and risky choice

***Fig. 4***
lowess lambda_rless_mp lotteryrescaled, title("") xtitle("Lottery choice and implied lambda_risky: 1=least loss averse; 7=most loss averse") xlabel(1 2 3 4 5 6 7) ytitle("lambda_riskless") ylabel(0 1 2 3 4 5 6 7 8 9 10 11)

sum lambda_rless_mp if lotteryrescaled==1 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==2 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==3 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==4 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==5 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==6 & monotonic==1&monotonic_lottery==1
sum lambda_rless_mp if lotteryrescaled==7 & monotonic==1&monotonic_lottery==1

spearman lambda_rless_mp lotteryrescaled if monotonic==1&monotonic_lottery==1
spearman lambda_rless_mp lotteryrescaled if monotonic==1&monotonic_lottery==1&lotteryrescaled<7
reg lambda_rless_mp i.lotteryrescaled if monotonic==1&monotonic_lottery==1, r


***Section 3.5 Socio-demographics and loss aversion
***uses only Study 2 data***

***Summary statistics are in Fig. 5 and are calculated below for all variables in turn

***Gender***
tab female if study==2 & monotonic==1
label var female "0 = male, 1 = female"

sum lambda_rless_mp if female==0&monotonic==1
sum lambda_rless_mp if female==1&monotonic==1

sum lotteryrescaled if female==0&monotonic_lottery==1
sum lotteryrescaled if female==1&monotonic_lottery==1

ranksum lambda_rless_mp if monotonic==1, by(female)
ranksum lotteryrescaled if monotonic_lottery==1, by(female)

***Age***
label var age "1 = 18-24, 2 = 25-34, 3 = 35-44, 4 = 45-54, 5 = 55-64, 6 = 65+"
tab age if study==2 & monotonic==1

sum lambda_rless_mp if monotonic==1&age==1
sum lambda_rless_mp if monotonic==1&age==2
sum lambda_rless_mp if monotonic==1&age==3
sum lambda_rless_mp if monotonic==1&age==4
sum lambda_rless_mp if monotonic==1&age==5
sum lambda_rless_mp if monotonic==1&age==6

sum lotteryrescaled if monotonic_lottery==1&age==1
sum lotteryrescaled if monotonic_lottery==1&age==2
sum lotteryrescaled if monotonic_lottery==1&age==3
sum lotteryrescaled if monotonic_lottery==1&age==4
sum lotteryrescaled if monotonic_lottery==1&age==5
sum lotteryrescaled if monotonic_lottery==1&age==6

spearman lambda_rless_mp age if monotonic==1
spearman lotteryrescaled age if monotonic_lottery==1

***Income***
label var income "1 <=14,999; 2=15,000-29,999; 3=30,000-49,999; 4=50,000-69,999; 5=70,000-99,999; 6=100,000+"
tab income if study==2 & monotonic==1

sum lambda_rless_mp if monotonic==1&income==1
sum lambda_rless_mp if monotonic==1&income==2
sum lambda_rless_mp if monotonic==1&income==3
sum lambda_rless_mp if monotonic==1&income==4
sum lambda_rless_mp if monotonic==1&income==5
sum lambda_rless_mp if monotonic==1&income==6

sum lotteryrescaled if monotonic_lottery==1&income==1
sum lotteryrescaled if monotonic_lottery==1&income==2
sum lotteryrescaled if monotonic_lottery==1&income==3
sum lotteryrescaled if monotonic_lottery==1&income==4
sum lotteryrescaled if monotonic_lottery==1&income==5
sum lotteryrescaled if monotonic_lottery==1&income==6


***Wealth***
label var wealth "1 <=9,999; 2=10,000-29,999; 3=30,000-49,999; 4=50,000-99,999; 5=100,000-249,999; 6=250,000+"
tab wealth if study==2 & monotonic==1

sum lambda_rless_mp if monotonic==1&wealth==1
sum lambda_rless_mp if monotonic==1&wealth==2
sum lambda_rless_mp if monotonic==1&wealth==3
sum lambda_rless_mp if monotonic==1&wealth==4
sum lambda_rless_mp if monotonic==1&wealth==5
sum lambda_rless_mp if monotonic==1&wealth==6

sum lotteryrescaled if monotonic_lottery==1&wealth==1
sum lotteryrescaled if monotonic_lottery==1&wealth==2
sum lotteryrescaled if monotonic_lottery==1&wealth==3
sum lotteryrescaled if monotonic_lottery==1&wealth==4
sum lotteryrescaled if monotonic_lottery==1&wealth==5
sum lotteryrescaled if monotonic_lottery==1&wealth==6

***Footnote 10***
spearman lambda_rless_mp income if monotonic==1
spearman lotteryrescaled income if monotonic_lottery==1
spearman lambda_rless_mp wealth if monotonic==1
spearman lotteryrescaled wealth if monotonic_lottery==1


***Education***
label var education "1 = no high school diploma; 2=High School Diploma; 3=University education"
tab education if study==2&monotonic==1

sum lambda_rless_mp if monotonic==1&education==1
sum lambda_rless_mp if monotonic==1&education==2
sum lambda_rless_mp if monotonic==1&education==3

sum lotteryrescaled if monotonic_lottery==1&education==1
sum lotteryrescaled if monotonic_lottery==1&education==2
sum lotteryrescaled if monotonic_lottery==1&education==3

spearman lambda_rless_mp education if monotonic==1
spearman lotteryrescaled education if monotonic_lottery==1

***Occupation***
label var occupation "1=No salaried job; 2=Blue collar; 3=White collar; 4=Manager; 5=Entrepreneur"
tab occupation if study==2&monotonic==1

sum lambda_rless_mp if monotonic==1&occupation==1
sum lambda_rless_mp if monotonic==1&occupation==2
sum lambda_rless_mp if monotonic==1&occupation==3
sum lambda_rless_mp if monotonic==1&occupation==4
sum lambda_rless_mp if monotonic==1&occupation==5

sum lotteryrescaled if monotonic_lottery==1&occupation==1
sum lotteryrescaled if monotonic_lottery==1&occupation==2
sum lotteryrescaled if monotonic_lottery==1&occupation==3
sum lotteryrescaled if monotonic_lottery==1&occupation==4
sum lotteryrescaled if monotonic_lottery==1&occupation==5

kwallis lambda_rless_mp if monotonic==1, by(occupation)
kwallis lotteryrescaled if monotonic_lottery==1, by(occupation)

***Table 2***
***To simplify the exposition and to have enough observations in each category, 
***we reduce the number of categories for age, income and wealth to three. 
***These variables are labelled age2, income2 and wealth2. 
gen age2 = 0
replace age2 = 1 if age==3
replace age2 = 1 if age==4
replace age2 = 2 if age>4

gen income2 = 0
replace income2 = 1 if income==3
replace income2 = 1 if income==4
replace income2 = 2 if income>4

gen wealth2 = 0
replace wealth2 = 1 if wealth==3
replace wealth2 = 1 if wealth==4
replace wealth2 = 2 if wealth>4

xi: reg  lambda_rless_mp female i.age2 if monotonic, r
xi: reg  lambda_rless_mp female i.age2  i.education  i.income2 if monotonic, r
xi: reg  lambda_rless_mp female i.age2  i.education  i.wealth2 if monotonic, r

xi: oprobit   lotteryrescaled female i.age2 if  monotonic_lottery==1, r
xi: oprobit   lotteryrescaled female i.age2 i.education i.income2 if  monotonic_lottery==1, r
xi: oprobit   lotteryrescaled female i.age2 i.education i.wealth2 if  monotonic_lottery==1, r

***Footnote 12
spearman income education 
***Footnote 13
spearman wealth income 
