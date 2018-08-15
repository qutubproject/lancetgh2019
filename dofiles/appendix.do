
* History Questions

	use  "${directory}/data/analysis.dta" , clear

		rctreg ce_? sp?_h_* ///
		using "${directory}/outputs/history.xlsx" [pweight=weight_city] ///
		,  treatment(sp_male) controls(city_? case_? cp_5) title("History Questions") cl(facilitycode)



* Graphs

	* All Raw

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			, over(sp_male) xlab(${pct}) legend(pos(5) ring(0) c(1)) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin))

		graph export "${directory}/outputs/comparisons_unadjusted.png" , replace

	* Citywise Raw

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if city == 1 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(off) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Delhi") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_1.gph" , replace

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if city == 2 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(off) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Patna") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_2.gph" , replace

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if city == 3 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(pos(5) ring(0) c(1) symxsize(small) symysize(small) size(small) textfirst) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Mumbai") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_3.gph" , replace

		graph combine ///
			"${directory}/outputs/comparisons_unadjusted_1.gph" ///
			"${directory}/outputs/comparisons_unadjusted_2.gph" ///
			"${directory}/outputs/comparisons_unadjusted_3.gph" ///
			, r(1) $comb_opts xsize(7)

			graph export "${directory}/outputs/comparisons_unadjusted_incity.png" , replace

	* Casewise Raw

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if case == 1 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(off) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Case 1") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_1.gph" , replace

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if case == 2 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(off) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Case 2") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_2.gph" , replace

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if case == 3 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(off) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Case 3") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_3.gph" , replace

		betterbar ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if case == 4 ///
			, over(sp_male) xlab(0 "0%" 1 "100%") legend(pos(5) ring(0) c(1) symxsize(small) symysize(small) size(small) textfirst) xsize(7) se ///
			barlook(1 lc(black) lw(thin) 2 lc(black) lw(thin)) subtitle("Case 4") $graph_opts

		graph save "${directory}/outputs/comparisons_unadjusted_4.gph" , replace



		graph combine ///
			"${directory}/outputs/comparisons_unadjusted_1.gph" ///
			"${directory}/outputs/comparisons_unadjusted_2.gph" ///
			"${directory}/outputs/comparisons_unadjusted_3.gph" ///
			"${directory}/outputs/comparisons_unadjusted_4.gph" ///
			, r(2) $comb_opts xsize(7)

			graph export "${directory}/outputs/comparisons_unadjusted_incase.png" , replace





	* All Adusted ORs

		chartable ///
			correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if cp_5 == 1 ///
			, command(logit) or p rhs(sp_male city_? case_? cp_5 [pweight = weight_city]) case0(Females) case1(Males)

		chartable ///
			correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if cp_5 == 0 ///
			, command(logit) or p rhs(sp_male city_? case_? cp_5 [pweight = weight_city]) case0(Females) case1(Males)



		chartable ///
			correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			, command(logit) or rhs(sp_male city_? case_? cp_5 [pweight = weight_city]) case0(Females) case1(Males) xsize(8)

		graph export "${directory}/outputs/comparisons.png" , replace

		chartable ///
			 treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if correct == 1 ///
			, command(logit) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males)

		chartable ///
			 dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if correct == 0 ///
			, command(logit) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males)

		chartable ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if dr_1 == 0 , command(logit) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males)

		chartable ///
			correct treat_refer re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
			if dr_1 == 1 , command(logit) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males)


		graph export "${directory}/outputs/comparisons.png" , replace


* Table. All characteristics.

	use  "${directory}/data/analysis.dta" , clear

	local theVarlist checklist correct treat_refer duration p_inr_2014 ///
			dr_1 re_1 re_3 re_4 ///
			med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9

		qui foreach var of varlist `theVarlist' {
			local theLabel : var label `var'
			local theLabels `"`theLabels' "`theLabel'""'

			reg `var' sp_age sp_height sp_weight city_? case_? cp_5
			est sto `var'
			}

			xml_tab `theVarlist' ///
			using "${directory}/outputs/outcomes_robustness.xls" ///
			, replace below keep(sp_age sp_height sp_weight) cnames(`theLabels') stats(mean N) ///
			 lines(COL_NAMES 3 LAST_ROW 3) title("Table A. Primary Outcomes SP Characteristics Regressions")

* Table. Provider gender

	use "${directory}/data/analysis.dta" , clear

	gen check = cp_18 * sp_male
		label var check "Male Provider and Male SP"


	local theVarlist checklist correct treat_refer duration p_inr_2014 ///
			dr_1 re_1 re_3 re_4 ///
			med_any med med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9

		qui foreach var of varlist `theVarlist' {
			local theLabel : var label `var'
			local theLabels `"`theLabels' "`theLabel'""'

			reg `var' cp_18 sp_male check sp_age sp_height sp_weight city_? case_? cp_5
			est sto `var'
			}

			xml_tab `theVarlist' ///
			using "${directory}/outputs/outcomes_robustness.xls" ///
			, replace below keep(sp_male cp_18 check sp_age sp_height sp_weight) cnames(`theLabels') stats(N) ///
			 lines(COL_NAMES 3 LAST_ROW 3) title("Table A. Primary Outcomes SP Characteristics Regressions")


* Abstract Version

	use "${directory}/data/analysis.dta" , clear

	chartable ///
		correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
		, $graph_opts command(logit) or rhs(sp_male city_? case_? cp_5) case0(Females) case1(Males) ///
		title("Differences in TB Management By Standardized Patient Gender")

		graph export "${directory}/outputs/comparisons_abstract.png" , replace width(1000)

* Have a lovely day!
