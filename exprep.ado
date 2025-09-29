*! version 1.0
*! exprep.ado
*! Author: Ashiqur Rahman Rony
*! Description: Expand repeat group section to manual section, presenting in a readable way
*! Supports numeric, byte, int, and string repeat values with repeat IDs

capture program drop exprep
program define exprep
    version 17.0

    syntax , ID(string) BASE(string) REPVARS(string) [T(string) NOORDER]

    * -----------------------------
    * Determine default variable type (unused now, but kept for compatibility)
    * -----------------------------
    local vartype "`t'"
    if "`vartype'" == "" local vartype "int"  // default numeric

    * -----------------------------
    * Collect all ID variables and repeat value variables
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
    * Find indicator variables for base
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
    * Check variable limit
    * -----------------------------
    local n_id : word count `allid'
    local n_rep : word count `repvars'
    local n_ind : word count `indvars'
    local n_newvars = `n_rep' * `n_ind'
    local maxvar = c(maxvar)
    di as text "Expected new variables: `n_newvars'"
    di as text "Current Stata variable limit: `maxvar'"
    if `n_newvars' > (`maxvar' - c(k)) {
        di as err "Creating `n_newvars' new variables would exceed Stata's limit of `maxvar' (current variables: `c(k)')."
        di as err "Reduce the number of repvars or use a Stata version with a higher variable limit."
        exit 1000
    }

    * -----------------------------
    * Extract suffixes from idvars
    * -----------------------------
    local suffixes ""
    foreach idvar of local allid {
        local suffix = regexr("`idvar'", "^.*_", "")
        local suffixes : list suffixes | suffix  // unique suffixes
        local id_for_suffix_`suffix' "`idvar'"
    }
    di as text "Suffixes found: `suffixes'"

    * -----------------------------
    * Pre-create option variables with cleaned names & labels, matching types
    * -----------------------------
    local opt_codes ""
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

        * Use repvar stub for variable name, with special handling for splits
        foreach repvar of local repvars {
            local reptype : type `repvar'
            local temp = regexr("`repvar'", "_[0-9]+$", "")  // remove repeat suffix
            local optioncode ""
            if regexm("`temp'", "_[0-9]+$") {
                local optioncode = regexr("`temp'", "^.*_", "")
                local repstub = regexr("`temp'", "_[0-9]+$", "")
            }
            else {
                local repstub "`temp'"
            }
            local fullstub "`repstub'_`safeopt'"
            local newvar "`fullstub'"
            if "`optioncode'" != "" {
                local newvar "`newvar'_`optioncode'"
            }
            local namelen = strlen("`newvar'")
            if `namelen' > 32 {
                local codelen = strlen("_`code'")
                local optlen = cond("`optioncode'"=="", 0, strlen("_`optioncode'"))
                local trunc = 32 - `codelen' - `optlen'
                if `trunc' < 1 {
                    local trunc = 1
                }
                local newvar = substr("`fullstub'",1,`trunc') + "_`code'" + cond("`optioncode'"=="","","_`optioncode'")
            }

            * Create variable if not exists, matching type of repvar
            capture confirm variable `newvar'
            if _rc {
                if strpos("`reptype'", "str") {
                    gen `reptype' `newvar' = ""
                }
                else {
                    gen `reptype' `newvar' = .
                }
                * Label format: for byte, copy value label; otherwise, use base_option: repvar label
                local repvarlabel : variable label `repvar'
                if "`repvarlabel'" == "" local repvarlabel "`repvar'"
                if "`reptype'" == "byte" {
                    local vallabel : value label `repvar'
                    if "`vallabel'" != "" {
                        label values `newvar' `vallabel'
                        label var `newvar' "`repvarlabel'"
                    }
                    else {
                        label var `newvar' "`labname': `repvarlabel'"
                    }
                }
                else {
                    label var `newvar' "`labname': `repvarlabel'"
                }
            }
            * Add to newvars only if not already present
            local newvars : list newvars | newvar
        }
        local opt_codes "`opt_codes' `code'"
    }

    * -----------------------------
    * Fill generated variables with repeat values, grouped by suffix
    * -----------------------------
    foreach suffix of local suffixes {
        local idvar "`id_for_suffix_`suffix''"
        capture confirm numeric variable `idvar'
        local id_is_numeric = !_rc

        * Find repvars for this suffix
        local repvars_this ""
        foreach repvar of local repvars {
            local repsuffix = regexr("`repvar'", "^.*_", "")
            if "`repsuffix'" == "`suffix'" {
                local repvars_this "`repvars_this' `repvar'"
            }
        }

        * For each repvar in this group, fill for each code
        foreach repvar of local repvars_this {
            local reptype : type `repvar'
            local temp = regexr("`repvar'", "_[0-9]+$", "")
            local optioncode ""
            if regexm("`temp'", "_[0-9]+$") {
                local optioncode = regexr("`temp'", "^.*_", "")
                local repstub = regexr("`temp'", "_[0-9]+$", "")
            }
            else {
                local repstub "`temp'"
            }

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

                local fullstub "`repstub'_`safeopt'"
                local newvar "`fullstub'"
                if "`optioncode'" != "" {
                    local newvar "`newvar'_`optioncode'"
                }
                local namelen = strlen("`newvar'")
                if `namelen' > 32 {
                    local codelen = strlen("_`code'")
                    local optlen = cond("`optioncode'"=="", 0, strlen("_`optioncode'"))
                    local trunc = 32 - `codelen' - `optlen'
                    if `trunc' < 1 {
                        local trunc = 1
                    }
                    local newvar = substr("`fullstub'",1,`trunc') + "_`code'" + cond("`optioncode'"=="","","_`optioncode'")
                }

                * Debug message
                di as txt "Filling `newvar' (type: `: type `newvar'') from `repvar' (type: `reptype') when `idvar' == `code' (id type: `=cond(`id_is_numeric', "numeric", "string")')"

                * Fill values
                capture {
                    if `id_is_numeric' {
                        if strpos("`reptype'", "str") {
                            quietly replace `newvar' = `repvar' if `idvar' == real("`code'")
                        }
                        else {
                            quietly replace `newvar' = `repvar' if `idvar' == real("`code'") & !missing(`repvar')
                        }
                    }
                    else {
                        quietly replace `newvar' = `repvar' if `idvar' == "`code'"
                    }
                }
                if _rc {
                    di as err "Error filling `newvar' from `repvar' for code `code': type mismatch or invalid data"
                    exit _rc
                }
            }
        }
    }

    * -----------------------------
    * Collect new variables for display, ensuring uniqueness
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
            local temp = regexr("`repvar'", "_[0-9]+$", "")
            local optioncode ""
            if regexm("`temp'", "_[0-9]+$") {
                local optioncode = regexr("`temp'", "^.*_", "")
                local repstub = regexr("`temp'", "_[0-9]+$", "")
            }
            else {
                local repstub "`temp'"
            }
            local fullstub "`repstub'_`safeopt'"
            local newvar "`fullstub'"
            if "`optioncode'" != "" {
                local newvar "`newvar'_`optioncode'"
            }
            local namelen = strlen("`newvar'")
            if `namelen' > 32 {
                local codelen = strlen("_`code'")
                local optlen = cond("`optioncode'"=="", 0, strlen("_`optioncode'"))
                local trunc = 32 - `codelen' - `optlen'
                if `trunc' < 1 {
                    local trunc = 1
                }
                local newvar = substr("`fullstub'",1,`trunc') + "_`code'" + cond("`optioncode'"=="","","_`optioncode'")
            }
            * Add to newvars only if not already present
            local newvars : list newvars | newvar
        }
    }

    di as text "Newly created/filled variables:"
    foreach nv of local newvars {
        di as text "  nv' (: variable label `nv'')"
    }

    * -----------------------------
    * Order variables after last repvar (optional)
    * -----------------------------
    if "`noorder'" == "" {
        local last_repvar : word `: word count `repvars'' of `repvars'
        capture confirm variable `last_repvar'
        if _rc == 0 {
            capture order `newvars', after(`last_repvar')
            if _rc {
                di as err "Warning: Could not order variables due to too many variables specified. Use NOORDER option to skip ordering."
            }
            else {
                di as text "Variables ordered by repvar after `last_repvar'"
            }
        }
    }

    * -----------------------------
    * Completion message in table style
    * -----------------------------
    local uniq_newvars : list uniq newvars
    local n_new : word count `uniq_newvars'

    di as result "+-----------------------------------------------------+"
    di as result "|      Expanded your repeat section                   |"
    di as result "+----------------------+------------------------------+"
    di as result "| Total new variables  | `n_new'"
    di as result "| For bug/issues contact| ashiqurrahman.stat@gmail.com |"
    di as result "+-----------------------------------------------------+"

end
