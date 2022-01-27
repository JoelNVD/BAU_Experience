/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to merge data downloaded in 03-downloading_data
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "03-matching_data"

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
*** PART 2: Matching
********************************************************************************

*** 2.1 Merge between GDP_WB and POP_WB
        use "${rawdata_3_1}/SP_POP_TOTL.dta", clear

        merge 1:1 id using "${rawdata_3_1}/NY_GDP_MKTP_CD"
        drop _merge IndicatorName IndicatorCode
        order id year
        tempfile local_GDP_POP_data
        save `local_GDP_POP_data'

*** 2.2 Merge between GDP-POP and SPE
        use "${rawdata_3_1}/SPE_CEPAL.dta", clear

        merge m:1 year country using `local_GDP_POP_data'
        order id year CountryCode

        sort country year
        drop _merge

*** 2.3 Cleaning
        local classi`" "Education", "Environmental Protection", "Health", "Housing and community services", "Recreational activities, culture and religion", "Social expenditure", "Social protection" "'
        keep if inlist(classification, `classi')
        drop id
        encode country, gen(country_id)

*** 2.4 Add IMF Contry code
        gen imf_code =.

        local abbrevi `" "ARG" "BHS" "BOL" "BRA" "BRB" "CHL" "COL" "CRI" "DOM" "ECU" "GTM" "GUY" "HND" "HTI" "JAM" "MEX" "NIC" "PAN" "PER" "PRY" "SLV" "TTO" "URY" "VEN" "CUB" "'
        local codeimf `" "213" "313" "218" "223" "316" "228" "233" "238" "243" "248" "258" "336" "268" "263" "343" "273" "278" "283" "293" "288" "253" "369" "298" "299" "928" "'

        forval n = 1/25{
                local a : word `n' of `abbrevi'
                local b : word `n' of `codeimf'

                replace imf_code = `b' if CountryCode == "`a'"
        }

        sort country year
        order year country_id country
        order year imf_code CountryCode country_id country 

*** 2.5 Adding labels
        label var year "Years 1960-2020"
        label var CountryCode "Country codes"
        label var country "Countries"
        label var classification "Social Public Expenditure classification"
        label var expenditure "Social Public Expenditure classification (%GDP)"
        label var SP_POP_TOTL "Population 1960-2020"
        label var NY_GDP_MKTP_CD "Gross Domestic Product (current US$) 1960-2020"
        label var imf_code "IMF Country Code"

*** 2.6 Saving database
        save "${data_3_1}/GDP_POP_SPE.dta", replace
        saveold  "${data_3_1}/GDP_POP_SPE_stata13.dta", version(13) replace

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
    log close
