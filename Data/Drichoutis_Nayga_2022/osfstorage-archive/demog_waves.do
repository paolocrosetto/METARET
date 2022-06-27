global risk linear 
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke cases_adj)  (muRA: ) (deltaD: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)  
ml display
estimates store demog_wv_eut_expo

global risk linear
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (kappaD: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id) 
ml display
estimates store demog_wv_eut_hyper

global risk gprelec
global discount Expo
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke ) (LNalpha: i.wave i.gender hsize age i.income i.nosmoke ) (LNbeta: i.wave i.gender hsize age i.income i.nosmoke ) (muRA: ) (deltaD: i.wave i.gender hsize age i.income i.nosmoke ) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke cases_adj) (LNalpha: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (LNbeta: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (deltaD: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id) continue
ml display 
estimates store demog_wv_rdu_expo

global risk gprelec
global discount Hyper
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke ) (LNalpha: i.wave i.gender hsize age i.income i.nosmoke ) (LNbeta: i.wave i.gender hsize age i.income i.nosmoke ) (muRA: ) (kappaD: i.wave i.gender hsize age i.income i.nosmoke) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id)
ml model lf MLcrra (r: choices RowProbA Vprizea1 Vprizea2 Vprizeb1 Vprizeb2 nchoice fed horizon principal DelayedP DelayedP2 ra = i.wave i.gender hsize age i.income i.nosmoke cases_adj) (LNalpha: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (LNbeta: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muRA: ) (kappaD: i.wave i.gender hsize age i.income i.nosmoke cases_adj) (muDR: ) if dominated==1 & gender~=. & hsize~=. & age~=. & income~=. & city!="Abroad" & cases_adj~=. & nosmoke~=., maximize difficult missing cluster(id) continue
ml display 
estimates store demog_wv_rdu_hyper


