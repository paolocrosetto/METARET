clear programs
qui do MLFunctions.do

program define preamble
	args x
	if "$risk"=="linear" {
	global rexpression 
	}
	if "$risk"=="gprelec" {
	global rexpression (LNalphapr: `x') (LNbetapr: `x')
	}	
	if "$discount"=="Expo" {
	global dexpression (deltaD: `x')
	}
	else if "$discount"=="Hyper" {
	global dexpression (kappaD: `x')
	}
	else if "$discount"=="Weibull" {
	global dexpression (LNrweib: `x') (LNsweib: `x')   
	}
end

foreach xs in i.wave ib1.events {

global index CL
foreach rstory in linear gprelec  {
global risk `rstory'
foreach tstory in Expo Hyper { 
global discount `tstory'
di in green "Risk is `rstory' and discount is `tstory'"
preamble `xs' 
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = `xs')  $rexpression (muRA: ) $dexpression (muDR: ) if dominated==1 /*& cases_adj!=.*/, maximize difficult missing cluster(id)  
ml display
	if "`xs'"=="ib1.events" {
		estimates store ev_`rstory'_`tstory'_subsmpl
	}
	else if "`xs'"=="i.wave" {
		estimates store wv_`rstory'_`tstory'_subsmpl
		}
	}
 }
}

* transform coefficients and place them back to e(b) and e(V)
estimates restore wv_linear_Expo_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp([deltaD]_b[_cons]+[deltaD]_b[4.wave])-exp([deltaD]_b[_cons])) ///
			(b2: exp([deltaD]_b[_cons]+[deltaD]_b[41.wave])-exp([deltaD]_b[_cons])) ///
			(bcons: exp([deltaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,7]=r(b)
			matrix V[1,7]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store wv_linear_Expo_subsmpl

estimates restore wv_linear_Hyper_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp([kappaD]_b[_cons]+[kappaD]_b[4.wave])-exp([kappaD]_b[_cons])) ///
			(b2: exp([kappaD]_b[_cons]+[kappaD]_b[41.wave])-exp([kappaD]_b[_cons])) ///
			(bcons: exp([kappaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,7]=r(b)
			matrix V[1,7]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store wv_linear_Hyper_subsmpl

estimates restore ev_linear_Expo_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp([deltaD]_b[_cons]+[deltaD]_b[2.events])-exp([deltaD]_b[_cons])) ///
			(b2: exp([deltaD]_b[_cons]+[deltaD]_b[3.events])-exp([deltaD]_b[_cons])) ///
			(b3: exp([deltaD]_b[_cons]+[deltaD]_b[4.events])-exp([deltaD]_b[_cons])) ///
			(b4: exp([deltaD]_b[_cons]+[deltaD]_b[5.events])-exp([deltaD]_b[_cons])) ///
			(b5: exp([deltaD]_b[_cons]+[deltaD]_b[6.events])-exp([deltaD]_b[_cons])) ///
			(bcons: exp([deltaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,10]=r(b)
			matrix V[1,10]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store ev_linear_Expo_subsmpl

estimates restore ev_linear_Hyper_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp([kappaD]_b[_cons]+[kappaD]_b[2.events])-exp([kappaD]_b[_cons])) ///
			(b2: exp([kappaD]_b[_cons]+[kappaD]_b[3.events])-exp([kappaD]_b[_cons])) ///
			(b3: exp([kappaD]_b[_cons]+[kappaD]_b[4.events])-exp([kappaD]_b[_cons])) ///
			(b4: exp([kappaD]_b[_cons]+[kappaD]_b[5.events])-exp([kappaD]_b[_cons])) ///
			(b5: exp([kappaD]_b[_cons]+[kappaD]_b[6.events])-exp([kappaD]_b[_cons])) ///
			(bcons: exp([kappaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,10]=r(b)
			matrix V[1,10]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store ev_linear_Hyper_subsmpl

estimates restore wv_gprelec_Expo_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(a1: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.wave])-exp([LNalphapr]_b[_cons])) ///
			(a2: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[41.wave])-exp([LNalphapr]_b[_cons])) ///
			(acons: exp([LNalphapr]_b[_cons])) ///
			(b0: 0) ///
			(b1: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.wave])-exp([LNbetapr]_b[_cons])) ///
			(b2: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[41.wave])-exp([LNbetapr]_b[_cons])) ///
			(bcons: exp([LNbetapr]_b[_cons])) ///
			(mu: [muRA]_b[_cons]) ///
			(d0: 0) ///
			(d1: exp([deltaD]_b[_cons]+[deltaD]_b[4.wave])-exp([deltaD]_b[_cons])) ///
			(d2: exp([deltaD]_b[_cons]+[deltaD]_b[41.wave])-exp([deltaD]_b[_cons])) ///
			(dcons: exp([deltaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,6]=r(b)
			matrix V[1,6]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store wv_gprelec_Expo_subsmpl

estimates restore wv_gprelec_Hyper_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(a1: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.wave])-exp([LNalphapr]_b[_cons])) ///
			(a2: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[41.wave])-exp([LNalphapr]_b[_cons])) ///
			(acons: exp([LNalphapr]_b[_cons])) ///
			(b0: 0) ///
			(b1: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.wave])-exp([LNbetapr]_b[_cons])) ///
			(b2: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[41.wave])-exp([LNbetapr]_b[_cons])) ///
			(bcons: exp([LNbetapr]_b[_cons])) ///
			(mu: [muRA]_b[_cons]) ///
			(d0: 0) ///
			(d1: exp([kappaD]_b[_cons]+[kappaD]_b[4.wave])-exp([kappaD]_b[_cons])) ///
			(d2: exp([kappaD]_b[_cons]+[kappaD]_b[41.wave])-exp([kappaD]_b[_cons])) ///
			(dcons: exp([kappaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,6]=r(b)
			matrix V[1,6]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store wv_gprelec_Hyper_subsmpl
		
estimates restore ev_gprelec_Expo_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(a2: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[2.events])-exp([LNalphapr]_b[_cons])) ///
			(a3: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[3.events])-exp([LNalphapr]_b[_cons])) ///
			(a4: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.events])-exp([LNalphapr]_b[_cons])) ///
			(a5: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[5.events])-exp([LNalphapr]_b[_cons])) ///
			(a6: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[6.events])-exp([LNalphapr]_b[_cons])) ///
			(acons: exp([LNalphapr]_b[_cons])) ///
			(b1: 0) ///
			(b2: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[2.events])-exp([LNbetapr]_b[_cons])) ///
			(b3: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[3.events])-exp([LNbetapr]_b[_cons])) ///
			(b4: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.events])-exp([LNbetapr]_b[_cons])) ///
			(b5: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[5.events])-exp([LNbetapr]_b[_cons])) ///
			(b6: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[6.events])-exp([LNbetapr]_b[_cons])) ///
			(bcons: exp([LNbetapr]_b[_cons])) ///
			(mu: [muRA]_b[_cons]) ///
			(d1: 0) ///
			(d2: exp([deltaD]_b[_cons]+[deltaD]_b[2.events])-exp([deltaD]_b[_cons])) ///
			(d3: exp([deltaD]_b[_cons]+[deltaD]_b[3.events])-exp([deltaD]_b[_cons])) ///
			(d4: exp([deltaD]_b[_cons]+[deltaD]_b[4.events])-exp([deltaD]_b[_cons])) ///
			(d5: exp([deltaD]_b[_cons]+[deltaD]_b[5.events])-exp([deltaD]_b[_cons])) ///
			(d6: exp([deltaD]_b[_cons]+[deltaD]_b[6.events])-exp([deltaD]_b[_cons])) ///
			(dcons: exp([deltaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,9]=r(b)
			matrix V[1,9]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store ev_gprelec_Expo_subsmpl
		
estimates restore ev_gprelec_Hyper_subsmpl
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(a2: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[2.events])-exp([LNalphapr]_b[_cons])) ///
			(a3: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[3.events])-exp([LNalphapr]_b[_cons])) ///
			(a4: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[4.events])-exp([LNalphapr]_b[_cons])) ///
			(a5: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[5.events])-exp([LNalphapr]_b[_cons])) ///
			(a6: exp([LNalphapr]_b[_cons]+[LNalphapr]_b[6.events])-exp([LNalphapr]_b[_cons])) ///
			(acons: exp([LNalphapr]_b[_cons])) ///
			(b1: 0) ///
			(b2: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[2.events])-exp([LNbetapr]_b[_cons])) ///
			(b3: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[3.events])-exp([LNbetapr]_b[_cons])) ///
			(b4: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[4.events])-exp([LNbetapr]_b[_cons])) ///
			(b5: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[5.events])-exp([LNbetapr]_b[_cons])) ///
			(b6: exp([LNbetapr]_b[_cons]+[LNbetapr]_b[6.events])-exp([LNbetapr]_b[_cons])) ///
			(bcons: exp([LNbetapr]_b[_cons])) ///
			(mu: [muRA]_b[_cons]) ///
			(d1: 0) ///
			(d2: exp([kappaD]_b[_cons]+[kappaD]_b[2.events])-exp([kappaD]_b[_cons])) ///
			(d3: exp([kappaD]_b[_cons]+[kappaD]_b[3.events])-exp([kappaD]_b[_cons])) ///
			(d4: exp([kappaD]_b[_cons]+[kappaD]_b[4.events])-exp([kappaD]_b[_cons])) ///
			(d5: exp([kappaD]_b[_cons]+[kappaD]_b[5.events])-exp([kappaD]_b[_cons])) ///
			(d6: exp([kappaD]_b[_cons]+[kappaD]_b[6.events])-exp([kappaD]_b[_cons])) ///
			(dcons: exp([kappaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,9]=r(b)
			matrix V[1,9]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display
estimates store ev_gprelec_Hyper_subsmpl