

*Importamos:

*Modulo 64:

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "RECH0"

save "data_hogar", replace

*Módulo 65:

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "RECH23.SAV"


save "data_rech23",replace

*Módulo 74: info de la madre
clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "RECH5"

gen space = " "
egen CASEID = concat (HHID space HA0)

save "data_madreinfo.dta",replace


*Modulo 74 - info niño :

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "RECH6"

gen space = " "
egen CASEID = concat (HHID space HC0)

save "data_niñoinfo.dta",replace


*Modulo 569: programas sociales 

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "ps_QALIWARMA"


gen space = " "
egen CASEID = concat (HHID space HVIDX)

save "qaliwarma.dta", replace


*Modulo 70: establecimientos de salud 

clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "REC95"

save "control.dta", replace


*Modulo 73: variables violencia 
clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "REC84DV"

*caseid
*D104
*D105

save "violencia.dta",replace


*Modulo 66:
clear
cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
import spss using "REC0111"

*rec011

save "REC0111.dta",replace


use "REC0111", clear

merge 1:1 CASEID using "violencia.dta", nogenerate
merge 1:1 CASEID using "data_madreinfo.dta", nogenerate
merge 1:1 CASEID using "data_niñoInfo.dta", nogenerate
merge 1:1 CASEID using "qaliwarma.dta", nogenerate
merge 1:m CASEID using "control.dta", nogenerate
merge m:1 HHID using "data_hogar.dta", nogenerate
merge m:1 HHID using "data_rech23.dta", nogenerate

save "base_2019"


cd "C:\Users\Malory\OneDrive\Documentos\NOVENO CICLO\TESIS\módulos 2019"
use "base_2019", clear
keep HHID CASEID ///
HV007 HV024 HV025 HV201 HV205 HV206 HV207 HV208 HV270 HA3 HA1 HC1 HC27 HC70 HC61 PS109_1R S466B D104 D108 HV005 V005 V157 V158 V159


* order id vars
order HHID CASEID
sort HHID CASEID
replace CASEID = trim(itrim(CASEID))
replace HHID = trim(itrim(HHID))

order HHID CASEID HC70 HA3

* CLEAN ZSCORE VARIABLE AT THE hh LEVEL
bysort HHID: egen height_by_age = max(HC70)
bysort HHID: egen height_mom = max(HA3)

order HHID CASEID HC70 HA3 height_by_age height_mom 

*GENERAMOS VIOLENCIA:

gen violencia = (D104 + D108)
tab violencia
drop if violencia==2
recode violencia (0=1 "No") (1=2 "Sí"), gen(violencia_domestica)

*GENERAMOS ESTABLECIMIENTO DE SALUD:

tab S466B

recode S466B (21=1 "Hospital MINSA") (22=2 "Hospital EsSalud") (23=3 "Hospital FF.AA & PNP") (24/25=4 "Centro de salud MINSA") (26=5 "Centro de EsSalud") (27=6 "Otros hospitales del gobierno") (31/32=7 "Privado") (41=8 "Clínica/ONG") (42=9 "Hospital/Iglesia") (96=10 "Otros") , gen(establecimiento_salud)


* GENERAMOS VARIABLES DEL NIÑO:

*zscore
sum  
gen zscore=height_by_age/100
keep if zscore>-6 & zscore<6


sum zscore if zscore>-6 & zscore<6

*sexo del niño:

recode HC27 (1=1 "Hombre") (2=2 "Mujer"), gen(sexo_niño)

*qaliwarma:

tab PS109_1R
recode PS109_1R (1=1 "Sí recibió") (2=2 "No recibió"), gen(qaliwarma)


* GENERAMOS VARIABLES DE LA MUJER:

*educacion de la madre:
recode HC61 (1=1 "Primaria") (2=2 "Secundaria") (3=3 "Superior") (0=0 "Sin educación") , gen(educ_madre)
drop if educ_madre == 9



*altura de la madre:
gen alturamadre=height_mom/1000
keep if alturamadre>1.30 & alturamadre<1.80


*GENERAMOS VARIABLES DEL HOGAR:
recode HV025 (1=1 Urbana) (2=2 Rural), gen(area) 
tab area

tab HV201
recode HV201 (10=1 "agua corriente") (11=2 "canalizado a la vivienda") (12=3 "Fuera de la vivienda") (13=4 "pillon/Grifo público") (21=5 "Pozo de la vivienda") (22=6 "Pozo público") (40=7 "aguas superficiales") (41=8 "Manantial") (43=9 "Rio/acequia/laguna") (51=10 "Agua de lluvia") (61=11 "Camión cisterna") (71=12 "Agua embotellada") (96=13 "Otro"), gen(serv_agua)

recode HV205 (11=1 "Dentro de la vivienda") (12=2 "Fuera de la vivienda") (20=3 "Letrina de pozo") (21=4 "Letrina mejorada") (22=5 "Pozo séptico") (23/24=6 "Letrina") (30=7 "Sin instalación") (31=8 "Rio, acequia o canal") (32=9 "Sin servicio") (96=10 "Otro"), gen(serv_sanitario)

recode HV206 (0=1 "No") (1=2 "Si"), gen(serv_electr)

tab V158
recode V158 (0=1 "Nunca") (1=2 "Menos de una vez a la semana") (2=3 "Al menos una vez a la semana") (3=4 "Casi todos los días"), gen(acceso_radio)

tab V159
recode V159 (0=1 "Nunca") (1=2 "Menos de una vez a la semana") (2=3 "Al menos una vez a la semana") (3=4 "Casi todos los días"), gen(acceso_televisión)

tab V157
recode V157 (0=1 "Nunca") (1=2 "Menos de una vez a la semana") (2=3 "Al menos una vez a la semana") (3=4 "Casi todos los días"), gen(acceso_periodico)


recode HV270 (1=1 "Los más pobres") (2=2 "Pobre") (3=3 "Medio") (4=4 "Rico") (5=5 "Más Rico"), gen(i_riqueza)


*Cambio de etiqueta de nuestras variables
rename HV024 region 
rename HC70 i_oms
 
lab var HHID "Identificación del cuestionario"
lab var region "Departamento"
lab var area "Área de Residencia" 
lab var alturamadre "Talla de la madre"
lab var sexo_niño "Sexo del niño"
lab var i_oms "Indicador establecido por la OMS" 
lab var serv_agua "Servicio de agua"
lab var serv_sanitario  "Servicio sanitario" 
lab var serv_electr "Servicio electrico"
lab var acceso_radio "Acceso a radio"
lab var acceso_televisión "Acceso a televisión"
lab var i_riqueza "Indice de Riqueza"
lab var educ_madre "Educación de la madre"
lab var PS109_1R "Programa qaliwarma"

*generamos factores:

gen factorhogar = HV005/1000000
gen factormujer = V005/1000000

save "base_2019_final.dta"