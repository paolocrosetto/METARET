* Joint significance tests Table 8
estimates restore demog_wv_eut_expo
test _b[r:4.wave]=_b[r:41.wave]=_b[deltaD:4.wave]=_b[deltaD:41.wave]=0
estimates restore demog_wv_rdu_expo 
test _b[r:4.wave]=_b[r:41.wave]=_b[LNalpha:4.wave]=_b[LNalpha:41.wave]=_b[LNbeta:4.wave]=_b[LNbeta:41.wave]=_b[deltaD:4.wave]=_b[deltaD:41.wave]=0
estimates restore demog_ev_eut_expo
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]=_b[deltaD:2.events]=_b[deltaD:3.events]=_b[deltaD:4.events]=_b[deltaD:5.events]=_b[deltaD:6.events]=0
estimates restore demog_ev_rdu_expo 
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]= ///
_b[LNalpha:2.events]=_b[LNalpha:3.events]=_b[LNalpha:4.events]=_b[LNalpha:5.events]=_b[LNalpha:6.events]= ///
_b[LNbeta:2.events]=_b[LNbeta:3.events]=_b[LNbeta:4.events]=_b[LNbeta:5.events]=_b[LNbeta:6.events]= ///
_b[deltaD:2.events]=_b[deltaD:3.events]=_b[deltaD:4.events]=_b[deltaD:5.events]=_b[deltaD:6.events]=0

* Joint significance tests Table 9
estimates restore demog_wv_eut_hyper
test _b[r:4.wave]=_b[r:41.wave]=_b[kappaD:4.wave]=_b[kappaD:41.wave]=0
estimates restore demog_wv_rdu_hyper 
test _b[r:4.wave]=_b[r:41.wave]=_b[LNalpha:4.wave]=_b[LNalpha:41.wave]=_b[LNbeta:4.wave]=_b[LNbeta:41.wave]=_b[kappaD:4.wave]=_b[kappaD:41.wave]=0
estimates restore demog_ev_eut_hyper
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]=_b[kappaD:2.events]=_b[kappaD:3.events]=_b[kappaD:4.events]=_b[kappaD:5.events]=_b[kappaD:6.events]=0
estimates restore demog_ev_rdu_hyper 
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]= ///
_b[LNalpha:2.events]=_b[LNalpha:3.events]=_b[LNalpha:4.events]=_b[LNalpha:5.events]=_b[LNalpha:6.events]= ///
_b[LNbeta:2.events]=_b[LNbeta:3.events]=_b[LNbeta:4.events]=_b[LNbeta:5.events]=_b[LNbeta:6.events]= ///
_b[kappaD:2.events]=_b[kappaD:3.events]=_b[kappaD:4.events]=_b[kappaD:5.events]=_b[kappaD:6.events]=0

* Test whether RDU collapses to EUT (test whether a=b=1 in the Prelec prob weighting function) 
* Results are reported in Tables 8 and 9
foreach model in demog_wv_rdu_expo demog_wv_rdu_hyper {
estimates restore `model'
test (_b[LNalpha:4.wave]=_b[LNalpha:41.wave]=_b[LNalpha:1.gender]=_b[LNalpha:hsize]=_b[LNalpha:age]=_b[LNalpha:4.income]=_b[LNalpha:5.income]=_b[LNalpha:1.nosmoke]=_b[LNalpha:cases_adj]=0) (_b[LNalpha:_cons]=1) (_b[LNbeta:4.wave]=_b[LNbeta:41.wave]=_b[LNbeta:1.gender]=_b[LNbeta:hsize]=_b[LNbeta:age]=_b[LNbeta:4.income]=_b[LNbeta:5.income]=_b[LNbeta:1.nosmoke]=_b[LNbeta:cases_adj]=0) (_b[LNbeta:_cons]=1), mtest(bonferroni)
}

foreach model in demog_ev_rdu_expo demog_ev_rdu_hyper {
estimates restore `model'
test (_b[LNalpha:2.events]=_b[LNalpha:3.events]=_b[LNalpha:4.events]=_b[LNalpha:5.events]=_b[LNalpha:6.events]=_b[LNalpha:1.gender]=_b[LNalpha:hsize]=_b[LNalpha:age]=_b[LNalpha:4.income]=_b[LNalpha:5.income]=_b[LNalpha:1.nosmoke]=_b[LNalpha:cases_adj]=0) (_b[LNalpha:_cons]=1) (_b[LNbeta:2.events]=_b[LNbeta:3.events]=_b[LNbeta:4.events]=_b[LNbeta:5.events]=_b[LNbeta:6.events]=_b[LNbeta:1.gender]=_b[LNbeta:hsize]=_b[LNbeta:age]=_b[LNbeta:4.income]=_b[LNbeta:5.income]=_b[LNbeta:1.nosmoke]=_b[LNbeta:cases_adj]=0) (_b[LNbeta:_cons]=1), mtest(bonferroni)
}