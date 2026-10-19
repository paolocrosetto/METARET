
******************************************
** Data Preparation - Fork Game **********
******************************************



*******************************************
************ Risk Treatment ***************
*******************************************

clear
import delimited "Fork_experiment_data.csv", delimiter(";") clear 


keep if oyun=="ours"


drop round1t_ms round1t_b1 round1t_b2 round1t_kl1 round1t_kr1 round1t_kl2 round1t_kr2 round1t_c1 round1t_c2 round1t_c3 
drop round1t_c4 round1t_earn round2t_ms round2t_b1 round2t_b2 round2t_kl1 round2t_kr1 round2t_kl2 round2t_kr2 round2t_c1 round2t_c2 
drop round2t_c3 round2t_c4 round2t_earn round3t_ms round3t_b1 round3t_b2 round3t_kl1 round3t_kr1 round3t_kl2 round3t_kr2 round3t_c1 
drop round3t_c2 round3t_c3 round3t_c4 round3t_earn round4t_ms round4t_b1 round4t_b2 round4t_kl1 round4t_kr1 round4t_kl2 round4t_kr2
drop round4t_c1 round4t_c2 round4t_c3 round4t_c4 round4t_earn round5t_ms round5t_b1 round5t_b2 round5t_kl1 round5t_kr1 round5t_kl2
drop round5t_kr2 round5t_c1 round5t_c2 round5t_c3 round5t_c4 round5t_earn round6t_ms round6t_b1 round6t_b2 round6t_kl1 round6t_kr1 
drop round6t_kl2 round6t_kr2 round6t_c1 round6t_c2 round6t_c3 round6t_c4 round6t_earn round7t_ms round7t_b1 round7t_b2 round7t_kl1 
drop round7t_kr1 round7t_kl2 round7t_kr2 round7t_c1 round7t_c2 round7t_c3 round7t_c4 round7t_earn round8t_ms round8t_b1 round8t_b2 
drop round8t_kl1 round8t_kr1 round8t_kl2 round8t_kr2 round8t_c1 round8t_c2 round8t_c3 round8t_c4 round8t_earn round9t_ms round9t_b1 round9t_b2 
drop round9t_kl1 round9t_kr1 round9t_kl2 round9t_kr2 round9t_c1 round9t_c2 round9t_c3 round9t_c4 round9t_earn round10t_ms round10t_b1 round10t_b2 
drop round10t_kl1 round10t_kr1 round10t_kl2 round10t_kr2 round10t_c1 round10t_c2 round10t_c3 round10t_c4 round10t_earn round11t_ms round11t_b1 
drop round11t_b2 round11t_kl1 round11t_kr1 round11t_kl2 round11t_kr2 round11t_c1 round11t_c2 round11t_c3 round11t_c4 round11t_earn round12t_ms 
drop round12t_b1 round12t_b2 round12t_kl1 round12t_kr1 round12t_kl2 round12t_kr2 round12t_c1 round12t_c2 round12t_c3 round12t_c4 round12t_earn 
drop round1p_ms round1p_b1 round1p_b2 round1p_k1 round1p_k2 round1p_c round1p_earn round2p_ms round2p_b1 round2p_b2 round2p_k1 round2p_k2 round2p_c
drop round2p_earn round3p_ms round3p_b1 round3p_b2 round3p_k1 round3p_k2 round3p_c round3p_earn round4p_ms round4p_b1 round4p_b2 round4p_k1 round4p_k2 
drop round4p_c round4p_earn round5p_ms round5p_b1 round5p_b2 round5p_k1 round5p_k2 round5p_c round5p_earn round6p_ms round6p_b1 round6p_b2 round6p_k1 
drop round6p_k2 round6p_c round6p_earn round7p_ms round7p_b1 round7p_b2 round7p_k1 round7p_k2 round7p_c round7p_earn round8p_ms round8p_b1 round8p_b2
drop round8p_k1 round8p_k2 round8p_c round8p_earn round9p_ms round9p_b1 round9p_b2 round9p_k1 round9p_k2 round9p_c round9p_earn round10p_ms round10p_b1
drop round10p_b2 round10p_k1 round10p_k2 round10p_c round10p_earn round11p_ms round11p_b1 round11p_b2 round11p_k1 
drop round11p_k2 round11p_c round11p_earn round12p_ms round12p_b1 round12p_b2 round12p_k1 round12p_k2 round12p_c round12p_earn



expandcl 12, cluster(id) generate(round)
replace round = mod(round,12)
replace round = 12 if round == 0



gen ms=.
replace ms=round1r_ms if round == 1
replace ms=round2r_ms if round == 2
replace ms=round3r_ms if round == 3
replace ms=round4r_ms if round == 4
replace ms=round5r_ms if round == 5
replace ms=round6r_ms if round == 6
replace ms=round7r_ms if round == 7
replace ms=round8r_ms if round == 8
replace ms=round9r_ms if round == 9
replace ms=round10r_ms if round == 10
replace ms=round11r_ms if round == 11
replace ms=round12r_ms if round == 12

