/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to download data. We use World Bank's database
      to downloaded Population and GDP; also we use CEPAL's to download Public 
      Social Expenditure
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "03-dowlonding_data"

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
*** PART 2: Using Python to download
********************************************************************************

*** 2.1 Short Python code
/*
python:
# Essential Packages
import seaborn as sns
import re
import os
from urllib.request import urlretrieve

# Define path
os.chdir(r'C:\Users\JOEL\Dropbox\Project_02\DataWork\B_RawData\03-download_data')

# Dowloading data
j = ['SP.POP.TOTL', 'NY.GDP.MKTP.CD', 'GC.XPN.TRFT.ZS']
k = ['SP_POP_TOTL', 'NY_GDP_MKTP_CD', 'GC_XPN_TRFT_ZS']

for p in [0,1,2]:
    url_wb = 'https://api.worldbank.org/v2/en/indicator/'+str(j[p])+'?downloadformat=excel'
    urlretrieve(url_wb, str(k[p])+'.xls')
end
*/

********************************************************************************
*** PART 3: Excel to .dta
********************************************************************************

*** 3.1 From World Bank
        local names `" "SP_POP_TOTL" "NY_GDP_MKTP_CD" "GC_XPN_TRFT_ZS" "'
        qui forval n=1/3{
                local a: word `n' of `names'

                import excel using "${rawdata_3_1}/`a'",sheet("Data") cellrange("A4:BM270") clear firstrow
                replace CountryName="Bahamas" if CountryName=="Bahamas, The"
                replace CountryName="Venezuela" if CountryName=="Venezuela, RB"
                rename CountryName country

                ds E-BM
                foreach v in `r(varlist)' {
                       local x : variable label `v'
                       rename `v' y`x'
                    }

                gen id=_n
                reshape long y, i(id) j(year)
                rename y `a' 
                drop id 
                gen id=_n

                save "${rawdata_3_1}/`a'.dta", replace
                saveold  "${rawdata_3_1}/`a'_stata13.dta", version(13) replace
            }

*** 3.2 From CEPAL
        import excel using "${rawdata_3_1}/SPE_CEPAL",clear firstrow

        ds y1990-y2019
        qui foreach k in `r(varlist)'{
                replace `k'="." if `k'=="..."
                destring `k', replace
            }

        gen id=_n
        reshape long y, i(id) j(year)
        rename y expenditure

        save "${rawdata_3_1}/SPE_CEPAL.dta", replace

*** 3.3 From IMF
        import excel using "${rawdata_3_1}/IMF_DATA_GFS_COFOG",sheet("Expenditure by Functions of Go") cellrange("A2:CU799") clear firstrow

        // Drop pair variables or variable within label: D(2) F(4) H(6) ...
           ds C-CU, not(varlabel)
           drop `r(varlist)'

        // Change Name variable from C to y1972 ...
           ds C-CU
           foreach v in `r(varlist)' {
                   local x : variable label `v'
                   rename `v' y`x'
           }

        // Database
           gen id=_n
           reshape long y, i(id) j(year)
           label var y "Classification of the Functions of Government (COFOG)"
           rename y expenditure_cofog
           drop id 
           gen id=_n
           drop id

        // Saving data
           save "${rawdata_3_1}/IMF_DATA_GFS_COFOG.dta", replace
           saveold  "${rawdata_3_1}/IMF_DATA_GFS_COFOG_stata13.dta", version(13) replace

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
    log close
