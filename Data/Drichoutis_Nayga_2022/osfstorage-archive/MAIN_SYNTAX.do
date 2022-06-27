version 16

* Figure 1
use Figure1data.dta, clear
do figure_responses&cases.do

* Reproduce Figure A1 in the Electronic Supplementary Material
do mobility_graphs.do

* load data
use data.dta, clear

quietly do checkdata.do
count
di in green "Total number of responses = " in yellow `r(N)'/50

***********
* TABLE 2 *
***********
* This will show for each wave pair (i.e., 3-4, 3-41, 4-41) the number of subjects
tab nwaves wave if nchoice==1
foreach w of numlist 3 4 41 {
preserve 
drop if wave==`w'
bysort AM: egen refvalue2=total(cond(wave==3 | wave==4 | wave==41,temp,.)) if nwaves!=3 // create variable to constrain sample to common pool over the 3 waves, see https://www.stata.com/support/faqs/statistics/reference-panel/
tab refvalue2 wave if nchoice==1
restore
}

* tabulate the N of usbjects that got paid (numbers are mentioned inline text)
tab Accepted if nchoice==1, missing
sum totalpay if Accepted=="yes " & nchoice==1



gen events=1 if wave==3 // 1= last year
replace events=2 if wave==4 & StartDate<clock("26/2/2020 14:00:00 μμ", "DMYhms") // 2= 2020 wave but before the first case appeared
replace events=3 if wave==4 & StartDate>=clock("26/2/2020 14:00:00 μμ", "DMYhms") & StartDate<clock("12/3/2020 14:00:00 μμ", "DMYhms") // before first death
replace events=4 if wave==4 & StartDate>=clock("12/3/2020 14:00:00 μμ", "DMYhms") & StartDate<clock("23/3/2020 08:00:00 πμ", "DMYhms")  // after first death & before curfew
replace events=5 if wave==41 & StartDate>=clock("23/3/2020 08:00:00 πμ", "DMYhms") & StartDate<clock("27/4/2020 18:00:00 μμ", "DMYhms") // curfew starts
replace events=6 if wave==41 & StartDate>=clock("27/4/2020 18:00:00 μμ", "DMYhms") & StartDate<clock("4/5/2020 08:00:00 πμ", "DMYhms") // anouncement of relaxing the measures
replace events=7 if wave==41 & StartDate>=clock("4/5/2020 08:00:00 πμ", "DMYhms") // lock down is relaxed
label define events 1 "2019" 2 "2020, Before first case" 3 "After first case, before first death" 4 "After first death, before curfew" 5 "Curfew starts" 6 "Measures to be relaxed (anouncement)" 7 "Measures relaxed"
label values events events

bysort AM: egen refvalue=total(cond(wave==3 | wave==4 | wave==41,temp,.)) 
la def wave 3 "2019 wave" 4 "2020A wave" 41 "2020B wave"
label val wave wave

log using RESULTS.txt, text replace

gen acceptpayment=(Accepted=="yes ")

* scale the data
replace Vprizea1=Vprizea1/113.9
replace Vprizea2=Vprizea2/113.9
replace Vprizeb1=Vprizeb1/113.9
replace Vprizeb2=Vprizeb2/113.9
replace principal=principal/113.9
replace DelayedP=DelayedP/113.9
replace DelayedP2=DelayedP2/113.9
replace RowProbA=RowProbA/100

egen wavecity=group(city wave) // values 2 and 3 indicate subjects taking the survey from abroad in 2020 waves
drop if wavecity==2 | wavecity==3
recode events (7=6)

* Footnote 18
do descriptives_safe_sooner_choices.do  // Kruskal-Wallis tests for the number of safe and sooner choices reported in a Footnote 18

* Estimate Exponential vs Hyperbolic, linear vs Generalized Prelec, for risk/time preferences
do gprelec_Expo_Hyper.do
*=========*
* Table 6 *
*=========*
esttab wv_linear_Expo wv_gprelec_Expo ev_linear_Expo ev_gprelec_Expo using tempexpo123.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
*=========*
* Table 7 *
*=========*
esttab  wv_linear_Hyper wv_gprelec_Hyper ev_linear_Hyper ev_gprelec_Hyper using temphyper123.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
*=====================================*
* Wald tests reported in Tables 6 & 7 *
*=====================================*
do Waldtests.do 