drop round1r_ms round2r_ms round3r_ms round4r_ms round5r_ms round6r_ms round7r_ms round8r_ms round9r_ms round10r_ms round11r_ms round12r_ms

gen w=.
replace w= max(round1r_l1, round1r_l2, round1r_r1, round1r_r2) if round == 1
replace w= max(round2r_l1, round2r_l2, round2r_r1, round2r_r2) if round == 2
replace w= max(round3r_l1, round3r_l2, round3r_r1, round3r_r2) if round == 3
replace w= max(round4r_l1, round4r_l2, round4r_r1, round4r_r2) if round == 4
replace w= max(round5r_l1, round5r_l2, round5r_r1, round5r_r2) if round == 5
replace w= max(round6r_l1, round6r_l2, round6r_r1, round6r_r2) if round == 6
replace w= max(round7r_l1, round7r_l2, round7r_r1, round7r_r2) if round == 7
replace w= max(round8r_l1, round8r_l2, round8r_r1, round8r_r2) if round == 8
replace w= max(round9r_l1, round9r_l2, round9r_r1, round9r_r2) if round == 9
replace w= max(round10r_l1, round10r_l2, round10r_r1, round10r_r2) if round == 10
replace w= max(round11r_l1, round11r_l2, round11r_r1, round11r_r2) if round == 11
replace w= max(round12r_l1, round12r_l2, round12r_r1, round12r_r2) if round == 12

gen low=.
replace low= min(round1r_l1, round1r_l2, round1r_r1, round1r_r2) if round == 1
replace low= min(round2r_l1, round2r_l2, round2r_r1, round2r_r2) if round == 2
replace low= min(round3r_l1, round3r_l2, round3r_r1, round3r_r2) if round == 3
replace low= min(round4r_l1, round4r_l2, round4r_r1, round4r_r2) if round == 4
replace low= min(round5r_l1, round5r_l2, round5r_r1, round5r_r2) if round == 5
replace low= min(round6r_l1, round6r_l2, round6r_r1, round6r_r2) if round == 6
replace low= min(round7r_l1, round7r_l2, round7r_r1, round7r_r2) if round == 7
replace low= min(round8r_l1, round8r_l2, round8r_r1, round8r_r2) if round == 8
replace low= min(round9r_l1, round9r_l2, round9r_r1, round9r_r2) if round == 9
replace low= min(round10r_l1, round10r_l2, round10r_r1, round10r_r2) if round == 10
replace low= min(round11r_l1, round11r_l2, round11r_r1, round11r_r2) if round == 11
replace low= min(round12r_l1, round12r_l2, round12r_r1, round12r_r2) if round == 12

gen k=.
replace k=8 if w==16 & low == 1
replace k=7 if w==14 & low == 2
replace k=7 if w==16 & low == 4
replace k=6 if w==13 & low == 3
replace k=4 if w==8 & low == 1
replace k=5 if w==10 & low == 2
replace k=4 if w==10 & low == 3
replace k=5 if w==12 & low == 4
replace k=5 if w==11 & low == 3
replace k=4 if w==12 & low == 5
replace k=6 if w==14 & low == 3
replace k=6 if w==12 & low == 1

gen d=.
replace d=7 if w==16 & low==1
replace d=5 if w==14 & low==2
replace d=5 if w==16 & low== 4
replace d=4 if w==13 & low== 3
replace d=3 if w==8 & low == 1
replace d=3 if w==10 & low== 2
replace d=3 if w==10 & low == 3
replace d=3 if w==12 & low == 4
replace d=3 if w==11 & low == 3
replace d=3 if w==12 & low == 5
replace d=5 if w==14 & low == 3
replace d=5 if w==12 & low == 1





gen choice =0
replace choice = 1 if round1r_earn != w & round1r_earn != low & round == 1
replace choice = 1 if round2r_earn != w & round2r_earn != low & round == 2
replace choice = 1 if round3r_earn != w & round3r_earn != low & round == 3
replace choice = 1 if round4r_earn != w & round4r_earn != low & round == 4
replace choice = 1 if round5r_earn != w & round5r_earn != low & round == 5
replace choice = 1 if round6r_earn != w & round6r_earn != low & round == 6
replace choice = 1 if round7r_earn != w & round7r_earn != low & round == 7
replace choice = 1 if round8r_earn != w & round8r_earn != low & round == 8
replace choice = 1 if round9r_earn != w & round9r_earn != low & round == 9
replace choice = 1 if round10r_earn != w & round10r_earn != low & round == 10
replace choice = 1 if round11r_earn != w & round11r_earn != low & round == 11
replace choice = 1 if round12r_earn != w & round12r_earn != low & round == 12


