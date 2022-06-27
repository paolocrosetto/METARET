estimates restore demog_wv_eut_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([deltaD]_b[_cons]+[deltaD]_b[4.wave])-exp([deltaD]_b[_cons])) ///
			(b2:  exp([deltaD]_b[_cons]+[deltaD]_b[41.wave])-exp([deltaD]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b5:  exp([deltaD]_b[_cons]+[deltaD]_b[hsize])-exp([deltaD]_b[_cons])) ///
			(b6:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([deltaD]_b[_cons]+[deltaD]_b[4.income])-exp([deltaD]_b[_cons])) ///
			(b9:  exp([deltaD]_b[_cons]+[deltaD]_b[5.income])-exp([deltaD]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b12:  exp([deltaD]_b[_cons]+[deltaD]_b[cases_adj])-exp([deltaD]_b[_cons])) ///
			(b13:  exp([deltaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,17]=r(b)
			matrix V[1,17]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store demog_wv_eut_expo

estimates restore demog_wv_eut_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([kappaD]_b[_cons]+[kappaD]_b[4.wave])-exp([kappaD]_b[_cons])) ///
			(b2:  exp([kappaD]_b[_cons]+[kappaD]_b[41.wave])-exp([kappaD]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b5:  exp([kappaD]_b[_cons]+[kappaD]_b[hsize])-exp([kappaD]_b[_cons])) ///
			(b6:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([kappaD]_b[_cons]+[kappaD]_b[4.income])-exp([kappaD]_b[_cons])) ///
			(b9:  exp([kappaD]_b[_cons]+[kappaD]_b[5.income])-exp([kappaD]_b[_cons])) ///
			(b10: 0) ///
			(b11: exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b12: exp([kappaD]_b[_cons]+[kappaD]_b[cases_adj])-exp([kappaD]_b[_cons])) ///
			(b13: exp([kappaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,17]=r(b)
			matrix V[1,17]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store demog_wv_eut_hyper

estimates restore demog_wv_rdu_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.wave])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[41.wave])-exp([LNalpha]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b9:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b10: 0) ///
			(b11: exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b12: exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b13: exp([LNalpha]_b[_cons])) ///
			 ///
			(b14:  0) ///
			(b15:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.wave])-exp([LNbeta]_b[_cons])) ///
			(b16:  exp([LNbeta]_b[_cons]+[LNbeta]_b[41.wave])-exp([LNbeta]_b[_cons])) ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b21:  0) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b23:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b24: 0) ///
			(b25: exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b26: exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b27: exp([LNbeta]_b[_cons])) ///
			///
			(b28: [muRA]_b[_cons]) ///
			///
			(b29:  0) ///
			(b30:  exp([deltaD]_b[_cons]+[deltaD]_b[4.wave])-exp([deltaD]_b[_cons])) ///
			(b31:  exp([deltaD]_b[_cons]+[deltaD]_b[41.wave])-exp([deltaD]_b[_cons])) ///
			(b32:  0) ///
			(b33:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b34:  exp([deltaD]_b[_cons]+[deltaD]_b[hsize])-exp([deltaD]_b[_cons])) ///
			(b35:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b36:  0) ///
			(b37:  exp([deltaD]_b[_cons]+[deltaD]_b[4.income])-exp([deltaD]_b[_cons])) ///
			(b38:  exp([deltaD]_b[_cons]+[deltaD]_b[5.income])-exp([deltaD]_b[_cons])) ///
			(b39: 0) ///
			(b40: exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b41: exp([deltaD]_b[_cons]+[deltaD]_b[cases_adj])-exp([deltaD]_b[_cons])) ///
			(b42: exp([deltaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,16]=r(b)
			matrix V[1,16]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store demog_wv_rdu_expo

estimates restore demog_wv_rdu_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.wave])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[41.wave])-exp([LNalpha]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b9:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b10: 0) ///
			(b11: exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b12: exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b13: exp([LNalpha]_b[_cons])) ///
			 ///
			(b14:  0) ///
			(b15:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.wave])-exp([LNbeta]_b[_cons])) ///
			(b16:  exp([LNbeta]_b[_cons]+[LNbeta]_b[41.wave])-exp([LNbeta]_b[_cons])) ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b21:  0) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b23:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b24: 0) ///
			(b25: exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b26: exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b27: exp([LNbeta]_b[_cons])) ///
			///
			(b28: [muRA]_b[_cons]) ///
			///
			(b29:  0) ///
			(b30:  exp([kappaD]_b[_cons]+[kappaD]_b[4.wave])-exp([kappaD]_b[_cons])) ///
			(b31:  exp([kappaD]_b[_cons]+[kappaD]_b[41.wave])-exp([kappaD]_b[_cons])) ///
			(b32:  0) ///
			(b33:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b34:  exp([kappaD]_b[_cons]+[kappaD]_b[hsize])-exp([kappaD]_b[_cons])) ///
			(b35:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b36:  0) ///
			(b37:  exp([kappaD]_b[_cons]+[kappaD]_b[4.income])-exp([kappaD]_b[_cons])) ///
			(b38:  exp([kappaD]_b[_cons]+[kappaD]_b[5.income])-exp([kappaD]_b[_cons])) ///
			(b39: 0) ///
			(b40: exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b41: exp([kappaD]_b[_cons]+[kappaD]_b[cases_adj])-exp([kappaD]_b[_cons])) ///
			(b42: exp([kappaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,16]=r(b)
			matrix V[1,16]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store demog_wv_rdu_hyper

estimates restore demog_ev_eut_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([deltaD]_b[_cons]+[deltaD]_b[2.events])-exp([deltaD]_b[_cons])) ///
			(b2:  exp([deltaD]_b[_cons]+[deltaD]_b[3.events])-exp([deltaD]_b[_cons])) ///
			(b3:  exp([deltaD]_b[_cons]+[deltaD]_b[4.events])-exp([deltaD]_b[_cons])) ///
			(b4:  exp([deltaD]_b[_cons]+[deltaD]_b[5.events])-exp([deltaD]_b[_cons])) ///
			(b5:  exp([deltaD]_b[_cons]+[deltaD]_b[6.events])-exp([deltaD]_b[_cons])) ///
			(b6:  0) ///
			(b7:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b8:  exp([deltaD]_b[_cons]+[deltaD]_b[hsize])-exp([deltaD]_b[_cons])) ///
			(b9:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([deltaD]_b[_cons]+[deltaD]_b[4.income])-exp([deltaD]_b[_cons])) ///
			(b12:  exp([deltaD]_b[_cons]+[deltaD]_b[5.income])-exp([deltaD]_b[_cons])) ///
			(b13:  0) ///
			(b14:  exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b15:  exp([deltaD]_b[_cons]+[deltaD]_b[cases_adj])-exp([deltaD]_b[_cons])) ///
			(b16:  exp([deltaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,20]=r(b)
			matrix V[1,20]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store demog_ev_eut_expo

estimates restore demog_ev_eut_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([kappaD]_b[_cons]+[kappaD]_b[2.events])-exp([kappaD]_b[_cons])) ///
			(b2:  exp([kappaD]_b[_cons]+[kappaD]_b[3.events])-exp([kappaD]_b[_cons])) ///
			(b3:  exp([kappaD]_b[_cons]+[kappaD]_b[4.events])-exp([kappaD]_b[_cons])) ///
			(b4:  exp([kappaD]_b[_cons]+[kappaD]_b[5.events])-exp([kappaD]_b[_cons])) ///
			(b5:  exp([kappaD]_b[_cons]+[kappaD]_b[6.events])-exp([kappaD]_b[_cons])) ///
			(b6:  0) ///
			(b7:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b8:  exp([kappaD]_b[_cons]+[kappaD]_b[hsize])-exp([kappaD]_b[_cons])) ///
			(b9:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([kappaD]_b[_cons]+[kappaD]_b[4.income])-exp([kappaD]_b[_cons])) ///
			(b12:  exp([kappaD]_b[_cons]+[kappaD]_b[5.income])-exp([kappaD]_b[_cons])) ///
			(b13:  0) ///
			(b14:  exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b15:  exp([kappaD]_b[_cons]+[kappaD]_b[cases_adj])-exp([kappaD]_b[_cons])) ///
			(b16:  exp([kappaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,20]=r(b)
			matrix V[1,20]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store demog_ev_eut_hyper

estimates restore demog_ev_rdu_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[2.events])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.events])-exp([LNalpha]_b[_cons])) ///
			(b3:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.events])-exp([LNalpha]_b[_cons])) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.events])-exp([LNalpha]_b[_cons])) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[6.events])-exp([LNalpha]_b[_cons])) ///
			(b6:  0) ///
			(b7:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b9:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b12:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b13: 0) ///
			(b14: exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b15: exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b16: exp([LNalpha]_b[_cons])) ///
			 ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[2.events])-exp([LNbeta]_b[_cons])) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.events])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.events])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.events])-exp([LNbeta]_b[_cons])) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[6.events])-exp([LNbeta]_b[_cons])) ///
			(b23:  0) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b25:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b27:  0) ///
			(b28:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b29:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b30: 0) ///
			(b31: exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b32: exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b33: exp([LNbeta]_b[_cons])) ///
			///
			(b34: [muRA]_b[_cons]) ///
			///
			(b35:  0) ///
			(b36:  exp([deltaD]_b[_cons]+[deltaD]_b[2.events])-exp([deltaD]_b[_cons])) ///
			(b37:  exp([deltaD]_b[_cons]+[deltaD]_b[3.events])-exp([deltaD]_b[_cons])) ///
			(b38:  exp([deltaD]_b[_cons]+[deltaD]_b[4.events])-exp([deltaD]_b[_cons])) ///
			(b39:  exp([deltaD]_b[_cons]+[deltaD]_b[5.events])-exp([deltaD]_b[_cons])) ///
			(b40:  exp([deltaD]_b[_cons]+[deltaD]_b[6.events])-exp([deltaD]_b[_cons])) ///
			(b41:  0) ///
			(b42:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b43:  exp([deltaD]_b[_cons]+[deltaD]_b[hsize])-exp([deltaD]_b[_cons])) ///
			(b44:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b45:  0) ///
			(b46:  exp([deltaD]_b[_cons]+[deltaD]_b[4.income])-exp([deltaD]_b[_cons])) ///
			(b47:  exp([deltaD]_b[_cons]+[deltaD]_b[5.income])-exp([deltaD]_b[_cons])) ///
			(b48: 0) ///
			(b49: exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b50: exp([deltaD]_b[_cons]+[deltaD]_b[cases_adj])-exp([deltaD]_b[_cons])) ///
			(b51: exp([deltaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,19]=r(b)
			matrix V[1,19]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store demog_ev_rdu_expo

estimates restore demog_ev_rdu_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[2.events])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.events])-exp([LNalpha]_b[_cons])) ///
			(b3:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.events])-exp([LNalpha]_b[_cons])) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.events])-exp([LNalpha]_b[_cons])) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[6.events])-exp([LNalpha]_b[_cons])) ///
			(b6:  0) ///
			(b7:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b9:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b12:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b13: 0) ///
			(b14: exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b15: exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b16: exp([LNalpha]_b[_cons])) ///
			 ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[2.events])-exp([LNbeta]_b[_cons])) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.events])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.events])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.events])-exp([LNbeta]_b[_cons])) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[6.events])-exp([LNbeta]_b[_cons])) ///
			(b23:  0) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b25:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b27:  0) ///
			(b28:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b29:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b30: 0) ///
			(b31: exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b32: exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b33: exp([LNbeta]_b[_cons])) ///
			///
			(b34: [muRA]_b[_cons]) ///
			///
			(b35:  0) ///
			(b36:  exp([kappaD]_b[_cons]+[kappaD]_b[2.events])-exp([kappaD]_b[_cons])) ///
			(b37:  exp([kappaD]_b[_cons]+[kappaD]_b[3.events])-exp([kappaD]_b[_cons])) ///
			(b38:  exp([kappaD]_b[_cons]+[kappaD]_b[4.events])-exp([kappaD]_b[_cons])) ///
			(b39:  exp([kappaD]_b[_cons]+[kappaD]_b[5.events])-exp([kappaD]_b[_cons])) ///
			(b40:  exp([kappaD]_b[_cons]+[kappaD]_b[6.events])-exp([kappaD]_b[_cons])) ///
			(b41:  0) ///
			(b42:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b43:  exp([kappaD]_b[_cons]+[kappaD]_b[hsize])-exp([kappaD]_b[_cons])) ///
			(b44:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b45:  0) ///
			(b46:  exp([kappaD]_b[_cons]+[kappaD]_b[4.income])-exp([kappaD]_b[_cons])) ///
			(b47:  exp([kappaD]_b[_cons]+[kappaD]_b[5.income])-exp([kappaD]_b[_cons])) ///
			(b48: 0) ///
			(b49: exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b50: exp([kappaD]_b[_cons]+[kappaD]_b[cases_adj])-exp([kappaD]_b[_cons])) ///
			(b51: exp([kappaD]_b[_cons])) 		
	matrix temp=vecdiag(r(V))
			matrix b[1,19]=r(b)
			matrix V[1,19]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct
