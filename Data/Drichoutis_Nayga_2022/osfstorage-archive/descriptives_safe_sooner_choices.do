preserve

sort wave AM nchoice
keep AM wave nchoice aa id choices ra events
quietly {
gen score=.
replace score=1 if ra==1 & choices==0 // left choice is scored as 1
replace score=0 if ra==1 & choices==1 // right choice is scored as 0
replace score=0.5 if ra==1 & choices==-1 // indifference is scored as 0.5

replace score=1 if ra==0 & choices==0 & nchoice<=20 // left choice in Time pref task is scored as 1
replace score=0 if ra==0 & choices==1 & nchoice<=20 // right choice in Time pref task is scored as 0
replace score=0.5 if ra==0 & choices==-1 & nchoice<=20 // indifference in Time pref task is scored as 0.5

replace score=1 if ra==0 & choices==0 & nchoice>20 // left choice in Time pref task is scored as 1
replace score=0.5 if ra==0 & choices==1 & nchoice>20 // middle choice in Time pref task is scored as 0.5
replace score=0 if ra==0 & choices==2 & nchoice>20 // right choice in Time pref task is scored as 0

gen nscore=.
egen group=group(wave AM ra)

foreach x of numlist 1/1000 {
sum score if group==`x'
replace nscore=r(sum) if group==`x'
}
foreach x of numlist 1001/1982 {
sum score if group==`x'
replace nscore=r(sum) if group==`x'
}

}
* Kruskal-Wallis tests
kwallis nscore if nchoice==31 & ra==1, by(wave)
kwallis nscore if nchoice==31 & ra==1, by(events)
kwallis nscore if nchoice==1 & ra==0, by(wave)
kwallis nscore if nchoice==1 & ra==0, by(events)
restore