gen outcome=.
replace outcome=round1r_earn if round==1
replace outcome=round2r_earn if round==2
replace outcome=round3r_earn if round==3
replace outcome=round4r_earn if round==4
replace outcome=round5r_earn if round==5
replace outcome=round6r_earn if round==6
replace outcome=round7r_earn if round==7
replace outcome=round8r_earn if round==8
replace outcome=round9r_earn if round==9
replace outcome=round10r_earn if round==10
replace outcome=round11r_earn if round==11
replace outcome=round12r_earn if round==12

drop low


drop round1r_l1 round1r_l2 round1r_r1 round1r_r2 round1r_c round1r_earn
drop round2r_l1 round2r_l2 round2r_r1 round2r_r2 round2r_c round2r_earn
drop round3r_l1 round3r_l2 round3r_r1 round3r_r2 round3r_c round3r_earn
drop round4r_l1 round4r_l2 round4r_r1 round4r_r2 round4r_c round4r_earn
drop round5r_l1 round5r_l2 round5r_r1 round5r_r2 round5r_c round5r_earn
drop round6r_l1 round6r_l2 round6r_r1 round6r_r2 round6r_c round6r_earn
drop round7r_l1 round7r_l2 round7r_r1 round7r_r2 round7r_c round7r_earn
drop round8r_l1 round8r_l2 round8r_r1 round8r_r2 round8r_c round8r_earn
drop round9r_l1 round9r_l2 round9r_r1 round9r_r2 round9r_c round9r_earn
drop round10r_l1 round10r_l2 round10r_r1 round10r_r2 round10r_c round10r_earn
drop round11r_l1 round11r_l2 round11r_r1 round11r_r2 round11r_c round11r_earn
drop round12r_l1 round12r_l2 round12r_r1 round12r_r2 round12r_c round12r_earn

drop treatment_order kazanc 
drop oturum baslama bitirme
drop demo_age demo_gpa demo_preexp demo_sex demo_dep demo_econcourses demo_difficulty demo_sure v1
drop gps_general_risk gps_future_benefit gps_punish_self gps_punish_others gps_good_cause gps_describe_favor
drop gps_describe_revenge gps_describe_intentions gps_describe_math gps_describe_postpone 
drop gps_stair_risk gps_gift gps_donation gps_stair_patience

gen treatment = "Risk"
save Fork_risk.dta, replace

****************************************
***** Prudence Treatment ***************
****************************************

clear

import delimited "Fork_experiment_data.csv", delimiter(";") clear 

keep if oyun=="ours"

drop round1r_ms round1r_l1 round1r_l2 round1r_r1 round1r_r2 round1r_c round1r_earn 
drop round2r_ms round2r_l1 round2r_l2 round2r_r1 round2r_r2 round2r_c round2r_earn round3r_ms 
drop round3r_l1 round3r_l2 round3r_r1 round3r_r2 round3r_c round3r_earn round4r_ms round4r_l1 
drop round4r_l2 round4r_r1 round4r_r2 round4r_c round4r_earn round5r_ms round5r_l1 
drop round5r_l2 round5r_r1 round5r_r2 round5r_c round5r_earn round6r_ms round6r_l1 
drop round6r_l2 round6r_r1 round6r_r2 round6r_c round6r_earn round7r_ms round7r_l1 
drop round7r_l2 round7r_r1 round7r_r2 round7r_c round7r_earn round8r_ms round8r_l1 
drop round8r_l2 round8r_r1 round8r_r2 round8r_c round8r_earn round9r_ms round9r_l1 
drop round9r_l2 round9r_r1 round9r_r2 round9r_c round9r_earn round10r_ms round10r_l1 
drop round10r_l2 round10r_r1 round10r_r2 round10r_c round10r_earn round11r_ms round11r_l1 
drop round11r_l2 round11r_r1 round11r_r2 round11r_c round11r_earn round12r_ms round12r_l1 
drop round12r_l2 round12r_r1 round12r_r2 round12r_c round12r_earn round1t_ms round1t_b1 
drop round1t_b2 round1t_kl1 round1t_kr1 round1t_kl2 round1t_kr2 round1t_c1 round1t_c2 
drop round1t_c3 round1t_c4 round1t_earn round2t_ms round2t_b1 round2t_b2 round2t_kl1 
drop round2t_kr1 round2t_kl2 round2t_kr2 round2t_c1 round2t_c2 round2t_c3 round2t_c4 
drop round2t_earn round3t_ms round3t_b1 round3t_b2 round3t_kl1 round3t_kr1 round3t_kl2 
drop round3t_kr2 round3t_c1 round3t_c2 round3t_c3 round3t_c4 round3t_earn round4t_ms 
drop round4t_b1 round4t_b2 round4t_kl1 round4t_kr1 round4t_kl2 round4t_kr2 round4t_c1 
drop round4t_c2 round4t_c3 round4t_c4 round4t_earn round5t_ms round5t_b1 round5t_b2 
drop round5t_kl1 round5t_kr1 round5t_kl2 round5t_kr2 round5t_c1 round5t_c2 round5t_c3 
drop round5t_c4 round5t_earn round6t_ms round6t_b1 round6t_b2 round6t_kl1 round6t_kr1 
drop round6t_kl2 round6t_kr2 round6t_c1 round6t_c2 round6t_c3 round6t_c4 round6t_earn 
drop round7t_ms round7t_b1 round7t_b2 round7t_kl1 round7t_kr1 round7t_kl2 round7t_kr2 
drop round7t_c1 round7t_c2 round7t_c3 round7t_c4 round7t_earn round8t_ms round8t_b1 
drop round8t_b2 round8t_kl1 round8t_kr1 round8t_kl2 round8t_kr2 round8t_c1 round8t_c2 
drop round8t_c3 round8t_c4 round8t_earn round9t_ms round9t_b1 round9t_b2 round9t_kl1 
drop round9t_kr1 round9t_kl2 round9t_kr2 round9t_c1 round9t_c2 round9t_c3 round9t_c4 
drop round9t_earn round10t_ms round10t_b1 round10t_b2 round10t_kl1 round10t_kr1 
drop round10t_kl2 round10t_kr2 round10t_c1 round10t_c2 round10t_c3 round10t_c4 
drop round10t_earn round11t_ms round11t_b1 round11t_b2 round11t_kl1 round11t_kr1 
drop round11t_kl2 round11t_kr2 round11t_c1 round11t_c2 round11t_c3 round11t_c4 
drop round11t_earn round12t_ms round12t_b1 round12t_b2 round12t_kl1 round12t_kr1 
drop round12t_kl2 round12t_kr2 round12t_c1 round12t_c2 round12t_c3 round12t_c4 round12t_earn
 


