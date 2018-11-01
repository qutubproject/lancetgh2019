// Simulate SP

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
		gen sp_id = 1 + mod(_n,25)
			merge m:1 sp_id using `sp' , nogen

		// Interaction outcome
		gen Y = .25 * sp_male + clin_fe + sp_fe + rnormal()
			reg Y sp_male
			mat results = nullmat(results) ///
				\ [_b[sp_male] , _se[sp_male]]
	}

	return matrix results = results
	
end

// Loop over it

	sim_sp , provs(1000) sps(2)
		mat a = r(results)
		clear
		svmat a

// Have a lovely day!
