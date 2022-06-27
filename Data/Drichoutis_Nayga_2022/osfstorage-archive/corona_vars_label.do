la var corona_comply "How much did you comply with the measures anounced by the Goverment to prevent the spread of the coronavirus (social distancing, limiting non-essential commuting, self-isolation)?"

la var corona_gov "Goverment's reaction to the coronavirus pandemic is:"

la var corona_social_dist "How efficient do you think social distancing measures are in order to prevent the spread of the coronavirus?"
recode corona_social_dist (1=2)
la define corona_social_dist 2 "very inefficient or inefficient" 3 "neither inefficient, nor efficient" 4 "efficient" 5 "very efficient"
la val corona_social_dist corona_social_dist

la var corona_highrisk "Do you have family members or others in your inner circle that are considered high risk group for the coronavirus?"
la define corona_highrisk 1 "No" 2 "Yes"
la val corona_highrisk corona_highrisk

la var corona_infection "Did any persons in your circle, including yourself, got infected with the coronavirus?"
la define corona_infection 1 "No" 2 "Yes"
la val corona_infection corona_infection

la var corona_stateofsubjec_1 "I'm nervous/stressed"
la define corona_stateofsubjec_1 1 "Highly disagree" 2 "Disagree" 3 "Neither agree, nor disagree" 4 "Agree" 5 "Highly agree" 
la val corona_stateofsubjec_1 corona_stateofsubjec_1
la var corona_stateofsubjec_2 "I'm calm/relaxed"
la define corona_stateofsubjec_2 1 "Highly disagree" 2 "Disagree" 3 "Neither agree, nor disagree" 4 "Agree" 5 "Highly agree" 
la val corona_stateofsubjec_2 corona_stateofsubjec_2
la var corona_stateofsubjec_3 "I worry about my health"
la define corona_stateofsubjec_3 1 "Highly disagree" 2 "Disagree" 3 "Neither agree, nor disagree" 4 "Agree" 5 "Highly agree" 
la val corona_stateofsubjec_3 corona_stateofsubjec_3
la var corona_stateofsubjec_4 "I worry about the health of members of my family"
la define corona_stateofsubjec_4 1 "Highly disagree" 2 "Disagree" 3 "Neither agree, nor disagree" 4 "Agree" 5 "Highly agree" 
la val corona_stateofsubjec_4 corona_stateofsubjec_4
la var corona_stateofsubjec_5 "I feel stressed when I have to leave home"
la define corona_stateofsubjec_5 1 "Highly disagree" 2 "Disagree" 3 "Neither agree, nor disagree" 4 "Agree" 5 "Highly agree" 
la val corona_stateofsubjec_5 corona_stateofsubjec_5

gen corona_stress=corona_stateofsubjec_1+(6-corona_stateofsubjec_2)+corona_stateofsubjec_3+corona_stateofsubjec_4+corona_stateofsubjec_5 // reverse code corona_stateofsubjec_2

la var corona_conspiracy_1 "Coronavirus was made in a lab in China, got out of control and transmitted to the population"
la define corona_conspiracy_1 1 "Very unlikely" 2 "Unlikely" 3 "Neither likely, not unlikely" 4 "Likely" 5 "Very likely"
la val corona_conspiracy_1 corona_conspiracy_1
la var corona_conspiracy_2 "Coronavirus was made in a US lab and US soldiers then infected the population in China"
la define corona_conspiracy_2 1 "Very unlikely" 2 "Unlikely" 3 "Neither likely, not unlikely" 4 "Likely" 5 "Very likely"
la val corona_conspiracy_2 corona_conspiracy_2
la var corona_conspiracy_3 "Coronavirus is a zoonosis that spread from animals to humans"
la define corona_conspiracy_3 1 "Very unlikely" 2 "Unlikely" 3 "Neither likely, not unlikely" 4 "Likely" 5 "Very likely"
la val corona_conspiracy_3 corona_conspiracy_3
la var corona_conspiracy_4 "Coronavirus is no more dangerous than common flu"
la define corona_conspiracy_4 1 "Very unlikely" 2 "Unlikely" 3 "Neither likely, not unlikely" 4 "Likely" 5 "Very likely"
la val corona_conspiracy_4 corona_conspiracy_4
la var corona_conspiracy_5 "Coronavirus was invented as a pretense for limiting personal liberties"
la define corona_conspiracy_5 1 "Very unlikely" 2 "Unlikely" 3 "Neither likely, not unlikely" 4 "Likely" 5 "Very likely"
la val corona_conspiracy_5 corona_conspiracy_5

gen corona_conspiracy=corona_conspiracy_1+corona_conspiracy_2+(6-corona_conspiracy_3)+corona_conspiracy_4+corona_conspiracy_5