* Master

	global directory "/Users/bbdaniels/GitHub/lancetgh2018/"

* Load .adofiles

	local adoFiles : dir `"${directory}/ado/"' files "*.ado"
	local adoFiles = subinstr(`" `adoFiles' "', `"""' , "" , .)
	foreach adoFile in `adoFiles' {
		qui do "${directory}/ado/`adoFile'"
		}

	net from http://fmwww.bc.edu/RePEc/bocode/t
		net install tabout

* Set Options

	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) /// <- remove la(center) for Stata < 15
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

	global graph_opts1 ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med) la(center)) /// <- remove la(center) for Stata < 15
		ylab(,angle(0) nogrid)  ///
		yscale(noline) legend(region(lc(none) fc(none)))

	global comb_opts ///
		graphregion(color(white) lc(white) lw(med) la(center))

	global hist_opts ///
		ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
		ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

	global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
	global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
	global bar lc(white) lw(thin) la(center) fi(100) // <- remove la(center) for Stata < 15

* Generate all the results

	qui do "${directory}/dofiles/results.do"
	qui do "${directory}/dofiles/appendix.do"

* Have a lovely day!
