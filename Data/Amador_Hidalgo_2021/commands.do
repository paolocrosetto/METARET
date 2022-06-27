
use "data file.dta", clear

*******************************************************************************
***VARIABLE DEFINITION*********************************************************
*******************************************************************************

**CABS*************************************************************************

rename tfc1_correctas sums
rename tfc2 expectsums

***diference between expected sums and sums
gen overconfidence=expectsums-sums



***CRT
**Cognitive reflection test (r stands for reflective/correct answer, i stands for intuitive/incorrect answer)
**reflective/correct answers
gen crt1r=1 if crt1_1==25
replace crt1r=0 if crt1_1!=25 & crt1_1<22222

gen crt2r=1 if crt1_2==10
replace crt2r=0 if crt1_2!=10 & crt1_2<22222

gen crt3r=1 if crt1_3==35
replace crt3r=0 if crt1_3!=35 & crt1_3<22222

gen crt4r=1 if crt1_4==4
replace crt4r=0 if crt1_4!=4 & crt1_4<22222

gen crt5r=1 if crt1_5==49
replace crt5r=0 if crt1_5!=49 & crt1_5<22222

gen crt6r=1 if crt1_6==20
replace crt6r=0 if crt1_6!=20 & crt1_6<22222

gen crt7r=1 if crt1_7==2
replace crt7r=0 if crt1_7!=2 & crt1_7<22222

**intuitive/incorrect answers
gen crt1i=1 if crt1_1==50
replace crt1i=0 if crt1_1!=50 & crt1_1<22222

gen crt2i=1 if crt1_2==80
replace crt2i=0 if crt1_2!=80 & crt1_2<22222

gen crt3i=1 if crt1_3==18
replace crt3i=0 if crt1_3!=18 & crt1_3<22222

gen crt4i=1 if crt1_4==9
replace crt4i=0 if crt1_4!=9 & crt1_4<22222

gen crt5i=1 if crt1_5==50
replace crt5i=0 if crt1_5!=50 & crt1_5<22222

gen crt6i=1 if crt1_6==10
replace crt6i=0 if crt1_6!=10 & crt1_6<22222

gen crt7i=1 if crt1_7==1
replace crt7i=0 if crt1_7!=1 & crt1_7<22222

*Reflective = Total correct answers in CRT 
gen reflective=crt1r+crt2r+crt3r+crt4r+crt5r+crt6r+crt7r

*Intuitive = Total intuitive answers in CRT 
gen intuitive=crt1i+crt2i+crt3i+crt4i+crt5i+crt6i+crt7i


***RAT QUESTIONS*************

gen algo=0
replace algo=1 if rat_t1!=. | rat_t2!=.  | rat_t3!=. | rat_t4!=. | rat_t5!=. | rat_t6!=. | rat_t7!=. | rat_t8!=. | rat_t9!=. | rat_t10!=. | rat_t11!=. | rat_t12!=. | rat_t13!=.

gen rat1_correct=0 if algo==1
replace rat1_correct=1 if rat_r1=="PINZA"
replace rat1_correct=1 if rat_r1=="PINZAS"
replace rat1_correct=1 if rat_r1=="PInzas"
replace rat1_correct=1 if rat_r1=="Pinza"
replace rat1_correct=1 if rat_r1=="Pinzas"
replace rat1_correct=1 if rat_r1=="pinza"
replace rat1_correct=1 if rat_r1=="pinzas"
replace rat1_correct=1 if rat_r1=="piza"

gen rat2_correct=0 if algo==1
replace rat2_correct=1 if rat_r2=="OSO"
replace rat2_correct=1 if rat_r2=="Oso"
replace rat2_correct=1 if rat_r2=="Oso "
replace rat2_correct=1 if rat_r2=="Oso polar"
replace rat2_correct=1 if rat_r2=="oso"
replace rat2_correct=1 if rat_r2=="oso polar"
replace rat2_correct=1 if rat_r2=="osos"


gen rat3_correct=0 if algo==1
replace rat3_correct=1 if rat_r3=="LIBRO"
replace rat3_correct=1 if rat_r3=="LIBROS"
replace rat3_correct=1 if rat_r3=="Libro"
replace rat3_correct=1 if rat_r3=="Libros"
replace rat3_correct=1 if rat_r3=="libro"
replace rat3_correct=1 if rat_r3=="libros"


gen rat4_correct=0 if algo==1
replace rat4_correct=1 if rat_r4=="LATA"
replace rat4_correct=1 if rat_r4=="Lata"
replace rat4_correct=1 if rat_r4=="Latas "
replace rat4_correct=1 if rat_r4=="lata"
replace rat4_correct=1 if rat_r4=="lata "
replace rat4_correct=1 if rat_r4=="latas"


gen rat5_correct=0 if algo==1
replace rat5_correct=1 if rat_r5=="GALLETA"
replace rat5_correct=1 if rat_r5=="GALLETAS"
replace rat5_correct=1 if rat_r5=="Galleta"
replace rat5_correct=1 if rat_r5=="Galletas"
replace rat5_correct=1 if rat_r5=="galleta"
replace rat5_correct=1 if rat_r5=="galletas"


