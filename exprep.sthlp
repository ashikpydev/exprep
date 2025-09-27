{smcl}
{* *! version 1.0  27sep2025}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "reshape" "help reshape"}{...}
{vieweralsosee "SurveyCTO" "help surveycto"}{...}
{viewerjumpto "Syntax" "exprep##syntax"}{...}
{viewerjumpto "Description" "exprep##description"}{...}
{viewerjumpto "Options" "exprep##options"}{...}
{viewerjumpto "Examples" "exprep##examples"}{...}
{viewerjumpto "Stored Results" "exprep##results"}{...}
{viewerjumpto "Author" "exprep##author"}{...}
{viewerjumpto "License" "exprep##license"}{...}

{title:Title}

{p 4 4 2}
{cmd:exprep} {hline 2} Expand SurveyCTO/ODK repeat group variables into separate variables or dummies

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:exprep} , {cmd:id(}{it:ID_variables}{cmd:)} {cmd:base(}{it:base_name}{cmd:)} {cmd:repvars(}{it:repeat_variables}{cmd:)} [{cmd:t(str)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmd:id(}{it:ID_variables}{cmd:)}}Specify ID variables (e.g., {cmd:h1a101_repeat_id_*}) for repeat groups{p_end}
{synopt:{cmd:base(}{it:base_name}{cmd:)}}Base name for indicator variables (e.g., {cmd:h1a101} for {cmd:h1a101_1}, {cmd:h1a101_2}){p_end}
{synopt:{cmd:repvars(}{it:repeat_variables}{cmd:)}}Repeat group variables to expand (e.g., {cmd:h1a101a_* h1a103oth_*}){p_end}
{synopt:{cmd:t(str)}}Optional; specify for text variables or string IDs (default: numeric){p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:exprep} reshapes SurveyCTO/ODK repeat group variables into a wide format, creating separate variables or dummies for each repeat instance (e.g., household members, diseases). It maps repeat group variables (e.g., {cmd:h1a101a_*}, {cmd:h1a103oth_*}) to new variables (e.g., {cmd:h1a101a_member1}, {cmd:h1a103oth_member1}) based on ID variables and indicator variables (e.g., {cmd:h1a101_1}, {cmd:h1a101_2}). This eliminates the need for manual variable creation in SurveyCTO Excel forms, streamlining data processing for large repeat groups (e.g., 27 diseases with 10 questions each).

{pstd}
Supported variable types include integer, {cmd:select_one}, {cmd:select_multiple}, and text, with numeric or string IDs. New variables are automatically ordered after the last repeat variable, and results are stored in {cmd:r(newvars)}.

{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{cmd:id(}{it:ID_variables}{cmd:)} specifies the ID variables that identify repeat group instances (e.g., {cmd:h1a101_repeat_id_*}). Multiple IDs are supported for multiple repeat groups.

{phang}
{cmd:base(}{it:base_name}{cmd:)} specifies the base name for indicator variables (e.g., {cmd:h1a101} for {cmd:h1a101_1}, {cmd:h1a101_2}). Indicators must follow the format {cmd:base_[number]}.

{phang}
{cmd:repvars(}{it:repeat_variables}{cmd:)} specifies the repeat group variables to expand (e.g., {cmd:h1a101a_* h1a103oth_*}). Supports integer, {cmd:select_one}, {cmd:select_multiple}, and text variables.

{dlgtab:Optional}

{phang}
{cmd:t(str)} specifies that new variables or IDs are string type (e.g., for text variables like {cmd:h1a103oth_*} or string IDs). Default is numeric (e.g., {cmd:int}).

{marker examples}{...}
{title:Examples}

{pstd}
Expand repeat group variables for household members:

{phang2}
{cmd:. exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)}

{pstd}
This creates variables like {cmd:h1a101a_member1}, {cmd:h1a101b_member1}, {cmd:h1a103oth_member1}, etc., for each household member, based on {cmd:h1a101_repeat_id_*} and indicators {cmd:h1a101_1}, {cmd:h1a101_2}.

{pstd}
For text variables with a string ID:

{phang2}
{cmd:. exprep, id(h1a101_repeat_id_1) base(h1a101) repvars(h1a103oth_1) t(str)}

{pstd}
Check new variables:

{phang2}
{cmd:. describe h1a101a_* h1a103oth_*}

{marker results}{...}
{title:Stored Results}

{pstd}
{cmd:exprep} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(newvars)}}List of newly created or filled variables{p_end}
{synoptline}

{marker author}{...}
{title:Author}

{pstd}
Ashiqur Rahman Rony{break}
Email: ashiqurrahman.stat@gmail.com{break}
GitHub: https://github.com/ashikpydev/exprep

{marker license}{...}
{title:License}

{pstd}
Licensed under the Apache License 2.0. See the LICENSE file at https://github.com/ashikpydev/exprep.

{marker remarks}{...}
{title:Remarks}

{pstd}
- Indicator variables must be named {cmd:base_[number]} (e.g., {cmd:h1a101_1}).
- Use {cmd:t(str)} for text variables or string IDs.
- {cmd:select_one} and {cmd:select_multiple} variables are numeric by default; use {cmd:t(str)} for string output.
- If ID and repeat variable counts differ, a warning is issued, and pairing uses the minimum count.
- New variables are ordered after the last repeat variable in the dataset.

{pstd}
For bug reports or feature requests, file an issue at https://github.com/ashikpydev/exprep.

{smcl}