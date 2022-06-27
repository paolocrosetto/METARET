*******************************************
*basic information about variables
******************************************

**female
tab female 

**age
sum age 

**is a boat owner
tab owner

**saver (membership in savings organization)
tab sav_member 

**occupation in agriculture
tab agriculture

** uses dagaa specific nets
tab dagaa

**upper_income should by roughly 50 percent
tab upper_income 
sum Y_Mean, detail

**full comprehension
tab comprehension_full 


**experience of luck
tab luck 

**investment
sum I , detail

**belief of other's investment
sum BI ,detail


**correct belief of other's investment
tab belief_bonus_invest


****
*Earnings
****
* result_payoff_multitip = payoff_investment_game+ belief_bonus_invest *500 + payoff_betting_task

sum result_payoff_multitip, detail

*#######################################################
*#######################################################
* RESULTS:
*#######################################################
**treatment abbreveations
* luck: good luck; 
*(bluck: bad luck)
* hiEndow: high lottery;
* (lowEndow: low lottery;)
* lowSI: low social information;
* (noSI: no social information;)
* hiSI: high social information;
*******************************************************
**********************************************************
*comparison of cells with different treatment combination
************************************************************
***********
*cell description
*in stata
tabstat luck hiEndow lowSI hiSI, by(cell) stat(n mean)
*as table with tabs (n in brackets)
*********
*				lowSI	noSI	hiSI  
* hiEndow+luck	a(61)	b(59)	c(55)
* hiEndow+bluck	d(47)	e(49)	f(53)
* lowEndow+luck	g(49)	h(64)	i(63)
* lowEndow+bluck	j(59)	k(44)	l(45)


*overview of cells

*##
*TABLE 1: socio-demographics
*##
tabstat dagaa agriculture owner sav_member upper_income age , by(cell) stat(n mean)

*##
*test of variables for footnote are at the end
*###

*###############################################
*CHAPTER 4.2 Infos in text
*###############################################

*##
*In text and table A3 in Appendix
*##
tabstat I, by(cell) stat(n mean sd min max med sk k)
tabstat BI, by(cell) stat(n mean sd min max med sk k)



*tests between cells on investment

*a vs b
ranksum I if   luck==1 & hiEndow==1 & hiSI ==0, by(lowSI)
*a vs c
ranksum I if  luck==1 & hiEndow==1 & noSI ==0, by(lowSI)
*a vs d
ranksum I if  lowSI==1 & hiEndow==1 & hiSI ==0, by(luck)
*a vs g
ranksum I if  luck==1 & lowSI==1 & hiSI ==0, by(hiEndow)
*b vs c
ranksum I if  luck==1 & hiEndow==1 & lowSI ==0, by(hiSI)
*b vs e
ranksum I if  lowSI==0 & hiEndow==1 & hiSI ==0, by(luck)
*b vs h
ranksum I if  luck==1 & lowSI==0 & hiSI ==0, by(hiEndow)
*c vs f
ranksum I if  hiSI==1 & hiEndow==1 & lowSI ==0, by(luck)
*c vs i
ranksum I if  luck==1 & lowSI==0 & hiSI ==1, by(hiEndow)
*d vs e
ranksum I if  luck==0 & hiEndow==1 & hiSI ==0, by(lowSI)
*d vs f
ranksum I if  luck==0 & hiEndow==1 & noSI ==0, by(lowSI)
*d vs g
ranksum I if   midEndow==1 & lowSI ==1, by(luck)
*d vs j
ranksum I if  luck==0 & lowSI==1 & hiSI ==0, by(hiEndow)
*e vs f
ranksum I if  luck==0 & hiEndow==1 & lowSI ==0, by(hiSI)
*e vs h
ranksum I if  lowSI==0 & midEndow==1 & hiSI ==0, by(luck)
*e vs k
ranksum I if  luck==0 & lowSI==0 & hiSI ==0, by(hiEndow)
*f vs l
ranksum I if  luck==0 &  hiSI ==1, by(hiEndow)
*f vs i
ranksum I if  hiSI ==1 &midEndow==1, by(luck)
*g vs h
ranksum I if  luck==1 & hiEndow==0 & hiSI ==0, by(lowSI)
*g vs i
ranksum I if  luck==1 & hiEndow==0 & noSI ==0, by(lowSI)
*g vs j
ranksum I if  lowSI==1 & hiEndow==0 & hiSI ==0, by(luck)
*h vs i
ranksum I if  luck==1 & hiEndow==0 & lowSI ==0, by(hiSI)
*h vs k                      
ranksum I if  lowSI==0 & hiEndow==0 & hiSI ==0, by(luck)
*i vs l                      
ranksum I if  lowSI==0 & hiEndow==0 & hiSI ==1, by(luck)
*j vs k
ranksum I if  luck==0 & hiEndow==0 & hiSI ==0, by(lowSI)
*j vs l
ranksum I if  luck==0 & hiEndow==0 & noSI ==0, by(lowSI)
*k vs l
ranksum I if  luck==0 & hiEndow==0 & lowSI ==0, by(hiSI)