gen rat6_correct=0 if algo==1
replace rat6_correct=1 if rat_r6=="QUESO"
replace rat6_correct=1 if rat_r6=="Queso"
replace rat6_correct=1 if rat_r6=="queso"


gen rat7_correct=0 if algo==1
replace rat7_correct=1 if rat_r7=="MEMORIA"
replace rat7_correct=1 if rat_r7=="Memoria"
replace rat7_correct=1 if rat_r7=="memoria"


gen rat8_correct=0 if algo==1
replace rat8_correct=1 if rat_r8=="REGALO"
replace rat8_correct=1 if rat_r8=="REGALOS"
replace rat8_correct=1 if rat_r8=="Regalo"
replace rat8_correct=1 if rat_r8=="regalo"
replace rat8_correct=1 if rat_r8=="regalos"

gen rat9_correct=0 if algo==1
replace rat9_correct=1 if rat_r9=="CERBEZA"
replace rat9_correct=1 if rat_r9=="CERVEZA"
replace rat9_correct=1 if rat_r9=="Cerveza"
replace rat9_correct=1 if rat_r9=="cerveza"


gen rat10_correct=0 if algo==1
replace rat10_correct=1 if rat_r10=="BANCO"
replace rat10_correct=1 if rat_r10=="Banco"
replace rat10_correct=1 if rat_r10=="banco"


gen rat11_correct=0 if algo==1
replace rat11_correct=1 if rat_r11=="CRISTAL"
replace rat11_correct=1 if rat_r11=="Cristal"
replace rat11_correct=1 if rat_r11=="crisal"
replace rat11_correct=1 if rat_r11=="cristal"
replace rat11_correct=1 if rat_r11=="cristal "
replace rat11_correct=1 if rat_r11=="cristal/vidreo"
replace rat11_correct=1 if rat_r11=="cristales"
replace rat11_correct=1 if rat_r11=="cristsal"
replace rat11_correct=1 if rat_r11=="VIDRIO"
replace rat11_correct=1 if rat_r11=="vidrio"
replace rat11_correct=1 if rat_r11=="vidrío"


gen rat12_correct=0 if algo==1
replace rat12_correct=1 if rat_r12=="POMPA"
replace rat12_correct=1 if rat_r12=="POMPAS"
replace rat12_correct=1 if rat_r12=="Pompa"
replace rat12_correct=1 if rat_r12=="Pompas"
replace rat12_correct=1 if rat_r12=="pompa"
replace rat12_correct=1 if rat_r12=="pompa "
replace rat12_correct=1 if rat_r12=="pompas"
replace rat12_correct=1 if rat_r12=="pompas de jabón"


gen rat13_correct=0 if algo==1
replace rat13_correct=1 if rat_r13=="MAQUINA"
replace rat13_correct=1 if rat_r13=="MAQUINA "
replace rat13_correct=1 if rat_r13=="MAQUINAS"
replace rat13_correct=1 if rat_r13=="Maquina"
replace rat13_correct=1 if rat_r13=="MÁQUINA"
replace rat13_correct=1 if rat_r13=="Máquina"
replace rat13_correct=1 if rat_r13=="maquina"
replace rat13_correct=1 if rat_r13=="maquina "
replace rat13_correct=1 if rat_r13=="maquinas"
replace rat13_correct=1 if rat_r13=="máquina"
replace rat13_correct=1 if rat_r13=="máquina "
replace rat13_correct=1 if rat_r13=="máquinas"

gen convergent=rat1_correct+rat2_correct+rat3_correct+rat4_correct+rat5_correct+rat6_correct+rat7_correct+rat8_correct+rat9_correct+rat10_correct+rat11_correct+rat12_correct+rat13_correct


**RTB*************************************************************************

**number of risky choices
gen nrisky=rp1+rp2+rp3+rp4+rp5+rp6+rp7+rp8+rp9+rp10-10
**number of safe choices (risk_aversion)
gen risk_aversion=10-nrisky

**number of loss averse choices (loss_aversion)
gen loss_aversion=la1+la2+la3+la4+la5+la6-6


**Measures of noisy, inconsistent decision making

gen rpinconsistent=1 if rp2<rp1 | rp3<rp2 | rp4<rp3 | rp5<rp4 | rp6<rp5 | rp7<rp6 | rp8<rp7 | rp9<rp8 | rp10<rp9
replace rpinconsistent=1 if risk_aversion==10 
replace rpinconsistent=0 if rpinconsistent==. & nrisky<2222

rename rpinconsistent Rinconsistent

gen rpincon_1=0 if Rinconsistent==1
replace rpincon_1=1 if rp2<rp1 & Rinconsistent==1

gen rpincon_2=0 if Rinconsistent==1
replace rpincon_2=1 if rp3<rp2 & Rinconsistent==1

gen rpincon_3=0 if Rinconsistent==1
replace rpincon_3=1 if rp4<rp3 & Rinconsistent==1

gen rpincon_4=0 if Rinconsistent==1
replace rpincon_4=1 if rp5<rp4 & Rinconsistent==1

gen rpincon_5=0 if Rinconsistent==1
replace rpincon_5=1 if rp6<rp5 & Rinconsistent==1

