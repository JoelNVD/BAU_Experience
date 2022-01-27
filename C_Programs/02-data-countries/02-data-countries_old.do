/*=====================================================================================================
* PROJECT NAME
* Principal: 		Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to nothing
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/
	*--------------------------------------------------
    * 1.1 Globals
    *--------------------------------------------------  
		global dofilename "02-data_countries_01"

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
		use "${rawdata_2_1}/main-data_all-countries_15Oct2020 165731.dta", clear

		describe
		summarize

********************************************************************************
*** PART 3: Closing log file
********************************************************************************
    log close