**********************
* Testing whether payment scheme has really no effect 
**********************
*with bad luck
ranksum I if  luck==0, by(hiEndow)
*with good luck
ranksum I if  luck==1, by(hiEndow)
*pooled
ranksum I, by(hiEndow)

*******************************************************************
*test of other treatments 
*******************************************************************

*****************
* overview of treatment values through ttest

** t-test give out mean values and standard deviation, which are used to get an overview concerning luck and social infornmation
** using the t-test gives additionally a first overview on potential treatment effects of good luck

* infos lowSI
ttest I if  lowSI==1, by(luck)
ttest BI if  lowSI==1, by(luck)
* infos noSI
ttest I if  noSI==1, by(luck)
ttest BI if  noSI==1, by(luck)
* infos highSI
ttest I if  hiSI==1, by(luck)
ttest BI if  hiSI==1, by(luck)
* infos luck
ttest I, by(luck)




*****************
* testing treatment effects

*good luck
* under lowSI
ranksum I if  lowSI==1, by(luck)
* under noSI
ranksum I if  noSI==1, by(luck)
* under highSI
ranksum I if  hiSI==1, by(luck)
*same income sample
ranksum I if midEndow==1, by(luck)
*same income/noSI
ranksum I if midEndow==1 & noSI==1, by(luck)


*pooled sample
ranksum I , by(luck)

esize twosample I , by(luck)

* lowSI
* under good luck
ranksum I if  hiSI==0 &luck==1, by(lowSI)
* under bad luck
ranksum I if  hiSI==0 &luck==0, by(lowSI)
*pooled
ranksum I if  hiSI==0, by(lowSI)

* hiSI
* under good luck
ranksum I if  lowSI==0 &luck==1, by(hiSI)
* under bad luck
ranksum I if  lowSI==0 &luck==0, by(hiSI)
* pooled
ranksum I if  lowSI==0, by(hiSI)

* hiSI vs. lowSI
* under good luck
ranksum I if  noSI==0 &luck==1, by(hiSI)
* under bad luck
ranksum I if  noSI==0 &luck==0, by(hiSI)
* pooled
ranksum I if  noSI==0, by(hiSI)




*************************************
*FIGURE2
*************************************

cumul I if lowSI &luck==1, gen(cul_low_gl)
cumul I if lowSI &luck==0, gen(cul_low_bl)
cumul I if noSI &luck==0, gen(cul_no_bl)
cumul I if noSI &luck==1, gen(cul_no_gl)
cumul I if hiSI &luck==1, gen(cul_hi_gl)
cumul I if hiSI &luck==0, gen(cul_hi_bl)
line cul_low_gl cul_low_bl cul_no_gl cul_no_bl cul_hi_gl cul_hi_bl I, sort


