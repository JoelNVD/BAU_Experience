/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to make line and bar graphs using total
      population, social public expenditure and gdp
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "04-average_perca_se"

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
        use "${data_3_1}/GDP_POP_SPE.dta", clear
        drop if classification != "Social expenditure"
        drop if country == "Latin America" | country=="Caribbean"

*** 2.2 Declare time series
        xtset  country_id year
        xtdes

********************************************************************************
*** PART 3: Graphs
********************************************************************************

*** 3.1 HBAR: it shows us the ASEpr average
        preserve
                gen ASEpr = (((expenditure/100)*NY_GDP_MKTP_CD)/SP_POP_TOTL)
                drop if year != 2016
                drop if ASEpr==.

                graph hbar ASEpr, over(country) bar(1, color(red) fintensity(inten20))             ///
                                  title("Average social expenditure per capita") subtitle("2016")  ///
                                  ytitle(" ") ysize(4) xsize(8) scale(*.6) ylabel(150(150)2700)    ///
                                  exclude0 note("Fuente: CEPALSTAT & World Bank")
                gr_edit plotregion1.bars[7].EditCustomStyle , style(shadestyle(color(blue)))
                gr_edit plotregion1.bars[7].EditCustomStyle , style(linestyle(color(blue)))

                graph export "${outputf_4_1}/ASEpr_hbar.pdf", replace
        restore
        
*** 3.2 LINES: 
        xtbalance , range(2000 2019) miss(expenditure NY_GDP_MKTP_CD)
        tsset

        gen ASEpr = (((expenditure)*NY_GDP_MKTP_CD)/SP_POP_TOTL)

        egen ASEpr_Wei_1 = wtmean(ASEpr), weight(NY_GDP_MKTP_CD) by (country year)

        twoway (line ASEpr_Wei_1 year if country=="Argentina") (line ASEpr_Wei_1 year if country=="Bahamas")            ///
               (line ASEpr_Wei_1 year if country=="Brazil")    (line ASEpr_Wei_1 year if country=="El Salvador")        ///
               (line ASEpr_Wei_1 year if country=="Colombia")  (line ASEpr_Wei_1 year if country=="Costa Rica")         ///
               (line ASEpr_Wei_1 year if country=="Uruguay")   (line ASEpr_Wei_1 year if country=="Ecuador")            ///
               (line ASEpr_Wei_1 year if country=="Chile")     (line ASEpr_Wei_1 year if country=="Guatemala")          ///
               (line ASEpr_Wei_1 year if country=="Honduras")  (line ASEpr_Wei_1 year if country=="Jamaica")            ///
               (line ASEpr_Wei_1 year if country=="Mexico")    (line ASEpr_Wei_1 year if country=="Nicaragua")          ///
               (line ASEpr_Wei_1 year if country=="Paraguay")  (line ASEpr_Wei_1 year if country=="Dominican Republic") ///
               (line ASEpr_Wei_1 year if country=="Latin America & Caribbean")                                          ///
               (scatter ASEpr_Wei_1 year if year==2019, mlab(country) mlabcol(black)),                                  ///
                       title("AVERAGE SOCIAL EXPENDITURE PER CAPITA BY COUNTRY") subtitle("(Time series)")      ///
                       ytitle(" ") xtitle(" ") legen(off) ysize(4) xsize(8) scale(*.6) xlabel(2000(1)2021)      ///
                       note("Fuente: CEPALSTAT & World Bank")
        graph export "${outputf_4_1}/ASEpr_line_new.pdf", replace

*** 3.2 LINES: Freddy's comments
       /*preserve
                xtbalance , range(2000 2019) miss(expenditure NY_GDP_MKTP_CD)
                drop if country=="Latin America & Caribbean"
                tsset

                gen ASEpr = (((expenditure/100)*NY_GDP_MKTP_CD)/SP_POP_TOTL)

                bys year: egen NY_GDP_MKTP_CD_sum = total(NY_GDP_MKTP_CD)
                gen Wei_1 = NY_GDP_MKTP_CD/NY_GDP_MKTP_CD_sum
                gen ASEpr_Wei_1 = ASEpr*Wei_1
                
                collapse (sum) ASEpr_Wei_1, by(year)
                gen country_new="Latin America & Caribbean"

                tempfile local_latan_carib
                save `local_latan_carib'

        restore

        xtbalance , range(2000 2019) miss(expenditure NY_GDP_MKTP_CD)
        drop if country=="Latin America & Caribbean"
        tsset

        gen ASEpr = (((expenditure/100)*NY_GDP_MKTP_CD)/SP_POP_TOTL)

        local countries `" "Argentina" "Bahamas" "Brazil" "Chile" "Colombia" "Costa Rica" "Dominican Republic" "Ecuador" "El Salvador" "Guatemala" "Honduras" "Jamaica" "Mexico" "Nicaragua" "Paraguay" "Uruguay" "'
        local numbers `" "1" "2" "5" "7" "8" "9" "11" "12" "13" "14" "17" "18" "21" "22" "24" "27" "'
        local h = 1

        forval n = 1/16 {
                local a: word `n' of `countries'
                local b: word `n' of `numbers'

                preserve     
                        bys year: egen NY_GDP_MKTP_CD_sum = total(NY_GDP_MKTP_CD)
                        gen Wei_1 = NY_GDP_MKTP_CD/NY_GDP_MKTP_CD_sum
                        gen ASEpr_Wei_1 = ASEpr*Wei_1

                        collapse (sum) ASEpr_Wei_1 if country_id==`b', by(year)
                        gen country_new="`a'"

                        tempfile local_`h'
                        save `local_`h''

                        local h = `h' + 1
                restore
        }

        use `local_1', clear
        forval h = 2/16{
                append using `local_`h''
        }
        append using `local_latan_carib'

        twoway  (line ASEpr_Wei_1 year if country_new=="Argentina") (line ASEpr_Wei_1 year if country_new=="Bahamas")            ///
                (line ASEpr_Wei_1 year if country_new=="Brazil")    (line ASEpr_Wei_1 year if country_new=="El Salvador")        ///
                (line ASEpr_Wei_1 year if country_new=="Colombia")  (line ASEpr_Wei_1 year if country_new=="Costa Rica")         ///
                (line ASEpr_Wei_1 year if country_new=="Uruguay")   (line ASEpr_Wei_1 year if country_new=="Ecuador")            ///
                (line ASEpr_Wei_1 year if country_new=="Chile")     (line ASEpr_Wei_1 year if country_new=="Guatemala")          ///
                (line ASEpr_Wei_1 year if country_new=="Honduras")  (line ASEpr_Wei_1 year if country_new=="Jamaica")            ///
                (line ASEpr_Wei_1 year if country_new=="Mexico")    (line ASEpr_Wei_1 year if country_new=="Nicaragua")          ///
                (line ASEpr_Wei_1 year if country_new=="Paraguay")  (line ASEpr_Wei_1 year if country_new=="Dominican Republic") ///
                (line ASEpr_Wei_1 year if country_new=="Latin America & Caribbean") (scatter ASEpr_Wei_1 year if year==2019, mlabel(country_new)), ///
                        title("Average social expenditure per capita") subtitle("by countries") ytitle("Y title") xtitle(" ")     ///
                        legen(off) ysize(4) xsize(8) scale(*.6) xlabel(2000(1)2021)  ///
                        note("Fuente: CEPALSTAT & World Bank")

        graph export "${outputf_4_1}/ASEpr_line.pdf", replace
        */

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
    log close
