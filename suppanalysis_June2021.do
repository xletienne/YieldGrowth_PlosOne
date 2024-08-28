//Supplemental analysis
cd "d:\Dropbox\CurrentSubmission\Yield\2023\data"

//Table S4, structural break and box cox transformation

clear all
use cyield.dta
merge 1:1 year using cyield_region.dta




tsset year

gen trend=_n
gen trend2=trend^2



rename cyield all
replace all=all/1000

rename Big4 big4
replace big4=big4/1000

rename Big4Other big4other
replace big4other=big4other/1000

rename Low low
replace low=low/1000

rename High high
replace high=high/1000

rename Maize maize
replace maize = maize/1000

rename Soybeans soybeans
replace soybeans = soybeans/1000

rename Wheat wheat
replace wheat = wheat/1000

rename Ricepaddy rice
replace rice = rice/1000


gen logall=log(all)

* Structural break test for the aggregate yield, 1993 is the break date

quietly regress all trend
estat sbcusum
quietly regress all trend
estat sbsingle
estat sbsingle,  all
estat sbsingle,  generate(wald)
tsline wald, title("Wald test statistics")

scalar br=1992-1960
scalar br1=1992
mkspline trend_before `=br' trend_after =trend, marginal


* Structural break test for the log aggregate yield, 1978 is the break date

quietly regress logall trend
estat sbcusum
quietly regress logall trend
estat sbsingle
estat sbsingle,  all
estat sbsingle,  generate(waldlog)
tsline waldlog, title("Wald test statistics")

scalar brlog=1977-1960
scalar br1log=1977
mkspline trend_beforelog `=brlog' trend_afterlog =trend, marginal



boxcox all trend
boxcox all trend trend2
boxcox all trend_before trend_after
boxcox all trend_beforelog trend_afterlog


// Table S5

* Table S5 Commodity disaagregation
eststo clear
local product "all big4other big4 maize rice wheat soybeans"
foreach prod in `product'{
	regress `prod' trend
	local r2= e(r2_a)
	predict resid`prod', r
	dfgls resid`prod' //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`prod' //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `prod' trend, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
esttab using results_tableS5.rtf, ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)  replace 

eststo clear
local product "all big4other big4 maize rice wheat soybeans"
foreach prod in `product'{
	regress `prod' trend trend2
	local r2= e(r2_a)
	predict resid`prod'2, r
	dfgls resid`prod'2 //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`prod'2 //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `prod' trend trend2, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
esttab using results_tableS5.rtf, ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)  append	
		
		
eststo clear
local product "all big4other big4 maize rice wheat soybeans"
foreach prod in `product'{
    //scalar br=1992-1960
	//scalar br1=1992
	//mkspline trend_before `=br' trend_after =trend, marginal
	quietly regress `prod' trend_before trend_after
	local r2= e(r2_a)
	predict resid`prod'3, r
	dfgls resid`prod'3 //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`prod'3 //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `prod' trend_before trend_after, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
	esttab using results_tableS5.rtf, ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)  append	
		
		
// Table S6

* Table S6 regional aggreation
drop resid*
rename LAC lac
replace lac =lac/1000

rename SEAO seao
replace seao = seao/1000

rename EECA eeca
replace eeca = eeca/1000

rename MENA mena
replace mena = mena/1000

rename SSA ssa
replace ssa = ssa/1000

eststo clear
local region "high low lac seao eeca mena ssa"
foreach reg in `region'{
	regress `reg' trend
	local r2= e(r2_a)
	predict resid`reg', r
	dfgls resid`reg' //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`reg' //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `reg' trend, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
	esttab using results_tableS6.rtf,  ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01) replace	


eststo clear
local region "high low lac seao eeca mena ssa"
foreach reg in `region'{
	regress `reg' trend trend2
	local r2= e(r2_a)
	predict resid`reg'2, r
	dfgls resid`reg'2 //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`reg'2 //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `reg' trend trend2, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
	esttab using results_tableS6.rtf,  ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)  append	

		

	
eststo clear
local region "high low lac seao eeca mena ssa"
foreach reg in `region'{
	quietly regress `reg' trend_before trend_after
	local r2= e(r2_a)
	predict resid`reg'3, r
	dfgls resid`reg'3 //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`reg'3 //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey `reg' trend_before trend_after, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}	
	esttab using results_tableS6.rtf,  ///
		b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01) append	



// Table S7 by commodity group

* commodity grops
* 1 = cereals and grains, 15 crops ID<=108
* 2 = oil crops, 21 in total (excluding jojoba seed, palm kernel and oil in FAO) 236<=ID<=339
* 3 = fruits and vegetables, 64 crops, 358<=ID<=619 and ID !=459
* 4 = others, including pulses, roots and tubers, treenuts, 

drop resid*
eststo clear

local i=1
forv i=1/4{
	replace cyield`i' =cyield`i'/1000
	local i=`i'+1
}



local i=1
forv i=1/4{
	regress cyield`i' trend
	local r2= e(r2_a)
	predict resid`i', r
	dfgls resid`i' //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`i' //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey cyield`i' trend, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
	local i=`i'+1
}
	esttab using results_tableS7.rtf, ///
		 b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)    replace	

drop resid*
eststo clear
local i=1
forv i = 1/4{
	regress cyield`i' trend trend2
	local r2= e(r2_a)
	predict resid`i', r
	dfgls resid`i' //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`i' //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey cyield`i' trend trend2, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}
	esttab using results_tableS7.rtf,  ///
		 b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)    append	

		

drop resid*	
eststo clear
local i=1
forv i=1/4{
	quietly regress cyield`i' trend_before trend_after
	local r2= e(r2_a)
	predict resid`i', r
	dfgls resid`i' //dfgls
	matrix b=r(results)
	local k=11-r(sclag)
	quietly pperron resid`i' //pperon
	local pT=r(Zt)
	local pP=r(pval)
	eststo: quietly newey cyield`i' trend_before trend_after, lag(1)
	estadd scalar DF_GLS = b[`k',5]
	estadd scalar pTau = `pT'
	estadd scalar pPval = `pP'
	estadd scalar r2= `r2'
}	
	esttab using results_tableS7.rtf,  ///
		 b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)    append	


		
		