* Calculate the discount rates for the Hyperbolic models (Reported inline)
foreach model in wv_linear_Hyper ev_linear_Hyper wv_gprelec_Hyper ev_gprelec_Hyper  {  
		estimates restore `model'
		nlcom   (kappa_2w: (1+[kappaD]_b[_cons]*(15/360))^(1/(15/360))-1) ///
				(kappa_2m: (1+[kappaD]_b[_cons]*(60/360))^(1/(60/360))-1) ///
				(kappa_6m: (1+[kappaD]_b[_cons]*(180/360))^(1/(180/360))-1)
}

* Reproduce Tables A4 to A9 in the Electronic Supplementary Material
do tablesA4_A9.do

*===========*
* Table A11 *
*===========*
tab city if nchoice==1 & e(sample)==1

* Add demographics+cases
recode income (1=3) (2=3) (6=5) (7=5)
gen nosmoke=(smokestatus==2 | smokestatus==4)

replace cases_adj=cases_adj*1000 // cases per 100.000 people (per region)
replace deaths_adj=deaths_adj*1000 // deaths per 100.000 people (per region)

global index CL
do demog_waves.do
do demog_events.do

* Do a reg with just wave 2020B and use the corona variables
* label corona related varιables
do corona_vars_label.do
do corona_wave.do

do transform_coefficients.do // do back_transform_coefs_demo.do

*=========*
* Table 8 *
*=========*
esttab demog_wv_eut_expo demog_wv_rdu_expo demog_ev_eut_expo demog_ev_rdu_expo using tempdemog_expo.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation" 1.gender "~~Males" cases_adj "~~N of cases/100K population" age "~~Age" hsize "~~Household size" 4.income "~~Average income" 5.income "~~Above average income" 1.nosmoke "~~Not smoking") order(_cons 4.wave 41.wave 2.events 3.events 4.events 5.events 6.events) type

*=========*
* Table 9 *
*=========*
esttab demog_wv_eut_hyper demog_wv_rdu_hyper demog_ev_eut_hyper demog_ev_rdu_hyper using tempdemog_hyper.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation" 1.gender "~~Males" cases_adj "~~N of cases/100K population" age "~~Age" hsize "~~Household size" 4.income "~~Average income" 5.income "~~Above average income" 1.nosmoke "~~Not smoking") order(_cons 4.wave 41.wave 2.events 3.events 4.events 5.events 6.events) type

*=====================================*
* Wald tests reported in Tables 8 & 9 *
*=====================================*
 do Waldtests_demog.do
 
*==========*
* Table 10 *
*==========*
esttab corona_eut_expo corona_rdu_expo corona_eut_hyper corona_rdu_hyper using tempcorona.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 1.gender "~~Males" cases_adj "~~N of cases/100K population" age "~~Age" hsize "~~Household size" 4.income "~~Average income" 5.income "~~Above average income" 1.nosmoke "~~Not smoking" 3.corona_social_dist "~~Neither inefficient, nor efficient" 4.corona_social_dist "~~Efficient" 5.corona_social_dist "~~Very efficient" 2.corona_highrisk "~~Close ones in high risk group" corona_stress "~~Coronavirus stress score" corona_conspiracy "~~Conspiracy theories score") order(_cons) type

*==========*
* Table A10 *
*==========*
esttab corona_restrict_rdu_expo corona_restrict_rdu_hyper using tempcorona_restrict.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 1.gender "~~Males" cases_adj "~~N of cases/100K population" age "~~Age" hsize "~~Household size" 4.income "~~Average income" 5.income "~~Above average income" 1.nosmoke "~~Not smoking" 3.corona_social_dist "~~Neither inefficient, nor efficient" 4.corona_social_dist "~~Efficient" 5.corona_social_dist "~~Very efficient" 2.corona_highrisk "~~Close ones in high risk group" corona_stress "~~Coronavirus stress score" corona_conspiracy "~~Conspiracy theories score") order(_cons) type

*=================================*
* Wald tests reported in Table 10 *
*=================================*
foreach model in corona_rdu_expo corona_rdu_hyper {
estimates restore `model'
test (_b[LNalpha:1.gender]=_b[LNalpha:age]=_b[LNalpha:hsize]=_b[LNalpha:4.income]=_b[LNalpha:5.income]=_b[LNalpha:1.nosmoke]=_b[LNalpha:cases_adj]=_b[LNalpha:3.corona_social_dist]=_b[LNalpha:4.corona_social_dist]=_b[LNalpha:5.corona_social_dist]=_b[LNalpha:2.corona_highrisk]=_b[LNalpha:corona_stress]=_b[LNalpha:corona_conspiracy]) (_b[LNalpha:_cons]=1) (_b[LNbeta:1.gender]=_b[LNbeta:age]=_b[LNbeta:hsize]=_b[LNbeta:4.income]=_b[LNbeta:5.income]=_b[LNbeta:1.nosmoke]=_b[LNbeta:cases_adj]=_b[LNbeta:3.corona_social_dist]=_b[LNbeta:4.corona_social_dist]=_b[LNbeta:5.corona_social_dist]=_b[LNbeta:2.corona_highrisk]=_b[LNbeta:corona_stress]=_b[LNbeta:corona_conspiracy]=0) (_b[LNbeta:_cons]=1)
}

