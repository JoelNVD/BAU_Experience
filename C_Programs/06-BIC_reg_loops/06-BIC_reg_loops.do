/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to find the best BIC with loops
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "06-BIC_reg_loops"

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
*** PART 2: 
********************************************************************************

*** 2.1
        use "${rawdata_2_1}/main-data_all-countries_15Oct2020 165731.dta", clear
        gl Subregiongl "" /* 5 regions */
        gl Regiongl "" /* 4 regions */
        local xvardepx "lgdppc"
        gl extrlines "drop if dum_smallc==1" /*ONLY all regressions*/

        if "$Subregiongl"!="" {
                        keep if Subregion=="$Subregiongl"
                }

        if "$Regiongl"!="" {
                        keep if Region=="$regiongl"
                }

        isid country year
        isid country_code year
        xtset country_code year

*** 2.2 ALTERNATIVE VERSION
        gen dum_epidem=1 if (dum_sars==1 | dum_mers==1 | dum_ebola==1 | dum_zika==1 | dum_flu==1) // H1N1 with dummy 2009
        replace dum_epidem=0 if dum_epidem==.

        gen dum_systemic=1 if dum_bankcrises==1 | dum_sobdet_crisis_==1 //| dum_curr_crisis_==1
        replace dum_systemic=0 if dum_systemic==.

***************************************************************************************************

********************************************************************************
*** PART 3: TIME EFFECTS
********************************************************************************

*** 3.1 
        sum year
        local yrmin "`r(min)'" 
        local yrmax "`r(max)'" 
        display in ye "`yrmin'"
        display in ye "`yrmax'"


        local ix=`yrmin'
        while `ix'<=`yrmax' {
                capture drop yr`ix'
                gen yr`ix'=(year==`ix')
                label var yr`ix' "time effect year `ix'"
                local ++ix
        }

********************************************************************************
*** PART 4: Additional variables (construction only)
********************************************************************************

*** 4.1 
        gen lcost=dama_gdp if dum_naturaldis_ref>0
        gen vlcost=(lcost!=.)
        replace vlcost=lcost if vlcost==1

        gen linsur_cost=dama_gdp-ins_dama_gdp if dum_naturaldis_ref>0  /*NOTICE -ins_dama_gdp*/
        gen vlinsur_cost=(linsur_cost!=.)
        replace vlinsur_cost=linsur_cost if vlinsur_cost==1

*** 4.2 
        assert dama_gdp!=. & ins_dama_gdp!=. if dum_naturaldis_ref>0

********************************************************************************
*** PART 5: Additional variables (construction only)
********************************************************************************

*** 5.1 
        rename ANE_TRD_GNFS_ZS trade_gdp
        rename ANE_CON_GOVT_ZS govcons_gdp
        rename AGC_TAX_TOTL_GD_ZS taxrev_gdp
        rename AFP_CPI_TOTL_ZG inflation

        gen deficit1=govcons_gdp-taxrev_gdp
        gen gkf_gdp=v_i/v_gdp

        by country_code: ipolate APV_EST year, gen(APV_EST_IPO)
        gen asianfc=(year==1997 & (country_code==536 | country_code==542 | country_code==548 | country_code==566 | country_code==576 | country_code==578) & dum_systemic!=1 )

        if "$spec_region"=="UNESCAP" {
                encode Subregion, gen(Subregion_n)
                local hh=1

                while `hh'<= 5 {
                        gen rdum_`hh'=(Subregion_n==`hh')
                        local ++hh
                }
        }
        else {
                encode Incomegroup, gen(Incomegroup_n)
                local hh=1

                while `hh'<= 4 {
                        gen rdum_`hh'=(Incomegroup_n==`hh')
                        local ++hh
                }
        }

        ${extrlines}
          
        gen lgdppc=log(ANY_GDP_MKTP_KN/ASP_POP_TOTL) 
        gen lc=log(q_c)
        gen li=log(q_i)
        gen lg=log(q_g)
        gen gini=gini_mkt
        gen lhc=log(hc)
        gen lhdi=log(hdi)
        gen lgdppcppp=log(ANY_GDP_PCAP_PP_KD)
        gen lgdppcus=log(ANY_GDP_PCAP_KD)

*** 5.2 
        local resil_vy "rrindex"
        sum `resil_vy', detail
        gen aux=(`resil_vy'>=r(p50)) if `resil_vy'!=.
        drop `resil_vy'
        rename aux `resil_vy'

        rename vlinsur_cost linc
        local resil_vyT "linc"
        local vdummy2 "naturaldis_ref"

        gen dum_`vdummy2'_`resil_vyT'=dum_`vdummy2'*`resil_vyT'

        gen dum_tot_ref_`resil_vy'=dum_tot_ref*`resil_vy'
        gen dum_natur_ref_linc_`resil_vy'=dum_naturaldis_ref_linc*`resil_vy'
        gen dum_epidem_`resil_vy'=dum_epidem*`resil_vy'
        gen dum_systemic_`resil_vy'=dum_systemic*`resil_vy'

********************************************************************************
*** PART 6: MODEL
********************************************************************************

*** 6.1 
        gl exoge "l(0/1).inflation l(0/1).trade_gdp civwar dum_usa l.dum_usa l2.dum_usa asianfc lgdppc rdum_* dum_SS"

*** 6.2 Excel defining
        putexcel set "${data_6_1}/BIC_Information", replace
        putexcel A1 = "Regresións"
        putexcel B1 = "BIC Information"
        putexcel C1 = "Lag Interactions"

*** 6.3 Loop
        local xgx=0 // 
        gen aux`xgx'=(f`xgx'.`xvardepx'-l.`xvardepx')*100
        gen daux`xgx'=(`xvardepx'-l.`xvardepx')*100

        local i = 1
        local j = 2

        qui forval a1 =1/4{
                forval b1 = 0/4{
                        forval c1 = 0/4{
                                forval d1 = 0/4{
                                        xtscc aux`xgx' l(1/`a1').daux0 l(0/`b1').dum_epidem  l(0/`c1').dum_epidem_`resil_vy' l(0/`d1').`resil_vy' yr* $exoge `des_tN', fe 
                                        
                                        eststo reg_`i'
                                                
                                                // Get predictions
                                                        predict y_tN, xb
                                                // Get RSS
                                                        gen res = (aux0 - y_tN) ^ 2
                                                // Sum RSS
                                                        sum res
                                                        local rss = r( sum )
                                                        drop res
                                                // Add matrix to regression
                                                        est restore reg_`i'
                
                                                // Generate K
                                                        scalar k = colsof( e( b ) )
                                                        scalar n1 = e(N )

                                                // Add bic
                                                        scalar bic2 = n1*ln( `rss' / n1) + k * ln(n1)
                                                        estadd scalar bic2

                                                // Add to Excel
                                                        putexcel A`j' = "reg_`i'"
                                                        putexcel B`j' = bic2
                                                        putexcel C`j' = "`a1' `b1' `c1' `d1'"
                                                       
                                        estimates clear

                                        capture noisily drop des_tN
                                        
                                        gen des_tN=aux`xgx'-y_tN
                                        
                                        capture noisily drop y_tN
                                        
                                        local des_tN "des_tN"
                                        dis( "Regression_`i'")
                                        local i = `i' + 1
                                        local j = `j' + 1
                                }
                        }
                }
        }
