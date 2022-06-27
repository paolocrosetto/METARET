frame reset 
frame rename default mobility
import delimited using "2020_GR_Region_Mobility_Report.csv", clear 
keep if sub_region_1=="Decentralized Administration of Attica"
keep date-residential_percent_change_from_
gen date2=date(date,"YMD")
drop date
rename date2 date
format date %td
generate retail_recreation=(retail_and_recreation_percent_ch[_n]+retail_and_recreation_percent_ch[_n-1]+retail_and_recreation_percent_ch[_n-2]+retail_and_recreation_percent_ch[_n-3]+retail_and_recreation_percent_ch[_n-4])/5 if _n>=5

generate parks=(parks_percent_change_from_baseli[_n]+parks_percent_change_from_baseli[_n-1]+parks_percent_change_from_baseli[_n-2]+parks_percent_change_from_baseli[_n-3]+parks_percent_change_from_baseli[_n-4])/5 if _n>=5

generate work=(workplaces_percent_change_from_b[_n]+workplaces_percent_change_from_b[_n-1]+workplaces_percent_change_from_b[_n-2]+workplaces_percent_change_from_b[_n-3]+workplaces_percent_change_from_b[_n-4])/5 if _n>=5

generate resid=(residential_percent_change_from_[_n]+residential_percent_change_from_[_n-1]+residential_percent_change_from_[_n-2]+residential_percent_change_from_[_n-3]+residential_percent_change_from_[_n-4])/5 if _n>=5
  
