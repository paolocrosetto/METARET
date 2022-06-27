quietly {
qui estimates restore chow_eut_expo_wv
estimates replay chow_eut_expo_wv, coeflegend
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp(_b[deltaD:3bn.wave])) ///
			(b2:  exp(_b[deltaD:4.wave])) ///
			(b3:  exp(_b[deltaD:41.wave])) ///
			(b4a: 0) ///
			(b4:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#1.gender])-exp(_b[deltaD:3bn.wave])) ///
			(b5a: 0) ///
			(b5:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#1.gender])-exp(_b[deltaD:4.wave])) ///
			(b6a: 0) ///
			(b6:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#1.gender])-exp(_b[deltaD:41.wave])) ///
			(b7:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#c.hsize])-exp(_b[deltaD:3bn.wave])) ///
			(b8:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.hsize])-exp(_b[deltaD:4.wave])) ///
			(b9:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.hsize])-exp(_b[deltaD:41.wave])) ///
			(b10:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#c.age])-exp(_b[deltaD:3bn.wave])) ///
			(b11:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.age])-exp(_b[deltaD:4.wave])) ///
			(b12:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.age])-exp(_b[deltaD:41.wave])) ///
			(b13a: 0) ///
			(b13:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#4.income])-exp(_b[deltaD:3bn.wave])) ///
			(b14:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#5.income])-exp(_b[deltaD:3bn.wave])) ///
			(b15a: 0) ///
			(b15:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#4.income])-exp(_b[deltaD:4.wave])) ///
			(b16:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#5.income])-exp(_b[deltaD:4.wave])) ///
			(b17a: 0) ///
			(b17:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#4.income])-exp(_b[deltaD:41.wave])) ///
			(b18:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#5.income])-exp(_b[deltaD:41.wave])) ///
			(b19a: 0) ///
			(b19:  exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#1.nosmoke])-exp(_b[deltaD:3bn.wave])) ///
			(b20a: 0) ///
			(b20:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#1.nosmoke])-exp(_b[deltaD:4.wave])) ///
			(b21a: 0) ///
			(b21:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#1.nosmoke])-exp(_b[deltaD:41.wave])) ///
			(b22:  0) ///
			(b23:  exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.cases_adj])-exp(_b[deltaD:4.wave])) ///
			(b24:  exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.cases_adj])-exp(_b[deltaD:41.wave])) 
	matrix temp=vecdiag(r(V))
			matrix b[1,35]=r(b)
			matrix V[1,35]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store chow_eut_expo_wv

qui estimates restore chow_eut_hyper_wv		
estimates replay chow_eut_hyper_wv, coeflegend
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp(_b[kappaD:3bn.wave])) ///
			(b2:  exp(_b[kappaD:4.wave])) ///
			(b3:  exp(_b[kappaD:41.wave])) ///
			(b4a: 0) ///
			(b4:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#1.gender])-exp(_b[kappaD:3bn.wave])) ///
			(b5a: 0) ///
			(b5:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#1.gender])-exp(_b[kappaD:4.wave])) ///
			(b6a: 0) ///
			(b6:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#1.gender])-exp(_b[kappaD:41.wave])) ///
			(b7:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#c.hsize])-exp(_b[kappaD:3bn.wave])) ///
			(b8:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.hsize])-exp(_b[kappaD:4.wave])) ///
			(b9:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.hsize])-exp(_b[kappaD:41.wave])) ///
			(b10:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#c.age])-exp(_b[kappaD:3bn.wave])) ///
			(b11:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.age])-exp(_b[kappaD:4.wave])) ///
			(b12:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.age])-exp(_b[kappaD:41.wave])) ///
			(b13a: 0) ///
			(b13:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#4.income])-exp(_b[kappaD:3bn.wave])) ///
			(b14:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#5.income])-exp(_b[kappaD:3bn.wave])) ///
			(b15a: 0) ///
			(b15:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#4.income])-exp(_b[kappaD:4.wave])) ///
			(b16:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#5.income])-exp(_b[kappaD:4.wave])) ///
			(b17a: 0) ///
			(b17:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#4.income])-exp(_b[kappaD:41.wave])) ///
			(b18:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#5.income])-exp(_b[kappaD:41.wave])) ///
			(b19a: 0) ///
			(b19:  exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#1.nosmoke])-exp(_b[kappaD:3bn.wave])) ///
			(b20a: 0) ///
			(b20:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#1.nosmoke])-exp(_b[kappaD:4.wave])) ///
			(b21a: 0) ///
			(b21:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#1.nosmoke])-exp(_b[kappaD:41.wave])) ///
			(b22:  0) ///
			(b23:  exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.cases_adj])-exp(_b[kappaD:4.wave])) ///
			(b24:  exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.cases_adj])-exp(_b[kappaD:41.wave])) 
	matrix temp=vecdiag(r(V))
			matrix b[1,35]=r(b)
			matrix V[1,35]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store chow_eut_hyper_wv

qui estimates restore chow_rdu_expo_wv	
estimates replay chow_rdu_expo_wv, coeflegend
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp(_b[LNalpha:3bn.wave])) ///
			(b2: exp(_b[LNalpha:4.wave])) ///
			(b3: exp(_b[LNalpha:41.wave])) ///
			(b4: 0) ///
			(b5: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#1.gender])-exp(_b[LNalpha:3bn.wave])) ///
			(b6: 0) ///
			(b7: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#1.gender])-exp(_b[LNalpha:4.wave])) ///
			(b8: 0) ///
			(b9: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#1.gender])-exp(_b[LNalpha:41.wave])) ///
			(b10: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#c.hsize])-exp(_b[LNalpha:3bn.wave])) ///
			(b11: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.hsize])-exp(_b[LNalpha:4.wave])) ///
			(b12: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.hsize])-exp(_b[LNalpha:41.wave])) ///
			(b13: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#c.age])-exp(_b[LNalpha:3bn.wave])) ///
			(b14: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.age])-exp(_b[LNalpha:4.wave])) ///
			(b15: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.age])-exp(_b[LNalpha:41.wave])) ///
			(b16: 0) ///
			(b17: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#4.income])-exp(_b[LNalpha:3bn.wave])) ///
			(b18: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#5.income])-exp(_b[LNalpha:3bn.wave])) ///
			(b19: 0) ///
			(b20: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#4.income])-exp(_b[LNalpha:4.wave])) ///
			(b21: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#5.income])-exp(_b[LNalpha:4.wave])) ///
			(b22: 0) ///
			(b23: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#4.income])-exp(_b[LNalpha:41.wave])) ///
			(b24: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#5.income])-exp(_b[LNalpha:41.wave])) ///
			(b25: 0) ///
			(b26: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#1.nosmoke])-exp(_b[LNalpha:3bn.wave])) ///
			(b27: 0) ///
			(b28: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#1.nosmoke])-exp(_b[LNalpha:4.wave])) ///
			(b29: 0) ///
			(b30: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#1.nosmoke])-exp(_b[LNalpha:41.wave])) ///
			(b31: 0) ///
			(b32: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.cases_adj])-exp(_b[LNalpha:4.wave])) ///
			(b33: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.cases_adj])-exp(_b[LNalpha:41.wave])) ///
				///
			(b34: exp(_b[LNbeta:3bn.wave])) ///
			(b35: exp(_b[LNbeta:4.wave])) ///
			(b36: exp(_b[LNbeta:41.wave])) ///
			(b37: 0) ///
			(b38: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#1.gender])-exp(_b[LNbeta:3bn.wave])) ///
			(b39: 0) ///
			(b40: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#1.gender])-exp(_b[LNbeta:4.wave])) ///
			(b41: 0) ///
			(b42: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#1.gender])-exp(_b[LNbeta:41.wave])) ///
			(b43: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#c.hsize])-exp(_b[LNbeta:3bn.wave])) ///
			(b44: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.hsize])-exp(_b[LNbeta:4.wave])) ///
			(b45: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.hsize])-exp(_b[LNbeta:41.wave])) ///
			(b46: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#c.age])-exp(_b[LNbeta:3bn.wave])) ///
			(b47: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.age])-exp(_b[LNbeta:4.wave])) ///
			(b48: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.age])-exp(_b[LNbeta:41.wave])) ///
			(b49: 0) ///
			(b50: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#4.income])-exp(_b[LNbeta:3bn.wave])) ///
			(b51: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#5.income])-exp(_b[LNbeta:3bn.wave])) ///
			(b52: 0) ///
			(b53: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#4.income])-exp(_b[LNbeta:4.wave])) ///
			(b54: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#5.income])-exp(_b[LNbeta:4.wave])) ///
			(b55: 0) ///
			(b56: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#4.income])-exp(_b[LNbeta:41.wave])) ///
			(b57: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#5.income])-exp(_b[LNbeta:41.wave])) ///
			(b58: 0) ///
			(b59: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#1.nosmoke])-exp(_b[LNbeta:3bn.wave])) ///
			(b60: 0) ///
			(b61: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#1.nosmoke])-exp(_b[LNbeta:4.wave])) ///
			(b62: 0) ///
			(b63: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#1.nosmoke])-exp(_b[LNbeta:41.wave])) ///
			(b64: 0) ///
			(b65: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.cases_adj])-exp(_b[LNbeta:4.wave])) ///
			(b66: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.cases_adj])-exp(_b[LNbeta:41.wave])) ///
			///
			(bmuRA: _b[muRA:_cons]) ///
			///
			(b67: exp(_b[deltaD:3bn.wave])) ///
			(b68: exp(_b[deltaD:4.wave])) ///
			(b69: exp(_b[deltaD:41.wave])) ///
			(b70: 0) ///
			(b71: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#1.gender])-exp(_b[deltaD:3bn.wave])) ///
			(b72: 0) ///
			(b73: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#1.gender])-exp(_b[deltaD:4.wave])) ///
			(b74: 0) ///
			(b75: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#1.gender])-exp(_b[deltaD:41.wave])) ///
			(b76: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#c.hsize])-exp(_b[deltaD:3bn.wave])) ///
			(b77: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.hsize])-exp(_b[deltaD:4.wave])) ///
			(b78: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.hsize])-exp(_b[deltaD:41.wave])) ///
			(b79: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#c.age])-exp(_b[deltaD:3bn.wave])) ///
			(b80: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.age])-exp(_b[deltaD:4.wave])) ///
			(b81: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.age])-exp(_b[deltaD:41.wave])) ///
			(b82: 0) ///
			(b83: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#4.income])-exp(_b[deltaD:3bn.wave])) ///
			(b84: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#5.income])-exp(_b[deltaD:3bn.wave])) ///
			(b85: 0) ///
			(b86: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#4.income])-exp(_b[deltaD:4.wave])) ///
			(b87: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#5.income])-exp(_b[deltaD:4.wave])) ///
			(b88: 0) ///
			(b89: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#4.income])-exp(_b[deltaD:41.wave])) ///
			(b90: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#5.income])-exp(_b[deltaD:41.wave])) ///
			(b91: 0) ///
			(b92: exp(_b[deltaD:3bn.wave]+_b[deltaD:3bn.wave#1.nosmoke])-exp(_b[deltaD:3bn.wave])) ///
			(b93: 0) ///
			(b94: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#1.nosmoke])-exp(_b[deltaD:4.wave])) ///
			(b95: 0) ///
			(b96: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#1.nosmoke])-exp(_b[deltaD:41.wave])) ///
			(b97: 0) ///
			(b98: exp(_b[deltaD:4.wave]+_b[deltaD:4.wave#c.cases_adj])-exp(_b[deltaD:4.wave])) ///
			(b99: exp(_b[deltaD:41.wave]+_b[deltaD:41.wave#c.cases_adj])-exp(_b[deltaD:41.wave])) 
	matrix temp=vecdiag(r(V))
			matrix b[1,34]=r(b)
			matrix V[1,34]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store chow_rdu_expo_wv

qui estimates restore chow_rdu_hyper_wv	
estimates replay chow_rdu_hyper_wv, coeflegend
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom 	(b1: exp(_b[LNalpha:3bn.wave])) ///
			(b2: exp(_b[LNalpha:4.wave])) ///
			(b3: exp(_b[LNalpha:41.wave])) ///
			(b4: 0) ///
			(b5: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#1.gender])-exp(_b[LNalpha:3bn.wave])) ///
			(b6: 0) ///
			(b7: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#1.gender])-exp(_b[LNalpha:4.wave])) ///
			(b8: 0) ///
			(b9: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#1.gender])-exp(_b[LNalpha:41.wave])) ///
			(b10: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#c.hsize])-exp(_b[LNalpha:3bn.wave])) ///
			(b11: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.hsize])-exp(_b[LNalpha:4.wave])) ///
			(b12: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.hsize])-exp(_b[LNalpha:41.wave])) ///
			(b13: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#c.age])-exp(_b[LNalpha:3bn.wave])) ///
			(b14: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.age])-exp(_b[LNalpha:4.wave])) ///
			(b15: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.age])-exp(_b[LNalpha:41.wave])) ///
			(b16: 0) ///
			(b17: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#4.income])-exp(_b[LNalpha:3bn.wave])) ///
			(b18: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#5.income])-exp(_b[LNalpha:3bn.wave])) ///
			(b19: 0) ///
			(b20: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#4.income])-exp(_b[LNalpha:4.wave])) ///
			(b21: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#5.income])-exp(_b[LNalpha:4.wave])) ///
			(b22: 0) ///
			(b23: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#4.income])-exp(_b[LNalpha:41.wave])) ///
			(b24: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#5.income])-exp(_b[LNalpha:41.wave])) ///
			(b25: 0) ///
			(b26: exp(_b[LNalpha:3bn.wave]+_b[LNalpha:3bn.wave#1.nosmoke])-exp(_b[LNalpha:3bn.wave])) ///
			(b27: 0) ///
			(b28: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#1.nosmoke])-exp(_b[LNalpha:4.wave])) ///
			(b29: 0) ///
			(b30: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#1.nosmoke])-exp(_b[LNalpha:41.wave])) ///
			(b31: 0) ///
			(b32: exp(_b[LNalpha:4.wave]+_b[LNalpha:4.wave#c.cases_adj])-exp(_b[LNalpha:4.wave])) ///
			(b33: exp(_b[LNalpha:41.wave]+_b[LNalpha:41.wave#c.cases_adj])-exp(_b[LNalpha:41.wave])) ///
				///
			(b34: exp(_b[LNbeta:3bn.wave])) ///
			(b35: exp(_b[LNbeta:4.wave])) ///
			(b36: exp(_b[LNbeta:41.wave])) ///
			(b37: 0) ///
			(b38: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#1.gender])-exp(_b[LNbeta:3bn.wave])) ///
			(b39: 0) ///
			(b40: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#1.gender])-exp(_b[LNbeta:4.wave])) ///
			(b41: 0) ///
			(b42: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#1.gender])-exp(_b[LNbeta:41.wave])) ///
			(b43: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#c.hsize])-exp(_b[LNbeta:3bn.wave])) ///
			(b44: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.hsize])-exp(_b[LNbeta:4.wave])) ///
			(b45: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.hsize])-exp(_b[LNbeta:41.wave])) ///
			(b46: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#c.age])-exp(_b[LNbeta:3bn.wave])) ///
			(b47: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.age])-exp(_b[LNbeta:4.wave])) ///
			(b48: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.age])-exp(_b[LNbeta:41.wave])) ///
			(b49: 0) ///
			(b50: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#4.income])-exp(_b[LNbeta:3bn.wave])) ///
			(b51: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#5.income])-exp(_b[LNbeta:3bn.wave])) ///
			(b52: 0) ///
			(b53: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#4.income])-exp(_b[LNbeta:4.wave])) ///
			(b54: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#5.income])-exp(_b[LNbeta:4.wave])) ///
			(b55: 0) ///
			(b56: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#4.income])-exp(_b[LNbeta:41.wave])) ///
			(b57: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#5.income])-exp(_b[LNbeta:41.wave])) ///
			(b58: 0) ///
			(b59: exp(_b[LNbeta:3bn.wave]+_b[LNbeta:3bn.wave#1.nosmoke])-exp(_b[LNbeta:3bn.wave])) ///
			(b60: 0) ///
			(b61: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#1.nosmoke])-exp(_b[LNbeta:4.wave])) ///
			(b62: 0) ///
			(b63: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#1.nosmoke])-exp(_b[LNbeta:41.wave])) ///
			(b64: 0) ///
			(b65: exp(_b[LNbeta:4.wave]+_b[LNbeta:4.wave#c.cases_adj])-exp(_b[LNbeta:4.wave])) ///
			(b66: exp(_b[LNbeta:41.wave]+_b[LNbeta:41.wave#c.cases_adj])-exp(_b[LNbeta:41.wave])) ///
			///
			(bmuRA: _b[muRA:_cons]) ///
			///
			(b67: exp(_b[kappaD:3bn.wave])) ///
			(b68: exp(_b[kappaD:4.wave])) ///
			(b69: exp(_b[kappaD:41.wave])) ///
			(b70: 0) ///
			(b71: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#1.gender])-exp(_b[kappaD:3bn.wave])) ///
			(b72: 0) ///
			(b73: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#1.gender])-exp(_b[kappaD:4.wave])) ///
			(b74: 0) ///
			(b75: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#1.gender])-exp(_b[kappaD:41.wave])) ///
			(b76: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#c.hsize])-exp(_b[kappaD:3bn.wave])) ///
			(b77: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.hsize])-exp(_b[kappaD:4.wave])) ///
			(b78: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.hsize])-exp(_b[kappaD:41.wave])) ///
			(b79: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#c.age])-exp(_b[kappaD:3bn.wave])) ///
			(b80: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.age])-exp(_b[kappaD:4.wave])) ///
			(b81: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.age])-exp(_b[kappaD:41.wave])) ///
			(b82: 0) ///
			(b83: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#4.income])-exp(_b[kappaD:3bn.wave])) ///
			(b84: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#5.income])-exp(_b[kappaD:3bn.wave])) ///
			(b85: 0) ///
			(b86: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#4.income])-exp(_b[kappaD:4.wave])) ///
			(b87: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#5.income])-exp(_b[kappaD:4.wave])) ///
			(b88: 0) ///
			(b89: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#4.income])-exp(_b[kappaD:41.wave])) ///
			(b90: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#5.income])-exp(_b[kappaD:41.wave])) ///
			(b91: 0) ///
			(b92: exp(_b[kappaD:3bn.wave]+_b[kappaD:3bn.wave#1.nosmoke])-exp(_b[kappaD:3bn.wave])) ///
			(b93: 0) ///
			(b94: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#1.nosmoke])-exp(_b[kappaD:4.wave])) ///
			(b95: 0) ///
			(b96: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#1.nosmoke])-exp(_b[kappaD:41.wave])) ///
			(b97: 0) ///
			(b98: exp(_b[kappaD:4.wave]+_b[kappaD:4.wave#c.cases_adj])-exp(_b[kappaD:4.wave])) ///
			(b99: exp(_b[kappaD:41.wave]+_b[kappaD:41.wave#c.cases_adj])-exp(_b[kappaD:41.wave])) 
	matrix temp=vecdiag(r(V))
			matrix b[1,34]=r(b)
			matrix V[1,34]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store chow_rdu_hyper_wv	
	
}
* Chow test
estimates restore chow_eut_expo_wv
test 	(_b[deltaD:3bn.wave#1.gender]=_b[deltaD:4.wave#1.gender]=_b[deltaD:41.wave#1.gender]) ///
		(_b[deltaD:3bn.wave#c.hsize]=_b[deltaD:4.wave#c.hsize]=_b[deltaD:41.wave#c.hsize])  ///
		(_b[deltaD:3bn.wave#c.age]=_b[deltaD:4.wave#c.age]=_b[deltaD:41.wave#c.age])  ///
		(_b[deltaD:3bn.wave#4.income]=_b[deltaD:4.wave#4.income]=_b[deltaD:41.wave#4.income])  ///
		(_b[deltaD:3bn.wave#5.income]=_b[deltaD:4.wave#5.income]=_b[deltaD:41.wave#5.income])  ///
		(_b[deltaD:3bn.wave#1.nosmoke]=_b[deltaD:4.wave#1.nosmoke]=_b[deltaD:41.wave#1.nosmoke])  ///
		(_b[deltaD:3bn.wave#c.cases_adj]=_b[deltaD:4.wave#c.cases_adj]=_b[deltaD:41.wave#c.cases_adj]) 
estimates restore chow_eut_hyper_wv
test 	(_b[kappaD:3bn.wave#1.gender]=_b[kappaD:4.wave#1.gender]=_b[kappaD:41.wave#1.gender]) ///
		(_b[kappaD:3bn.wave#c.hsize]=_b[kappaD:4.wave#c.hsize]=_b[kappaD:41.wave#c.hsize])  ///
		(_b[kappaD:3bn.wave#c.age]=_b[kappaD:4.wave#c.age]=_b[kappaD:41.wave#c.age])  ///
		(_b[kappaD:3bn.wave#4.income]=_b[kappaD:4.wave#4.income]=_b[kappaD:41.wave#4.income])  ///
		(_b[kappaD:3bn.wave#5.income]=_b[kappaD:4.wave#5.income]=_b[kappaD:41.wave#5.income])  ///
		(_b[kappaD:3bn.wave#1.nosmoke]=_b[kappaD:4.wave#1.nosmoke]=_b[kappaD:41.wave#1.nosmoke])  ///
		(_b[kappaD:3bn.wave#c.cases_adj]=_b[kappaD:4.wave#c.cases_adj]=_b[kappaD:41.wave#c.cases_adj]) 		
estimates restore chow_rdu_expo_wv		
test 	(_b[LNalpha:3bn.wave#1.gender]=_b[LNalpha:4.wave#1.gender]=_b[LNalpha:41.wave#1.gender]) ///
		(_b[LNalpha:3bn.wave#c.hsize]=_b[LNalpha:4.wave#c.hsize]=_b[LNalpha:41.wave#c.hsize])  ///
		(_b[LNalpha:3bn.wave#c.age]=_b[LNalpha:4.wave#c.age]=_b[LNalpha:41.wave#c.age])  ///
		(_b[LNalpha:3bn.wave#4.income]=_b[LNalpha:4.wave#4.income]=_b[LNalpha:41.wave#4.income])  ///
		(_b[LNalpha:3bn.wave#5.income]=_b[LNalpha:4.wave#5.income]=_b[LNalpha:41.wave#5.income])  ///
		(_b[LNalpha:3bn.wave#1.nosmoke]=_b[LNalpha:4.wave#1.nosmoke]=_b[LNalpha:41.wave#1.nosmoke])  ///
		(_b[LNalpha:3bn.wave#c.cases_adj]=_b[LNalpha:4.wave#c.cases_adj]=_b[LNalpha:41.wave#c.cases_adj]) 	///
		///
		(_b[LNbeta:3bn.wave#1.gender]=_b[LNbeta:4.wave#1.gender]=_b[LNbeta:41.wave#1.gender]) ///
		(_b[LNbeta:3bn.wave#c.hsize]=_b[LNbeta:4.wave#c.hsize]=_b[LNbeta:41.wave#c.hsize])  ///
		(_b[LNbeta:3bn.wave#c.age]=_b[LNbeta:4.wave#c.age]=_b[LNbeta:41.wave#c.age])  ///
		(_b[LNbeta:3bn.wave#4.income]=_b[LNbeta:4.wave#4.income]=_b[LNbeta:41.wave#4.income])  ///
		(_b[LNbeta:3bn.wave#5.income]=_b[LNbeta:4.wave#5.income]=_b[LNbeta:41.wave#5.income])  ///
		(_b[LNbeta:3bn.wave#1.nosmoke]=_b[LNbeta:4.wave#1.nosmoke]=_b[LNbeta:41.wave#1.nosmoke])  ///
		(_b[LNbeta:3bn.wave#c.cases_adj]=_b[LNbeta:4.wave#c.cases_adj]=_b[LNbeta:41.wave#c.cases_adj]) 	///
		///
		(_b[deltaD:3bn.wave#1.gender]=_b[deltaD:4.wave#1.gender]=_b[deltaD:41.wave#1.gender]) ///
		(_b[deltaD:3bn.wave#c.hsize]=_b[deltaD:4.wave#c.hsize]=_b[deltaD:41.wave#c.hsize])  ///
		(_b[deltaD:3bn.wave#c.age]=_b[deltaD:4.wave#c.age]=_b[deltaD:41.wave#c.age])  ///
		(_b[deltaD:3bn.wave#4.income]=_b[deltaD:4.wave#4.income]=_b[deltaD:41.wave#4.income])  ///
		(_b[deltaD:3bn.wave#5.income]=_b[deltaD:4.wave#5.income]=_b[deltaD:41.wave#5.income])  ///
		(_b[deltaD:3bn.wave#1.nosmoke]=_b[deltaD:4.wave#1.nosmoke]=_b[deltaD:41.wave#1.nosmoke])  ///
		(_b[deltaD:3bn.wave#c.cases_adj]=_b[deltaD:4.wave#c.cases_adj]=_b[deltaD:41.wave#c.cases_adj]) 
estimates restore chow_rdu_hyper_wv		
test 	(_b[LNalpha:3bn.wave#1.gender]=_b[LNalpha:4.wave#1.gender]=_b[LNalpha:41.wave#1.gender]) ///
		(_b[LNalpha:3bn.wave#c.hsize]=_b[LNalpha:4.wave#c.hsize]=_b[LNalpha:41.wave#c.hsize])  ///
		(_b[LNalpha:3bn.wave#c.age]=_b[LNalpha:4.wave#c.age]=_b[LNalpha:41.wave#c.age])  ///
		(_b[LNalpha:3bn.wave#4.income]=_b[LNalpha:4.wave#4.income]=_b[LNalpha:41.wave#4.income])  ///
		(_b[LNalpha:3bn.wave#5.income]=_b[LNalpha:4.wave#5.income]=_b[LNalpha:41.wave#5.income])  ///
		(_b[LNalpha:3bn.wave#1.nosmoke]=_b[LNalpha:4.wave#1.nosmoke]=_b[LNalpha:41.wave#1.nosmoke])  ///
		(_b[LNalpha:3bn.wave#c.cases_adj]=_b[LNalpha:4.wave#c.cases_adj]=_b[LNalpha:41.wave#c.cases_adj]) 	///
		///
		(_b[LNbeta:3bn.wave#1.gender]=_b[LNbeta:4.wave#1.gender]=_b[LNbeta:41.wave#1.gender]) ///
		(_b[LNbeta:3bn.wave#c.hsize]=_b[LNbeta:4.wave#c.hsize]=_b[LNbeta:41.wave#c.hsize])  ///
		(_b[LNbeta:3bn.wave#c.age]=_b[LNbeta:4.wave#c.age]=_b[LNbeta:41.wave#c.age])  ///
		(_b[LNbeta:3bn.wave#4.income]=_b[LNbeta:4.wave#4.income]=_b[LNbeta:41.wave#4.income])  ///
		(_b[LNbeta:3bn.wave#5.income]=_b[LNbeta:4.wave#5.income]=_b[LNbeta:41.wave#5.income])  ///
		(_b[LNbeta:3bn.wave#1.nosmoke]=_b[LNbeta:4.wave#1.nosmoke]=_b[LNbeta:41.wave#1.nosmoke])  ///
		(_b[LNbeta:3bn.wave#c.cases_adj]=_b[LNbeta:4.wave#c.cases_adj]=_b[LNbeta:41.wave#c.cases_adj]) 	///
		///
		(_b[kappaD:3bn.wave#1.gender]=_b[kappaD:4.wave#1.gender]=_b[kappaD:41.wave#1.gender]) ///
		(_b[kappaD:3bn.wave#c.hsize]=_b[kappaD:4.wave#c.hsize]=_b[kappaD:41.wave#c.hsize])  ///
		(_b[kappaD:3bn.wave#c.age]=_b[kappaD:4.wave#c.age]=_b[kappaD:41.wave#c.age])  ///
		(_b[kappaD:3bn.wave#4.income]=_b[kappaD:4.wave#4.income]=_b[kappaD:41.wave#4.income])  ///
		(_b[kappaD:3bn.wave#5.income]=_b[kappaD:4.wave#5.income]=_b[kappaD:41.wave#5.income])  ///
		(_b[kappaD:3bn.wave#1.nosmoke]=_b[kappaD:4.wave#1.nosmoke]=_b[kappaD:41.wave#1.nosmoke])  ///
		(_b[kappaD:3bn.wave#c.cases_adj]=_b[kappaD:4.wave#c.cases_adj]=_b[kappaD:41.wave#c.cases_adj]) 		