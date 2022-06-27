* Joint significance tests (Tables in Appendix)
estimates restore wv_linear_Expo_subsmpl 
test _b[r:4.wave]=_b[r:41.wave]=_b[deltaD:4.wave]=_b[deltaD:41.wave]=0
estimates restore wv_gprelec_Expo_subsmpl 
test _b[r:4.wave]=_b[r:41.wave]=_b[LNalphapr:4.wave]=_b[LNalphapr:41.wave]=_b[LNbetapr:4.wave]=_b[LNbetapr:41.wave]=_b[deltaD:4.wave]=_b[deltaD:41.wave]=0
estimates restore ev_linear_Expo_subsmpl 
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]=_b[deltaD:2.events]=_b[deltaD:3.events]=_b[deltaD:4.events]=_b[deltaD:5.events]=_b[deltaD:6.events]=0
estimates restore ev_gprelec_Expo_subsmpl 
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]= ///
_b[LNalphapr:2.events]=_b[LNalphapr:3.events]=_b[LNalphapr:4.events]=_b[LNalphapr:5.events]=_b[LNalphapr:6.events]= ///
_b[LNbetapr:2.events]=_b[LNbetapr:3.events]=_b[LNbetapr:4.events]=_b[LNbetapr:5.events]=_b[LNbetapr:6.events]= ///
_b[deltaD:2.events]=_b[deltaD:3.events]=_b[deltaD:4.events]=_b[deltaD:5.events]=_b[deltaD:6.events]=0

* Joint significance tests (Tables in Appendix)
estimates restore wv_linear_Hyper_subsmpl
test _b[r:4.wave]=_b[r:41.wave]=_b[kappaD:4.wave]=_b[kappaD:41.wave]=0
estimates restore wv_gprelec_Hyper_subsmpl
test _b[r:4.wave]=_b[r:41.wave]=_b[LNalphapr:4.wave]=_b[LNalphapr:41.wave]=_b[LNbetapr:4.wave]=_b[LNbetapr:41.wave]=_b[kappaD:4.wave]=_b[kappaD:41.wave]=0
estimates restore ev_linear_Hyper_subsmpl 
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]=_b[kappaD:2.events]=_b[kappaD:3.events]=_b[kappaD:4.events]=_b[kappaD:5.events]=_b[kappaD:6.events]=0
estimates restore ev_gprelec_Hyper_subsmpl
test _b[r:2.events]=_b[r:3.events]=_b[r:4.events]=_b[r:5.events]=_b[r:6.events]= ///
_b[LNalphapr:2.events]=_b[LNalphapr:3.events]=_b[LNalphapr:4.events]=_b[LNalphapr:5.events]=_b[LNalphapr:6.events]= ///
_b[LNbetapr:2.events]=_b[LNbetapr:3.events]=_b[LNbetapr:4.events]=_b[LNbetapr:5.events]=_b[LNbetapr:6.events]= ///
_b[kappaD:2.events]=_b[kappaD:3.events]=_b[kappaD:4.events]=_b[kappaD:5.events]=_b[kappaD:6.events]=0

* Test whether RDU collpses to EUT (test whether a=b=1 in the Prelec prob weighting function) 
* Results are reported in Tables A4-A9 in Appendix
foreach model in wv_gprelec_Expo_subsmpl wv_gprelec_Hyper_subsmpl {
estimates restore `model'
test  (_b[LNalphapr:_cons]=1) (_b[LNbetapr:_cons]=1) (_b[LNalphapr:4.wave]=0) (_b[LNalphapr:41.wave]=0) (_b[LNbetapr:4.wave]=0) (_b[LNbetapr:41.wave]=0), mtest(bonferroni)
}

foreach model in ev_gprelec_Expo_subsmpl  ev_gprelec_Hyper_subsmpl {
estimates restore `model'
test (_b[LNalphapr:_cons]=1) (_b[LNbetapr:_cons]=1) (_b[LNalphapr:2.events]=0) (_b[LNalphapr:3.events]=0) (_b[LNalphapr:4.events]=0) (_b[LNalphapr:5.events]=0) (_b[LNalphapr:6.events]=0) (_b[LNbetapr:2.events]=0) (_b[LNbetapr:3.events]=0) (_b[LNbetapr:4.events]=0) (_b[LNbetapr:5.events]=0) (_b[LNbetapr:6.events]=0), mtest(bonferroni)
}