*########################################
* CHAPTER 4.3
*########################################

***********************************************************************
*regression analysis comparison of I 
***********************************************************************


*##
*TABLE 2 & TABLE A1
*##

****
*cluster robust estimation
****

*basic estimation
reg I lowSI hiSI luck hiEndow, cluster(session_id)
est sto reg_basic_cluster


*+control variables
reg I lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , cluster(session_id)
est sto reg_full_cluster

*+ control variables + BI
reg I lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop BI , cluster(session_id)
est sto reg_full_BI_cluster



esttab reg_basic_cluster reg_full_cluster reg_full_BI_cluster using "${dataFolder}regression_TZ_cluster.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.10 ** 0.05 *** 0.01) replace


*with significance level p<0.05


esttab reg_basic_cluster reg_full_cluster reg_full_BI_cluster using "${dataFolder}regression_TZ_cluster.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.05 ** 0.01 *** 0.001) replace



*******************************
*belief of others behavior
***************************
*Pearson correlation
pwcorr I BI, sig



***********************************************************************
*regression analysis comparison of BI 
***********************************************************************

*##
*TABLE 3 and Table A4
*##

****
*cluster robust estimation
****

*basic estimation
reg BI lowSI hiSI luck hiEndow, cluster(session_id)
est sto reg_BI_basic_cluster

*+control variables
reg BI lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , cluster(session_id)
est sto reg_BI_full_cluster


*+ control variables + I
reg BI lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop I , cluster(session_id)
est sto reg_BI_full_I_cluster

esttab reg_BI_basic_cluster reg_BI_full_cluster  using "${dataFolder}regression_TZ_BI_cluster.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.10 ** 0.05 *** 0.01) replace


*with significance level p<0.05

esttab reg_BI_basic_cluster reg_BI_full_cluster  using "${dataFolder}regression_TZ_BI_cluster.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.05 ** 0.01 *** 0.001) replace

*#########################################################
*test of variables (for footnote in Chapter 4.1)
*########################################################

*dagaa

prtest dagaa if lowSI==0& luck ==0,by(hiSI)
prtest dagaa if lowSI==0& luck ==1,by(hiSI)
prtest dagaa if lowSI==0,by(hiSI)
prtest dagaa if hiSI==0& luck ==0,by(lowSI)
prtest dagaa if hiSI==0& luck ==1,by(lowSI)
prtest dagaa if hiSI==0,by(lowSI)
prtest dagaa if noSI==0& luck ==0,by(hiSI)
prtest dagaa if noSI==0& luck ==1,by(hiSI)
prtest dagaa if noSI==0,by(hiSI)

prtest dagaa if hiSI==1,by(luck)
prtest dagaa if lowSI==1,by(luck)
prtest dagaa if noSI==1,by(luck)
prtest dagaa ,by(luck)

*agriculture

prtest agriculture if lowSI==0& luck ==0,by(hiSI)
prtest agriculture if lowSI==0& luck ==1,by(hiSI)
prtest agriculture if lowSI==0,by(hiSI)
prtest agriculture if hiSI==0& luck ==0,by(lowSI)
prtest agriculture if hiSI==0& luck ==1,by(lowSI)
prtest agriculture if hiSI==0,by(lowSI)
prtest agriculture if noSI==0& luck ==0,by(hiSI)
prtest agriculture if noSI==0& luck ==1,by(hiSI)
prtest agriculture if noSI==0,by(hiSI)

prtest agriculture if hiSI==1,by(luck)
prtest agriculture if lowSI==1,by(luck)
prtest agriculture if noSI==1,by(luck)
prtest agriculture ,by(luck)


*owner