gen rpincon_6=0 if Rinconsistent==1
replace rpincon_6=1 if rp7<rp6 & Rinconsistent==1

gen rpincon_7=0 if Rinconsistent==1
replace rpincon_7=1 if rp8<rp7 & Rinconsistent==1

gen rpincon_8=0 if Rinconsistent==1
replace rpincon_8=1 if rp9<rp8 & Rinconsistent==1

gen rpincon_9=0 if Rinconsistent==1
replace rpincon_9=1 if rp10<rp9 & Rinconsistent==1


gen time_Rinconsistent=rpincon_1+rpincon_2+rpincon_3+rpincon_4+rpincon_5+rpincon_6+rpincon_7+rpincon_8+rpincon_9
replace time_Rinconsistent=0 if Rinconsistent==0

**for multinomial
gen type_incon=0 if Rinconsistent==0
replace type_incon=1 if time_Rinconsistent==0 & Rinconsistent==1
replace type_incon=2 if time_Rinconsistent==1 & Rinconsistent==1
replace type_incon=3 if time_Rinconsistent>1 & Rinconsistent==1
label define type_Rincon 0 "Consistent" 1 "Inconsistente+dominated" 2 "1 switch" 3 "more than 1 switch"
label values type_incon type_Rincon

**choose dominated option
gen dominada=0 if rp10!=.
replace dominada=1 if rp10==1

rename Rinconsistent rinconsistent


gen lainconsistent=1 if la2<la1 | la3<la2 | la4<la3 | la5<la4 | la6<la5
replace lainconsistent=0 if lainconsistent==. & loss_aversion<2222

rename lainconsistent Linconsistent


gen laincon_1=0 if Linconsistent==1
replace laincon_1=1 if la2<la1 & Linconsistent==1

gen laincon_2=0 if Linconsistent==1
replace laincon_2=1 if la3<la2 & Linconsistent==1

gen laincon_3=0 if Linconsistent==1
replace laincon_3=1 if la4<la3 & Linconsistent==1

gen laincon_4=0 if Linconsistent==1
replace laincon_4=1 if la5<la4 & Linconsistent==1

gen laincon_5=0 if Linconsistent==1
replace laincon_5=1 if la6<la5 & Linconsistent==1


gen time_Linconsistent=laincon_1+laincon_2+laincon_3+laincon_4+laincon_5
replace time_Linconsistent=0 if Linconsistent==0

**for multinomial
gen type_Lincon=0 if Linconsistent==0
replace type_Lincon=1 if time_Linconsistent==1 & Linconsistent==1
replace type_Lincon=2 if time_Linconsistent>1 & Linconsistent==1
label define type_Lincon 0 "Consistent" 1 "1 switch" 2 "more than 1 switch"
label values type_Lincon type_Lincon

rename Linconsistent linconsistent






gen no_missing_1=0
replace no_missing_1=1 if missing(risk_aversion, loss_aversion, linconsistent, rinconsistent,sums, overconfidence, reflective, intuitive, convergent)==0
								

**Imputing missing values of income
reg nivel_ingresos i.region female edad [pweight=weight_stratified] if no_missing==1 
predict incomepred if nivel_ingresos==.
replace nivel_ingresos=incomepred if nivel_ingresos==.




********************************************************************************
*****TABLE 1. DESCRIPTIVE TABLE
********************************************************************************
sum sums reflective intuitive convergent [weight=weight_stratified]  if no_missing_1==1 
sum expectsums overconfidence [weight=weight_stratified]  if no_missing_1==1 &  expectsums<=34.17 
sum risk_aversion loss_aversion rinconsistent linconsistent  [weight=weight_stratified]  if no_missing_1==1 
sum female nivel_ingresos edad [weight=weight_stratified]  if no_missing_1==1 


sum time_Rinconsistent time_Linconsistent dominada type_incon type_Lincon [weight=weight_stratified]  if no_missing_1==1 




**no reportadas
*tab time_Rinconsistent if no_missing_1==1
*tab type_incon if no_missing_1==1 
*tab dominada if no_missing_1==1 
*tab time_Linconsistent if no_missing_1==1
*tab type_Lincon if no_missing_1==1 

********************************************************************************+

********************************************************************************+
*****TABLE 2. ZERO ORDER PEARSON CORRELATIONS  
*****AT THE END******************
********************************************************************************+


***************************************************************
***FACTOR ANALYSIS FOR CABS***************************************
******************************************************************								
egen zsums=std(sums) if no_missing_1==1
egen zexpectsums=std(expectsums) if no_missing_1==1

factor crt1r-crt7r  rat1_correct-rat13_correct zsums zexpectsums [aweight=weight_stratified] if no_missing_1==1
predict factor1-factor8	

**factor loading of factor1 in Table A.1						
	
***************************************************************
***FACTOR ANALYSIS FOR RISK***************************************
******************************************************************								
gen rp1_bis=1 if rp1==1
replace rp1_bis=0 if rp1==2

gen rp2_bis=1 if rp2==1
replace rp2_bis=0 if rp2==2

gen rp3_bis=1 if rp3==1
replace rp3_bis=0 if rp3==2

gen rp4_bis=1 if rp4==1
replace rp4_bis=0 if rp4==2