expandcl 12, cluster(id) generate(round)
replace round = mod(round,12)
replace round = 12 if round == 0



gen ms=.
replace ms=round1p_ms if round == 1
replace ms=round2p_ms if round == 2
replace ms=round3p_ms if round == 3
replace ms=round4p_ms if round == 4
replace ms=round5p_ms if round == 5
replace ms=round6p_ms if round == 6
replace ms=round7p_ms if round == 7
replace ms=round8p_ms if round == 8
replace ms=round9p_ms if round == 9
replace ms=round10p_ms if round == 10
replace ms=round11p_ms if round == 11
replace ms=round12p_ms if round == 12


drop round1p_ms round2p_ms round3p_ms round4p_ms round5p_ms round6p_ms 
drop round7p_ms round8p_ms round9p_ms round10p_ms round11p_ms round12p_ms


gen w=.
replace w= max(round1p_b1, round1p_b2) if round == 1
replace w= max(round2p_b1, round2p_b2) if round == 2
replace w= max(round3p_b1, round3p_b2) if round == 3
replace w= max(round4p_b1, round4p_b2) if round == 4
replace w= max(round5p_b1, round5p_b2) if round == 5
replace w= max(round6p_b1, round6p_b2) if round == 6
replace w= max(round7p_b1, round7p_b2) if round == 7
replace w= max(round8p_b1, round8p_b2) if round == 8
replace w= max(round9p_b1, round9p_b2) if round == 9
replace w= max(round10p_b1, round10p_b2) if round == 10
replace w= max(round11p_b1, round11p_b2) if round == 11
replace w= max(round12p_b1, round12p_b2) if round == 12


gen k=.
replace k= max(round1p_b1, round1p_b2) - min(round1p_b1, round1p_b2) if round == 1
replace k= max(round2p_b1, round2p_b2) - min(round2p_b1, round2p_b2) if round == 2
replace k= max(round3p_b1, round3p_b2) - min(round3p_b1, round3p_b2) if round == 3
replace k= max(round4p_b1, round4p_b2) - min(round4p_b1, round4p_b2) if round == 4
replace k= max(round5p_b1, round5p_b2) - min(round5p_b1, round5p_b2) if round == 5
replace k= max(round6p_b1, round6p_b2) - min(round6p_b1, round6p_b2) if round == 6
replace k= max(round7p_b1, round7p_b2) - min(round7p_b1, round7p_b2) if round == 7
replace k= max(round8p_b1, round8p_b2) - min(round8p_b1, round8p_b2) if round == 8
replace k= max(round9p_b1, round9p_b2) - min(round9p_b1, round9p_b2) if round == 9
replace k= max(round10p_b1, round10p_b2) - min(round10p_b1, round10p_b2) if round == 10
replace k= max(round11p_b1, round11p_b2) - min(round11p_b1, round11p_b2) if round == 11
replace k= max(round12p_b1, round12p_b2) - min(round12p_b1, round12p_b2) if round == 12

