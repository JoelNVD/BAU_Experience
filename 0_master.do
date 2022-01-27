/***************************************************************************************************
* PROJECT:     Project
* TITLE:       Title
* YEAR:        2021
* PRINCIPAL:   Freddy Rojas Cama
* STATA:       17
* RA:          Joel Vicencio Damian
****************************************************************************************************

*** Outline:
    0. Set initial configurations and globals
    	0.0 Install required packages
    	0.1 Setting up users
    	0.2 Setting up folders
    	0.3 Setting up execution
    1. Schpae file to stata

****************************************************************************************************
*** PART 0: Set initial configurations and globals
***************************************************************************************************/

*** 0.0 Install required packages:
    set more off
    pause on

    local packages ietoolkit iefieldkit winsor estout outreg2 asdoc xml_tab outwrite reghdfe ftools ///
                   winexec wbopendata _gwtmean xtscc stripplot XTBALANCE inlist2 dataex chunky fs
		
    quie foreach pgks in `packages' {	
	  				
            capture which `pgks'

            if (_rc != 111) {
                    display as text in smcl "Paquete {it:`pgks'} está instalado "
                }

            else {
                    display as error in smcl `"Paquete {it:`pgks'} necesita instalarse."'

                    capture ssc install `pgks', replace

                    if (_rc == 601) {
                            display as error in smcl `"Package `pgks' is not found at SSC;"' _newline ///
                            `"Please check if {it:`pgks'} is spelled correctly and whether `pgks' is indeed a user-written command."'
                        }

                    else {
                            display as result in smcl `"Paquete `pgks' ha sido instalado."'
                        }
                }
        }
	
	ieboilstart, version(14.0)
	
*** 0.1 Setting up users
    if ("`c(username)'" == "JOEL") {
           global project   "C:\Users\JOEL\Desktop\research assistant\Project_02\DataWork"
        }

    if ("`c(username)'" == "freddyrojascama") {
           global project   "C:/Users/..."
        }

*** 0.2 Setting up folders
        global A "${project}\A_Data"
        global B "${project}\B_RawData"
        global C "${project}\C_Programs"
        global D "${project}\D_Results"
        global E "${project}\E_Tables"
        global F "${project}\F_Figures"

        // PART 1:
            global data_1_1         "${A}/01-example"
            global rawdata_1_1      "${B}/01-example"
            global code_1_1         "${C}/01-example"
            global outputt_1_1      "${E}/01-example"
            global outputf_1_1      "${F}/01-example"

        // PART 2:
            global data_2_1         "${A}/02-data-countries"
            global rawdata_2_1      "${B}/02-data-countries"
            global code_2_1         "${C}/02-data-countries"

        // PART 3:
            global data_3_1         "${A}/03-download_match_data"
            global rawdata_3_1      "${B}/03-download_data"
            global code_3_1         "${C}/03-download_match_data"

        // PART 4:
            global data_4_1         "${A}/04-graphs"
            global code_4_1         "${C}/04-graphs"
            global outputf_4_1      "${F}/04-graphs"

        // PART 5:
            global data_5_1         "${A}/05-SS_data"
            global code_5_1         "${C}/05-SS_data"

        // PART 6:
            global data_6_1         "${A}/06-BIC_reg_loops"
            global code_6_1         "${C}/06-BIC_reg_loops"

*** 0.3 Setting up execution 
    global first_work    0
    global second_work   0
    global third_work    0
    global fourth_work   0
    global fifth_work    0
    global sixth_work    0

****************************************************************************************************
***	PART 1: Jordán example
****************************************************************************************************
    if (${first_work} == 1) {
        do "${code_1_1}/01-jordan_example.do"
    }

****************************************************************************************************
*** PART 2: Freddy's database
****************************************************************************************************
    if (${second_work} == 1) {
        do "${code_2_1}/02-data-countries_old.do"
    }

****************************************************************************************************
*** PART 3: Download and marge data from CEPALSTAT and Worl Bank
****************************************************************************************************
    if (${third_work} == 1) {
        do "${code_3_1}/03-downlonding_data.do"
        do "${code_3_1}/03-matching_data.do"
        *do "${code_3_1}/03-downlonding_data_International_Merchandise_trade.do"
    }

****************************************************************************************************
*** PART 4: Differents graphs with Freddy's database
****************************************************************************************************
    if (${fourth_work} == 1) {
        do "${code_4_1}/04-average_perca_se.do"
        do "${code_4_1}/04-45º_line_index.do"
    }

****************************************************************************************************
*** PART 5: SS Data
****************************************************************************************************
    if (${fifth_work} == 1) {
        do "${code_5_1}/05-SS_data.do"
    }

****************************************************************************************************
*** PART 6: Best BIC with loops
****************************************************************************************************
    if (${sixth_work} == 1) {
        do "${code_6_1}/06-BIC_reg_loops.do"
    }