frame create covid
frame change covid
import delimited greeceTimeline.csv, clear encoding(utf8)
rename v370 feb2621
rename v371 feb2721
rename v372 feb2821
rename v373 mar121
keep if status=="deaths" | status=="total cases"
local y=1
foreach var of varlist feb26-feb25 feb2621 feb2721 feb2821 mar121 {
recode `var' (.=0)
rename `var' var`y'
local y=`y'+1
}
gen id=_n
reshape long var, i(id) j(date)
gen newdate=mdy(2,26,2020) if date==1
bysort id status (date): replace newdate=newdate[_n-1]+1 if _n>1
format newdate %d
drop date
rename newdate date

gen totdeaths=.
gen idn=.
local y=1
foreach x of numlist 21971(1)22340 {
local z=`y'+370
replace idn=`y' in `y'
replace idn=`y' in `z'
sum var if date<=`x' & status=="deaths"
di r(sum)
replace totdeaths=r(sum)  in `y'
local y=`y'+1
}
replace var=totdeaths if totdeaths!=.
drop totdeaths
replace status="total deaths" if status=="deaths"
keep idn status var date
rename var totdeaths
gen totcases=.

local y=1
foreach x of numlist 21971(1)22340 {
local z=`y'+370
replace totcases=totdeaths[`z'] in `y'
local y=`y'+1
}
drop if totcases==.
drop status idn

frame change mobility
frlink 1:1 date, frame(covid) generate(linkvar)
frget totcases totdeaths, from(linkvar) 
drop linkvar 
gen lnallcases=log(totcases)
gen lnalldeaths=log(totdeaths)

twoway scatter retail_and_recreation_percent_ch date, recast(line) lcolor(blue*0.9) lw(thin) ylabel(-100(20)160) tlabel(15feb2020 01mar2020 15mar2020 01apr2020 15apr2020 01may2020 15may2020 01jun2020 15jun2020 01jul2020 15jul2020 01aug2020 15aug2020 01sep2020 15sep2020 01oct2020 15oct2020 01nov2020 15nov2020 01dec2020 15dec2020 01jan2021 15jan2021 01feb2021 15feb2021 01mar2021, angle(80) format(%tdmd)) yline(0, lcolor(black)) || scatter parks_percent_change_from_baseli* date, lcolor("0 136 55*0.9") lw(thin) recast(line) legend(order(1 "Retail" 2 "Parks" 3 "Work" 4  "Residential" 5 "Cases" 6 "Deaths") position(6) cols(4)) || scatter workplaces_percent_* date, lcolor("252 102 0*1") lw(medium) recast(line) || scatter residential_percent_ date, recast(line) lcolor(red*0.9) lw(medium) xtitle("") tline(23mar2020 04may2020 07nov2020) tmlabel(23mar2020 04may2020 07nov2020, format(%tdmd) angle(95) labcolor(red)) ttext(170 30mar2020 "1st curfew" 170 01dec2020 "2nd curfew", placement(3) size(vsmall)) || scatter lnallcases date, recast(line) lcolor("218 165 32%80") lwidth(thick) yaxis(2) yscale(range(-7.6, 10) axis(2)) || scatter lnalldeaths date, recast(line) lcolor("170 56 30%80") lwidth(thick) yaxis(2) ylabel(12.154779 "190000" 10.714418 "45000" 8.764 "6400" 7.824 "2500" 6.65 "750" 5.0106 "150" 2.708 "15", axis(2) nogextend) yscale(range(-7) axis(2)) ytitle("Cases/deaths", axis(2))

* 5-day rolling average
twoway scatter retail_recreation date, recast(line) lcolor(blue*0.9) lw(thin) ylabel(-100(20)160) tlabel(15feb2020 01mar2020 15mar2020 01apr2020 15apr2020 01may2020 15may2020 01jun2020 15jun2020 01jul2020 15jul2020 01aug2020 15aug2020 01sep2020 15sep2020 01oct2020 15oct2020 01nov2020 15nov2020 01dec2020 15dec2020 01jan2021 15jan2021 01feb2021 15feb2021 01mar2021, angle(80) format(%tdmd)) yline(0, lcolor(black)) || scatter parks date, lcolor("0 136 55*0.9") lw(thin) recast(line) legend(order(1 "Retail" 2 "Parks" 3 "Work" 4  "Residential" 5 "Cases" 6 "Deaths") position(6) cols(4)) || scatter work date, lcolor("252 102 0*1") lw(medium) recast(line) || scatter resid date, recast(line) lcolor(red*0.9) lw(medium) xtitle("") tline(23mar2020 04may2020 07nov2020) tmlabel(23mar2020 04may2020 07nov2020, format(%tdmd) angle(95) labcolor(red)) ttext(170 30mar2020 "1st curfew" 170 01dec2020 "2nd curfew", placement(3) size(vsmall)) || scatter lnallcases date, recast(line) lcolor("218 165 32%80") lwidth(thick) yaxis(2) yscale(range(-7.6, 10) axis(2)) || scatter lnalldeaths date, recast(line) lcolor("170 56 30%80") lwidth(thick) yaxis(2) ylabel(12.154779 "190000" 10.714418 "45000" 8.764 "6400" 7.824 "2500" 6.65 "750" 5.0106 "150" 2.708 "15", axis(2) nogextend) yscale(range(-7) axis(2)) ytitle("Cases/deaths", axis(2))
graph export "mobility.png", as(png) width(6000) replace

*ssc install mylabels
mylabels 20 40 60 80 100 120 140 160 180, myscale(@*1000) local(mylabel)
twoway scatter totcases date, recast(line) lcolor("218 165 32%80") lwidth(medthick) tlabel(15feb2020 01mar2020 15mar2020 01apr2020 15apr2020 01may2020 15may2020 01jun2020 15jun2020 01jul2020 15jul2020 01aug2020 15aug2020 01sep2020 15sep2020 01oct2020 15oct2020 01nov2020 15nov2020 01dec2020 15dec2020 01jan2021 15jan2021 01feb2021 15feb2021 01mar2021, angle(80) format(%tdmd)) yline(0, lcolor(black)) || scatter totdeaths date, recast(line) lcolor("170 56 30%80") lwidth(medthick) xtitle("") tline(23mar2020 04may2020 07nov2020) tmlabel(23mar2020 04may2020 07nov2020, format(%tdmd) angle(95) labcolor(red)) ttext(200000 30mar2020 "1st curfew" 200000 01dec2020 "2nd curfew", placement(3) size(vsmall)) legend(order(1 "Cases" 2 "Deaths") position(6) rows(1)) ylabel(`mylabel') ymtick(10000(20000)190000) || scatter totcases date, yaxis(2) msymbol(none) ytitle("Cases/deaths", axis(2))  ylabel(0 "0          ", axis(2) nogextend)
graph export "casesdeaths.png", as(png) width(6000) replace