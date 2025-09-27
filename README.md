# exprep

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Stata](https://img.shields.io/badge/Stata-17.0-blue)](https://www.stata.com)

A Stata package to expand SurveyCTO/ODK repeat group variables into a wide format for efficient data processing.

## Features

- Expands repeat group variables (e.g., integer, `select_one`, `select_multiple`, text) into separate variables or dummies.
- Supports numeric and string IDs for flexible mapping.
- Handles large repeat groups (e.g., 27 diseases with 10 questions each) without manual SurveyCTO form edits.
- Creates clean variable names and labels, preserving data structure.
- Silently orders new variables after the last repeat variable.
- Returns the list of new variables in `r(newvars)` for programmatic use.

## Description

`exprep` simplifies data processing for SurveyCTO/ODK repeat groups by reshaping them into a wide format. Repeat groups, common in surveys for entities like household members or diseases, generate multiple variables (e.g., `h1a101a_*`, `h1a103oth_*`). Manually defining these in SurveyCTO Excel forms is inefficient (e.g., 270 variables for 27 diseases with 10 questions). `exprep` automates this by mapping repeat group variables to new variables (e.g., `h1a101a_member1`) based on ID and indicator variables (e.g., `h1a101_1`, `h1a101_2`), supporting integer, `select_one`, `select_multiple`, and text variables.

## Requirements

- Stata 17.0 or higher.
- Active internet connection for installation.
- SurveyCTO/ODK dataset with repeat group variables and matching ID/indicator variables.

## Installation

Install from GitHub in Stata:

```stata
net install exprep, from("https://raw.githubusercontent.com/ashikpydev/exprep/main")
```

### Troubleshooting

If installation fails:
- Ensure Stata version is 17.0 or higher (`version` command).
- Verify internet connectivity.
- Check the repository URL: `https://raw.githubusercontent.com/ashikpydev/exprep/main`.
- Clear previous installations: `ado uninstall exprep`.

## Usage

```stata
exprep, id(ID_variables) base(base_name) repvars(repeat_variables) [t(type)]
```

- `id()`: ID variables (e.g., `h1a101_repeat_id_*`).
- `base()`: Base name for indicator variables (e.g., `h1a101` for `h1a101_1`, `h1a101_2`).
- `repvars()`: Repeat group variables (e.g., `h1a101a_* h1a103oth_*`).
- `t(str)`: Optional; specify for text variables or string IDs (default: numeric).

## Example

For a dataset with household member repeat groups:
- ID: `h1a101_repeat_id_*`
- Indicators: `h1a101_1` to `h1a101_n`
- Repeat variables: `h1a101a_*` (integer), `h1a101b_*` (select_one), `h1a103_*` (select_multiple), `h1a103oth_*` (text), etc.

```stata
exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)
```

Output: New variables like `h1a101a_member1`, `h1a103oth_member1`, etc.

For text variables:

```stata
exprep, id(h1a101_repeat_id_1) base(h1a101) repvars(h1a103oth_1) t(str)
```

Run `help exprep` after installation for details.

## Notes

- Indicator variables must be named `base_[number]` (e.g., `h1a101_1`).
- Use `t(str)` for text variables (e.g., `h1a103oth_*`) or string IDs.
- `select_one` and `select_multiple` variables are numeric by default; use `t(str)` for string output.
- New variables are automatically ordered after the last repeat variable.
- If ID and repeat variable counts differ, a warning is issued, and pairing uses the minimum count.
- Results are stored in `r(newvars)` for programmatic use.

## Contributing

Contributions are welcome! Please:
- Submit bug reports or feature requests via [GitHub Issues](https://github.com/ashikpydev/exprep/issues).
- Follow Stata coding conventions for pull requests.
- Update documentation (`exprep.sthlp`, `README.md`) for code changes.

## License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). See the [LICENSE](LICENSE) file for details.


## Contact

For questions or bug reports, contact Ashiqur Rahman Rony at [ashiqurrahman.stat@gmail.com](mailto:ashiqurrahman.stat@gmail.com) or file an issue at [https://github.com/ashikpydev/exprep](https://github.com/ashikpydev/exprep).