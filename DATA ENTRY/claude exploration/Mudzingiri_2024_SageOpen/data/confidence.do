
use confidence

*****************************************************
*correlation
****************************************************
corr risk_conf  finpercent  fin_conf female age urban lincome  family_members fconfidence tolerance  
pcorr risk_conf  finpercent  fin_conf female age urban lincome  family_members fconfidence tolerance


ci means safe  rperception finpercent finpp risk_conf fin_conf  female age urban expenditure family_members fconfidence tolerance


  
 ***********************************************************************
 ***risk confidence and financial literacy confidence histogram
 ******************************************************************
 
 histogram risk_conf, discrete width(1) percent xtitle(risk confidence deviations) title( Financial risk confidence)
 
 histogram fin_conf, discrete width(1) percent xtitle(financial literacy confidence deviations) title(financial literacy confidence)
 
 
 ****cumlative curves***
 *cumul ltolerance , generate(ltolerance_cdf1) 
*cumul lconfidence, generate(lconfidence_cdf1)
//We can then compare the cdfs of the imputed and non-imputed household expenditure variables: 
*twoway (line ltolerance_cdf1 ltolerance , sort) (line lconfidence_cdf1 lconfidence, sort) 

cumul safe , generate(safe_cdf1) 
cumul rperception, generate(rp_cdf1)
//We can then compare the cdfs of the imputed and non-imputed household expenditure variables: 
twoway (line safe_cdf1 safe , sort) (line rp_cdf1 rperception, sort) 

cumul finpercent , generate(finpercent_cdf1) 
cumul finpp  , generate(finpp_cdf1)
//We can then compare the cdfs of the imputed and non-imputed household expenditure variables: 
twoway (line finpercent_cdf1 finpercent , sort) (line finpp_cdf1 finpp, sort) 

//What is our conclusion?
 
 
 ***crosstabulations*****
 sum, d
 
 
 
 **** ttest******
 
 ttest risk_conf,by(female)
 
 ttest tolerance, by(female)
 
 ttest safe,by(female)
 
 ttest rperception,by(female)
 
  ttest safe == rperception
  
 ttest fin_conf,by(female)
  
 ttest finpercent == finpp
 
 ttest finpp,by(female)
 
 ttest finpercent,by(female)
 
 ttest risk_conf,by(literacy_dummy)
 
 ttest fin_conf, by(literacy_dummy)
 
 
  
 ttest fconfidence, by(female)
   
 ttest tolerance,by(literacy_dummy)
 
 ttest fconfidence, by(literacy_dummy)
 
 
 *ttest rperception == risk, unpaired
 
 *ttest finpercent == finpp, unpaired
 
    gen literacy_dummy=.
  replace literacy_dummy=1 if fin_literacy>12
   
   replace literacy_dummy=0 if fin_literacy<=12
 
 
 
 
 

****************************************************************
* Financial risk tolerance and financial literacy confidence deviations combined
****************************************************************
xtset game

  
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , re vce (robust)
 eststo a2, title(male)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , re vce (robust)
 eststo a3, title(female)
 
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Actual financial risk preferences confidence dependent ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re

****************************************************************
* Financial risk preferences residuals and financial literacy residuals hierarchical regression r is 'risk preferences residuals'
*rf is 'financial literacy residuals'
****************************************************************
xtset game

  
  xtreg r c.rf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg r c.rf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , re vce (robust)
 eststo a2, title(male)
 
  xtreg r c.rf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , re vce (robust)
 eststo a3, title(female)
 
 xtreg r c.rf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg r c.rf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg r c.rf  i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Financial risk preferences residuals dependent ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re

 ****************************************************************
* Financial risk tolerance and financial literacy confidence deviations less confident (confidence<0)
****************************************************************
xtset game

  
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if risk_conf<0 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 & risk_conf<0, re vce (robust)
 eststo a2, title(male)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2 & risk_conf<0 , re vce (robust)
 eststo a3, title(female)
 
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12& risk_conf<0 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12 & risk_conf<0 , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 if risk_conf<0, re  vce (robust) 
 eststo a6, title(All)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Financial risk lessconfident dependant variable ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re


 ****************************************************************
* Financial risk tolerance and financial literacy confidence deviations over confident(confidence>0)
****************************************************************
xtset game

  
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if risk_conf>0 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 & risk_conf>0, re vce (robust)
 eststo a2, title(male)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2 & risk_conf>0 , re vce (robust)
 eststo a3, title(female)
 
 xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12& risk_conf>0 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12 & risk_conf>0 , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 if risk_conf>0, re  vce (robust) 
 eststo a6, title(All)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Financial risk overconfidence dependant variable ) /// 
nonumbers mtitles replace	

****************************************************************
* Financial risk tolerance and financial literacy confidence absolute values
****************************************************************
xtset game

  
  xtreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , re vce (robust)
 eststo a2, title(male)
 
  xtreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , re vce (robust)
 eststo a3, title(female)
 
 xtreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg ltolerance c.lconfidence  i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Absolute financial risk preferences confidence ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re

