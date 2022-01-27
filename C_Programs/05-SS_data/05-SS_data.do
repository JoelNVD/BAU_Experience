/*=====================================================================================================
* PROJECT NAME
* Principal: 	    Freddy Rojas Cama
* STATA Version:    17
* RA:               Joel Vicencio Damian
*======================================================================================================
********************************************************************************
Note: These DO file was created to add a Sudden Stops variable
********************************************************************************

********************************************************************************
*** PART 1: Introduction
*******************************************************************************/

*** 1.1 Globals
        global dofilename "05-SS_data"

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
*** PART 2: Sudden Stops
********************************************************************************

*** 2.1 Cleaning
        use "${rawdata_2_1}/main-data_all-countries_15Oct2020 165731.dta", clear
        keep country year

*** 2.2 SS1 var
        gen dum_ss1_old=0
                local name1o `" "Brazil" "Croatia" "Czech Republic" "Guatemala" "Hungary" "India" "Indonesia" "Israel" "Jordan" "Korea, Rep." "Latvia" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "South Africa" "Thailand" "Turkey" "Venezuela, RB" "'
                local year1o `" "1998" "2011" "2008" "2008" "1996" "2008" "1997" "2011" "2003" "1997" "2008" "2008" "1994" "1998" "1998" "1997" "2008" "2008" "2000" "1997" "1994" "2006" "'
                local name2o `" "Jordan" "Korea, Rep." "Pakistan" "Russian Federation" "South Africa" "Thailand" "Turkey" "Ukraine" "'
                local year2o `" "2003" "2008" "1999" "2008" "2008" "2008" "2000" "2014" "'
                local name3o `" "Russian Federation" "Turkey" "'
                local year3o `" "2014" "2008" "'

                qui forval n=1/22{
                                local a: word `n' of `name1o'
                                local b: word `n' of `year1o'
                                replace dum_ss1_old=1 if country=="`a'" & year==`b'

                        forval m=1/8{
                                        local c: word `m' of `name2o'
                                        local d: word `m' of `year2o'
                                        replace dum_ss1_old=1 if country=="`c'" & year==`d'

                                forval j=1/2{
                                                local e: word `j' of `name3o'
                                                local f: word `j' of `year3o'
                                                replace dum_ss1_old=1 if country=="`e'" & year==`f' 
                                }
                        }
                }

        gen dum_ss1_new=dum_ss1_old
                local name1n `" "Brazil" "Czech Republic" "Guatemala" "India" "Indonesia" "Israel" "Korea, Rep." "Latvia" "Mexico" "Peru" "Philippines" "Poland" "Romania" "South Africa" "Thailand" "'
                local year1n `" "1999" "2009" "2009" "2009" "1998" "2012" "1998" "2009" "1995" "1999" "1998" "2009" "2009" "2001" "1998" "'
                local name2n `" "Jordan" "Pakistan" "Russian Federation" "Thailand" "Turkey" "'
                local year2n `" "2004" "2000" "2009" "2009" "2001" "'
                local name3n `" "Russian Federation" "Turkey" "'
                local year3n `" "2015" "2009" "'

                qui forval n=1/15{
                                local a: word `n' of `name1n'
                                local b: word `n' of `year1n'
                                replace dum_ss1_new=1 if country=="`a'" & year==`b'

                        forval m=1/5{
                                        local c: word `m' of `name2n'
                                        local d: word `m' of `year2n'
                                        replace dum_ss1_new=1 if country=="`c'" & year==`d'

                                forval j=1/2{
                                                local e: word `j' of `name3n'
                                                local f: word `j' of `year3n'
                                                replace dum_ss1_new=1 if country=="`e'" & year==`f' 
                                }
                        }
                }

        label var dum_ss1_old  "SS1 Start date, Duration in quarters"
        label var dum_ss1_new  "SS1 Start date to ahead, Duration in quarters"

*** 2.2 SS2 var
        gen dum_ss2_old=0
                local name1o `" "Brazil" "Croatia" "Czech Republic" "Guatemala" "Hungary" "India" "Indonesia" "Israel" "Jordan" "Korea, Rep." "Latvia" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "South Africa" "Thailand" "Turkey" "Venezuela, RB" "'
                local year1o `" "1998" "2011" "2008" "2008" "1996" "2008" "1997" "2011" "2003" "1997" "2008" "2008" "1994" "1998" "1998" "1997" "2008" "2008" "2000" "1997" "1994" "2006" "'
                local name2o `" "Korea, Rep." "Russian Federation" "South Africa" "Thailand" "Turkey" "Ukraine" "'
                local year2o `" "2008" "2008" "2008" "2008" "2000" "2014" "'
                local name3o `" "Russian Federation" "Turkey" "'
                local year3o `" "2014" "2008" "'

                qui forval n=1/22{
                                local a: word `n' of `name1o'
                                local b: word `n' of `year1o'
                                replace dum_ss2_old=1 if country=="`a'" & year==`b'

                        forval m=1/6{
                                        local c: word `m' of `name2o'
                                        local d: word `m' of `year2o'
                                        replace dum_ss2_old=1 if country=="`c'" & year==`d'

                                forval j=1/2{
                                                local e: word `j' of `name3o'
                                                local f: word `j' of `year3o'
                                                replace dum_ss2_old=1 if country=="`e'" & year==`f' 
                                }
                        }
                }


        gen dum_ss2_new=dum_ss2_old
                local name1n `" "Brazil" "Croatia" "Czech Republic" "Guatemala" "India" "Indonesia" "Israel" "Jordan" "Korea, Rep." "Latvia" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "Russian Federation" "South Africa" "Thailand" "Turkey" "'
                local year1n `" "1999" "2012" "2009" "2009" "2009" "1998" "2012" "2004" "1998" "2009" "2009"  "1995" "1999" "1999" "1998" "2009" "2009" "2009" "2001" "1998" "1995" "'
                local name2n `" "Brazil" "Croatia" "Indonesia" "Korea, Rep." "Korea, Rep." "Pakistan" "Peru" "Russian Federation" "Russian Federation" "South Africa" "South Africa" "Thailand" "Thailand" "Turkey" "Turkey" "'
                local year2n `" "2000" "2013" "1999" "1999" "2009" "2000" "2000" "2010" "2015" "2002" "2009" "1999" "2009" "2001" "2009" "'
                local name3n `" "Pakistan" "Peru" "Russian Federation" "South Africa" "Thailand" "Turkey" "Turkey" "'
                local year3n `" "2001" "2001" "2011" "2003" "2000" "2002" "2010" "'

                qui forval n=1/21{
                                local a: word `n' of `name1n'
                                local b: word `n' of `year1n'
                                replace dum_ss2_new=1 if country=="`a'" & year==`b'

                        forval m=1/15{
                                        local c: word `m' of `name2n'
                                        local d: word `m' of `year2n'
                                        replace dum_ss2_new=1 if country=="`c'" & year==`d'

                                forval j=1/7{
                                                local e: word `j' of `name3n'
                                                local f: word `j' of `year3n'
                                                replace dum_ss2_new=1 if country=="`e'" & year==`f' 
                                }
                        }
                }

        label var dum_ss2_old  "SS 2 Start date, Duration in quarters"
        label var dum_ss2_new  "SS 2 Start date to ahead, Duration in quarters"

*** 2.3 SS1 M var
        gen dum_ss1m_old=0
                local name1o `" "Argentina" "Belarus" "Brazil" "Chile" "Croatia" "Czech Republic" "Guatemala" "Hungary" "India" "Indonesia" "Israel" "Jordan" "Kazakhstan" "Korea, Rep." "Latvia" "Lithuania" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "Russian Federation" "South Africa"  "Sri Lanka" "Thailand" "Turkey" "Ukraine" "Venezuela, RB" "'
                local year1o `" "1998"  "2012" "1998" "2008" "2011" "2008" "2008" "1996" "2008" "1997" "2011" "1993" "2007" "1997" "2008" "2008" "2008" "1994" "1998" "1998" "1997" "2008" "2008" "1998" "2000" "2001" "1997" "1994" "2008" "2006" "'
                local name2o `" "Brazil" "Hungary" "Jordan" "Korea, Rep." "Peru" "Philippines" "Russian Federation" "South Africa" "Thailand" "Turkey" "Ukraine" "'
                local year2o `" "2008" "2011" "2003" "2008" "2008" "2008" "2008" "2008" "2008" "2000" "2014" "'
                local name3o `" "Jordan" "Russian Federation" "Turkey" "'
                local year3o `" "2007" "2014" "2008" "'

                qui forval n=1/30{
                                local a: word `n' of `name1o'
                                local b: word `n' of `year1o'
                                replace dum_ss1m_old=1 if country=="`a'" & year==`b'

                        forval m=1/11{
                                        local c: word `m' of `name2o'
                                        local d: word `m' of `year2o'
                                        replace dum_ss1m_old=1 if country=="`c'" & year==`d'

                                forval j=1/3{
                                                local e: word `j' of `name3o'
                                                local f: word `j' of `year3o'
                                                replace dum_ss1m_old=1 if country=="`e'" & year==`f' 
                                }
                        }
                }

        gen dum_ss1m_new=dum_ss1m_old
                local name1n `" "Argentina" "Brazil" "Chile" "Czech Republic" "Guatemala" "India" "Indonesia" "Israel" "Jordan" "Kazakhstan" "Korea, Rep." "Latvia" "Lithuania" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "Russian Federation" "South Africa" "Sri Lanka" "Thailand" "Ukraine" "'
                local year1n `" "1999" "1999" "2009" "2009" "2009" "2009" "1998" "2012" "1994" "2008" "1998" "2009" "2009" "2009" "1995" "1999" "1999" "1998" "2009" "2009" "1999" "2001" "2002" "1998" "2009" "'
                local name2n `" "Brazil" "Hungary" "Jordan" "Kazakhstan" "Pakistan" "Peru" "Russian Federation" "Russian Federation" "Thailand" "Turkey" "'
                local year2n `" "2009" "2012" "2004" "2009" "2000" "2009" "2000" "2009" "2009" "2001" "'
                local name3n `" "Jordan" "Kazakhstan" "Russian Federation" "Turkey" "'
                local year3n `" "2008" "2010" "2015" "2009" "'

                qui forval n=1/25{
                                        local a: word `n' of `name1n'
                                        local b: word `n' of `year1n'
                                        replace dum_ss1m_new=1 if country=="`a'" & year==`b'

                                forval m=1/10{
                                                local c: word `m' of `name2n'
                                                local d: word `m' of `year2n'
                                                replace dum_ss1m_new=1 if country=="`c'" & year==`d'

                                        forval j=1/4{
                                                        local e: word `j' of `name3n'
                                                        local f: word `j' of `year3n'
                                                        replace dum_ss1m_new=1 if country=="`e'" & year==`f' 
                                        }
                                }
                        }
        label var dum_ss1m_old "SS1 Modified Start date, Duration in quarters"
        label var dum_ss1m_new "SS1 Modified Start date to ahead, Duration in quarters"

*** 2.4 SS2 M var
        gen dum_ss2m_old=0
                local name1o `" "Argentina" "Belarus" "Brazil" "Chile" "Croatia" "Czech Republic" "Guatemala" "Hungary" "India" "Indonesia" "Israel" "Jordan" "Kazakhstan" "Korea, Rep." "Latvia" "Lithuania" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "Russian Federation" "South Africa" "Sri Lanka" "Thailand" "Turkey" "Ukraine" "Venezuela, RB" "'
                local year1o `" "1998" "2012" "1998" "2008" "2011" "2008" "2008" "1996" "2008" "1997" "2011" "1993" "2007" "1997" "2008" "2008" "2008" "1994" "1998" "1998" "2008" "2008" "2008" "1998" "2000" "2001" "1997" "1994" "2008" "2006" "'
                local name2o `" "Brazil" "Hungary" "Jordan" "Korea, Rep." "Peru" "Russian Federation" "South Africa" "Thailand" "Turkey" "Ukraine" "'
                local year2o `" "2008" "2011" "2003" "2008" "2008" "2008" "2008" "2008" "2000" "2014" "'
                local name3o `" "Jordan" "Russian Federation" "Turkey" "'
                local year3o `" "2007" "2014" "2008" "'

                qui forval n=1/30{
                                local a: word `n' of `name1o'
                                local b: word `n' of `year1o'
                                replace dum_ss2m_old=1 if country=="`a'" & year==`b'

                        forval m=1/10{
                                        local c: word `m' of `name2o'
                                        local d: word `m' of `year2o'
                                        replace dum_ss2m_old=1 if country=="`c'" & year==`d'

                                forval j=1/3{
                                                local e: word `j' of `name3o'
                                                local f: word `j' of `year3o'
                                                replace dum_ss2m_old=1 if country=="`e'" & year==`f' 
                                }
                        }
                }

        gen dum_ss2m_new=dum_ss2m_old
                local name1n `" "Argentina" "Belarus" "Brazil" "Chile" "Croatia" "Czech Republic" "Guatemala" "India" "Indonesia" "Israel" "Jordan" "Kazakhstan" "Korea, Rep." "Latvia" "Lithuania" "Malaysia" "Mexico" "Pakistan" "Peru" "Philippines" "Poland" "Romania" "Russian Federation" "South Africa" "Sri Lanka" "Thailand" "Turkey" "Ukraine" "'
                local year1n `" "1999" "2013" "1999" "2009" "2012" "2009" "2009" "2009" "1998" "2012" "1994" "2008" "1998" "2009" "2009" "2009" "1995" "1999" "1999" "2009" "2009" "2009" "1999" "2001" "2002" "1998" "1995" "2009" "'
                local name2n `" "Brazil" "Brazil" "Croatia" "Hungary" "Indonesia" "Jordan" "Kazakhstan" "Pakistan" "Peru" "Russian Federation" "Russian Federation" "South Africa" "South Africa" "Thailand" "Thailand" "Turkey" "Turkey" "'
                local year2n `" "2000" "2009" "2013" "2012" "1999" "2004" "2009" "2000" "2009" "2000" "2009" "2002" "2009" "1999" "2009" "2001" "2009" "'
                local name3n `" "Jordan" "Kazakhstan" "Pakistan" "Russian Federation" "South Africa" "Thailand" "Turkey" "Turkey" "'
                local year3n `" "2008" "2010" "2001" "2015" "2003" "2000" "2002" "2010" "'

                qui forval n=1/28{
                                        local a: word `n' of `name1n'
                                        local b: word `n' of `year1n'
                                        replace dum_ss2m_new=1 if country=="`a'" & year==`b'

                                forval m=1/17{
                                                local c: word `m' of `name2n'
                                                local d: word `m' of `year2n'
                                                replace dum_ss2m_new=1 if country=="`c'" & year==`d'

                                        forval j=1/8{
                                                        local e: word `j' of `name3n'
                                                        local f: word `j' of `year3n'
                                                        replace dum_ss2m_new=1 if country=="`e'" & year==`f' 
                                        }
                                }
                        }
        label var dum_ss2m_old "SS2 Modified Start date, Duration in quarters"
        label var dum_ss2m_new "SS2 Modified Start date to ahead, Duration in quarters"

********************************************************************************
*** PART 3: Saving new database
********************************************************************************

*** 3.1 Save
        save "${data_5_1}/main-data_all-countries_Sudden_Stops.dta", replace
        saveold  "${data_5_1}/Freddy_main-data_all-countries_Sudden_Stops.dta", version(13) replace

********************************************************************************
*** PART 4: Closing log file
********************************************************************************
        log close
