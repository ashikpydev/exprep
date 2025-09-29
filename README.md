# exprep: Expand SurveyCTO Repeat Group Data to a Readable Format

[![Stata](https://img.shields.io/badge/Stata-17-blue.svg)](https://www.stata.com/)
[![Version](https://img.shields.io/badge/version-1.0-green.svg)](https://github.com/ashikpydev/exprep)

## Description

`exprep` expands SurveyCTO repeat group data into a flatter, more readable format suitable for statistical analysis. SurveyCTO repeat groups store data compactly for collection but can be complex for analysis. This package processes repeat groups without altering original values, ensuring transparency.

The command identifies repeat indicators from the base variable, creates new variables by appending cleaned option labels to repeat stubs, fills them with corresponding values, and optionally orders them after the original repeats.

## Installation

To install `exprep` from this GitHub repository, run the following command in your Stata command window:

```stata
net install exprep, from("https://raw.githubusercontent.com/ashikpydev/exprep/main")
```

For additional help after installation, type `help exprep` in Stata.

## Syntax

```stata
exprep , id(numeric) base(string) repvars(string/byte/numeric)
```

### Required Options
- `id(numeric)`: ID variables identifying repeat instances (e.g., `h1a101_repeat_id_*`).
- `base(string)`: Base name for indicator variables (e.g., `h1a101`).
- `repvars(string/byte/numeric)`: Repeat group variables to expand (e.g., `h1a101a_* h1a102_* ...`).

## Options

- `id(string)`: Specifies the ID variables that link repeats to options (wildcards allowed, e.g., `h1a101_repeat_id_*`).
- `base(string)`: Specifies the base name for indicator variables (e.g., `h1a101` for `h1a101_1`, `h1a101_2`, etc.).
- `repvars(string)`: Lists the repeat variables to expand (wildcards allowed, e.g., `h1a101a_*`).

## Examples

Consider an individual-level survey dataset, section "H1: Acute Illness". The variable `h1a101` allows multiple disease selections over the last 4 weeks. For each disease, questions repeat: `h1a101a` (days suffered), `h1a101b` (currently suffering?), `h1a102` (sought treatment?), `h1a103` (treatment source), `h1a104` (reason for provider), `h1a105a` to `h1a105e` (costs like transport, consultation, etc.).

Syntax example:

```stata
exprep, id(h1a101_repeat_id_*) base(h1a101) repvars(h1a101a_* h1a101b_* h1a102_* h1a103_* h1a103oth_* h1a104_* h1a104oth_* h1a105a_* h1a105b_* h1a105c_* h1a105d_* h1a105e_*)
```

How it works:

- If the first option in `h1a101` is "Cold/Cough", new variables are generated like: `h1a101a_Cold_cough`, `h1a101b_Cold_cough`, etc. The original variable name precedes the disease descriptor.
- Labels are updated, e.g., "Cold/Cough: How many days did [line_h1_name] suffer for?". The disease option comes first, followed by the original text.
- Variables are ordered by disease, grouped after the repeat section ends.
- Original repeats are retained for transparency; new variables follow, forming disease-specific chunks.

Outcome:

- New variables associating responses with diseases.
- Clear labels for interpretation.
- Ordered groups by disease, with originals preserved.

## Author

Ashiqur Rahman Rony  
Data Analyst, Development Research Initiative (dRi)  
Email: [ashiqurrahman.stat@gmail.com](mailto:ashiqurrahman.stat@gmail.com)

## Also See

- [reshape](https://www.stata.com/help.cgi?reshape)
- [wide](https://www.stata.com/help.cgi?wide)

## License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). See the [LICENSE](LICENSE) file for details.

For bugs or issues, contact the author or open an issue on GitHub.
