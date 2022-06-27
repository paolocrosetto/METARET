* On how to do the Chow test in Stata: https://www.stata.com/support/faqs/statistics/chow-tests/
global risk linear 
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant)  (muRA: ) (deltaD: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)  
estimates store chow_eut_expo_wv

global risk linear 
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant)  (muRA: ) (kappaD: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)  
estimates store chow_eut_hyper_wv

global risk gprelec
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (LNalpha: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (LNbeta: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muRA: ) (deltaD: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)
estimates store chow_rdu_expo_wv

global risk gprelec
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (LNalpha: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (LNbeta: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muRA: ) (kappaD: ibn.wave ibn.wave#(i.gender c.hsize c.age i.income i.nosmoke c.cases_adj), noconstant) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)
estimates store chow_rdu_hyper_wv