estimates store demog_ev_rdu_hyper

estimates restore corona_eut_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:   exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b2:   exp([deltaD]_b[_cons]+[deltaD]_b[hsize])-exp([deltaD]_b[_cons])) ///
			(b3:   exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b4:   0) ///
			(b5:   exp([deltaD]_b[_cons]+[deltaD]_b[4.income])-exp([deltaD]_b[_cons])) ///
			(b6:   exp([deltaD]_b[_cons]+[deltaD]_b[5.income])-exp([deltaD]_b[_cons])) ///
			(b7:   0) ///
			(b8:   exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b9:   exp([deltaD]_b[_cons]+[deltaD]_b[cases_adj])-exp([deltaD]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([deltaD]_b[_cons]+[deltaD]_b[3.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b12:  exp([deltaD]_b[_cons]+[deltaD]_b[4.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b13:  exp([deltaD]_b[_cons]+[deltaD]_b[5.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b14: 0) ///
			(b15:  exp([deltaD]_b[_cons]+[deltaD]_b[2.corona_highrisk])-exp([deltaD]_b[_cons])) ///			
			(b16:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_stress])-exp([deltaD]_b[_cons])) ///
			(b17:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_conspiracy])-exp([deltaD]_b[_cons])) ///
			(b18:  exp([deltaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,22]=r(b)
			matrix V[1,22]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store corona_eut_expo

estimates restore corona_eut_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:   exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b2:   exp([kappaD]_b[_cons]+[kappaD]_b[hsize])-exp([kappaD]_b[_cons])) ///
			(b3:   exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b4:   0) ///
			(b5:   exp([kappaD]_b[_cons]+[kappaD]_b[4.income])-exp([kappaD]_b[_cons])) ///
			(b6:   exp([kappaD]_b[_cons]+[kappaD]_b[5.income])-exp([kappaD]_b[_cons])) ///
			(b7:   0) ///
			(b8:   exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b9:   exp([kappaD]_b[_cons]+[kappaD]_b[cases_adj])-exp([kappaD]_b[_cons])) ///
			(b10:  0) ///
			(b11:  exp([kappaD]_b[_cons]+[kappaD]_b[3.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b12:  exp([kappaD]_b[_cons]+[kappaD]_b[4.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b13:  exp([kappaD]_b[_cons]+[kappaD]_b[5.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b14: 0) ///
			(b15:  exp([kappaD]_b[_cons]+[kappaD]_b[2.corona_highrisk])-exp([kappaD]_b[_cons])) ///			
			(b16:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_stress])-exp([kappaD]_b[_cons])) ///
			(b17:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_conspiracy])-exp([kappaD]_b[_cons])) ///
			(b18:  exp([kappaD]_b[_cons]))
	matrix temp=vecdiag(r(V))
			matrix b[1,22]=r(b)
			matrix V[1,22]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale
estimates store corona_eut_hyper

estimates restore corona_restrict_rdu_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b5:  0) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b7:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b9:  0) ///
			(b10: exp([LNalpha]_b[_cons]+[LNalpha]_b[2.corona_highrisk])-exp([LNalpha]_b[_cons])) ///			
			(b11: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_stress])-exp([LNalpha]_b[_cons])) ///
			(b12: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_conspiracy])-exp([LNalpha]_b[_cons])) ///
			(b13: exp([LNalpha]_b[_cons])) ///
			///
			(b14: 0) ///
			(b15:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b16:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b19:  0) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b23:  0) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[2.corona_highrisk])-exp([LNbeta]_b[_cons])) ///			
			(b25:  exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_stress])-exp([LNbeta]_b[_cons])) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_conspiracy])-exp([LNbeta]_b[_cons])) ///
			(b27:  exp([LNbeta]_b[_cons])) ///
			(b28:  [muRA]_b[_cons]) ///
			///
			(b28:  0) ///
			(b29:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b30:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b31:  0) ///
			(b32:  exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b33:  0) ///
			(b34:  exp([deltaD]_b[_cons]+[deltaD]_b[3.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b35:  exp([deltaD]_b[_cons]+[deltaD]_b[4.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b36:  exp([deltaD]_b[_cons]+[deltaD]_b[5.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b37:  0) ///
			(b38:  exp([deltaD]_b[_cons]+[deltaD]_b[2.corona_highrisk])-exp([deltaD]_b[_cons])) ///			
			(b39:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_stress])-exp([deltaD]_b[_cons])) ///
			(b40:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_conspiracy])-exp([deltaD]_b[_cons])) ///
			(b41:  exp([deltaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,16]=r(b)
			matrix V[1,16]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store corona_restrict_rdu_expo

estimates restore corona_restrict_rdu_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b3:  0) ///
			(b4:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b5:  0) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b7:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b9:  0) ///
			(b10: exp([LNalpha]_b[_cons]+[LNalpha]_b[2.corona_highrisk])-exp([LNalpha]_b[_cons])) ///			
			(b11: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_stress])-exp([LNalpha]_b[_cons])) ///
			(b12: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_conspiracy])-exp([LNalpha]_b[_cons])) ///
			(b13: exp([LNalpha]_b[_cons])) ///
			///
			(b14: 0) ///
			(b15:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b16:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b17:  0) ///
			(b18:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b19:  0) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b22:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b23:  0) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[2.corona_highrisk])-exp([LNbeta]_b[_cons])) ///			
			(b25:  exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_stress])-exp([LNbeta]_b[_cons])) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_conspiracy])-exp([LNbeta]_b[_cons])) ///
			(b27:  exp([LNbeta]_b[_cons])) ///
			(b28:  [muRA]_b[_cons]) ///
			///
			(b28:  0) ///
			(b29:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b30:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b31:  0) ///
			(b32:  exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b33:  0) ///
			(b34:  exp([kappaD]_b[_cons]+[kappaD]_b[3.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b35:  exp([kappaD]_b[_cons]+[kappaD]_b[4.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b36:  exp([kappaD]_b[_cons]+[kappaD]_b[5.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b37:  0) ///
			(b38:  exp([kappaD]_b[_cons]+[kappaD]_b[2.corona_highrisk])-exp([kappaD]_b[_cons])) ///			
			(b39:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_stress])-exp([kappaD]_b[_cons])) ///
			(b40:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_conspiracy])-exp([kappaD]_b[_cons])) ///
			(b41:  exp([kappaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,16]=r(b)
			matrix V[1,16]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store corona_restrict_rdu_hyper

estimates restore corona_rdu_expo
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b3:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b4:  0) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b81:  exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b9:  0) ///
			(b10:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b11:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b12:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b13:  0) ///
			(b14: exp([LNalpha]_b[_cons]+[LNalpha]_b[2.corona_highrisk])-exp([LNalpha]_b[_cons])) ///			
			(b15: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_stress])-exp([LNalpha]_b[_cons])) ///
			(b16: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_conspiracy])-exp([LNalpha]_b[_cons])) ///
			(b17: exp([LNalpha]_b[_cons])) ///
			///
			(b18: 0) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b22:  0) ///
			(b23:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b25:  0) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b26a:  exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b27:  0) ///
			(b28:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b29:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b30:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b31:  0) ///
			(b32: exp([LNbeta]_b[_cons]+[LNbeta]_b[2.corona_highrisk])-exp([LNbeta]_b[_cons])) ///			
			(b33: exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_stress])-exp([LNbeta]_b[_cons])) ///
			(b34: exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_conspiracy])-exp([LNbeta]_b[_cons])) ///
			(b35: exp([LNbeta]_b[_cons])) ///
			(b36:  [muRA]_b[_cons]) ///
			///
			(b37:  0) ///
			(b38:  exp([deltaD]_b[_cons]+[deltaD]_b[1.gender])-exp([deltaD]_b[_cons])) ///
			(b39:  exp([deltaD]_b[_cons]+[deltaD]_b[age])-exp([deltaD]_b[_cons])) ///
			(b40:  0) ///
			(b41:  exp([deltaD]_b[_cons]+[deltaD]_b[1.nosmoke])-exp([deltaD]_b[_cons])) ///
			(b42:  0) ///
			(b43:  exp([deltaD]_b[_cons]+[deltaD]_b[3.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b44:  exp([deltaD]_b[_cons]+[deltaD]_b[4.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b45:  exp([deltaD]_b[_cons]+[deltaD]_b[5.corona_social_dist])-exp([deltaD]_b[_cons])) ///
			(b46:  0) ///
			(b47:  exp([deltaD]_b[_cons]+[deltaD]_b[2.corona_highrisk])-exp([deltaD]_b[_cons])) ///			
			(b48:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_stress])-exp([deltaD]_b[_cons])) ///
			(b49:  exp([deltaD]_b[_cons]+[deltaD]_b[corona_conspiracy])-exp([deltaD]_b[_cons])) ///
			(b50:  exp([deltaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,21]=r(b)
			matrix V[1,21]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store corona_rdu_expo

estimates restore corona_rdu_hyper
	matrix b=e(b)
	matrix V=vecdiag(e(V))
	nlcom   (b1:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.gender])-exp([LNalpha]_b[_cons])) ///
			(b2:  exp([LNalpha]_b[_cons]+[LNalpha]_b[age])-exp([LNalpha]_b[_cons])) ///
			(b3:  exp([LNalpha]_b[_cons]+[LNalpha]_b[hsize])-exp([LNalpha]_b[_cons])) ///
			(b4:  0) ///
			(b5:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.income])-exp([LNalpha]_b[_cons])) ///
			(b6:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.income])-exp([LNalpha]_b[_cons])) ///
			(b7:  0) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[1.nosmoke])-exp([LNalpha]_b[_cons])) ///
			(b8:  exp([LNalpha]_b[_cons]+[LNalpha]_b[cases_adj])-exp([LNalpha]_b[_cons])) ///
			(b9:  0) ///
			(b10:  exp([LNalpha]_b[_cons]+[LNalpha]_b[3.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b11:  exp([LNalpha]_b[_cons]+[LNalpha]_b[4.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b12:  exp([LNalpha]_b[_cons]+[LNalpha]_b[5.corona_social_dist])-exp([LNalpha]_b[_cons])) ///
			(b13:  0) ///
			(b14: exp([LNalpha]_b[_cons]+[LNalpha]_b[2.corona_highrisk])-exp([LNalpha]_b[_cons])) ///			
			(b15: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_stress])-exp([LNalpha]_b[_cons])) ///
			(b16: exp([LNalpha]_b[_cons]+[LNalpha]_b[corona_conspiracy])-exp([LNalpha]_b[_cons])) ///
			(b17: exp([LNalpha]_b[_cons])) ///
			///
			(b18: 0) ///
			(b19:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.gender])-exp([LNbeta]_b[_cons])) ///
			(b20:  exp([LNbeta]_b[_cons]+[LNbeta]_b[age])-exp([LNbeta]_b[_cons])) ///
			(b21:  exp([LNbeta]_b[_cons]+[LNbeta]_b[hsize])-exp([LNbeta]_b[_cons])) ///
			(b22:  0) ///
			(b23:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.income])-exp([LNbeta]_b[_cons])) ///
			(b24:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.income])-exp([LNbeta]_b[_cons])) ///
			(b25:  0) ///
			(b26:  exp([LNbeta]_b[_cons]+[LNbeta]_b[1.nosmoke])-exp([LNbeta]_b[_cons])) ///
			(b26a:  exp([LNbeta]_b[_cons]+[LNbeta]_b[cases_adj])-exp([LNbeta]_b[_cons])) ///
			(b27:  0) ///
			(b28:  exp([LNbeta]_b[_cons]+[LNbeta]_b[3.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b29:  exp([LNbeta]_b[_cons]+[LNbeta]_b[4.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b30:  exp([LNbeta]_b[_cons]+[LNbeta]_b[5.corona_social_dist])-exp([LNbeta]_b[_cons])) ///
			(b31:  0) ///
			(b32: exp([LNbeta]_b[_cons]+[LNbeta]_b[2.corona_highrisk])-exp([LNbeta]_b[_cons])) ///			
			(b33: exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_stress])-exp([LNbeta]_b[_cons])) ///
			(b34: exp([LNbeta]_b[_cons]+[LNbeta]_b[corona_conspiracy])-exp([LNbeta]_b[_cons])) ///
			(b35: exp([LNbeta]_b[_cons])) ///
			(b36:  [muRA]_b[_cons]) ///
			///
			(b37:  0) ///
			(b38:  exp([kappaD]_b[_cons]+[kappaD]_b[1.gender])-exp([kappaD]_b[_cons])) ///
			(b39:  exp([kappaD]_b[_cons]+[kappaD]_b[age])-exp([kappaD]_b[_cons])) ///
			(b40:  0) ///
			(b41:  exp([kappaD]_b[_cons]+[kappaD]_b[1.nosmoke])-exp([kappaD]_b[_cons])) ///
			(b42:  0) ///
			(b43:  exp([kappaD]_b[_cons]+[kappaD]_b[3.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b44:  exp([kappaD]_b[_cons]+[kappaD]_b[4.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b45:  exp([kappaD]_b[_cons]+[kappaD]_b[5.corona_social_dist])-exp([kappaD]_b[_cons])) ///
			(b46:  0) ///
			(b47:  exp([kappaD]_b[_cons]+[kappaD]_b[2.corona_highrisk])-exp([kappaD]_b[_cons])) ///			
			(b48:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_stress])-exp([kappaD]_b[_cons])) ///
			(b49:  exp([kappaD]_b[_cons]+[kappaD]_b[corona_conspiracy])-exp([kappaD]_b[_cons])) ///
			(b50:  exp([kappaD]_b[_cons])) 	
	matrix temp=vecdiag(r(V))
			matrix b[1,21]=r(b)
			matrix V[1,21]=temp		
	mat V=diag(V)
	erepost b=b V=V
ml display	// The displayed coefficients are now in the correct scale			
estimates store corona_rdu_hyper