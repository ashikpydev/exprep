*! version 1.0
*! exprep.ado
*! Author: Ashiqur Rahman Rony (fixed)
*! Description: Expand specified variables in a repeat group into separate variables/dummies
*! Supports numeric, byte, int, and string repeat values with repeat IDs

capture program drop exprep
program define exprep
    version 17.0

    syntax , ID(string) BASE(string) REPVARS(string) [T(string)]

    * -----------------------------
    * Determine default variable type
    * -----------------------------
    local vartype "`t'"
    if "`vartype'" == "" local vartype "int"  // default numeric

    * -----------------------------
    * Collect all ID variables (may be multiple) and repeat value variables
    * -----------------------------
    unab allid : `id'
    if "`allid'" == "" {
        di as err "No ID variables found matching `id'"
        exit 198
    }
    di as text "ID variable(s): `allid'"

    unab repvars : `repvars'
    if "`repvars'" == "" {
        di as err "No repeat group variables found matching `repvars'"
        exit 198
    }
    di as text "Repeat group variables: `repvars'"

    * -----------------------------
    * Find indicator variables (option list) for base
    * -----------------------------
    capture ds `base'_*
    if _rc {
        di as err "No indicator vars found for base `base'_"
        exit 198
    }
    local indvars_all "`r(varlist)'"
    local indvars ""
    foreach v of local indvars_all {
        if regexm("`v'", "^`base'_[1-9][0-9]*$") {
            local indvars "`indvars' `v'"
        }
    }
    if "`indvars'" == "" {
        di as err "No valid indicator vars found for base `base'_[1-9][0-9]*"
        exit 198
    }
    di as text "Indicator vars: `indvars'"

    * -----------------------------
    * Ensure same number of id and repvars
    * -----------------------------
    local n_id : word count `allid'
    local n_rep : word count `repvars'
    if `n_id' != `n_rep' {
        di as txt "Warning: number of id vars (`n_id') != number of repvars (`n_rep'). Pairing by position; using min(`n_id',`n_rep')."
    }
    local nmin = `n_id'
    if `n_rep' < `nmin' local nmin = `n_rep'

    * -----------------------------
    * Pre-create option variables (one per indicator) with cleaned names & labels
    * -----------------------------
    local opt_codes ""
    foreach v of local indvars {
        local code = regexr("`v'", "^`base'_","")
        local labname : variable label `v'
        if "`labname'" == "" local labname "option_`code'"

        local labclean = subinstr("`labname'", " ", "_", .)
        local labclean = subinstr("`labclean'", "/", "_", .)
        local labclean = subinstr("`labclean'", "-", "_", .)
        local labclean = subinstr("`labclean'", ",", "", .)
        if "`labclean'" == "" local labclean "option_`code'"

        capture mata: st_local("safeopt", strtoname("`labclean'"))
        if _rc | "`safeopt'" == "" local safeopt "opt`code'"

        * Use repvar stub for variable name
        foreach repvar of local repvars {
            local repstub = regexr("`repvar'", "_[0-9]+$", "")
            local newvar "`repstub'_`safeopt'"
            if strlen("`newvar'") > 32 local newvar = substr("`repstub'_`safeopt'",1,28) + "_`code'"

            * create variable if not exists
            capture confirm variable `newvar'
            if _rc {
                gen double `newvar' = .
                * Label format: base_option: repvar label
                local repvarlabel : variable label `repvar'
                if "`repvarlabel'" == "" local repvarlabel "`repvar'"
                label var `newvar' "`labname': `repvarlabel'"
            }
        }
        local opt_codes "`opt_codes' `code'"
    }

    * -----------------------------
    * Loop over repeat slots and assign values
    * -----------------------------
    forvalues j = 1/`nmin' {
        local repvar : word `j' of `repvars'
        local idvar  : word `j' of `allid'

        * Skip if not found
        capture confirm variable `repvar'
        if _rc continue
        capture confirm variable `idvar'
        if _rc continue

        * Determine storage type
        capture confirm numeric variable `repvar'
        if !_rc {
            quietly describe `repvar'
            local rep_storage = r(type)
        }
        else local rep_storage = "str"

        * Assign repeat value to matching option variable
        foreach v of local indvars {
            local code = regexr("`v'", "^`base'_","")
            local labname : variable label `v'
            if "`labname'" == "" local labname "option_`code'"

            local labclean = subinstr("`labname'", " ", "_", .)
            local labclean = subinstr("`labclean'", "/", "_", .)
            local labclean = subinstr("`labclean'", "-", "_", .)
            local labclean = subinstr("`labclean'", ",", "", .)
            if "`labclean'" == "" local labclean "option_`code'"

            capture mata: st_local("safeopt", strtoname("`labclean'"))
            if _rc | "`safeopt'" == "" local safeopt "opt`code'"

            local repstub = regexr("`repvar'", "_[0-9]+$", "")
            local newvar "`repstub'_`safeopt'"
            if strlen("`newvar'") > 32 local newvar = substr("`repstub'_`safeopt'",1,28) + "_`code'"

            * ensure exists
            capture confirm variable `newvar'
            if _rc {
                if inlist("`rep_storage'", "byte", "int", "long", "float", "double") gen double `newvar' = .
                else gen strL `newvar' = ""
                * Label format
                local repvarlabel : variable label `repvar'
                if "`repvarlabel'" == "" local repvarlabel "`repvar'"
                label var `newvar' "`labname': `repvarlabel'"
            }

            * assign values
            capture confirm numeric variable `idvar'
            if !_rc {
                quietly {
                    tempvar __code_num
                    gen double `__code_num' = real("`code'")
                    replace `newvar' = `repvar' if !missing(`repvar') & `idvar' == `__code_num'
                    drop `__code_num'
                }
            }
            else replace `newvar' = `repvar' if !missing(`repvar') & trim(`idvar') == "`code'"
        }
    }

    * -----------------------------
    * Collect new variables for display
    * -----------------------------
    local newvars ""
    foreach v of local indvars {
        local code = regexr("`v'", "^`base'_","")
        local labname : variable label `v'
        if "`labname'" == "" local labname "option_`code'"
        local labclean = subinstr("`labname'", " ", "_", .)
        local labclean = subinstr("`labclean'", "/", "_", .)
        local labclean = subinstr("`labclean'", "-", "_", .)
        local labclean = subinstr("`labclean'", ",", "", .)
        if "`labclean'" == "" local labclean "option_`code'"
        capture mata: st_local("safeopt", strtoname("`labclean'"))
        if _rc | "`safeopt'" == "" local safeopt "opt`code'"
        foreach repvar of local repvars {
            local repstub = regexr("`repvar'", "_[0-9]+$", "")
            local newvar "`repstub'_`safeopt'"
            if strlen("`newvar'") > 32 local newvar = substr("`repstub'_`safeopt'",1,28) + "_`code'"
            local newvars "`newvars' `newvar'"
        }
    }

    di as text "Newly created/filled variables:"
    foreach nv of local newvars {
        di as text "  `nv' (`: variable label `nv'')"
    }

    * -----------------------------
    * Order variables after last repvar
    * -----------------------------
    local last_repvar : word `: word count `repvars'' of `repvars'
    capture confirm variable `last_repvar'
    if _rc == 0 {
        order `newvars', after(`last_repvar')
        di as text "Variables ordered by repvar after `last_repvar'"
    }

	* -----------------------------
	* Completion message in table style
	* -----------------------------
	local uniq_newvars : list uniq newvars
	local n_new : word count `uniq_newvars'

	* Print top border
	di as result "+-----------------------------------------------------+"
	* Print title
	di as result "|      Expanded your repeat section                   |"
	* Print middle border
	di as result "+----------------------+------------------------------+"
	* Print total new variables
	di as result "| Total new variables  | `n_new'`"
	* Print contact info
	di as result "| For bug/issues contact| ashiqurrahman.stat@gmail.com |"
	* Print bottom border
	di as result "+-----------------------------------------------------+"


end