*==================================*
* Wald tests reported in Table A10 *
*==================================*
estimates restore corona_restrict_rdu_expo
test (_b[LNalpha:1.gender]=_b[LNalpha:age]=_b[LNalpha:1.nosmoke]=_b[LNalpha:3.corona_social_dist]=_b[LNalpha:4.corona_social_dist]=_b[LNalpha:5.corona_social_dist]=_b[LNalpha:2.corona_highrisk]=_b[LNalpha:corona_stress]=_b[LNalpha:corona_conspiracy]) (_b[LNalpha:_cons]=1) (_b[LNbeta:1.gender]=_b[LNbeta:age]=_b[LNbeta:1.nosmoke]=_b[LNbeta:3.corona_social_dist]=_b[LNbeta:4.corona_social_dist]=_b[LNbeta:5.corona_social_dist]=_b[LNbeta:2.corona_highrisk]=_b[LNbeta:corona_stress]=_b[LNbeta:corona_conspiracy]=0) (_b[LNbeta:_cons]=1)

estimates restore corona_restrict_rdu_hyper
test (_b[LNalpha:1.gender]=_b[LNalpha:age]=_b[LNalpha:1.nosmoke]=_b[LNalpha:3.corona_social_dist]=_b[LNalpha:4.corona_social_dist]=_b[LNalpha:5.corona_social_dist]=_b[LNalpha:2.corona_highrisk]=_b[LNalpha:corona_stress]=_b[LNalpha:corona_conspiracy]) (_b[LNalpha:_cons]=1) (_b[LNbeta:1.gender]=_b[LNbeta:age]=_b[LNbeta:1.nosmoke]=_b[LNbeta:3.corona_social_dist]=_b[LNbeta:4.corona_social_dist]=_b[LNbeta:5.corona_social_dist]=_b[LNbeta:2.corona_highrisk]=_b[LNbeta:corona_stress]=_b[LNbeta:corona_conspiracy]=0) (_b[LNbeta:_cons]=1)


* Chow tests reported in Footnote 22
qui do chow_estim.do // Chow tests with wave dummies
do chow_transform.do

*===================*
* Tables A1, A2, A3 *
*===================*
do label_risk_time.do

ologit time1 i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m1
ologit time2 i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m2
regress bis i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m3
ologit risk i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m4
regress riskinvest i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m5
regress dospert i.wave i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m6

ologit time1 ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m7
ologit time2 ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m8
regress bis ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m9
ologit risk ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m10
regress riskinvest ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m11
regress dospert ib1.events i.gender cases_adj deaths_adj if nchoice==1, cluster(id)
estimates store m12

ologit time1 i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc1
ologit time2 i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc2
regress bis i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc3
ologit risk i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc4
regress riskinvest i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc5
regress dospert i.gender cases_adj deaths_adj i.corona_social_dist i.corona_highrisk corona_stress corona_conspiracy if nchoice==1, robust
estimates store mc6

