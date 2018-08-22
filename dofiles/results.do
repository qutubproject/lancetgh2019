* Gender analysis for standardized patients

* Table 1 and 2 are generated manually

* Table 3

	use "${directory}/data/analysis.dta" , clear

	tabout sp_gender_group case   ///
		using "${directory}/outputs/Table_3_1.xls" ///
		, replace

	collapse (firstnm) sp_male , by(sp_id case city)

	egen sp_gender_group = group(city sp_male) , label

	tabout sp_gender_group  case  ///
		using "${directory}/outputs/Table_3_2.xls" ///
		, replace

* Table 4

	use "${directory}/data/analysis.dta" , clear

	replace sp4_spur_1 = . if case !=4

	rctreg ///
		cp_5 cp_17_1 cp_17_2 cp_17_3 cp_18 cp_19 cp_20 cp_21 ///
	using "${directory}/outputs/Table_4.xlsx" ///
		[pweight=weight_city] ///
	, p ci treatment(sp_male) controls(city_? case_?) title("Title") cl(facilitycode)

* Table 5

	forvalues i = 1/4 {

  		use "${directory}/data/analysis.dta" , clear

  		egen temptype = group(case sp_male) , label

  		gen maletemp = case == `i' & sp_male == 1
  			bys facilitycode: egen any_male = max(maletemp)
  		gen femaletemp = case == `i' & sp_male == 0
  			bys facilitycode: egen any_female = max(femaletemp)

  		drop if (any_male == 0 & any_female == 0)
  		expand 2 if (any_male == 1 & any_female == 1), gen(tempfalse)
  			replace any_male = 0 if (any_male == 1 & any_female == 1 & tempfalse == 0)
  			replace any_female = 0 if (any_male == 1 & any_female == 1 & tempfalse == 1)

  		drop if case == `i'

  		qui separate correct , by(temptype) short
  			foreach var of varlist correct? {
  				local theLabel : var label `var'
  				local theLabel = subinstr("`theLabel'","temptype == ","",.)
  				label var `var' "`theLabel'"
  				}

  		label def any_male 0 "Female SP`i'" 1 "Male SP`i'"
  			label var any_male any_male

  		table temptype any_male , c(mean correct freq)

  		chartable ///
  			correct? ///
  			using "${directory}/outputs/Table_5_`i'.xlsx" ///
  			[pweight=weight_city] ///
  			, $graph_opts command(logit) or regopts(cl(facilitycode)) rhs(any_male city_2 city_3 case_1 case_2 case_3 case_4 cp_5) xsize(10) case0(F-SP`i') case1(M-SP`i') ///
  			p title("Balance among providers who saw any SP`i'")
  	}

* Table 6

	use "${directory}/data/analysis.dta" , clear

	replace sp4_spur_1 = . if case !=4

	replace g5 = 1 if g5 == 3

	foreach var of varlist g6-g10 {
		recode `var' (1 2 = 0)(3 = 1)
		}

	rctreg ///
		g1 g2 g3 checklist duration g6 g9 g10 g4 g5 g7 g8 g11 ///
	using "${directory}/outputs/Table_6.xlsx" ///
		[pweight=weight_city] ///
	, p ci treatment(sp_male) controls(city_? case_?) title("Title") cl(facilitycode)

* Table 7

	use  "${directory}/data/analysis.dta" , clear

	separate correct, by(case)

	clonevar ca1 = correct if cp_5  == 1
	clonevar ca2 = correct if cp_5  == 0

	clonevar cb1 = correct if cp_18 == 1
	clonevar cb2 = correct if cp_18 == 0

	clonevar cc1 = correct if city == 2
	clonevar cc2 = correct if city == 3

	rctreg ///
		correct correct? c?? treat_refer ///
		dr_1 re_1 re_3 re_4 ///
		med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
		using "${directory}/outputs/Table_7.xlsx" ///
		[pweight=weight_city] ///
		, p ci treatment(sp_male) controls(city_? case_? cp_5) title("Key Outcomes") cl(facilitycode)

* Figure 1

	use "${directory}/data/analysis.dta" , clear

	chartable ///
		correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
		, ${graph_opts} command(logit) regopts(cl(facilitycode)) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males) ///
			xsize(8)

		graph export "${directory}/outputs/Figure_1.tif" , replace
		graph export "${directory}/outputs/Figure_1.png" , replace width(1000)

* Have a lovely day!