gen e=.
replace e=round1p_k1 if round==1
replace e=round2p_k1 if round==2
replace e=round3p_k1 if round==3
replace e=round4p_k1 if round==4
replace e=round5p_k1 if round==5
replace e=round6p_k1 if round==6
replace e=round7p_k1 if round==7
replace e=round8p_k1 if round==8
replace e=round9p_k1 if round==9
replace e=round10p_k1 if round==10
replace e=round11p_k1 if round==11
replace e=round12p_k1 if round==12


gen choice=0

replace choice=1 if round1p_b2>round1p_b1 & round1p_c==2 &round==1
replace choice=1 if round1p_b2<round1p_b1 & round1p_c==1 &round==1

replace choice=1 if round2p_b2>round2p_b1 & round2p_c==2 &round==2
replace choice=1 if round2p_b2<round2p_b1 & round2p_c==1 &round==2

replace choice=1 if round3p_b2>round3p_b1 & round3p_c==2 &round==3
replace choice=1 if round3p_b2<round3p_b1 & round3p_c==1 &round==3

replace choice=1 if round4p_b2>round4p_b1 & round4p_c==2 &round==4
replace choice=1 if round4p_b2<round4p_b1 & round4p_c==1 &round==4

replace choice=1 if round5p_b2>round5p_b1 & round5p_c==2 &round==5
replace choice=1 if round5p_b2<round5p_b1 & round5p_c==1 &round==5

replace choice=1 if round6p_b2>round6p_b1 & round6p_c==2 &round==6
replace choice=1 if round6p_b2<round6p_b1 & round6p_c==1 &round==6

replace choice=1 if round7p_b2>round7p_b1 & round7p_c==2 &round==7
replace choice=1 if round7p_b2<round7p_b1 & round7p_c==1 &round==7

replace choice=1 if round8p_b2>round8p_b1 & round8p_c==2 &round==8
replace choice=1 if round8p_b2<round8p_b1 & round8p_c==1 &round==8

replace choice=1 if round9p_b2>round9p_b1 & round9p_c==2 &round==9
replace choice=1 if round9p_b2<round9p_b1 & round9p_c==1 &round==9

replace choice=1 if round10p_b2>round10p_b1 & round10p_c==2 &round==10
replace choice=1 if round10p_b2<round10p_b1 & round10p_c==1 &round==10

replace choice=1 if round11p_b2>round11p_b1 & round11p_c==2 &round==11
replace choice=1 if round11p_b2<round11p_b1 & round11p_c==1 &round==11

replace choice=1 if round12p_b2>round12p_b1 & round12p_c==2 &round==12
replace choice=1 if round12p_b2<round12p_b1 & round12p_c==1 &round==12


drop round1p_b1 round1p_b2 round1p_k1 round1p_k2 round2p_b1 round2p_b2 round2p_k1 round2p_k2
drop round3p_b1 round3p_b2 round3p_k1 round3p_k2 round4p_b1 round4p_b2 round4p_k1 round4p_k2
drop round5p_b1 round5p_b2 round5p_k1 round5p_k2 round6p_b1 round6p_b2 round6p_k1 round6p_k2
drop round7p_b1 round7p_b2 round7p_k1 round7p_k2 round8p_b1 round8p_b2 round8p_k1 round8p_k2
drop round9p_b1 round9p_b2 round9p_k1 round9p_k2 round10p_b1 round10p_b2 round10p_k1 round10p_k2
drop round11p_b1 round11p_b2 round11p_k1 round11p_k2 round12p_b1 round12p_b2 round12p_k1 round12p_k2


gen outcome=.
replace outcome=round1p_earn if round==1
replace outcome=round2p_earn if round==2
replace outcome=round3p_earn if round==3
replace outcome=round4p_earn if round==4
replace outcome=round5p_earn if round==5
replace outcome=round6p_earn if round==6
replace outcome=round7p_earn if round==7
replace outcome=round8p_earn if round==8
replace outcome=round9p_earn if round==9
replace outcome=round10p_earn if round==10
replace outcome=round11p_earn if round==11
replace outcome=round12p_earn if round==12


drop round1p_c round1p_earn round2p_c round2p_earn round3p_c round3p_earn round4p_c round4p_earn 
drop round5p_c round5p_earn round6p_c round6p_earn round7p_c round7p_earn round8p_c round8p_earn 
drop round9p_c round9p_earn round10p_c round10p_earn round11p_c round11p_earn round12p_c round12p_earn

drop treatment_order kazanc
drop oturum baslama bitirme
drop demo_age demo_gpa demo_preexp demo_sex demo_dep demo_econcourses demo_difficulty demo_sure v1
drop gps_general_risk gps_future_benefit gps_punish_self gps_punish_others gps_good_cause gps_describe_favor
drop gps_describe_revenge gps_describe_intentions gps_describe_math gps_describe_postpone 
drop gps_stair_risk gps_gift gps_donation gps_stair_patience