gen rp5_bis=1 if rp5==1
replace rp5_bis=0 if rp5==2

gen rp6_bis=1 if rp6==1
replace rp6_bis=0 if rp6==2

gen rp7_bis=1 if rp7==1
replace rp7_bis=0 if rp7==2

gen rp8_bis=1 if rp8==1
replace rp8_bis=0 if rp8==2

gen rp9_bis=1 if rp9==1
replace rp9_bis=0 if rp9==2

gen rp10_bis=1 if rp10==1
replace rp10_bis=0 if rp10==2


factor 	rp1_bis-rp10_bis  [aweight=weight_stratified] if no_missing_1==1
predict risk1
**factor loading of risk1 in Table A.2						


***************************************************************
***FACTOR ANALYSIS FOR LOSS***************************************
******************************************************************								
factor 	la1-la6  [aweight=weight_stratified] if no_missing_1==1 
predict l1

**factor loading of la1 in Table A.3						




global control female  nivel_ingresos edad	


**TABLE 3 (Impact of CAfactor on the number of switchbacks in the RTB tasks and on the choice of the dominated option in the risk aversion task)
*******************************************************************************
reg time_Rinconsistent factor1  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent factor1 $control  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 

reg time_Linconsistent factor1  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent factor1 $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 

logit dominada factor1 if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada factor1 $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx


**TABLE 4 (Impact of CAfactor on inconsistency in the risk aversion task. Multinomial regression)
*******************************************************************************
**base grpup 0 (consistent)
mlogit type_incon factor1 if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(factor1)
**base group 1 (inconsistent+choose dominated option) 
mlogit type_incon factor1  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(factor1)
**base group 2 (1 switch)
mlogit type_incon factor1 if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(factor1)

**with controls
**base grpup 0 (consistent)
mlogit type_incon factor1 $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(factor1)
**base group 1 (inconsistent+choose dominated option) 
mlogit type_incon factor1 $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(factor1)
**base group 2 (1 switch)
mlogit type_incon factor1 $control if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(factor1)


**TABLE 5 (Impact of CAfactor on inconsistency in the loss aversion task. Multinomial regression)
*******************************************************************************

**base group 0 (consistent)
mlogit type_Lincon factor1  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(factor1)
**base group 1 (1 switch) 
mlogit type_Lincon factor1  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(factor1)

***with controls
**base group 0 (consistent)
mlogit type_Lincon factor1 $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(factor1)
**base group 1 (1 switch) 
mlogit type_Lincon factor1 $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(factor1)




**TAble 6. (SEM: Impact of CAfactor on risk/loss aversion mediated by Rinconsistent/Linconsistent)
***************************************************************
gsem (risk_aversion <- factor1)( risk_aversion <-rinconsistent )(rinconsistent <- factor1, logit) ///
     (loss_aversion <- factor1)( loss_aversion <-linconsistent )(linconsistent <- factor1, logit) ///
	 (loss_aversion <- risk_aversion) if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent 
margins, dydx(factor1)
gsem, coeflegend
**indirect effect of factor on risk aversion
display -0.07*0.64
nlcom  _b[rinconsistent:factor1]*_b[risk_aversion:rinconsistent]
**indirect effect of factor on loss via linconsistent
display -0.08*-0.53
nlcom  _b[linconsistent:factor1]*_b[loss_aversion:linconsistent]
**indirect effect of factor on loss via risk_aversion
display (-0.073*0.626-0.035)*0.061
nlcom (_b[rinconsistent:factor1]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:factor])*_b[loss_aversion:risk_aversion]
**indirect effect of Rinconsistent on loss via risk_aversion
display 0.626*0.061
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
**total effects 
regress risk_aversion factor1 if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
display -0.07*0.63-0.04
regress loss_aversion factor1 if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


***with controls
gsem (risk_aversion <- factor1 $control)( risk_aversion <-rinconsistent )(rinconsistent <- factor1, logit) (factor1<-$control) ///
     (loss_aversion <- factor1 $control)( loss_aversion <-linconsistent )(linconsistent <- factor1, logit) ///
	 (loss_aversion <- risk_aversion) if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(factor1)
gsem, coeflegend
**indirect effect of factor on risk aversion
display -0.07*0.62
nlcom  _b[rinconsistent:factor1]*_b[risk_aversion:rinconsistent]
**indirect effect of factor on loss via linconsistent
display -0.07*-0.51
nlcom  _b[linconsistent:factor1]*_b[loss_aversion:linconsistent]
**indirect effect of factor on loss via risk_aversion
display (-0.07*0.62-0.03)*0.06
nlcom (_b[rinconsistent:factor1]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:factor])*_b[loss_aversion:risk_aversion]
**indirect effect of Rinconsistent on loss via risk_aversion
display 0.62*0.06
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
**total effects 
regress risk_aversion factor1 $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion factor1 $control  if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


***TABLE 7 (SEM: Impact of CAfactor on RAfactor/LAfactor mediated by Rinconsistent/Linconsistent)
gsem (risk1 <- factor1)( risk1 <-rinconsistent )(rinconsistent <- factor1, logit) ///
     (l1 <- factor1)( l1 <-linconsistent )(linconsistent <- factor1, logit) ///
	 (l1 <- risk1) if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(factor1)