prtest owner if lowSI==0& luck ==0,by(hiSI)
prtest owner if lowSI==0& luck ==1,by(hiSI)
prtest owner if lowSI==0,by(hiSI)
prtest owner if hiSI==0& luck ==0,by(lowSI)
prtest owner if hiSI==0& luck ==1,by(lowSI)
prtest owner if hiSI==0,by(lowSI)
prtest owner if noSI==0& luck ==0,by(hiSI)
prtest owner if noSI==0& luck ==1,by(hiSI)
prtest owner if noSI==0,by(hiSI)

prtest owner if hiSI==1,by(luck)
prtest owner if lowSI==1,by(luck)
prtest owner if noSI==1,by(luck)
prtest owner ,by(luck)


*sav_member

prtest sav_member if lowSI==0& luck ==0,by(hiSI)
prtest sav_member if lowSI==0& luck ==1,by(hiSI)
prtest sav_member if lowSI==0,by(hiSI)
prtest sav_member if hiSI==0& luck ==0,by(lowSI)
prtest sav_member if hiSI==0& luck ==1,by(lowSI)
prtest sav_member if hiSI==0,by(lowSI)
prtest sav_member if noSI==0& luck ==0,by(hiSI)
prtest sav_member if noSI==0& luck ==1,by(hiSI)
prtest sav_member if noSI==0,by(hiSI)

prtest sav_member if hiSI==1,by(luck)
prtest sav_member if lowSI==1,by(luck)
prtest sav_member if noSI==1,by(luck)
prtest sav_member ,by(luck)



*age

ttest age if lowSI==0& luck ==0,by(hiSI)
ttest age if lowSI==0& luck ==1,by(hiSI)
ttest age if lowSI==0,by(hiSI)
ttest age if hiSI==0& luck ==0,by(lowSI)
ttest age if hiSI==0& luck ==1,by(lowSI)
ttest age if hiSI==0,by(lowSI)
ttest age if noSI==0& luck ==0,by(hiSI)
ttest age if noSI==0& luck ==1,by(hiSI)
ttest age if noSI==0,by(hiSI)

ttest age if hiSI==1,by(luck)
ttest age if lowSI==1,by(luck)
ttest age if noSI==1,by(luck)
ttest age ,by(luck)


*upper_income

prtest upper_income if lowSI==0& luck ==0,by(hiSI)
prtest upper_income if lowSI==0& luck ==1,by(hiSI)
prtest upper_income if lowSI==0,by(hiSI)
prtest upper_income if hiSI==0& luck ==0,by(lowSI)
prtest upper_income if hiSI==0& luck ==1,by(lowSI)
prtest upper_income if hiSI==0,by(lowSI)
prtest upper_income if noSI==0& luck ==0,by(hiSI)
prtest upper_income if noSI==0& luck ==1,by(hiSI)
prtest upper_income if noSI==0,by(hiSI)
				
prtest upper_income if hiSI==1,by(luck)
prtest upper_income if lowSI==1,by(luck)
prtest upper_income if noSI==1,by(luck)
prtest upper_income ,by(luck)




***************************************************************
*##############################################################
*APPENDIX
*#############################################################
**************************************************************


************************
*Appendix_estimations control Questions
*##
*TABLEA4
*************************
*interaction estimations
*interaction  basic
reg I 1.lowSI##1.comprehension_full 1.hiSI##1.comprehension_full 1.luck##1.comprehension_full 1.hiEndow##1.comprehension_full, cluster(session_id)
est sto reg_basic_cluster_inter

*interaction + control variables
reg I 1.lowSI##1.comprehension_full 1.hiSI##1.comprehension_full 1.luck##1.comprehension_full 1.hiEndow##1.comprehension_full  age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , cluster(session_id)
est sto reg_full_cluster_inter

*interaction + control variables + BI
reg I 1.lowSI##1.comprehension_full 1.hiSI##1.comprehension_full 1.luck##1.comprehension_full 1.hiEndow##1.comprehension_full BI age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , cluster(session_id)
est sto reg_full_BI_cluster_inter