gen treatment = "Prudence"
save Fork_prudence.dta, replace


*******************************************
************ Temperance Treatment *********
*******************************************

clear

import delimited "Fork_experiment_data.csv", delimiter(";") clear 

keep if oyun=="ours"

drop round1r_ms round1r_l1 round1r_l2 round1r_r1 round1r_r2 round1r_c 
drop round1r_earn round2r_ms round2r_l1 round2r_l2 round2r_r1 round2r_r2 round2r_c 
drop round2r_earn round3r_ms round3r_l1 round3r_l2 round3r_r1 round3r_r2 round3r_c 
drop round3r_earn round4r_ms round4r_l1 round4r_l2 round4r_r1 round4r_r2 round4r_c 
drop round4r_earn round5r_ms round5r_l1 round5r_l2 round5r_r1 round5r_r2 round5r_c 
drop round5r_earn round6r_ms round6r_l1 round6r_l2 round6r_r1 round6r_r2 round6r_c 
drop round6r_earn round7r_ms round7r_l1 round7r_l2 round7r_r1 round7r_r2 round7r_c 
drop round7r_earn round8r_ms round8r_l1 round8r_l2 round8r_r1 round8r_r2 round8r_c 
drop round8r_earn round9r_ms round9r_l1 round9r_l2 round9r_r1 round9r_r2 round9r_c 
drop round9r_earn round10r_ms round10r_l1 round10r_l2 round10r_r1 round10r_r2 
drop round10r_c round10r_earn round11r_ms round11r_l1 round11r_l2 round11r_r1 
drop round11r_r2 round11r_c round11r_earn round12r_ms round12r_l1 round12r_l2 
drop round12r_r1 round12r_r2 round12r_c round12r_earn

drop round1p_ms round1p_b1 round1p_b2 round1p_k1 round1p_k2 round1p_c round1p_earn 
drop round2p_ms round2p_b1 round2p_b2 round2p_k1 round2p_k2 round2p_c round2p_earn 
drop round3p_ms round3p_b1 round3p_b2 round3p_k1 round3p_k2 round3p_c round3p_earn 
drop round4p_ms round4p_b1 round4p_b2 round4p_k1 round4p_k2 round4p_c round4p_earn 
drop round5p_ms round5p_b1 round5p_b2 round5p_k1 round5p_k2 round5p_c round5p_earn 
drop round6p_ms round6p_b1 round6p_b2 round6p_k1 round6p_k2 round6p_c round6p_earn 
drop round7p_ms round7p_b1 round7p_b2 round7p_k1 round7p_k2 round7p_c round7p_earn 
drop round8p_ms round8p_b1 round8p_b2 round8p_k1 round8p_k2 round8p_c round8p_earn 
drop round9p_ms round9p_b1 round9p_b2 round9p_k1 round9p_k2 round9p_c round9p_earn 
drop round10p_ms round10p_b1 round10p_b2 round10p_k1 round10p_k2 round10p_c round10p_earn 
drop round11p_ms round11p_b1 round11p_b2 round11p_k1 round11p_k2 round11p_c round11p_earn 
drop round12p_ms round12p_b1 round12p_b2 round12p_k1 round12p_k2 round12p_c round12p_earn
 


expandcl 12, cluster(id) generate(round)
replace round = mod(round,12)
replace round = 12 if round == 0

destring round1t_ms round1t_b1 round1t_b2 round1t_kl1 round1t_kr1 round1t_kl2 round1t_kr2 round1t_earn, force replace
destring round2t_ms round2t_b1 round2t_b2 round2t_kl1 round2t_kr1 round2t_kl2 round2t_kr2 round2t_earn, force replace
destring round3t_ms round3t_b1 round3t_b2 round3t_kl1 round3t_kr1 round3t_kl2 round3t_kr2 round3t_earn, force replace
destring round4t_ms round4t_b1 round4t_b2 round4t_kl1 round4t_kr1 round4t_kl2 round4t_kr2 round4t_earn, force replace
destring round5t_ms round5t_b1 round5t_b2 round5t_kl1 round5t_kr1 round5t_kl2 round5t_kr2 round5t_earn, force replace
destring round6t_ms round6t_b1 round6t_b2 round6t_kl1 round6t_kr1 round6t_kl2 round6t_kr2 round6t_earn, force replace
destring round7t_ms round7t_b1 round7t_b2 round7t_kl1 round7t_kr1 round7t_kl2 round7t_kr2 round7t_earn, force replace
destring round8t_ms round8t_b1 round8t_b2 round8t_kl1 round8t_kr1 round8t_kl2 round8t_kr2 round8t_earn, force replace
destring round9t_ms round9t_b1 round9t_b2 round9t_kl1 round9t_kr1 round9t_kl2 round9t_kr2 round9t_earn, force replace
destring round10t_ms round10t_b1 round10t_b2 round10t_kl1 round10t_kr1 round10t_kl2 round10t_kr2 round10t_earn, force replace
destring round11t_ms round11t_b1 round11t_b2 round11t_kl1 round11t_kr1 round11t_kl2 round11t_kr2 round11t_earn, force replace
destring round12t_ms round12t_b1 round12t_b2 round12t_kl1 round12t_kr1 round12t_kl2 round12t_kr2 round12t_earn, force replace