gsem, coeflegend
**indirect effect of factor on risk aversion
display -0.07*0.50
nlcom  _b[rinconsistent:factor1]*_b[risk1:rinconsistent]
**indirect effect of factor on loss via linconsistent
display -0.0754*-1.06
nlcom  _b[linconsistent:factor1]*_b[l1:linconsistent]
**indirect effect of factor on loss via risk_aversion
display (-0.07*0.50-0.01)*-0.01
nlcom (_b[rinconsistent:factor1]*_b[risk1:rinconsistent]+_b[risk1:factor])*_b[l1:risk1]
**indirect effect of Rinconsistent on loss via risk_aversion
display 0.50*-0.01
nlcom _b[risk1:rinconsistent]*_b[l1:risk1]
**total effects 
regress risk1 factor1  if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress l1 factor1   if no_missing_1==1 [pweight=weight_stratified], vce(robust) 

**With controls
gsem (risk1 <- factor1 $control)( risk1 <-rinconsistent )(rinconsistent <- factor1, logit) (factor1<-$control) ///
     (l1 <- factor1 $control)( l1 <-linconsistent )(linconsistent <- factor1, logit) ///
	 (l1 <- risk1) if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(factor1)
gsem, coeflegend
**indirect effect of factor on risk aversion
display -0.073*0.49
nlcom  _b[rinconsistent:factor1]*_b[risk1:rinconsistent]
**indirect effect of factor on loss via linconsistent
display -0.0755*-1.06
nlcom  _b[linconsistent:factor1]*_b[l1:linconsistent]
**indirect effect of factor on loss via risk_aversion
display (-0.073*0.49-0.01)*-0.01
nlcom (_b[rinconsistent:factor1]*_b[risk1:rinconsistent]+_b[risk1:factor])*_b[l1:risk1]
**indirect effect of Rinconsistent on loss via risk_aversion
display 0.49*-0.01
nlcom _b[risk1:rinconsistent]*_b[l1:risk1]
**total effects
regress risk1 factor1 $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress l1 factor1 $control  if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


********************************************************************************
****APPENDIX
********************************************************************************
***TABLE A.4 (Impact of Cabs on inconsistent decision making)
logit rinconsistent sums  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent sums $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent expectsums  if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent expectsums $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent overconfidence $control if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent reflective $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent intuitive if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent intuitive $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit rinconsistent convergent $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx


logit linconsistent sums if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent sums $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent expectsums if no_missing_1==1 & expectsums<=34.17 & expectsums>=-18.90 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent expectsums $control if no_missing_1==1 & expectsums<=34.17 & expectsums>=-18.90 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent overconfidence if no_missing_1==1 & expectsums<=34.17 & expectsums>=-18.90 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent overconfidence $control if no_missing_1==1 & expectsums<=34.17 & expectsums>=-18.90 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent reflective $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent intuitive if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent intuitive $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent convergent $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
*********************************************************************************


**TABLE A.5. (Regression analysis with all explanatory variables simultaneously. Impact of Cabs on inconsistent RTB)
********************************************************************************
logit rinconsistent sums expectsums reflective convergent if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent sums expectsums reflective convergent if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx


**wiht controls 
global control female nivel_ingresos edad
logit rinconsistent sums expectsums reflective convergent $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit linconsistent sums expectsums reflective convergent $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx




**TABLE A.6. (Impact of Cabs on the number of switchbacks in the RTB tasks)
****************************************************************************
**TABLE A.6, COLUMN 1 y 2
reg time_Rinconsistent sums  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent expectsums  if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent intuitive if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 

reg time_Rinconsistent sums $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent expectsums $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent overconfidence $control if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent reflective $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent intuitive $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent convergent $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 

**TABLE A.6, COLUMN 3 y 4
reg time_Linconsistent sums  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent expectsums  if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent intuitive if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 

reg time_Linconsistent sums $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent expectsums $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent overconfidence $control if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent reflective $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent intuitive $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent convergent $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


**TABLE A.7. Regression analysis with all explanatory variables simultaneously. Impact of Cabs on the number of switchbacks in the RTB tasks
****************************************************************************
reg time_Rinconsistent sums expectsums reflective convergent if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Rinconsistent sums expectsums reflective convergent $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 

reg time_Linconsistent sums expectsums reflective convergent if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
reg time_Linconsistent sums expectsums reflective convergent $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 



**TABLE A.8. Impact of Cabs on the choice of the dominated option in the risk aversion task
****************************************************************************
logit dominada sums  if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada expectsums  if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust)
mfx 
logit dominada overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
mfx
logit dominada reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit dominada intuitive if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx

logit dominada sums $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada expectsums $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada overconfidence $control if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
mfx
logit dominada reflective $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx
logit dominada intuitive $control if no_missing_1==1  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada convergent $control if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
mfx



**TABLE A.9. Regression analysis with all explanatory variables simultaneously. 
**Impact of Cabs on the choice of the dominated option in the risk aversion task
****************************************************************************
logit dominada sums expectsums reflective convergent if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx
logit dominada sums expectsums reflective convergent $control if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
mfx

