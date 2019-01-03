
* Table A1

	use  "${directory}/data/analysis.dta" , clear

	weightab ///
		correct treat_refer dr_1 re_1 re_3 re_4 med_any med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
	using "${directory}/appendix/Table_A1.xlsx" ///
		[pweight=weight_city] ///
	, replace over(sp_gender_group) stats(b se ll ul)

* Table A2

	use  "${directory}/data/analysis.dta" , clear

	rctreg ///
	ce_1 ce_2 ce_3 ce_4 ce_5 ce_6 ce_7 ///
	sp1_h_1 sp1_h_2 sp1_h_3 sp1_h_4 sp1_h_5 sp1_h_6 sp1_h_7 sp1_h_8 sp1_h_9 sp1_h_10 ///
		sp1_h_11 sp1_h_12 sp1_h_13 sp1_h_14 sp1_h_15 sp1_h_16 sp1_h_17 sp1_h_18 sp1_h_19 ///
		sp1_h_20 sp1_h_21 ///
	sp2_h_1 sp2_h_2 sp2_h_3 sp2_h_4 sp2_h_5 sp2_h_6 sp2_h_7 sp2_h_8 sp2_h_9 sp2_h_10 ///
		sp2_h_11 sp2_h_12 sp2_h_13 sp2_h_14 sp2_h_15 sp2_h_16 sp2_h_17 sp2_h_18 sp2_h_19 ///
		sp2_h_20 sp2_h_21 sp2_h_22 sp2_h_23 sp2_h_24 sp2_h_25 sp2_h_26 sp2_h_27 sp2_h_28 ///
	sp3_h_1 sp3_h_2 sp3_h_3 sp3_h_4 sp3_h_5 sp3_h_6 sp3_h_7 sp3_h_8 sp3_h_9 sp3_h_10 ///
		sp3_h_11 sp3_h_12 sp3_h_13 sp3_h_14 sp3_h_15 sp3_h_16 sp3_h_17 sp3_h_18 sp3_h_19 ///
		sp3_h_20 sp3_h_21 sp3_h_22 sp3_h_23 ///
	sp4_h_1 sp4_h_2 sp4_h_3 sp4_h_4 sp4_h_5 sp4_h_6 sp4_h_7 sp4_h_8 sp4_h_9 sp4_h_10 ///
		sp4_h_11 sp4_h_12 sp4_h_13 sp4_h_14 sp4_h_15 sp4_h_16 sp4_h_17 sp4_h_18 sp4_h_19 ///
		sp4_h_20 sp4_h_21 sp4_h_22 sp4_h_23 sp4_h_24 sp4_h_25 sp4_h_26 sp4_h_27 sp4_h_28 ///
		sp4_h_29 sp4_h_30 sp4_h_31 ///
	using "${directory}/appendix/Table_A2.xlsx" [pweight=weight_city] ///
	,  treatment(sp_male) controls(city_? case_? cp_5) title("History Questions") cl(sp_id)

// Figure A1: Simulate SP fixed effects for power calculations

	// Set up simulation program
	cap program drop sim_sp
	program define sim_sp , rclass

		syntax , [sps(integer 25)] [provs(integer 100)] [interactions(string asis)] [ratio(real 1)] [reps(integer 100)]

		// Main loop
		cap mat drop results
		qui forvalues i = 1/`reps' {

			// Generate SP roster
			clear
				set obs `sps'
				gen sp_id = _n
				gen sp_fe = rnormal()
				gen rand = rnormal()
					xtile sp_male = rand , n(2)
					replace sp_male = 2 - sp_male
					drop rand

				tempfile sp
					save `sp'

			// Provider schedule
			clear
				set obs `provs'
				gen clin_fe = rnormal() * `ratio'

			// More interactions if specified
			if "`interactions'" != "" {
				expand `interactions'
			}

			// Assign SPs
			gen sp_id = 1 + mod(_n,`sps')
				merge m:1 sp_id using `sp' , nogen

			// Interaction outcome
			gen Y = rnormal() + .1 * sp_male + clin_fe + sp_fe
				reg Y sp_male , cl(sp_id)
				mat results = nullmat(results) ///
					\ [_b[sp_male] , _se[sp_male], 1]
				reg Y sp_male
				mat results = nullmat(results) ///
					\ [_b[sp_male] , _se[sp_male], 0]
		}

		return matrix results = results
	end

	// Loop over simulations at fixed parameters
	clear
	tempfile a
	save `a' , emptyok

	set seed 20181119
	cap mat drop results
	qui forvalues sps = 4(2)100 {
		qui forvalues provs = 200(200)1600 {

		sim_sp , provs(`provs') sps(`sps') reps(100)
			mat a = r(results)
			clear
			svmat a
			gen sps = `sps'
			gen provs = `provs'
			collapse (sd) a1 (mean) a2, by(sps provs a3)
			append using `a'
			save `a' , replace
		}
	}

	// Clean

		rename (a1 a2 a3) (sd_actual se_asymp cluster)
		label var sd_actual " "
		label var se_asymp  " "

	// Contours

		tw contour sd_actual sps provs if cluster == 0 ///
		,  ${graph_opts} ccuts(.3(.1)1) title("True SE size for gender effect") xtit("Number of Facilities") ytit("Number of Individual SPs")
			graph save "a.gph" , replace
		tw contour se_asymp  sps provs if cluster == 0 ///
		,  ${graph_opts} title("Unadjusted regression SE sizes") xtit("Number of Facilities") ytit("Number of Individual SPs")
			graph save "b.gph" , replace
		tw contour se_asymp  sps provs if cluster == 1 ///
		,  ${graph_opts} ccuts(.3(.1)1) title("Clustered regression SE sizes") xtit("Number of Facilities") ytit("Number of Individual SPs")
			graph save "c.gph" , replace

		tw ///
		 	(lpoly sd_actual sps if cluster == 0 , lw(thick) degree(1)) ///
			(lpoly se_asymp  sps if cluster == 0 , lw(thick) degree(1)) ///
			(lpoly se_asymp  sps if cluster == 1 , lw(thick) degree(1)) ///
		, ${graph_opts} ytit(" ") title("Standard error size, by number of SPs")  xtit("Number of Individual SPs {&rarr}") ///
			legend(symxsize(small) r(1) order(1 "True" 2 "Unadjusted" 3 "Clustered")) ylab(0(.25)1)
			graph save "d.gph" , replace

		graph combine a.gph c.gph b.gph d.gph, ${comb_opts}
			graph export "${directory}/appendix/Figure_A1.png" , replace

		!rm a.gph
		!rm b.gph
		!rm c.gph
		!rm d.gph

// Have a lovely day!
