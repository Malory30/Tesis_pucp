

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\bases finales (append)"

use "base_2016_final.dta", clear
append using "base_2017_final.dta"
append using "base_2018_final.dta"
append using "base_2019_final.dta"
append using "base_2020_final.dta"

save "base_desnutrición", replace



clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\bases finales (append)"

use "base_desnutrición.dta", clear 

histogram zscore
mean i_riqueza [pw=factorhogar]
mean V157 [pw=factormujer]

