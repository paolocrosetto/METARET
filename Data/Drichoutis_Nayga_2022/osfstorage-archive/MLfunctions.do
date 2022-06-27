version 10

* CRRA
	program MLcrra
	if "$discount"=="Expo" | "$discount"=="Hyper" {
			if "$risk"=="linear" {
			args lnf r muRA LNdiscount muDR 
			}
			else if "$risk"=="power" {
			args lnf r beta muRA LNdiscount muDR 
			}
			else if "$risk"=="tk" { // This is for Tversky and Kahnemann
			args lnf r gamma muRA LNdiscount muDR
			}
			else if "$risk"=="gtk" {
			args lnf r gamma LNdelta muRA  LNdiscount muDR // Generalized TK (it nests Karmakar if delta=1 and TK if delta=1/gamma)
			}
			else if "$risk"=="linlog" {
			args lnf r gamma delta muRA LNdiscount muDR // It nests Karmakar if delta=1 
			}
			else if "$risk"=="prelec" {
			args lnf r LNalphapr muRA LNdiscount muDR 			// the function is not defined if p=0
			}		
			else if "$risk"=="gprelec" {
			args lnf r LNalphapr LNbetapr muRA LNdiscount muDR // the function is not defined if p=0
			}	
	}
	else if "$discount"=="HyperLP" { // The Lowenstein-Prelec 1992 Hyperbolic generalization has two extra parameters
			if "$risk"=="linear" {
			args lnf r muRA LNalphaD LNbetaD muDR 
			}
			else if "$risk"=="power" {
			args lnf r beta muRA LNalphaD LNbetaD muDR 
			}
			else if "$risk"=="tk" { // This is for Tversky and Kahnemann
			args lnf r gamma muRA LNalphaD LNbetaD muDR
			}
			else if "$risk"=="gtk" {
			args lnf r gamma LNdelta muRA  LNalphaD LNbetaD muDR // Generalized TK (it nests Karmakar if delta=1 and TK if delta=1/gamma)
			}
			else if "$risk"=="linlog" {
			args lnf r gamma delta muRA LNalphaD LNbetaD muDR // It nests Karmakar if delta=1 
			}
			else if "$risk"=="prelec" {
			args lnf r LNalphapr muRA LNalphaD LNbetaD muDR 			// the function is not defined if p=0
			}		
			else if "$risk"=="gprelec" {
			args lnf r LNalphapr LNbetapr muRA LNalphaD LNbetaD muDR // the function is not defined if p=0
			}	
	}	
	else if "$discount"=="Weibull" { // The Lowenstein-Prelec 1992 Hyperbolic generalization has two extra parameters
			if "$risk"=="linear" {
			args lnf r muRA LNrweib LNsweib muDR 
			}
			else if "$risk"=="power" {
			args lnf r beta muRA LNrweib LNsweib muDR 
			}
			else if "$risk"=="tk" { // This is for Tversky and Kahnemann
			args lnf r gamma muRA LNrweib LNsweib muDR
			}
			else if "$risk"=="gtk" {
			args lnf r gamma LNdelta muRA  LNrweib LNsweib muDR // Generalized TK (it nests Karmakar if delta=1 and TK if delta=1/gamma)
			}
			else if "$risk"=="linlog" {
			args lnf r gamma delta muRA LNrweib LNsweib muDR // It nests Karmakar if delta=1 
			}
			else if "$risk"=="prelec" {
			args lnf r LNalphapr muRA LNrweib LNsweib muDR 			// the function is not defined if p=0
			}		
			else if "$risk"=="gprelec" {
			args lnf r LNalphapr LNbetapr muRA LNrweib LNsweib muDR // the function is not defined if p=0
			}	
	}
	
		tempvar ra t tau tauprime mA mB mC prob1 prob2 mA1 mA2 mB1 mB2 yA1 yA2 yB1 yB2 wp1 wp2 euA euB 
		tempvar uA uB uC euRatio uRatio uDiff euDiff mMIN mMAX urMIN urMAX deltaD kappaD fed uDiscount
		tempvar utMIN utMAX euContext uContext tmp nchoice alphapr betapr /*gamma delta beta  */ betag deltagtk  sd uDFT 
		if "$discount"=="HyperLP" {
		tempvar alphaD betaD
		}
		else if "$discount"=="Weibull" {
		tempvar rweib sweib
		}

		syntax varlist [if] [in] [fweight pweight] [, noLOg	Robust CLuster(varname)	svy	EForm *]
		marksample touse
		if "`svy'" != "" {
			svymarkout `touse'
		}
 
		quietly {
			* initialize probabilities and payoffs
			
			generate double `prob1' = $ML_y2      
			generate double `prob2' = 1 - `prob1'
			generate double `mA1' 	= $ML_y3      
			generate double `mA2' 	= $ML_y4
			generate double `mB1' 	= $ML_y5
			generate double `mB2' 	= $ML_y6
			generate double `nchoice' = $ML_y7
			generate double `fed'	= $ML_y8
			generate double `t' 	= $ML_y9/360 // horizon is either 95 or 190 days
			generate double `tau' 	= (`fed'+$ML_y9)/360  // $ML_y9 is 190 days for the first 20 choices, 95 days for the middle option in choices 21-30 and 190 days for the much later option in choices 21-30
			generate double `tauprime' 	= (`fed'+$ML_y9+$ML_y9)/360 // this is appropriate for the much later option in choices 21-30
			generate double `mA'	= $ML_y10
			generate double `mB'	= $ML_y11
			generate double `mC'	= $ML_y12
			generate double `ra' 	= $ML_y13
			
			* estimating over risk responses
			generate double `yA1' = ((`mA1')^(-`r'+1))/(-`r'+1) if `ra'==1
			generate double `yA2' = ((`mA2')^(-`r'+1))/(-`r'+1) if `ra'==1
			generate double `yB1' = ((`mB1')^(-`r'+1))/(-`r'+1) if `ra'==1
			generate double `yB2' = ((`mB2')^(-`r'+1))/(-`r'+1) if `ra'==1
			if "$risk"=="linear" {
			generate double `wp1' = `prob1'  if `ra'==1						
			generate double `wp2' = `prob2'  if `ra'==1							
			}
			else if "$risk"=="power" {
			*generate double `beta'    = exp(`LNbeta') // It allows the ML program to pick any value fro LNgamma but wp is only evaluated for gamma>0
			generate double `wp1'=(`prob1'^`beta') 	 	if `ra'==1			
			generate double `wp2'=1-`wp1'  				if `ra'==1						
			}
			else if "$risk"=="tk" {
			*generate double `gamma'    = exp(`LNgamma')
			generate double `tmp'=((`prob1'^`gamma')+(`prob2'^`gamma'))^(1/`gamma') 	 	if `ra'==1
			generate double `wp1'=(`prob1'^`gamma')/`tmp' 			 						if `ra'==1
			generate double `wp2'=1-`wp1'						 							if `ra'==1	
			}
			else if "$risk"=="gtk" {
			*generate double `gamma'    = exp(`LNgamma')
			generate double `deltagtk'    = exp(`LNdelta')  									if `ra'==1
			generate double `tmp'=((`prob1'^`gamma')+(`prob2'^`gamma'))^`deltagtk'			if `ra'==1
			generate double `wp1'=`prob1'^`gamma'/`tmp' 									if `ra'==1	
			generate double `wp2'=1-`wp1'													if `ra'==1
			}
			else if "$risk"=="linlog" {
			*generate double `gamma'    = exp(`LNgamma')
			*generate double `deltag'    = exp(`LNdelta')			
			generate double `tmp'=`delta'*(`prob1'^`gamma')+(`prob2'^`gamma')				 if `ra'==1
			generate double `wp1'=(`delta'*(`prob1'^`gamma'))/`tmp' 						 if `ra'==1
			generate double `wp2'=1-`wp1'													 if `ra'==1
			}
			else if "$risk"=="prelec" {
			generate double `alphapr'    = exp(`LNalphapr') 	/*`LNalphapr'*/					 if `ra'==1	
			generate double `wp1'=exp( (-1) * ((-ln(`prob1'))^`alphapr')) 	 if `ra'==1	// the function is not defined if p=0			
			generate double `wp2'=1-`wp1'  									 if `ra'==1
			}
			else if "$risk"=="gprelec" {
			generate double `alphapr'    = exp(`LNalphapr')	/*`LNalphapr'*/			if `ra'==1
			generate double `betapr'    = exp(`LNbetapr')							if `ra'==1
			generate double `wp1'=exp( (-`betapr') * ((-ln(`prob1'))^`alphapr'))  	if `ra'==1	// the function is not defined if p=0			
			generate double `wp2'=1-`wp1'										if `ra'==1
			}

			generate double `uA' = (`wp1'*`yA1')+(`wp2'*`yA2')					if `ra'==1	      
			generate double `uB' = (`wp1'*`yB1')+(`wp2'*`yB2')					if `ra'==1
			generate double `uC' = .											if `ra'==1 // this will store values for the third option in the time preferences tasks 21-30
			
			* generate index
			if "$index" == "L" {
				generate double `uRatio' = exp((`uB')/`muRA')/(exp((`uA')/`muRA')+exp((`uB')/`muRA'))	if `ra'==1 // This expression is equivalent to writting: generate double `euDiff'= invlogit((`euB'-`euA')/`muRA')
				replace `lnf' = ln(`uRatio')											if $ML_y1==1  & `ra'==1	
				replace `lnf' = ln(1-`uRatio')											if $ML_y1==0  & `ra'==1	
				replace `lnf' = (ln(1-`uRatio')/2)+(ln(`uRatio')/2)						if $ML_y1==-1 & `ra'==1
			}
			else if "$index" == "CL" {
				generate double `mMIN' = `mB2'						if `ra'==1
				generate double `mMAX' = `mB1'						if `ra'==1
				generate double `urMIN' = (`mMIN'^(1-`r'))/(1-`r')	if `ra'==1				
				generate double `urMAX' = (`mMAX'^(1-`r'))/(1-`r')	if `ra'==1				
				generate double `uContext' = (((`uB'-`uA')/abs(`urMAX'-`urMIN'))/`muRA') if `ra'==1 
				// exp((`uB')/(abs(`urMAX'-`urMIN')/`muRA'))/(exp((`uA')/(abs(`urMAX'-`urMIN')/`muRA'))+exp((`uB')/(abs(`urMAX'-`urMIN')/`muRA'))) // exp(((`uB')*`muRA')/(abs(`urMAX'-`urMIN')))/(exp(((`uA')*`muRA')/(abs(`urMAX'-`urMIN')))+exp(((`uB')*`muRA')/(abs(`urMAX'-`urMIN')))) // 	// Equivalent to: generate double `euContext' = exp((`euA'/(abs(`urMAX'-`urMIN')))/`muRA')/(exp((`euA'/(abs(`urMAX'-`urMIN')))/`muRA')+exp((`euB'/(abs(`urMAX'-`urMIN')))/`muRA'))     
				replace `lnf' = ln(invlogit(`uContext')) 										if $ML_y1==1  & `ra'==1				
				replace `lnf' = ln(invlogit(-`uContext'))										if $ML_y1==0  & `ra'==1	
				replace `lnf' = (ln(invlogit(-`uContext'))/2)+(ln(invlogit(`uContext'))/2)		if $ML_y1==-1 & `ra'==1
			}
			else if "$index" == "DFTL" {
				*generate double `sd' = sqrt((`wp1'*((`yA1'-`yB1')^2))+(`wp2'*((`yA2'-`yB2')^2))-((`uA'-`uB')^2)) if `nchoice'<50 & `ra'==1
				*replace 		`sd' = sqrt((`wp1'*((`yA1'-`yB1')^2))+(`wp2'*((`yA2'-`yB2')^2))-((`uA'-`uB')^2)) if `nchoice'>50 & `ra'==1
				* Alternatively:
				generate double `sd' = sqrt( `wp1'*`wp2'*((`yB1'-`yA1'+`yA2'-`yB2')^2) ) if `nchoice'<50 & `ra'==1
				replace 		`sd' = sqrt( `wp1'*`wp2'*((`yB1'-`yA1'+`yA2'-`yB2')^2) ) if `nchoice'>50 & `ra'==1
				
				generate double `uDFT' = ((`uB'-`uA')/`muRA')/(`sd')					if `ra'==1	
				replace `lnf' = ln(invlogit(`uDFT'))  									if $ML_y1==1  & `ra'==1		
				replace `lnf' = ln(invlogit(-`uDFT')) 									if $ML_y1==0  & `ra'==1	
				replace `lnf' = (ln(invlogit(-`uDFT'))/2)+(ln(invlogit(`uDFT'))/2)		if $ML_y1==-1 & `ra'==1	
			}
			
			* transform discount parameters
			if "$discount"=="Expo" {
			generate double `deltaD'  = exp(`LNdiscount') //`LNdiscount' //  if deltaD comes out as negative, you need to use the exp(`LNdiscount') expression
			}
			else if "$discount"=="Hyper" {
			generate double `kappaD' = exp(`LNdiscount') //`LNdiscount' // exp(`LNdiscount') same comment as above
			}
			else if "$discount"=="HyperLP" {
			generate double `alphaD' = exp(`LNalphaD')
			generate double `betaD' = exp(`LNbetaD')
			}
			else if "$discount"=="Weibull" {
			generate double `rweib' = exp(`LNrweib')
			generate double `sweib' = exp(`LNsweib')
			}			
			*  discounting choices
			if "$discount"=="Expo" {
				replace `uA' = ((1+`deltaD')^(-`fed'/360 )) * ((`mA')^(1-`r'))/(1-`r')		if `ra'==0
				replace `uB' = ((1+`deltaD')^(-`tau' )) * ((`mB')^(1-`r'))/(1-`r')			if `ra'==0
				replace `uC' = ((1+`deltaD')^(-`tauprime' )) * ((`mC')^(1-`r'))/(1-`r')		if `ra'==0 & nchoice>20	
			}
			else if "$discount"=="Hyper" {
			
				replace `uA' = (1 / (1+`kappaD'*(`fed'/360)) ) * ((`mA')^(1-`r'))/(1-`r')				if `ra'==0
				replace `uB' = (1 / (1+`kappaD'*(`tau' )) ) * ((`mB')^(1-`r'))/(1-`r')					if `ra'==0	
				replace `uC' = (1 / (1+`kappaD'*(`tauprime' )) ) * ((`mC')^(1-`r'))/(1-`r')				if `ra'==0 & nchoice>20	
			}
			else if "$discount"=="HyperLP" {
				replace `uA' = (1+`alphaD'*(`fed'/360))^(-`betaD'/`alphaD') * ((`mA')^(1-`r'))/(1-`r')			if `ra'==0
				replace `uB' = (1+`alphaD'*(`tau'))^(-`betaD'/`alphaD') * ((`mB')^(1-`r'))/(1-`r')				if `ra'==0	
				replace `uC' = (1+`alphaD'*(`tauprime'))^(-`betaD'/`alphaD') * ((`mC')^(1-`r'))/(1-`r')			if `ra'==0	& nchoice>20	
			}			
			else if "$discount"=="Weibull" {
				replace `uA' = exp(-`rweib'*((`fed'/360)^(1/`sweib')))			if `ra'==0
			    replace `uB' = exp(-`rweib'*((`tau'	  )^(1/`sweib')))			if `ra'==0	 			
			    replace `uC' = exp(-`rweib'*((`tauprime'	  )^(1/`sweib'))) 	if `ra'==0 & nchoice>20			
			}
			
			* generate index for discounting tasks