gen ms=.
replace ms=round1t_ms if round == 1
replace ms=round2t_ms if round == 2
replace ms=round3t_ms if round == 3
replace ms=round4t_ms if round == 4
replace ms=round5t_ms if round == 5
replace ms=round6t_ms if round == 6
replace ms=round7t_ms if round == 7
replace ms=round8t_ms if round == 8
replace ms=round9t_ms if round == 9
replace ms=round10t_ms if round == 10
replace ms=round11t_ms if round == 11
replace ms=round12t_ms if round == 12


drop round1t_ms round2t_ms round3t_ms round4t_ms round5t_ms round6t_ms 
drop round7t_ms round8t_ms round9t_ms round10t_ms round11t_ms round12t_ms



gen w=.
replace w=round1t_b1 if round==1
replace w=round2t_b1 if round==2
replace w=round3t_b1 if round==3
replace w=round4t_b1 if round==4
replace w=round5t_b1 if round==5
replace w=round6t_b1 if round==6
replace w=round7t_b1 if round==7
replace w=round8t_b1 if round==8
replace w=round9t_b1 if round==9
replace w=round10t_b1 if round==10
replace w=round11t_b1 if round==11
replace w=round12t_b1 if round==12


gen e_1=.
replace e_1=round1t_kl1 if round==1
replace e_1=round2t_kl1 if round==2
replace e_1=round3t_kl1 if round==3
replace e_1=round4t_kl1 if round==4
replace e_1=round5t_kl1 if round==5
replace e_1=round6t_kl1 if round==6
replace e_1=round7t_kl1 if round==7
replace e_1=round8t_kl1 if round==8
replace e_1=round9t_kl1 if round==9
replace e_1=round10t_kl1 if round==10
replace e_1=round11t_kl1 if round==11
replace e_1=round12t_kl1 if round==12

gen e_2=.
replace e_2=round1t_kl2 if round==1
replace e_2=round2t_kl2 if round==2
replace e_2=round3t_kl2 if round==3
replace e_2=round4t_kl2 if round==4
replace e_2=round5t_kl2 if round==5
replace e_2=round6t_kl2 if round==6
replace e_2=round7t_kl2 if round==7
replace e_2=round8t_kl2 if round==8
replace e_2=round9t_kl2 if round==9
replace e_2=round10t_kl2 if round==10
replace e_2=round11t_kl2 if round==11
replace e_2=round12t_kl2 if round==12

gen choice=.
replace choice=1 if round1t_c1=="1"&round1t_c2=="2"&round==1 | round1t_c1=="2"&round1t_c2=="1"&round==1
replace choice=1 if round2t_c1=="1"&round2t_c2=="2"&round==2 | round2t_c1=="2"&round2t_c2=="1"&round==2
replace choice=1 if round3t_c1=="1"&round3t_c2=="2"&round==3 | round3t_c1=="2"&round3t_c2=="1"&round==3
replace choice=1 if round4t_c1=="1"&round4t_c2=="2"&round==4 | round4t_c1=="2"&round4t_c2=="1"&round==4
replace choice=1 if round5t_c1=="1"&round5t_c2=="2"&round==5 | round5t_c1=="2"&round5t_c2=="1"&round==5
replace choice=1 if round6t_c1=="1"&round6t_c2=="2"&round==6 | round6t_c1=="2"&round6t_c2=="1"&round==6
replace choice=1 if round7t_c1=="1"&round7t_c2=="2"&round==7 | round7t_c1=="2"&round7t_c2=="1"&round==7
replace choice=1 if round8t_c1=="1"&round8t_c2=="2"&round==8 | round8t_c1=="2"&round8t_c2=="1"&round==8
replace choice=1 if round9t_c1=="1"&round9t_c2=="2"&round==9 | round9t_c1=="2"&round9t_c2=="1"&round==9
replace choice=1 if round10t_c1=="1"&round10t_c2=="2"&round==10 | round10t_c1=="2"&round10t_c2=="1"&round==10
replace choice=1 if round11t_c1=="1"&round11t_c2=="2"&round==11 | round11t_c1=="2"&round11t_c2=="1"&round==11
replace choice=1 if round12t_c1=="1"&round12t_c2=="2"&round==12 | round12t_c1=="2"&round12t_c2=="1"&round==12

