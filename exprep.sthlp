{smcl}
{* *! version 1.0  29sep2025}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "reshape" "help reshape"}{...}
{vieweralsosee "wide" "help wide"}{...}
{viewerjumpto "Syntax" "exprep##syntax"}{...}
{viewerjumpto "Description" "exprep##description"}{...}
{viewerjumpto "Options" "exprep##options"}{...}
{viewerjumpto "Installation" "exprep##installation"}{...}
{viewerjumpto "Examples" "exprep##examples"}{...}
{viewerjumpto "Author" "exprep##author"}{...}
{title:Title}

{p2colset 1 16 18 2}{...}
{p2col :{hi:exprep} {hline 2}} Expand SurveyCTO repeat group data to a readable format{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:exprep} {cmd:,} {opt id(string)} {opt base(string)} {opt repvars(string)} [{opt t(string)} {opt noorder}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opt id(string)}}ID variables identifying repeat instances (e.g., {cmd:h1a101_repeat_id_*}) {p_end}
{synopt :{opt base(string)}}Base name for indicator variables (e.g., {cmd:h1a101}) {p_end}
{synopt :{opt repvars(string)}}Repeat group variables to expand (e.g., {cmd:h1a101a_* h1a102_* ...}) {p_end}

{syntab:Optional}
{synopt :{opt t(string)}}Default variable type (default: {cmd:int}; unused but kept for compatibility) {p_end}
{synopt :{opt noorder}}Skip ordering new variables after the last repeat variable {p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:exprep} expands SurveyCTO repeat group data into a flatter, more readable format suitable for statistical analysis. SurveyCTO repeat groups store data compactly for collection but can be complex for analysis. This package, developed by the dRi (Development Research Initiative) Data Team, processes repeat groups without altering original values, ensuring transparency.

{pstd}
The command identifies repeat indicators from the base variable, creates new variables by appending cleaned option labels to repeat stubs, fills them with corresponding values, and optionally orders them after the original repeats.

{marker options}{...}
{title:Options}

{phang}
{opt id(string)} specifies the ID variables that link repeats to options (wildcards allowed, e.g., {cmd:h1a101_repeat_id_*}).

{phang}
{opt base(string)} specifies the base name for indicator variables (e.g., {cmd:h1a101} for {cmd:h1a101_1}, {cmd:h1a101_2}, etc.).

{phang}
{opt repvars(string)} lists the repeat variables to expand (wildcards allowed, e.g., {cmd:h1a101a_*}).

{phang}
{opt t(string)} sets the default type for new variables (e.g., {cmd:int}, {cmd:str}; default: {cmd:int}). Currently unused but retained for compatibility.

{phang}
{opt noorder} prevents reordering new variables after the last repeat variable, useful if ordering fails due to limits.

{marker installation}{...}
{title:Installation and Use}

{pstd}
To install {cmd:exprep}, copy and paste the following into your Stata command window:

{p 8 12 2}{cmd:net install exprep, from("https://raw.githubusercontent.com/ashikpydev/exprep/main")}{p_end}

{pstd}
For additional help, type {cmd:help exprep} in Stata.

{marker examples}{...}
{title:Examples}

{pstd}
Consider an individual-level survey dataset, section "H1: Acute Illness". The variable {cmd:h1a101} allows multiple disease selections over the last 4 weeks. For each disease, questions repeat: {cmd:h1a101a} (days suffered), {cmd:h1a101b} (currently suffering?), {cmd:h1a102} (sought treatment?), {cmd:h1a103} (treatment source), {cmd:h1a104} (reason for provider), {cmd:h1a105a} to {cmd:h1a105e} (costs like transport, consultation, etc.).

{pstd}
Syntax example:

{p 8 12 2}{cmd:exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)}{p_end}

{pstd}
How it works:

{phang2}
If the first option in {cmd:h1a101} is "Cold/Cough", new variables are generated like: {cmd:h1a101a_Cold_cough}, {cmd:h1a101b_Cold_cough}, etc. The original variable name precedes the disease descriptor.

{phang2}
Labels are updated, e.g., "Cold/Cough: How many days did [line_h1_name] suffer for?". The disease option comes first, followed by the original text.

{phang2}
Variables are ordered by disease, grouped after the repeat section ends.

{phang2}
Original repeats are retained for transparency; new variables follow, forming disease-specific chunks.

{pstd}
Outcome:

{phang2}
- New variables associating responses with diseases.

{phang2}
- Clear labels for interpretation.

{phang2}
- Ordered groups by disease, with originals preserved.

{marker author}{...}
{title:Author}

{pstd}
Ashiqur Rahman Rony{p_end}
{pstd}
Data Analyst, Development Research Initiative (dRi){p_end}
{pstd}
Email: {browse "mailto:ashiqurrahman.stat@gmail.com":ashiqurrahman.stat@gmail.com}{p_end}

{title:Also see}

{psee}
Online:  {help reshape}, {help order}
