*==============================================================================================================*
* Estimates for subsamples: Exponential vs Hyperbolic, linear vs Generalized Prelec, for risk/time preferences *
*==============================================================================================================*
* Sample restricted to those that participated to at least TWO waves
preserve
keep if refvalue!=50
levelsof AM, local(levels) 
foreach m of local levels {
qui sum dominated if AM==`m' & refvalue!=50
if r(mean)!=1 & r(N)>0 {
qui recode dominated (1=0) if AM==`m'
} 
}
do gprelec_Expo_Hyper_subsamples.do
	*==========*
	* Table A4 *
	*==========*
esttab wv_linear_Expo_subsmpl wv_gprelec_Expo_subsmpl ev_linear_Expo_subsmpl ev_gprelec_Expo_subsmpl using tempexpo23.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
	*==========*
	* Table A5 *
	*==========*
esttab  wv_linear_Hyper_subsmpl wv_gprelec_Hyper_subsmpl ev_linear_Hyper_subsmpl ev_gprelec_Hyper_subsmpl using temphyper23.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
restore
	*=======================================*
	* Wald tests reported in Tables Α4 & Α5 *
	*=======================================*
do Waldtests_subsamples.do

* Sample restricted to those that participated to at all THREE waves
preserve
keep if refvalue==150
levelsof AM, local(levels) 
foreach m of local levels {
qui sum dominated if AM==`m' & refvalue!=50
if r(mean)!=1 & r(N)>0 {
qui recode dominated (1=0) if AM==`m'
} 
}
do gprelec_Expo_Hyper_subsamples.do
	*==========*
	* Table A6 *
	*==========*
esttab wv_linear_Expo_subsmpl wv_gprelec_Expo_subsmpl ev_linear_Expo_subsmpl ev_gprelec_Expo_subsmpl using tempexpo3.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
	*==========*
	* Table A7 *
	*==========*
esttab  wv_linear_Hyper_subsmpl wv_gprelec_Hyper_subsmpl ev_linear_Hyper_subsmpl ev_gprelec_Hyper_subsmpl using temphyper3.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
restore
	*=======================================*
	* Wald tests reported in Tables Α6 & Α7 *
	*=======================================*
do Waldtests_subsamples.do

* Sample restricted to those that accepted the electronic bank transfer
preserve
keep if acceptpayment==1
do gprelec_Expo_Hyper_subsamples.do
	*==========*
	* Table A8 *
	*==========*
esttab wv_linear_Expo_subsmpl wv_gprelec_Expo_subsmpl ev_linear_Expo_subsmpl ev_gprelec_Expo_subsmpl using tempexpo_acceptpay.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
	*==========*
	* Table A9 *
	*==========*
esttab  wv_linear_Hyper_subsmpl wv_gprelec_Hyper_subsmpl ev_linear_Hyper_subsmpl ev_gprelec_Hyper_subsmpl using temphyper_acceptpay.tex, wide b(%9.3f) se star(* 0.1 ** 0.05 *** 0.01) nonotes addnotes(Standard errors in parentheses. * p$<$0.1, ** p$<$0.05 *** p$<$0.01) scalars("ll Log-likelihood") sfmt(%9.2f) nogaps noeqline nobase replace coeflabel(_cons "~~Constant" 4.wave "~~2020A wave" 41.wave "~~2020B wave" 2.events "~~Before first case" 3.events "~~Before first death" 4.events "~~Before curfew" 5.events "~~Curfew starts" 6.events "~~Curfew announced relaxation") order(_cons) type
restore
	*=======================================*
	* Wald tests reported in Tables Α8 & Α9 *
	*=======================================*
do Waldtests_subsamples.do