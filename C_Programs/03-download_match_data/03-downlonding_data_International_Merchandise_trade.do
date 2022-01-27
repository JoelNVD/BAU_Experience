/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to download data → INCOMPLETE
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "03-downlonding_data_International_Merchandise_trade"

*** 1.2 Strucuture of te log file name 
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
*** PART 2: Dowloading
********************************************************************************
        
        import delimited "${rawdata_3_1}/International_Merchandise_trade/US_TradeMatrix_Part1_ST202109291451_v1.csv", ///
                colrange(:11) rowrange(1048576) clear

// Do file using chunky.ado to piece together parts of a very large file
// Pay particular attention to the edit points for infile and chunksize and keep

// edit VeryLargeFile.csv on the following line to point to your file
local infile VeryLargeFile.csv

// edit to size of chunk you want
local chunksize 10000

// Get just the first line if it has variable names
chunky using `"`infile'"', index(1) chunk(1) saving("varnames.csv",
replace) list

local chunk 1
local nextrow 2
while !`r(eof)' {  // aborts loop when end of file is reached
        tempfile chunkfile chunkappend
        chunky using `"`infile'"', ///
          index(`r(index)') chunk(`chunksize') saving("`chunkfile'")
        if `r(eof)' {
                continue, break
                }
                else {
                        local nextrow `=`r(index)'+1'
                        }
        // use a shell command to append the varnames with the chunk
        !copy varnames.csv+`chunkfile' `chunkappend'

        // edit the following to conform to your csv delimiter
        insheet using "`chunkappend'", clear tab names

        // edit the following to keep specific variables
        keep *

        // save part of file and increment chunk count
        save part`chunk++', replace
        }
// Append parts together
local nparts `=`chunk'-1'
use part1, clear
forvalues i=2/`nparts' {
        append using part`i'
        // uncomment the following line to erase the parts
        // erase part`i'
        }
describe

********************************************************************************
*** PART 3: Saving new database
********************************************************************************

*** 3.1 Save
        *save "${data_5_1}/International_Merchandise_trade", replace
        *saveold  "${data_5_1}/International_Merchandise_trade", version(13) replace

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
        log close