/*			if "$index" == "P" | "$index" == "CP" | "$index" == "DFTP" {	
			  generate double `uDiscount'=(`uB'-`uA')/`muDR'							if `ra'==0
			  replace `lnf' = ln(normal(`uDiscount'))  									if $ML_y1==1 	&  `ra'==0 			
			  replace `lnf' = ln(normal(-`uDiscount')) 									if $ML_y1==0 	&  `ra'==0 
			  replace `lnf' = (ln(normal(-`uDiscount'))/2)+(ln(normal(`uDiscount'))/2)	if $ML_y1==-1 	&  `ra'==0 
			 }	*/
			if "$index"=="L" | "$index" == "CL" | "$index" == "DFTL" {
				generate double `uDiscount' = (`uB'-`uA')/`muDR' 								if 				   `ra'==0 & nchoice<=20
				replace `lnf' = ln(invlogit(`uDiscount'))										if $ML_y1==1	&  `ra'==0 & nchoice<=20
				replace `lnf' = ln(invlogit(-`uDiscount'))										if $ML_y1==0	&  `ra'==0 & nchoice<=20
			    replace `lnf' = (ln(invlogit(-`uDiscount'))/2)+(ln(invlogit(`uDiscount'))/2)	if $ML_y1==-1	&  `ra'==0 & nchoice<=20
			  
				replace `lnf' = ln(exp(`uA'/`muDR')/(exp(`uA'/`muDR')+exp(`uB'/`muDR')+exp(`uC'/`muDR'))) 			if $ML_y1==0 	&  `ra'==0 & nchoice>20	 
				replace `lnf' = ln(exp(`uB'/`muDR')/(exp(`uA'/`muDR')+exp(`uB'/`muDR')+exp(`uC'/`muDR'))) 			if $ML_y1==1 	&  `ra'==0 & nchoice>20	
				replace `lnf' = ln(exp(`uC'/`muDR')/(exp(`uA'/`muDR')+exp(`uB'/`muDR')+exp(`uC'/`muDR'))) 			if $ML_y1==2 	&  `ra'==0 & nchoice>20	
				}
}
	end