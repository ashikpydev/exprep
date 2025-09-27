# exprep

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stata](https://img.shields.io/badge/Stata-17.0-blue)](https://www.stata.com)

A Stata package to expand SurveyCTO/ODK repeat group variables into separate variables for efficient data processing.

## Description

The `exprep` package streamlines data processing for SurveyCTO/ODK repeat groups by reshaping them into a clean, wide format. In SurveyCTO/ODK surveys, repeat groups collect data for selections like household members or diseases, with questions (e.g., integer, select_one, select_multiple, text) repeated for each selection. For instance, a survey with 27 diseases and 10 questions per disease would require manually creating 270 variables in the SurveyCTO Excel form, which is highly inefficient. `exprep` automates this by expanding repeat group variables into separate variables or dummies, mapping values based on ID and indicator variables (e.g., {cmd:h1a101_1}, {cmd:h1a101_2}). It supports numeric (integer, select_one, select_multiple) and string (text) variables and IDs, making data analysis-ready without manual form edits.

## Installation

Install `exprep` from GitHub in Stata:

```stata
net install exprep, from("https://raw.githubusercontent.com/ashikpydev/exprep/main")
```

### Troubleshooting

If installation fails, check:
- Stata version 17.0 or higher.
- Active internet connection.
- Correct repository URL: https://raw.githubusercontent.com/ashikpydev/exprep/main

## Usage

```stata
exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)
```

This command expands repeat group variables like {cmd:h1a101a_*} (integer), {cmd:h1a101b_*} (select_one), {cmd:h1a103_*} (select_multiple), and {cmd:h1a103oth_*} (text) into new variables (e.g., {cmd:h1a101a_member1}, {cmd:h1a101b_member1}, {cmd:h1a103oth_member1}) based on {cmd:h1a101_repeat_id_*} matching indicator variables {cmd:h1a101_1}, {cmd:h1a101_2}, etc.

## Example

Suppose a SurveyCTO dataset has a repeat group for household members, with:
- ID variables: {cmd:h1a101_repeat_id_*}
- Indicator variables: {cmd:h1a101_1} to {cmd:h1a101_n}
- Repeat group variables:
  - {cmd:h1a101a_*} (integer)
  - {cmd:h1a101b_*}, {cmd:h1a102_*} (select_one yn)
  - {cmd:h1a103_*}, {cmd:h1a104_*} (select_multiple)
  - {cmd:h1a103oth_*}, {cmd:h1a104oth_*} (text)
  - {cmd:h1a105a_*} to {cmd:h1a105e_*} (integer)

Run:

```stata
exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)
```

This creates variables like {cmd:h1a101a_member1}, {cmd:h1a101b_member1}, {cmd:h1a103oth_member1}, etc., for each household member.

For text variables, use:

```stata
exprep, id(h1a101_repeat_id_1) base(h1a101) repvars(h1a103oth_1) t(str)
```

See {cmd:help exprep} for more details after installation.

## Notes

- Indicator variables must follow the format {cmd:base_[number]} (e.g., {cmd:h1a101_1}).
- Use {cmd:t(str)} for text variables (e.g., {cmd:h1a103oth_*}) or string IDs.
- {cmd:select_one} and {cmd:select_multiple} variables are typically numeric in Stata; use {cmd:t(str)} for string output if needed.
- New variables are ordered after the last repeat variable.
- Requires Stata 17.0 or higher.


## Contributing

Contributions are welcome! Submit bug reports, feature requests, or pull requests via the [GitHub repository](https://github.com/ashikpydev/exprep). Follow Stata coding conventions and update documentation for code submissions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or bug reports, contact Ashiqur Rahman Rony at ashiqurrahman.stat@gmail.com or file an issue at https://github.com/ashikpydev/exprep.