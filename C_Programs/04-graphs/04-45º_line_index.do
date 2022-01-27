/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to make 45º line graphs between the 
      Average 1980-2000 and Average 2001-2018
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "04-45º_line_index"

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
*** PART 2: Cleaning database
********************************************************************************

*** 2.1 Cleaning
        use "${rawdata_2_1}/main-data_all-countries_15Oct2020 165731.dta", clear

        keep year country gdppgrowth ASL_UEM_TOTL_ZS gini_disp cgrowth AFD_AST_PRVT_GD_ZS

        replace country="Bahamas" if country=="Bahamas, The"

        local center `" "Belize", "Costa Rica", "El Salvador", "Guatemala", "Honduras", "Nicaragua", "Panama" "'
        local cabba1 `" "Antigua and Barbuda", "Bahamas", "Barbados", "Cuba", "Dominica", "Haiti", "Jamaica", "Dominican Republic" "'
        local cabba2 `" "St. Kitts and Nevis", "St. Lucia", "St. Vincent and the Grenadines", "Trinidad and Tobago" "'
        keep if inlist(country, `center') | inlist(country, `cabba1') | inlist(country, `cabba2')

        /*
        Latin America & Caribbean
        local group1 `" "Antigua and Barbuda", "Argentina", "Aruba", "The Bahamas", "Barbados", "Belize", "Bolivia", "Brazil", "Cayman Islands" "'
        local group2 `" "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "Ecuador", "El Salvador", "Grenada", "Guatemala", "Guyana" "'
        local group3 `" "Jamaica" , "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru", "Puerto Rico", "St. Kitts and Nevis" "'
        local group4 `" "Suriname" , "Trinidad and Tobago", "Turks and Caicos Islands", "Uruguay", "Venezuela", "Venezuela, RB" "'
        local group5 `" "Colombia", "Honduras", "St. Lucia" , "St. Vincent and the Grenadines", "Virgin Islands (U.S.)", "Chile", "Haiti" "'
        keep if inlist(country, `group1') | inlist(country, `group2') | inlist(country, `group3') | inlist(country, `group4') | inlist(country, `group5')
        */

        drop if year<1980 | year>2018
        encode country, gen(country_id)

        order year country country_id

*** 2.2 Declare time series
        xtset country_id year, yearly


********************************************************************************
*** PART 3: Graphs
********************************************************************************

*** 3.1 45º line graphs

        local var `" "gini_disp" "ASL_UEM_TOTL_ZS" "gdppgrowth" "cgrowth" "AFD_AST_PRVT_GD_ZS" "'
        local numb `" "35 55" "0 25" "-2 -2 -2 6 6 6 -2 -2" "-2 -2 -2 6 6 6 -2 -2" "0 0 0 80 80 80 0 0" "'
        local title `" "Gini (household) disposable income" "Unemployment, total" "GDP per capita growth" "Consumption annual change" "Domestic credit to private sector by banks" "'
        local subti `" "(post-tax, post-transfer)" "(% of total labor force) (modeled ILO estimate)" "(annual %)" " " "(% of GDP)" "'

                local id_1 `" "Costa Rica", "Trinidad and Tobago", "Honduras", "Guyana", "Puerto Rico", "St. Kitts and Nevis", "St. Lucia" "' // gini_disp
                local id_2 `" "Guatemala", "Mexico", "Honduras", "Costa Rica", "Chile", "Brazil", "Haiti", "St. Lucia", "Bahamas" "' // ASL_UEM_TOTL_ZS
                local id_3 `" "Mexico", "Jamaica", "Barbados", "Bahamas", "Chile", "Puerto Rico", "Grenada", "Belize", "Dominica" "'  // gdppgrowth: 
                local id_4 `" "Suriname", "Barbados", "Venezuela, RB", "St. Lucia", "Dominica", "Mexico", "Haiti", "Puerto Rico", "Jamaica" "' // cgrowth:
                local id_5 `" "Argentina", "Uruguay", "Brazil", "Dominican Republic", "Suriname", "Venezuela, RB" "' // AFD_AST_PRVT_GD_ZS
                local ids  "id_1 id_2 id_3 id_4 id_5"
                local list1 = subinstr("`ids'", "!", " ", .)

                        local id_32 `" "Antigua and Barbuda", "Aruba", "St. Kitts and Nevis", "St. Vincent and the Grenadines", "St. Lucia" "' // gdppgrowth: 
                        local id_42 `" "Bahamas", "St. Kitts and Nevis", "Belize", "Paraguay", "Turks and Caicos Islands", "Antigua and Barbuda", "Cayman Islands", "Aruba" "' // cgrowth:

        forval n = 1/5 {
                local a: word `n' of `var'
                local b: word `n' of `numb'
                local c: word `n' of `title'
                local d: word `n' of `subti'
                local e: word `n' of `list1'
                
                preserve
                        drop if year>2000
                        collapse (mean) `a', by(country_id)
                        rename `a' `a'_80_00
                        tempfile local_`a'_80_00
                        save `local_`a'_80_00'
                restore

                preserve
                        drop if year<2001
                        collapse (mean) `a', by(country_id)
                        rename `a' `a'_01_18
                        tempfile local_`a'_01_18
                        save `local_`a'_01_18'

                        use `local_`a'_80_00', clear
                        merge 1:1 country_id using `local_`a'_01_18', nogen
                        decode country_id, gen(country)

                        if `n'<=2 {
                                gen `a'_id = 1 if inlist(country, ``e'')

                                two (function y=x, range(`b') recast(area) horizontal color(red%8))                                                                ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==., msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(grey%70) mlabcolor(grey%70)) ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==1, msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(red) mlabcolor(red)),        ///
                                                legend(off) scale(0.6) title("`c'") subtitle("`d'") xtitle("Average 1980-2000") ytitle("Average 2001-2018")        ///
                                                note(Fuente: Freddy's database) ysize(4) xsize(8)
                                graph export "${outputf_4_1}/`a'_45.pdf", replace  
                        }

                       else if `n'==3 {
                                gen `a'_id = 0 if inlist(country, ``e'') | inlist(country, `id_32')

                                two (scatteri `b', recast(area) horizontal color(red%8))                                                                           ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==0, msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(grey%70) mlabcolor(grey%70)) ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==., msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(red) mlabcolor(red)),        ///
                                                legend(off) scale(0.6) title("`c'") subtitle("`d'") xtitle("Average 1980-2000") ytitle("Average 2001-2018")        ///
                                                note(Fuente: Freddy's database) ysize(4) xsize(8)
                                graph export "${outputf_4_1}/`a'_45.pdf", replace  
                        }

                        else if `n'==4 {
                                gen `a'_id = 0 if inlist(country, ``e'') | inlist(country, `id_42')

                                two (scatteri `b', recast(area) horizontal color(red%8))                                                                           ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==0, msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(grey%70) mlabcolor(grey%70)) ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==., msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(red) mlabcolor(red)),        ///
                                                legend(off) scale(0.6) title("`c'") subtitle("`d'") xtitle("Average 1980-2000") ytitle("Average 2001-2018")        ///
                                                note(Fuente: Freddy's database) ysize(4) xsize(8) xlabel(-2(2)8)
                                graph export "${outputf_4_1}/`a'_45.pdf", replace  
                        }

                        else {
                                gen `a'_id = 0 if inlist(country, ``e'')

                                two (scatteri `b', recast(area) horizontal color(red%8))                                                                           ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==0, msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(grey%70) mlabcolor(grey%70)) ///
                                        (scatter `a'_01_18 `a'_80_00 if `a'_id==., msymbol(o) mla(country_id) /*mlabv(country_id)*/ color(red) mlabcolor(red)),        ///
                                                legend(off) scale(0.6) title("`c'") subtitle("`d'") xtitle("Average 1980-2000") ytitle("Average 2001-2018")        ///
                                                note(Fuente: Freddy's database) ysize(4) xsize(8)
                                graph export "${outputf_4_1}/`a'_45.pdf", replace  
                        }
                restore
        }

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
    log close

********************************************************************************
*** PART 4: Graphs move video
********************************************************************************

*** 4.1 Gini
        /*
        local mu=0
        qui forval i=1960/2019{
                local mu = string(`mu'+1, "%03.0f")
                scatter gini_disp country_id if year==`i', mlabel(country) scale(*.75) ysize(3) title("GINI `i'") xlabel(1(2)25, nolabels noticks)
                graph export "${outputf_4_1}/gini`mu'.png", replace
        }

        winexec "C:\ffmpeg\bin\ffmpeg.exe" -r 2 -i "${outputf_4_1}/gini%03d.png" -b:v 200k -r 30 "${outputf_4_1}/gini_video.mpg" -y
        */