****************************************************************
* Financial risk tolerance and financial literacy confidence absolute values plus linear fconfidence
****************************************************************
xtset game

  
  xtreg ltolerance c.fin_conf c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a1, title(All)
  
 xtreg ltolerance c.fin_conf c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , re vce (robust)
 eststo a2, title(male)
 
  xtreg ltolerance c.fin_conf c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , re vce (robust)
 eststo a3, title(female)
 
 xtreg ltolerance c.fin_conf c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,re vce (robust)
 eststo a4, title(high fin lit)
 
  xtreg ltolerance c.fin_conf c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , re vce (robust)
 eststo a5, title(low fin lit)
 
  xtreg ltolerance c.fin_conf c.lconfidence  i.g1 i. g2 i.g3 i.g4 , re  vce (robust) 
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( RE Panel Regression : Absolute financial risk preferences confidence ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re



****************************************************************
* Financial risk tolerance and financial literacy confidence deviations quantile 0.25
****************************************************************
xtset game

  
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.25) 
 eststo a1, title(All)
  
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , quantile (.25)
 eststo a2, title(male)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , quantile (.25)
 eststo a3, title(female)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,quantile (.25)
 eststo a4, title(high fin lit)
 
  bsqreg ltolerance c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , quantile (.25)
 eststo a5, title(low fin lit)
 
  bsqreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 , quantile (.25)
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( 25th quantile Regression : Financial risk preferences confidence dependant variable ) /// 
nonumbers mtitles replace	

 xttest0 
estimate store re

****************************************************************
* Financial risk tolerance and financial literacy confidence deviations quantile 0.5
****************************************************************
xtset game

  
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.5  )  
 eststo a1, title(All)
  
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , quantile (.5)
 eststo a2, title(male)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , quantile (.5)
 eststo a3, title(female)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,quantile (.5)
 eststo a4, title(high fin lit)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , quantile (.5)
 eststo a5, title(low fin lit)
 
  bsqreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 , quantile (.5)
 eststo a6, title(V-interest)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap 50th quantile Regression : Financial risk preferences confidence dependant variable ) /// 
nonumbers mtitles replace	

****************************************************************
* Financial risk tolerance and financial literacy confidence deviations quantile 0.75
****************************************************************
xtset game

  
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.75) 
 eststo a1, title(All)
  
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , quantile (.75)
 eststo a2, title(male)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , quantile (.75)
 eststo a3, title(female)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,quantile (.75)
 eststo a4, title(high fin lit)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , quantile (.75)
 eststo a5, title(low fin lit)
 
  bsqreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 , quantile (.75)
 eststo a6, title(All)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title(bootstrap 75th quantile Regression : Financial risk preferences confidence dependant variable) /// 
nonumbers mtitles replace 

***************************************************************
* Financial risk tolerance and financial literacy confidence deviations quantile 0.9
****************************************************************
xtset game

  
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.9) 
 eststo a1, title(All)
  
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==1 , quantile (.9)
 eststo a2, title(male)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if gender==2  , quantile (.9)
 eststo a3, title(female)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy>12 ,quantile (.9)
 eststo a4, title(high fin lit)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 if fin_literacy<=12  , quantile (.9)
 eststo a5, title(low fin lit)
 
  bsqreg risk_conf c.fin_conf  i.g1 i. g2 i.g3 i.g4 , quantile (.9)
 eststo a6, title(All)
 
 esttab a1 a2 a3 a4 a5 a6 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap 90th quantile Regression : Financial risk preferences confidence dependant variable ) /// 
nonumbers mtitles replace 



**********************************************************************
*bootstrap quantile regression
*********************************************************************

bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (1.0  ) reps(500) 
 eststo q0, title(OLS)
 
  bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.25  ) reps(500) 
 eststo q1, title(q25)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile ( .5  ) reps(500) 
 eststo q2, title(q50)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.75 ) reps(500) 
 eststo q3, title(q75)
 
 bsqreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile ( .9 ) reps(500) 
 eststo q4, title(q90)
  
esttab q0 q1 q2 q3 q4  using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap quantile Regression : Comparison across q25, q50, q75 and q90 ) /// 
nonumbers mtitles replace


**********************************************************************
* quantile regression
*********************************************************************

 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.1  ) 
 eststo q1, title(q10)

  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.2  ) 
 eststo q2, title(q20)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.3  ) 
 eststo q3, title(q30)
 
 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile ( .4  )  
 eststo q4, title(q40)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.5  ) 
 eststo q5, title(q50)
 
 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.6 ) 
 eststo q6, title(q60)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.7  ) 
 eststo q7, title(q70)
 
 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile ( .8 ) 
 eststo q8, title(q80)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.9  ) 
 eststo q9, title(q90)
  
esttab q1 q2 q3 q4 q5 q6 q7 q8 q9 using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap quantile Regression : Comparison across q20, q40, q60 and q80 ) /// 
nonumbers mtitles replace


**********************************************************************
* quantile regression
*********************************************************************

 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (1  ) 
 eststo q0, title(OLS)

  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.1  ) 
 eststo q1, title(q10)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.25  ) 
 eststo q2, title(q25)
 
 qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile ( .5  )  
 eststo q3, title(q50)
 
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.75  ) 
 eststo q4, title(q75)
  
  qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4 , quantile (.9  ) 
 eststo q5, title(q90)
  
