label var time1 "Are you generally an impatient person, or someone who always shows great patience?"
label define time1 1 "very impatient" 6 "neither patient, nor impatient" 11 "very patient"
label values time1 time1

label var time2 "Are you generally an impulsive person, or someone who always shows great caution?"
label define time2 1 "Not at all impulsive" 6 "neither cautious, nor impulsive" 11 "very impulsive"
label values time2 time2

*=======================================================*
*  The Baratt Impulsiveness Scale - subscale Attention  *
*=======================================================*
label var bis_1 "I plan tasks carefully"
label var bis_2 "I do things without thinking"
label var bis_3 "I don't 'pay attention"
label var bis_4 "I plan for the future"
label var bis_5 "I concentrate easily"
label var bis_6 "I save regularly"
label var bis_7 "I 'squirm' at plays or lectures"
label var bis_8 "I am a careful thinker"
label var bis_9 "I plan for job security"
label var bis_10 "I say things without thinking"
label var bis_11 "I act 'on impulse'"
label var bis_12 "I get easily bored when solving thought problems"
label var bis_13 "I act on the spur of the moment"		
label var bis_14 "I buy things on impulse"				
label var bis_15 "I am restless at the theater or lectures"

foreach x of numlist 1/15 {
label define bis_`x' 1 "Rarely/Never" 2 "Occasionally" 3"Often" 4 "Almost always/Always", replace
label values bis_`x' bis_`x'	
}

gen BISmotor=bis_11+bis_13+bis_2+bis_10+bis_14
label var BISmotor "BIS, motor subscale"
gen BISnonplan=(5-bis_9)+(5-bis_4)+(5-bis_6)+(5-bis_1)+(5-bis_8)
label var BISnonplan "BIS, nonplanning subscale"
gen BISattention=bis_15+bis_7+(5-bis_5)+bis_3+bis_12
label var BISattent "BIS, attention subscale"

gen bis=BISmotor+BISnonplan+BISattention
la var bis "The Baratt Impulsiveness Scale (higher scores=more impulsive)"

la var risk "Are you generally a person who is fully prepared to take risks or do you try to avoid taking risks?"
label drop risk
label define risk 0 "not at all willing to take risks" 5 "neither willing, nor unwilling" 10 "very willing to take risks"
lab val risk risk

recode riskinvest (1=100) (2=80) (3=60) (4=40) (5=20) (6=0)
la var riskinvest "How much money of 100,000€ would you be prepared to invest in a lottery with 50% chance to double the mone and 50%  chance to lose half of the amount"
label define riskinvest 0 "nothing, I would decline the offer" 20 "20,000€" 40 "40,000€" 60 "60,000€" 80 "80,000€" 100 "100,000€"