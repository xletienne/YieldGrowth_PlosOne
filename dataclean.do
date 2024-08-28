
cd "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2023\data"

import delimited prod.csv, clear
rename itemcodefao itemcode
keep itemcode item year value
rename value prod
egen id = concat(itemcode year)
save prod.dta, replace


import delimited area.csv, clear
rename itemcodefao itemcode
keep itemcode item year value
rename value area
egen id = concat(itemcode year)
save area.dta, replace

merge 1:1 id using prod

list if _merge<3 /*for rice paddy, the calorie used later is for rice paddy, not rice paddy milled*/
/* missing area info
Brazil nuts
Tallowtree seeds
mushrooms and truffles
Coir, raw
Balata, gutta-percha, guayule, chicle and similar natural gums in primary forms or in plates, sheets or strip
*/
drop if _merge==2 
drop _merge


save data_all.dta, replace


import excel "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2023\data\calorie.xlsx", sheet("FAOSTAT_data_5-28-2020") firstrow clear

rename ItemCode itemcode
rename D calorie_original_item


merge 1:m itemcode using data_all


order G, last
sort itemcode year
list if _merge<3

* drop palm kernels and palm oil since we will just use plam fruit data
drop if Item=="Palm kernels" | Item=="Oil, palm"


/* The calorie for Kapok fruit is for Kapok oil. 27.5% of kapok seeds is kapok oil. 
* Use the Kapok seeds production data instead of the Kapok fruit data
* Area is still the area for Kapok fruit

replace prod = prod[_n+59] if Item == "Kapok fruit"
drop if item == "Kapokseed in shell"*/


/* Area data for cottonseed missining, using the area for seed cotton
replace area = area[_n-59] if Item == "Cottonseed" 
replace area = area[_n-27] if Item == "Cottonseed" & region =="Central Asia"
drop if item == "Seed cotton" 2019 update removed the cottonseed item*/

* The calorie data for "Vegetables, leguminous nes" is the average of "beans green, peas greem, broad breans green, string beans"
replace calorie_original_item =" avg of beans, peas, broad, string beans" if item == "Vegetables, leguminous nes"


* Now these are the items with both production and area info, but they are not for human * consumption
drop if Item == "Jute" 
drop if Item == "Bastfibres, other"
drop if Item == "Ramie"
drop if Item == "Flax fibre and tow"
drop if Item == "Hemp tow waste"
drop if Item == "Sisal"
drop if Item == "Agave fibres nes"
drop if Item == "Manila fibre (abaca)"
drop if Item == "Fibre crops nes"
drop if Item == "Tobacco, unmanufactured"
drop if Item == "Rubber, natural"
drop if Item == "Gums, natural" //production data not available
drop if Item == "Pyrethrum, dried"
drop if Item == "Jojoba seed" // mostly used for personal care products
drop if Item == "Tallowtree seed" //seeds and fruit of the tree are poisonous to humans. Not for human consumption?
drop if Item == "Hops" //hops are added to provide a bitter flavour to beer, no calorie
drop if Item == "Coir" //hops are added to provide a bitter flavour to beer, no calorie

drop if Item == "Rice, paddy (rice milled equivalent)"

list if prod == . & area !=.
list if prod != . & area ==. //Brazil nuts (216), Mushrooms and truffles (449),  Balata, (839) no area info

list if Calorieperton ==. // Balata, (839) 

drop if prod == . & area !=.
drop if prod != . & area ==.



replace Conversionfactor = 1 if Conversionfactor ==.

egen N_cropbyyear = count(itemcode), by (year)


**********************************************************************************
*  Now generates aggregate index
***********************************************************************************

gen caloriecrop = prod * Calorieperton * Conversionfactor
label variable caloriecrop "kcal of crop in year X"
sort year itemcode

by year: egen calorietotal = total(caloriecrop)
label variable calorietotal "kcal of all crops by year"
format calorietotal %20.0g

by year: egen areatotal = total(area)
label variable areatotal "areas all crops by year"
format areatotal %20.0g

gen cyield = calorietotal/areatotal
label variable cyield "total yield for all crops"
drop item _merge G

save data_all.dta, replace

*****************************************************************************
*============================================================================