esttab q0 q1 q2 q3 q4 q5  using fin_status1.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Quantile Regression : Comparison across OLS, q10, q25, q50 q75 and q90 ) /// 
nonumbers mtitles replace



**********************************************************************
*bootstrap quantile regression Main variables
*********************************************************************

  bsqreg risk_conf c.fin_conf  , quantile (1 ) reps(500) 
 eststo q0, title(OLS)
 
 bsqreg risk_conf c.fin_conf  , quantile ( .1 ) reps(500) 
 eststo q1, title(q10)
 
 bsqreg risk_conf c.fin_conf , quantile (.25) reps(500) 
 eststo q2, title(q25)
 
 bsqreg risk_conf c.fin_conf , quantile ( .5) reps(500) 
 eststo q3, title(q50)
 
 bsqreg risk_conf c.fin_conf , quantile ( .75)reps(500) 
 eststo q4,title(q75)
 
 bsqreg risk_conf c.fin_conf , quantile ( .9)reps(500) 
 eststo q5,title(q90)
 
 
  
esttab q0 q1 q2 q3 q4 q5  using confidence.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap quantile Regression : Comparison across q25, q50, q75 and q90 ) /// 
nonumbers mtitles replace

**********************************************************************
*bootstrap quantile regression Main variables
*********************************************************************

  bsqreg risk_conf c.fin_conf  , quantile (.1 ) 
 eststo q1, title(q10)
 
 bsqreg risk_conf c.fin_conf  , quantile ( .2 ) 
 eststo q2, title(q20)
 
 bsqreg risk_conf c.fin_conf , quantile (.3) 
 eststo q3, title(q30)
 
 bsqreg risk_conf c.fin_conf , quantile ( .4) 
 eststo q4, title(q40)
 
 bsqreg risk_conf c.fin_conf , quantile ( .5) 
 eststo q5,title(q50)
 
 bsqreg risk_conf c.fin_conf , quantile ( .6) 
 eststo q6,title(q60)
 
 bsqreg risk_conf c.fin_conf , quantile ( .7) 
 eststo q7,title(q70)
 
 bsqreg risk_conf c.fin_conf , quantile ( .8)
 eststo q8,title(q80)
 
 bsqreg risk_conf c.fin_conf , quantile ( .97)
 eststo q9,title(q90)
 
  
esttab q1 q2 q3 q4 q5 q6 q7 q8 q9 using confidence.rtf, r2 star(* 0.10 ** 0.05 *** 0.01) se(3) b(a2) compress ///*The compress option reduces horizontal spacing to fit more models on screen without line breaking*/
title( Bootstrap quantile Regression : Comparison across q25, q50, q75 and q90 ) /// 
nonumbers mtitles replace

************************************************************
***interquantile 
********************************************************

iqreg risk_conf c.fin_conf, quantile (0.2 0.8) reps(500)
 
 iqreg risk_conf c.fin_conf, quantile (0.2 0.6) reps(500)
 
 iqreg risk_conf c.fin_conf, quantile (0.2 0.4) reps(500)
 
 iqreg risk_conf c.fin_conf, quantile (0.4 0.8) reps(500)
 
 iqreg risk_conf c.fin_conf, quantile (0.4 0.60) reps(500)
 iqreg risk_conf c.fin_conf, quantile (0.6 0.8) reps(500)
 
 
 
 iqreg risk_conf c.fin_conf, quantile (0.1 0.6) reps(500)
 
 iqreg risk_conf c.fin_conf, quantile (0.2 0.9) reps(500)

************************************************************
*quintile regression***
***************************************

*xtset game

  
  *qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily  i.g1 i. g2 i.g3 i.g4 if risk_conf<0
  
  * qreg risk_conf c.fin_conf i.female c.lage i.urban c.lincome  c.lfamily  i.g1 i. g2 i.g3 i.g4 if risk_conf>0
  
  *quietly test [q0.25]TG=[q0.50]TG
  
 * i.g1 i. g2 i.g3 i.g4 , quintile (0.25 0.5 0.75) 
 * re  vce (robust) 
 *eststo a1, title(All)
 
 *qreg ltolerance c.lconfidence i.female c.lage i.urban c.lincome  c.lfamily i.g1 i. g2 i.g3 i.g4, quantile (.5) 
 
 
 
 
 *, quintile (0.25 0.5 0.75) 
 *eststo a1, title(All)
 
 *************************
 *Sevias Commands
 **************************
 
 *simultaneous quantile regressions, sqreg & interquantile regression, iqreg – models:
*xi: sqreg depvar indepvars, nolog quantile (0.25 0.50 0.75) reps(500)
*or 
*xi: sqreg depvar indepvars, quantile (0.25 0.50 0.75) reps(500)
*postestimation tests are:
*quietly test [q25]TG = [q50]TG
*test [q25]TG = [q75]TG, accumulate

*and 

*xi: iqreg depvar indepvars, nolog quantile (.25 .75) reps(500)
*or 
*xi: iqreg depvar indepvars, quantile (.25 .75) reps(500)


 
 