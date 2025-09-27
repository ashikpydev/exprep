{smcl}
{* *! version 1.0  27sep2025}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "reshape" "help reshape"}{...}
{vieweralsosee "tabulate" "help tabulate"}{...}
{vieweralsosee "egen" "help egen"}{...}
{viewerjumpto "Syntax" "exprep##syntax"}{...}
{viewerjumpto "Description" "exprep##description"}{...}
{viewerjumpto "Options" "exprep##options"}{...}
{viewerjumpto "Examples" "exprep##examples"}{...}
{viewerjumpto "Notes" "exprep##notes"}{...}
{viewerjumpto "Author" "exprep##author"}{...}
{title:Title}

{phang}
{bf:exprep} {hline 2} Expand SurveyCTO/ODK repeat group variables into separate variables

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:exprep} , {cmd:id(}{it:string}{cmd:)} {cmd:base(}{it:string}{cmd:)} {cmd:repvars(}{it:string}{cmd:)} [{cmd:t(}{it:string}{cmd:)}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:exprep} simplifies data processing for SurveyCTO/ODK repeat groups by reshaping them into a clean, wide format. In SurveyCTO/ODK surveys, repeat groups collect data for a selection (e.g., household members, diseases) with questions like integer, select_one, select_multiple, or text repeated for each selection. For example, a survey with 27 diseases and 10 questions per disease would require manually creating 270 variables in the SurveyCTO Excel form, which is inefficient. {cmd:exprep} automates this by expanding repeat group variables into separate variables or dummies based on ID and indicator variables (e.g., {cmd:h1a101_1}, {cmd:h1a101_2}). It supports numeric (integer, select_one, select_multiple) and string (text) repeat values and IDs, making data analysis-ready without manual form edits.

{marker options}{...}
{title:Options}

{phang}
{opt id(string)} specifies the ID variable(s) identifying repeat group slots (e.g., {cmd:h1a101_repeat_id_*}). Multiple ID variables can be specified using wildcards or lists.

{phang}
{opt base(string)} specifies the base name of indicator variables (e.g., {cmd:h1a101} for {cmd:h1a101_1}, {cmd:h1a101_2}).

{phang}
{opt repvars(string)} specifies the repeat group variables to expand (e.g., {cmd:h1a101a_* h1a101b_*}).

{phang}
{opt t(string)} specifies the storage type for new variables (default: {cmd:int}). Supported types: {cmd:byte}, {cmd:int}, {cmd:long}, {cmd:float}, {cmd:double}, {cmd:str}. Use {cmd:str} for text variables.

{marker examples}{...}
{title:Examples}

{pstd}Suppose a SurveyCTO dataset has a repeat group for household members, with ID variables {cmd:h1a101_repeat_id_*}, indicator variables {cmd:h1a101_1} to {cmd:h1a101_n}, and repeat group variables like {cmd:h1a101a_*} (integer), {cmd:h1a101b_*} (select_one yn), {cmd:h1a103_*} (select_multiple), and {cmd:h1a103oth_*} (text).{p_end}

{phang}{cmd:. exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)} {p_end}
{pstd}This creates new variables like {cmd:h1a101a_member1}, {cmd:h1a101b_member1}, {cmd:h1a103oth_member1}, etc., mapping values from {cmd:h1a101a_*}, {cmd:h1a101b_*}, etc., based on {cmd:h1a101_repeat_id_*} matching {cmd:h1a101_1}, {cmd:h1a101_2}, etc.{p_end}

{phang}{cmd:. exprep, id(h1a101_repeat_id_1) base(h1a101) repvars(h1a103oth_1) t(str)} {p_end}
{pstd}This handles the text variable {cmd:h1a103oth_1}, creating string-type variables like {cmd:h1a103oth_member1} for string IDs in {cmd:h1a101_repeat_id_1}.{p_end}

{marker notes}{...}
{title:Notes}

{pstd}1. Indicator variables must follow the format {cmd:base_[number]} (e.g., {cmd:h1a101_1}, {cmd:h1a101_2}).{p_end}
{pstd}2. The number of ID variables should match the number of repeat variables, or the minimum is used.{p_end}
{pstd}3. Use {cmd:t(str)} for text variables (e.g., {cmd:h1a103oth_*}, {cmd:h1a104oth_*}) or string IDs to avoid type mismatches.{p_end}
{pstd}4. Variables like {cmd:select_one} and {cmd:select_multiple} are typically numeric in Stata; use {cmd:t(str)} if string output is needed.{p_end}
{pstd}5. Requires Stata version 17.0 or higher.{p_end}
{pstd}6. New variables are ordered after the last repeat variable for convenience.{p_end}

{marker author}{...}
{title:Author}

{pstd}Ashiqur Rahman Rony{p_end}
{pstd}ashiqurrahman.stat@gmail.com{p_end}
{pstd}Report bugs or issues at https://github.com/ashikpydev/exprep{p_end}