replace choice=0 if choice==.

gen outcome=.
replace outcome=round1t_earn if round==1
replace outcome=round2t_earn if round==2
replace outcome=round3t_earn if round==3
replace outcome=round4t_earn if round==4
replace outcome=round5t_earn if round==5
replace outcome=round6t_earn if round==6
replace outcome=round7t_earn if round==7
replace outcome=round8t_earn if round==8
replace outcome=round9t_earn if round==9
replace outcome=round10t_earn if round==10
replace outcome=round11t_earn if round==11
replace outcome=round12t_earn if round==12

drop round1t_b1 round1t_b2 round1t_kl1 round1t_kr1 round1t_kl2 round1t_kr2 
drop round1t_c1 round1t_c2 round1t_c3 round1t_c4 round1t_earn round2t_b1 round2t_b2 
drop round2t_kl1 round2t_kr1 round2t_kl2 round2t_kr2 round2t_c1 round2t_c2 round2t_c3 
drop round2t_c4 round2t_earn round3t_b1 round3t_b2 round3t_kl1 round3t_kr1 round3t_kl2 
drop round3t_kr2 round3t_c1 round3t_c2 round3t_c3 round3t_c4 round3t_earn round4t_b1 
drop round4t_b2 round4t_kl1 round4t_kr1 round4t_kl2 round4t_kr2 round4t_c1 round4t_c2 
drop round4t_c3 round4t_c4 round4t_earn round5t_b1 round5t_b2 round5t_kl1 round5t_kr1 
drop round5t_kl2 round5t_kr2 round5t_c1 round5t_c2 round5t_c3 round5t_c4 round5t_earn 
drop round6t_b1 round6t_b2 round6t_kl1 round6t_kr1 round6t_kl2 round6t_kr2 round6t_c1 
drop round6t_c2 round6t_c3 round6t_c4 round6t_earn round7t_b1 round7t_b2 round7t_kl1 
drop round7t_kr1 round7t_kl2 round7t_kr2 round7t_c1 round7t_c2 round7t_c3 round7t_c4 
drop round7t_earn round8t_b1 round8t_b2 round8t_kl1 round8t_kr1 round8t_kl2 round8t_kr2 
drop round8t_c1 round8t_c2 round8t_c3 round8t_c4 round8t_earn round9t_b1 round9t_b2 
drop round9t_kl1 round9t_kr1 round9t_kl2 round9t_kr2 round9t_c1 round9t_c2 round9t_c3 
drop round9t_c4 round9t_earn round10t_b1 round10t_b2 round10t_kl1 round10t_kr1 round10t_kl2 
drop round10t_kr2 round10t_c1 round10t_c2 round10t_c3 round10t_c4 round10t_earn round11t_b1 
drop round11t_b2 round11t_kl1 round11t_kr1 round11t_kl2 round11t_kr2 round11t_c1 round11t_c2 
drop round11t_c3 round11t_c4 round11t_earn round12t_b1 round12t_b2 round12t_kl1 round12t_kr1 
drop round12t_kl2 round12t_kr2 round12t_c1 round12t_c2 round12t_c3 round12t_c4 round12t_earn

drop treatment_order kazanc
drop oturum baslama bitirme
drop demo_age demo_gpa demo_preexp demo_sex demo_dep demo_econcourses demo_difficulty demo_sure v1
drop gps_general_risk gps_future_benefit gps_punish_self gps_punish_others gps_good_cause gps_describe_favor
drop gps_describe_revenge gps_describe_intentions gps_describe_math gps_describe_postpone 
drop gps_stair_risk gps_gift gps_donation gps_stair_patience

gen treatment = "Temperance"
save Fork_temperance.dta, replace


*************************************
******** Merge Treatments ***********
*************************************

clear
use Fork_risk.dta
append using Fork_prudence.dta
append using Fork_temperance.dta

order id treatment round
sort id treatment round


save Fork_experiment_data, replace


**************************************
***** Merge GPS Survey data **********
**************************************


clear

import delimited "Fork_experiment_data.csv", delimiter(";") clear 

keep if oyun=="ours"

keep id treatment_order kazanc  oturum baslama bitirme demo_age demo_gpa demo_preexp demo_sex demo_dep demo_econcourses ///
demo_difficulty demo_sure gps_general_risk gps_future_benefit gps_punish_self gps_punish_others gps_good_cause gps_describe_favor ///
gps_describe_revenge gps_describe_intentions gps_describe_math gps_describe_postpone gps_stair_risk gps_gift ///
gps_donation gps_stair_patience

save Fork_survey.dta, replace

clear
use Fork_experiment_data.dta
merge m:1 id using Fork_survey.dta


order id  treatment round choice w k d e e_1 e_2
sort id  treatment round 

drop _merge
gen game="Fork"
save Fork_experiment_data.dta, replace



