***correct control_question

*basic + control variables
reg I 1.lowSI 1.hiSI 1.luck 1.hiEndow  age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop if comprehension_full==1, cluster(session_id)
est sto reg_full_cluster_compr

***not correct control question

*basic + control variables
reg I 1.lowSI 1.hiSI 1.luck 1.hiEndow age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop if comprehension_full==0, cluster(session_id)
est sto reg_full_cluster_no_compr

esttab reg_basic_cluster_inter reg_full_cluster_inter reg_full_BI_cluster_inter reg_full_cluster_compr reg_full_cluster_no_compr using "${dataFolder}regression_TZ_BI_compr_interact.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.10 ** 0.05 *** 0.01) replace

*with significance level p<0.05
esttab reg_basic_cluster_inter reg_full_cluster_inter reg_full_BI_cluster_inter reg_full_cluster_compr reg_full_cluster_no_compr using "${dataFolder}regression_TZ_BI_compr_interact.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.05 ** 0.01 *** 0.001) replace

**********************************************
*##
*TABLE A5: Appendix interaction treatment variables
*##
**************************************************
****
*cluster robust estimation
****
*basic estimation
reg I luck lowSI 1.luck#1.lowSI hiSI 1.luck#1.hiSI hiEndow, cluster(session_id)
est sto reg_basic_cluster_inter
*+control variables
reg I luck lowSI 1.luck#1.lowSI hiSI 1.luck#1.hiSI hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , cluster(session_id)
est sto reg_full_cluster_inter
*+ control variables + BI
reg I luck lowSI 1.luck#1.lowSI hiSI 1.luck#1.hiSI hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop BI , cluster(session_id)
est sto reg_full_BI_cluster_inter
esttab reg_basic_cluster_inter reg_full_cluster_inter reg_full_BI_cluster_inter using "${dataFolder}regression_TZ_cluster_inter.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.10 ** 0.05 *** 0.01) replace
*with significance level p<0.05
esttab reg_basic_cluster_inter reg_full_cluster_inter reg_full_BI_cluster_inter using "${dataFolder}regression_TZ_cluster_inter.rtf", cells(b(star fmt(4)) se(par fmt(4))) stats(N r2 r2_a, fmt(0 4 4)) starlevel(* 0.05 ** 0.01 *** 0.001) replace




*******************************************
*##Table A6
*******************************************
*cluster robust OLS regression






****************************************************************************************************************************************************************************
*********************************
*//further control regressions that are not in the appendix, but used for better understanding
***********************************
*********************************
**********************
*without social information in first game
*************************

*only treatment variables
reg I lowSI hiSI luck hiEndow if treat_info==0, cluster(session_id)

*interaction term
reg I lowSI##treat_info hiSI##treat_info luck hiEndow  age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop, cluster(session_id)

*including control variables
reg I lowSI hiSI luck hiEndow  age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop if treat_info==0, cluster(session_id)

*including control variables + BI
reg I lowSI hiSI luck hiEndow  age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop BI if treat_info==0, cluster(session_id)



********************************
*cluster robust tobit estimation I
*********************************

*only treatment variables
tobit I lowSI hiSI luck hiEndow, ll(0) ul(1000) vce(cluster session_id)

*including control variables
tobit I lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , ll(0) ul(1000) vce(cluster session_id)

*including control variables
tobit I lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop BI ,ll(0) ul(1000) vce(cluster session_id)


****
*cluster robust tobit estimation BI
****

*only treatment variables
tobit BI lowSI hiSI luck hiEndow, vce(cluster session_id)


*including control variables
tobit BI lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop , vce(cluster session_id)

*including control variables + investment
tobit BI lowSI hiSI luck hiEndow comprehension_full age age_sq owner female upper_income sav_member agriculture dagaa avg_payoff_natcoop I , vce(cluster session_id)




******************************************************************************************************************************************************************************************