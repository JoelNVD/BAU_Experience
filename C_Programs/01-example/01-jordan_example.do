/*=====================================================================================================
* PROJECT NAME
* Purpose: 			Simple time series example
* Principal: 		Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created according to Óscar Jordan example from his
	  website: https://sites.google.com/site/oscarjorda/home/local-projections
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/
	*--------------------------------------------------
    * 1.1 Globals
    *--------------------------------------------------  
		global dofilename "01-jordan_example"

	*--------------------------------------------------
    * 1.2 Strucuture of te log file name 
    *--------------------------------------------------
        cap log close
        local td: di %td_CY-N-D  date("$S_DATE", "DMY") 
        local td = trim("`td'")
        local td = subinstr("`td'"," ","_",.)
        local td = subinstr("`td'",":","",.)
        log using "${D}/${dofilename}-`td'_1", text replace 
        local today "`c(current_time)'"
        local curdir "`c(pwd)'"
        local newn = c(N) + 1

********************************************************************************
*** PART 2: Introduction
********************************************************************************

	*--------------------------------------------------
    * 2.1 Using website database
    *--------------------------------------------------
		use "${rawdata_1_1}/jorda_database_old.dta", clear

		describe
		summarize

	*--------------------------------------------------
    * 2.2 Choose impulse response horizon
    *--------------------------------------------------
		local hmax = 12

	*--------------------------------------------------
    * 2.3 Generate LHS variables for the LPs
    *--------------------------------------------------
		qui forvalues h = 0/`hmax' {
				* Levels
					gen gs10_`h' = f`h'.gs10
				* Differences
					gen gs10d`h' = f`h'.gs10 - l.f`h'.gs10 
				* Cumulative
					gen gs10c`h' = f`h'.gs10 - l.gs10 
			}

		save "${data_1_1}/jorda_database_new.dta", replace

	*--------------------------------------------------
    * 2.5 Run the LPs 
    *--------------------------------------------------
    	use "${data_1_1}/jorda_database_new.dta", clear

		qui foreach x in "gs1"{
				foreach y in "dgs1"{
					eststo clear

					cap drop b u d Years Zero

					gen Years = _n-1  if _n<=`hmax'
					gen Zero  =  0    if _n<=`hmax'
					gen b=0
					gen u=0
					gen d=0

					* levels
						forv h = 0/`hmax' {
						 reg `x'0_`h' l(0/4).`x' l(1/3).`x'0, vce(robust)
							replace b = _b[`x']                    if _n == `h'+1
							replace u = _b[`x'] + 1.645* _se[`x']  if _n == `h'+1
							replace d = _b[`x'] - 1.645* _se[`x']  if _n == `h'+1
							eststo
						}
						cap gen b_level = b

					* Differences
						forv h = 0/`hmax' {
						reg gs10d`h' l(0/4).`y' l(1/3).`y'0, vce(robust)
							replace b = _b[`y']                    if _n == `h'+1
							replace u = _b[`y'] + 1.645* _se[`y']  if _n == `h'+1
							replace d = _b[`y'] - 1.645* _se[`y']  if _n == `h'+1
							eststo
						}

						twoway (rarea u d  Years, fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) 				///
							   (line b Years, lcolor(blue) lpattern(solid) lwidth(thick)) 							///
							   (line Zero Years, lcolor(black)), legend(off) 										///
							   title("Impulse response of GS10 to 1pp shock to GS1", color(black) size(medsmall)) 	///
							   ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) tlabel(0(1)11) 		///
							   name(first, replace)

					   graph export "${outputf_1_1}/first_graph.pdf", replace

					* Cumulative
						forv h = 0/`hmax' {
						reg gs10c`h' l(0/4).`y' l(1/3).`y'0, vce(robust)
							replace b = _b[`y']                    if _n == `h'+1
							replace u = _b[`y'] + 1.645* _se[`y']  if _n == `h'+1
							replace d = _b[`y'] - 1.645* _se[`y']  if _n == `h'+1
							eststo
						}

						twoway (rarea u d  Years, fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid))				 		 ///
							   (line b Years, lcolor(blue) lpattern(solid) lwidth(thick)) 									 ///
							   (line b_level Years, lcolor(red) lpattern(dash) lwidth(vthick)) 								 ///
							   (line Zero Years, lcolor(black)), legend(off) tlabel(0(1)11)									 ///
							   title("Cumulative response of GS10 to 1pp shock to GS1", color(black) size(medsmall)) 		 ///
							   subtitle("Levels on levels (solid blue) vs. Cumulative (dash red)", color(black) size(small)) ///
							   ytitle("Percent", size(medsmall)) xtitle("Year", size(medsmall)) name(second, replace) 

						   graph export "${outputf_1_1}/second_graph.pdf", replace

					gr combine first second, title("Levels and cumulated impulse responses") ///
									 note("Note: 90% confidence bands displayed") iscale(0.6)
						graph export "${outputf_1_1}/third_graph.pdf", replace
				}
			}

********************************************************************************
*** PART 3: Closing log file
********************************************************************************
    log close