**TABLE A.10. Impact of Cabs on inconsistency in the risk aversion task. Multinomial regression
****************************************************************************

**base group 0 (consistent)
mlogit type_incon sums  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
mlogit type_incon expectsums  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(convergent)

**base group 0 (consistent) with controls
mlogit type_incon sums $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
mlogit type_incon expectsums $control  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(convergent)


**base group 1 (inconsistent+choose dominated option) 
mlogit type_incon sums  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(sums)
mlogit type_incon expectsums  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(convergent)

**base group 1 (inconsistent+choose dominated option)  + controls
mlogit type_incon sums $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(sums)
mlogit type_incon expectsums $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(convergent)



**base group 2 (1 switch)
mlogit type_incon sums  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(sums)
mlogit type_incon expectsums  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(convergent)


**base group 2 (1 switch +controls)
mlogit type_incon sums $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(sums)
mlogit type_incon expectsums $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(expectsums)
mlogit type_incon overconfidence $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(overconfidence)
mlogit type_incon reflective $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(reflective)
mlogit type_incon intuitive $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(intuitive)
mlogit type_incon convergent $control  if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust) 
margins, dydx(convergent)


**TABLE A.11. Regression analysis with all explanatory variables simultaneously. 
**Impact of Cabs on inconsistency in the risk aversion task. Multinomial regression
********************************************************************************
mlogit type_incon sums expectsums reflective convergent if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_incon sums expectsums reflective convergent if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_incon sums expectsums reflective convergent if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)

**with controls
mlogit type_incon sums expectsums reflective convergent $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_incon sums expectsums reflective convergent $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_incon sums expectsums reflective convergent $control if no_missing_1==1  [pweight=weight_stratified], base(2) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)


**TABLE A.12. Impact of Cabs on inconsistency in the loss aversion task. Multinomial regression
*******************************************************************************

**base group 0 (consistent)
mlogit type_Lincon sums  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
mlogit type_Lincon expectsums  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(expectsums)
mlogit type_Lincon overconfidence  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(overconfidence)
mlogit type_Lincon reflective  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(reflective)
mlogit type_Lincon intuitive  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(intuitive)
mlogit type_Lincon convergent if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(convergent)

**base group 1 (1 switch) 
mlogit type_Lincon sums  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(sums)
mlogit type_Lincon expectsums  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(expectsums)
mlogit type_Lincon overconfidence  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(overconfidence)
mlogit type_Lincon reflective  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(reflective)
mlogit type_Lincon intuitive  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(intuitive)
mlogit type_Lincon convergent  if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(convergent)


**with controls
**base group 0 (consistent)
mlogit type_Lincon sums $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
mlogit type_Lincon expectsums $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(expectsums)
mlogit type_Lincon overconfidence $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(overconfidence)
mlogit type_Lincon reflective $control  if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(reflective)
mlogit type_Lincon intuitive $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(intuitive)
mlogit type_Lincon convergent $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust) 
margins, dydx(convergent)

**base group 1 (1 switch) 
mlogit type_Lincon sums $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(sums)
mlogit type_Lincon expectsums $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(expectsums)
mlogit type_Lincon overconfidence $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(overconfidence)
mlogit type_Lincon reflective $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(reflective)
mlogit type_Lincon intuitive $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(intuitive)
mlogit type_Lincon convergent $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust) 
margins, dydx(convergent)


**TABLE A.13. Regression analysis with all explanatory variables simultaneously. 
**Impact of Cabs on inconsistency in the loss aversion task. Multinomial regression
********************************************************************************
mlogit type_Lincon sums expectsums reflective convergent if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_Lincon sums expectsums reflective convergent if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)


**with controls
mlogit type_Lincon sums expectsums reflective convergent $control if no_missing_1==1  [pweight=weight_stratified], base(0) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)
mlogit type_Lincon sums expectsums reflective convergent $control if no_missing_1==1  [pweight=weight_stratified], base(1) vce(robust)
margins, dydx(sums)
margins, dydx(expectsums)
margins, dydx(reflective)
margins, dydx(convergent)



***TABLE A.14. SEM: Impact of sums on risk /loss aversion mediated by Rinconsistent/Linconsistent
*********************************************************************************
gsem (risk_aversion <- sums)( risk_aversion <-rinconsistent )(rinconsistent <- sums, logit) ///
     (loss_aversion <- sums)( loss_aversion <-linconsistent )(linconsistent <- sums, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
**what appears in table are the direct marginal effects (except for the logit)
**with the following command I obtain the direct marginal effect of sums on Rinconsistent
gsem, coeflegend
margins, dydx(sums)
*the marginal effect of the indirect effect is obtained by multiplying the marginal effect of sums on 
*Rinconsistent by the marginal effect of rinconsistent on risk aversion
display -.0006425* _b[risk_aversion:rinconsistent]
*its pvalue is calculated with command nlcom
nlcom  _b[rinconsistent:sums]*_b[risk_aversion:rinconsistent]
**indirect effect of sums on loss via linconsistent
display -.0076069*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:sums]*_b[loss_aversion:linconsistent]
**indirect effect of sums on loss via risk_aversion
display (-.0006425* _b[risk_aversion:rinconsistent])*_b[risk_aversion:sums]
nlcom (_b[rinconsistent:sums]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:sums])*_b[loss_aversion:risk_aversion]
**indirect effect of Rinconsistent on loss via risk
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
**Marginal effects of total effect
regress risk_aversion sums if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion sums if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