* Table A1
esttab m1 m2 m3 m4 m5 m6 using tempregw.tex, b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood" "r2 R^2" "r2_a R^2-adjusted") nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 1.gender "~~Males" cases_adj "~~N of cases/100K population" deaths_adj "~~N of deaths/100K population") order(_cons) type

* Table A2
esttab m7 m8 m9 m10 m11 m12 using tempregev.tex, b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood" "r2 R^2" "r2_a R^2-adjusted") nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 1.gender "~~Males" cases_adj "~~N of cases/100K population" deaths_adj "~~N of deaths/100K population") order(_cons) type

* Table A3
esttab mc1 mc2 mc3 mc4 mc5 mc6 using tempw3reg.tex, b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood" "r2 R^2" "r2_a R^2-adjusted") nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 1.gender "~~Males" cases_adj "~~N of cases/100K population" deaths_adj "~~N of deaths/100K population" 3.corona_social_dist "~~Neither inefficient, nor efficient" 4.corona_social_dist "~~Efficient" 5.corona_social_dist "~~Very efficient" 2.corona_highrisk "~~Close ones in high risk group" corona_stress "~~Coronavirus stress score" corona_conspiracy "~~Conspiracy theories score") order(_cons) type


* DiD reported inline in the last paragraph of the Results section
encode city, gen(cities)
gen inathens=(cities==6 | cities==28)
table inathens wave if nchoice==1
di 257/(55+257)
di 302/(19+302)
di 298/(60+298)

* EUT
global index CL
global risk linear 
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.wave#c.cases_adj i.gender)  (muRA: ) (kappaD: i.wave i.wave#c.cases_adj i.gender) (muDR: ) if dominated==1 & gender~=. & cases_adj~=. & deaths_adj~=. & city!="Abroad", maximize difficult missing cluster(id) 
ml display

* RDU
global index CL
global risk gprelec
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.wave#c.cases_adj i.gender) (LNalphapr: i.wave i.wave#c.cases_adj i.gender) (LNbetapr: i.wave i.wave#c.cases_adj i.gender) (muRA: ) (kappaD: i.wave i.wave#c.cases_adj i.gender) (muDR: ) if dominated==1 & gender~=. & cases_adj~=. & deaths_adj~=. & city!="Abroad", maximize difficult missing cluster(id) 
ml display
estimates store didwaves

estimates restore didwaves
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  0) ///
			(b2:  exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.wave])-exp([LNalphapr]_b[_cons])) ///
			(b3:  exp([LNalphapr]_b[_cons]+[LNalphapr]_b[41.wave])-exp([LNalphapr]_b[_cons])) ///
			(b4:  0) ///
			(b5:  exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.wave#c.cases_adj])-exp([LNalphapr]_b[_cons])) ///
			(b6:  exp([LNalphapr]_b[_cons]+[LNalphapr]_b[41.wave#c.cases_adj])-exp([LNalphapr]_b[_cons])) ///			
			(b7: 0) ///
			(b8: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[1.gender])-exp([LNalphapr]_b[_cons])) ///
			(b9: exp([LNalphapr]_b[_cons])) ///		
			(b10:  0) ///
			(b11:  exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.wave])-exp([LNbetapr]_b[_cons])) ///
			(b12:  exp([LNbetapr]_b[_cons]+[LNbetapr]_b[41.wave])-exp([LNbetapr]_b[_cons])) ///
			(b13:  0) ///
			(b14:  exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.wave#c.cases_adj])-exp([LNbetapr]_b[_cons])) ///
			(b15:  exp([LNbetapr]_b[_cons]+[LNbetapr]_b[41.wave#c.cases_adj])-exp([LNbetapr]_b[_cons])) ///			
			(b16: 0) ///
			(b17: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[1.gender])-exp([LNbetapr]_b[_cons])) ///
			(b18: exp([LNbetapr]_b[_cons]))	
	matrix temp=vecdiag(r(V))
			matrix b[1,10]=r(b)
			matrix V[1,10]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store didwaves_rescl

log close