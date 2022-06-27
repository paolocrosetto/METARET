global risk linear
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ib1.events i.gender hsize age i.income i.nosmoke cases_adj)  (muRA: ) (deltaD: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)  
ml display
estimates store demog_ev_eut_expo

global risk linear
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (kappaD: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)
ml display
estimates store demog_ev_eut_hyper

global risk gprelec
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (LNalpha: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (LNbeta: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (deltaD: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id) 
ml display
estimates store demog_ev_rdu_expo

global risk gprelec
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (LNalpha: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (LNbeta: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (kappaD: ib1.events i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id) 
ml display
estimates store demog_ev_rdu_hyper