***with controls
global control female  nivel_ingresos edad	

gsem (risk_aversion <- sums $control)( risk_aversion <-rinconsistent )(rinconsistent <- sums, logit) (sums<-$control) ///
     (loss_aversion <- sums $control)( loss_aversion <-linconsistent )(linconsistent <- sums, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
gsem, coeflegend
margins, dydx(sums)
display -.0006425* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:sums]*_b[risk_aversion:rinconsistent]
display .00024*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:sums]*_b[loss_aversion:linconsistent]
display (-.0006425* _b[risk_aversion:rinconsistent])*_b[risk_aversion:sums]
nlcom (_b[rinconsistent:sums]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:sums])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion sums if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion sums if no_missing_1==1 [pweight=weight_stratified], vce(robust) 





***TABLE A.15. SEM: Impact of expect sums on risk/loss aversion mediated by Rinconsistent/Linconsistent
gsem (risk_aversion <- expectsums)( risk_aversion <-rinconsistent )(rinconsistent <- expectsums, logit) ///
     (loss_aversion <- expectsums)( loss_aversion <-linconsistent )(linconsistent <- expectsums, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(expectsums)
**indirect effect of expectsums on risk via rinconsistent
display -.0040999* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:expectsums]*_b[risk_aversion:rinconsistent]
**indirect effect of expectsums on loss via linconsistent
display  -.005627*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:expectsums]*_b[loss_aversion:linconsistent]
**indirect effect of expectsums on loss via risk_aversion
display (-.0040999* _b[risk_aversion:rinconsistent])*_b[risk_aversion:expectsums]
nlcom (_b[rinconsistent:expectsums]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:expectsums])*_b[loss_aversion:risk_aversion]
**indirect effect of Rinconsistent on loss via risk
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
**Total effects
regress risk_aversion expectsums if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
regress loss_aversion expectsums if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 


***with controls
global control female  nivel_ingresos edad	

gsem (risk_aversion <- expectsums $control)( risk_aversion <-rinconsistent )(rinconsistent <- expectsums, logit) (expectsums<-$control) ///
     (loss_aversion <- expectsums $control)( loss_aversion <-linconsistent )(linconsistent <- expectsums, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) nocapslatent
gsem, coeflegend
margins, dydx(expectsums)
display  -.0040999* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:expectsums]*_b[risk_aversion:rinconsistent]
display  -.005627*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:expectsums]*_b[loss_aversion:linconsistent]
display ( -.0040999* _b[risk_aversion:rinconsistent])*_b[risk_aversion:expectsums]
nlcom (_b[rinconsistent:expectsums]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:expectsums])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion expectsums if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
regress loss_aversion expectsums if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 



***TABLE A.16. SEM: Impact of overconfidence on risk/loss aversion mediated by Rinconsistent/Linconsistent
gsem (risk_aversion <- overconfidence)( risk_aversion <-rinconsistent )(rinconsistent <- overconfidence, logit) ///
     (loss_aversion <- overconfidence)( loss_aversion <-linconsistent )(linconsistent <- overconfidence, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(overconfidence)
display  -.0026244* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:overconfidence]*_b[risk_aversion:rinconsistent]
display -.0058272*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:overconfidence]*_b[loss_aversion:linconsistent]
display ( -.0026244* _b[risk_aversion:rinconsistent])*_b[risk_aversion:overconfidence]
nlcom (_b[rinconsistent:overconfidence]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:overconfidence])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion overconfidence if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 
regress loss_aversion overconfidence if no_missing_1==1 & expectsums<=34.17  [pweight=weight_stratified], vce(robust) 


global control female  nivel_ingresos edad	

gsem (risk_aversion <- overconfidence $control)( risk_aversion <-rinconsistent )(rinconsistent <- overconfidence, logit) (overconfidence<-$control) ///
     (loss_aversion <- overconfidence $control)( loss_aversion <-linconsistent )(linconsistent <- overconfidence, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(overconfidence)
display -.0026244* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:overconfidence]*_b[risk_aversion:rinconsistent]
display   -.0058272*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:overconfidence]*_b[loss_aversion:linconsistent]
display (-.0026244* _b[risk_aversion:rinconsistent])*_b[risk_aversion:overconfidence]
nlcom (_b[rinconsistent:overconfidence]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:overconfidence])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 
regress loss_aversion overconfidence if no_missing_1==1 & expectsums<=34.17 [pweight=weight_stratified], vce(robust) 




***TABLE A.17
****reflective 