* Add new aggregate index to a seperate file
use data_all.dta, clear
keep if itemcode==15
keep year calorietotal areatotal cyield
rename calorietotal calorieTotal
rename areatotal areaTotal
save cyield.dta, replace
label data "clean calorific yield, calorie total, and area info for indexes"
save cyield.dta, replace
* save data_cyield.dta, replace

* Add maize, wheat, rice, and soybean area and calorie production info and yied to dataset


use data_all.dta, clear

input str213 big4
"Wheat"
"Ricepaddy"
"Maize" 
"Soybeans" 
end

replace Item="Ricepaddy" if Item=="Rice, paddy"

levelsof big4, local(levels)
foreach i of local levels {
	di "`i'"
    preserve
    keep if Item=="`i'" 
    rename caloriecrop calorie`i'
	format calorie`i' %20.0g
	rename area area`i'
    gen `i' = calorie`i'/area`i'
    keep year calorie`i' area`i' `i'
    merge 1:1 year using cyield.dta
	drop _merge
	save cyield.dta, replace
	restore
}


use cyield.dta, clear




**********************************************************************************
*  Now generates aggregate index for big 4 and other crops
***********************************************************************************

use data_all.dta, clear

gen big4 =1 if Item=="Wheat" | Item=="Rice, paddy" | Item =="Maize" | Item=="Soybeans"
replace big4=0 if big4==.

by year: egen caloriebig4 = total(caloriecrop) if big4==1
by year: egen caloriebig4other = total(caloriecrop) if big4==0
label variable caloriebig4 "kcal of big4 by year"
label variable caloriebig4other "kcal of crops other than big4 by year"
format caloriebig4 %20.0g
format caloriebig4other %20.0g

by year: egen areabig4 = total(area) if big4==1
by year: egen areabig4other = total(area) if big4==0
format areabig4 %20.0g
format areabig4other %20.0g

gen cyieldbig4 = caloriebig4/areabig4
gen cyieldbig4other = caloriebig4other/areabig4other

sort itemcode year

preserve
keep if itemcode==15 //randomly selecte one of the big 4 crops, since numbers are same for all big4
keep year caloriebig4 areabig4 cyieldbig4
rename cyieldbig4 Big4
merge 1:1 year using cyield.dta
drop _merge
rename caloriebig4 calorieBig4
rename areabig4 areaBig4
save cyield.dta, replace
restore

preserve
keep if itemcode==75 //randomly selecte one of the other crops, since numbers are same for all big4
keep year caloriebig4other areabig4other cyieldbig4other
rename cyieldbig4other Big4Other
rename caloriebig4other calorieBig4Other
rename areabig4other areaBig4Other
merge 1:1 year using cyield.dta
drop _merge
save cyield.dta, replace

use cyield.dta, clear

**********************************************************************************
*  Now generates aggregate index for big 4 and other crops
***********************************************************************************
use data_all.dta, clear

* commodity grops
* 1 = cereals and grains, 15 crops ID<=108
* 2 = oil crops, 21 in total (excluding jojoba seed, palm kernel and oil in FAO) 236<=ID<=339
* 3 = fruits and vegetables, 64 crops, 358<=ID<=619 and ID !=459
* 4 = others, including pulses, roots and tubers, treenuts, 

gen cropgroup = 1 if itemcode<=108
replace cropgroup = 2 if itemcode>= 236 & itemcode<=339 
replace cropgroup =3 if itemcode >=358 & itemcode <=619 & itemcode !=459
replace cropgroup =4 if cropgroup==.

local i=1
forv i=1/4{
	di `i'
    preserve
    keep if cropgroup==`i' 
    by year: egen area`i' = total(area) 
	by year: egen calorie`i'=total(caloriecrop)
	format calorie`i' %20.0g
	format area`i' %20.0g
    gen cyield`i' = calorie`i'/area`i'
	sort itemcode year
    keep year calorie`i' area`i' cyield`i'
	keep in 1/61
    merge 1:1 year using cyield.dta
	drop _merge
	save cyield.dta, replace
	restore
}

**************

use cyield.dta, clear

export excel using "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2023\data\YieldIndex23.xlsx", sheet("world", replace) firstrow(variables) 



