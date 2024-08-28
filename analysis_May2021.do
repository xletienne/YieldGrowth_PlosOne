

cd "C:\Users\sherr\Dropbox\CurrentSubmission\Yield\2023\data"

cd "d:\Dropbox\CurrentSubmission\Yield\2023\data"
//Analysis for various sub-indicies (crops) PLS change everything to 2002

clear all
use cyield.dta
merge 1:1 year using cyield_region.dta




tsset year

gen trend=_n
gen trend2=trend^2


rename cyield all
replace all=all/1000

gen logall=log(all)

rename Big4 big4
replace big4=big4/1000

rename Big4Other big4other
replace big4other=big4other/1000

rename Low low
replace low=low/1000

rename High high
replace high=high/1000




* Structural break test for the aggregate yield, 1993 is the break date

quietly regress all trend
estat sbcusum
quietly regress all trend
estat sbsingle
estat sbsingle,  all
estat sbsingle,  generate(wald)
tsline wald, title("Wald test statistics")

drop wald
* Structural break test for the log aggregate yield, 1993 is the break date

quietly regress logall trend
estat sbcusum
quietly regress logall trend
estat sbsingle
estat sbsingle,  all
estat sbsingle,  generate(wald)
tsline wald, title("Wald test statistics")


**************************************************************************

scalar br=1992-1960
scalar br1=1992
mkspline trend_before `=br' trend_after =trend, marginal


**** Box cox transformation 

boxcox all trend, model(lhsonly) 
boxcox all trend trend2, model(lhsonly) 
boxcox all trend trend_before trend_after, model(lhsonly) 



scalar br2=1977-1960
scalar br3=1977
mkspline trend_beforelog `=br2' trend_afterlog =trend, marginal


boxcox all trend trend_beforelog trend_afterlog, model(lhsonly) 




eststo clear


* Table 1

*** All


regress all trend
local r2= e(r2_a)
predict resid, r
dfgls resid //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey all trend, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2 = `r2'


regress all trend trend2
local r2= e(r2_a)
predict resid2, r
dfgls resid2 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid2 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey all trend trend2, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

regress all trend_before trend_after
local r2= e(r2_a)
predict resid3, r
dfgls resid3 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid3 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey all trend_before trend_after, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'


*** Big 4

regress big4 trend
local r2= e(r2_a)
predict resid4, r
dfgls resid4 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid4 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4 trend, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

regress big4 trend trend2
local r2= e(r2_a)
predict resid5, r
dfgls resid5 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid5 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4 trend trend2, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

quietly regress big4 trend_before trend_after
local r2= e(r2_a)
predict resid6, r
dfgls resid6 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid6 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4 trend_before trend_after, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

*** Other

regress big4other trend
local r2= e(r2_a)
predict resid7, r
dfgls resid7 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid7 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4other trend, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

regress big4other trend trend2
local r2= e(r2_a)
predict resid8, r
dfgls resid8 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid8 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4other trend trend2, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'


quietly regress big4other trend_before trend_after
local r2= e(r2_a)
predict resid9, r
dfgls resid9 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid9 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey big4other trend_before trend_after, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

*** Mature

regress high trend
local r2= e(r2_a)
predict resid10, r
dfgls resid10 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid10 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey high trend, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'


regress high trend trend2
local r2= e(r2_a)
predict resid11, r
dfgls resid11 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid11 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey high trend trend2, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'


quietly regress high trend_before trend_after
local r2= e(r2_a)
predict resid12, r
dfgls resid12 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid12 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey high trend_before trend_after, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

*** Growing

regress low trend
local r2= e(r2_a)
predict resid13, r
dfgls resid13 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid13 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey low trend, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

regress low trend trend2
local r2= e(r2_a)
predict resid14, r
dfgls resid14 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid14 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey low trend trend2, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

quietly regress low trend_before trend_after
local r2= e(r2_a)
predict resid15, r
dfgls resid15 //dfgls
matrix b=r(results)
local k=11-r(sclag)
quietly pperron resid15 //pperon
local pT=r(Zt)
local pP=r(pval)
eststo: newey low trend_before trend_after, lag(1)
estadd scalar DF_GLS = b[`k',5]
estadd scalar pTau = `pT'
estadd scalar pPval = `pP'
estadd scalar r2= `r2'

esttab using results_table1.rtf,   ///
  b(%9.2f) se(%9.2f)  stats(r2 N DF_GLS pTau pPval, fmt(%9.2f %9.00g %9.2f %9.2f %9.2f)) star(* 0.10 ** 0.05 *** 0.01)  replace


	