gsem (risk_aversion <- reflective)( risk_aversion <-rinconsistent )(rinconsistent <- reflective, logit) ///
     (loss_aversion <- reflective)( loss_aversion <-linconsistent )(linconsistent <- reflective, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(reflective)
display -.0317424* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:reflective]*_b[risk_aversion:rinconsistent]
display -.0418987*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:reflective]*_b[loss_aversion:linconsistent]
display (-.0317424* _b[risk_aversion:rinconsistent])*_b[risk_aversion:reflective]
nlcom (_b[rinconsistent:reflective]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:reflective])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


global control female  nivel_ingresos edad	

gsem (risk_aversion <- reflective $control)( risk_aversion <-rinconsistent )(rinconsistent <- reflective, logit) (reflective<-$control) ///
     (loss_aversion <- reflective $control)( loss_aversion <-linconsistent )(linconsistent <- reflective, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(reflective)
display -.0317424* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:reflective]*_b[risk_aversion:rinconsistent]
display  -.0418987*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:reflective]*_b[loss_aversion:linconsistent]
display (-.0317424* _b[risk_aversion:rinconsistent])*_b[risk_aversion:reflective]
nlcom (_b[rinconsistent:reflective]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:reflective])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion reflective if no_missing_1==1 [pweight=weight_stratified], vce(robust) 



***TABLE A.18
****convergent 

gsem (risk_aversion <- convergent)( risk_aversion <-rinconsistent )(rinconsistent <- convergent, logit) ///
     (loss_aversion <- convergent)( loss_aversion <-linconsistent )(linconsistent <- convergent, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(convergent)
display -.0195949* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:convergent]*_b[risk_aversion:rinconsistent]
display -.0136625*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:convergent]*_b[loss_aversion:linconsistent]
display (-.0195949* _b[risk_aversion:rinconsistent])*_b[risk_aversion:convergent]
nlcom (_b[rinconsistent:convergent]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:convergent])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


global control female  nivel_ingresos edad	

gsem (risk_aversion <- convergent $control)( risk_aversion <-rinconsistent )(rinconsistent <- convergent, logit) (convergent<-$control) ///
     (loss_aversion <- convergent $control)( loss_aversion <-linconsistent )(linconsistent <- convergent, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(convergent)
display -.0195949* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:convergent]*_b[risk_aversion:rinconsistent]
display   -.0136625*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:convergent]*_b[loss_aversion:linconsistent]
display (-.0195949* _b[risk_aversion:rinconsistent])*_b[risk_aversion:convergent]
nlcom (_b[rinconsistent:convergent]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:convergent])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion convergent if no_missing_1==1 [pweight=weight_stratified], vce(robust) 



***TABLE A.19
****intuitive
gsem (risk_aversion <- intuitive)( risk_aversion <-rinconsistent )(rinconsistent <- intuitive, logit) ///
     (loss_aversion <- intuitive)( loss_aversion <-linconsistent )(linconsistent <- intuitive, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(intuitive)
display   .0136687* _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:intuitive]*_b[risk_aversion:rinconsistent]
display  .025063*_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:intuitive]*_b[loss_aversion:linconsistent]
display (  .0136687* _b[risk_aversion:rinconsistent])*_b[risk_aversion:intuitive]
nlcom (_b[rinconsistent:intuitive]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:intuitive])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion intuitive if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion intuitive if no_missing_1==1 [pweight=weight_stratified], vce(robust) 


***con controles
global control female  nivel_ingresos edad	

gsem (risk_aversion <- intuitive $control)( risk_aversion <-rinconsistent )(rinconsistent <- intuitive, logit) (intuitive<-$control) ///
     (loss_aversion <- intuitive $control)( loss_aversion <-linconsistent )(linconsistent <- intuitive, logit) ///
	 (loss_aversion <- risk_aversion)if no_missing_1==1 [pweight=weight_stratified], vce(robust) nocapslatent
margins, dydx(intuitive)
display  .0136687 * _b[risk_aversion:rinconsistent]
nlcom  _b[rinconsistent:intuitive]*_b[risk_aversion:rinconsistent]
display      .025063 *_b[loss_aversion:linconsistent]
nlcom  _b[linconsistent:intuitive]*_b[loss_aversion:linconsistent]
display ( .0136687 * _b[risk_aversion:rinconsistent])*_b[risk_aversion:intuitive]
nlcom (_b[rinconsistent:intuitive]*_b[risk_aversion:rinconsistent]+_b[risk_aversion:intuitive])*_b[loss_aversion:risk_aversion]
nlcom _b[risk_aversion:rinconsistent]*_b[loss_aversion:risk_aversion]
regress risk_aversion intuitive if no_missing_1==1 [pweight=weight_stratified], vce(robust) 
regress loss_aversion intuitive if no_missing_1==1 [pweight=weight_stratified], vce(robust) 





********************************************************************************+
*****TABLE 2. PEARSON CORRELATIONS
replace expectsums=. if expectsums>34.17
replace overconfidence=. if expectsums>34.17

**Pearson with weights
pwcorr risk_aversion loss_aversion rinconsistent linconsistent sums expectsums overconfidence reflective intuitive convergent if no_missing_1==1 [weight=weight_stratified], sig obs

**Spearman
spearman risk_aversion loss_aversion rinconsistent linconsistent sums expectsums overconfidence reflective intuitive convergent if no_missing_1==1 , stats(rho p obs) pw 


