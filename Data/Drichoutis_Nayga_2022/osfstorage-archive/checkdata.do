tab choices if nchoice==50, missing // How many subjects with missing responses in the rik/time preferences tasks
drop if choices==. // 90 subjects are dropped with missing risk/time preferences data

* Label the demographic variables
	* Gender
la def gender 1 "Male" 0 "Female"
la val gender gender
	* Age
gen age=2020-byear if wave>=4
replace age=2019-byear if wave==3
drop if age>26 & age~=. // drop one subject that is a very old student
la var age "Subject's age"
	* Household size
la var hsize "Household size" 
drop if hsize>=12 & hsize~=.  // drop two more subjects with implausible value
	* Registration year
replace regyear=2007+regyear // equialent to recode regyear (5=2012) (6=2013) ...
la var regyear "Registration year at the university"
	* Income
la def income 1 "Extremely bad" 2 "Moderately bad" 3 "Slightly bad" 4 "Neither good nor bad" 5 "Slightly good" 6 "Moderately good" 7 "Extremely good"
la val income income

* Create a varable to indicate whether any given subject has participated in one, two or all three waves.
gen temp=1
bysort AM: egen nwaves=total(cond(wave==3 | wave==4 | wave==41,temp,.)) // create variable to constrain sample to common pool over the 3 waves, see https://www.stata.com/support/faqs/statistics/reference-panel/
recode nwaves (50=1) (100=2) (150=3)
la var nwaves "Number of waves a subject has participated in..."

* Check if gender, a time invariant variable, is indeed time invariant. Otherwise it might indicate low quality subjects.
* Check for gender
levelsof AM, local(levels) 
foreach m of local levels {
qui sum gender if AM==`m'
if r(sd)!=0 & r(N)>0 {
di in red "AM = " in red `m' " SD=" in red r(sd) 
}
}
list nwaves wave gender if AM==16084 // Subject with this ID number has incosistent answer about gender.
recode gender (1=0) if AM==16084 // we verify subjects gender from the university's files