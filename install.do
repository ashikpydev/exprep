* install_exprep.do
* Installation script for exprep package
* Version: 1.0, 27sep2025
* Author: Ashiqur Rahman Rony
* License: Apache License 2.0
* Contact: ashiqurrahman.stat@gmail.com, https://github.com/ashikpydev/exprep

clear all
net install exprep, replace from("https://raw.githubusercontent.com/ashikpydev/exprep/main")
display as result _n "exprep installed successfully. Type 'help exprep' for more details."