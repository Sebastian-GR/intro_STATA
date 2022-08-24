*Clase inicial STATA (cuestiones básicas, con comentarios para mí mismo)
clear all
chdir "G:\Mi unidad\Econometría y estadística\Curso - Trombetta\Datos\Clase 1"


*Conversar un poco de STATA y su potencia (datos, regresiones, métodos, procedimientos automatizados, etc).

*Presentar el panel

*Comentar mi estética

*Comentar comentarios * y /**/

*Comentar case sensitive

*Hablar de buenas prácticas

**************************************************************************

/*Comentar formas alternativas de traer datos:
	Copiar y pegar
	use "nombredta.dta"
*/
*Importar desde un excel → HABLAR DEL FORMATO DE DATOS
import excel "para_comenzar.xlsx", firstrow case (lower)
*Luego de una coma ponemos OPCIONES

*Cuidado cómo se expresan los decimales
*Si se tiene problemas al respecto ver 'set dp'.
*Comentar cómo setear esto en excel

********************************************************************************

*Podemos guardar la base en formato dta
save "formatodta", replace

*Labeling y nombres
rename edad años
rename años edad

label variable region "Región de residencia"
label variable edad "Edad medida en años"
label variable edad2 "Cuadrado de la edad"
label variable educ "Años de educación"
label variable est_civil "0 si soltero, 1 si casado"
label variable experiencia "Años de experiencia"
label variable experiencia2 "Cuadrado de años de experiencia"
label variable formal "0 si trabaja en sector informal, 1 si formal"
label variable sexo "0 si hombre, 1 si mujer"
label variable sexo_educ "sexo * educ"
label variable error "Error (no se conoce)"
label variable w "log del salario"


*Cargar el mismo dta
clear
use "formatodta"

*Si quisiéramos exportar a excel
* export excel using "datos", firstrow(variables) replace 

********************************************************************************
********************************************************************************
********************************************************************************
*Explorar la base
browse
*Toda la base
describe 	/*datos de la base (labels, format, etc)*/
summ		/*estad descriptivas de la base*/

/*No podemos tener experiencia negativa*/
*drop if experiencia < 0
keep if experiencia >= 0
summ
save "formatodta", replace
*Una o más variables
describe educ
summ educ

* ¿Qué pasa con la variable region?
describe region
summ region

tab region
tab edad
*También podemos obtener más medidas de resumen:
tabstat edad, statistics (mean median sd count) 
tabstat w, statistics (mean median sd count) 
*Mean=media
*median=mediana
*sd= desv est
*count = contar (excluímos los NA)

*Explicar lo que es una variable Dummy y para que sirve
tabstat est_civil, statistics (mean count)

*También lo podemos abrir en grupos
tabstat w, statistics (mean median sd count) by(sexo)

*Cuadro doble entrada
tab est_civil sexo


********************************************************************************
* Variables, condicionales y NA

/*Tips y reglas para nombrar variables:
	Fáciles
	Cortos
	No pueden tener espacios, usen guión bajo
	Eviten mezclar mayus y minusc
	No usen nombres preexistentes
*/
gen salario = exp(w)
tabstat salario, statistics (mean median sd count) by(sexo)


/*Condicionales
<= 	menor o igual
< 	menor
==	igual
>=	mayor o igual
>	mayor
!=	distinto
*/


tab est_civil if sexo == 1

*Prestar atención a cambios hechos y a NA
gen cat_educ = .
replace cat_educ = 0 if educ == 0
replace cat_educ = 1 if educ > 0 & educ <= 6
replace cat_educ = 2 if educ > 6 & educ <= 12
replace cat_educ = 3 if educ > 12 & educ <= 17
replace cat_educ = 4 if educ > 17

tab cat_educ
summ cat_educ /*Qué está pasando con cantidad de observaciones?*/
tabstat cat_educ, statistics (count)

*Para ALGUNOS CASOS PARTICULARES, relacionados con funciones, usamos egen.
egen educ_media = mean(educ)
drop educ_media

*Descripción en apertura por categorías (¿por qué categorías?)
table cat_educ, contents (mean salario sd salario)
table region, contents (mean salario sd salario)

********************************************************************************
********************************************************************************
********************************************************************************

*Recapitulando, vimos como manipular base/variables: gen, replace, drop, keep
*ej
gen sal_cuadr=salario^2
drop sal_cuadr

*Para sobreescribir una variable podemos usar replace
replace sal_cuadr = salary^3 /*Error*/

gen sal_cuadr = salario^2
replace sal_cuadr = salario^3 /*ok*/
*y podemos repetirlo
replace sal_cuadr = salario^2 /*ok*/

********************************************************************************
********************************************************************************
********************************************************************************
*CATEGÓRICAS
*Bonus: 
tab region, ge(region)
br
br region1-region5

*check
gen suma = region1 + region2 + region3 + region4 + region5
summ suma
drop suma
********************************************************************************
********************************************************************************
********************************************************************************

*Ordenado de la base. Sort ordena en orden ascendente. gsort permite descendente al poner un '-' adelante.

sort salario/*ascendente*/
gsort -salario/*descendente*/
gsort salario -est_civil

*Para lo que haremos no creo que encontremos tanta utilidad pero con otras bases sí!

*Esto permite también una interaccion con comandos.
bysort est_civil: egen media_salario= mean(salario)
tab est_civil media_salario
drop media_salario

*Podríamos hacer medias por más subcategroías
bysort est_civil sexo: egen media_salario= mean(salario)
drop media_salario

*Comentario: los NA al usar sort/gsort se toman como el valor más grande

********************************************************************************
********************************************************************************
********************************************************************************


*Gráficos (notar que STATA abre de a uno):
*(Mostrar algo del editor y cómo guardar)

*Histograma
hist salario /*Notación científica*/
*Cambiar formato: https://www.statalist.org/forums/forum/general-stata-discussion/general/1359404-scientific-notation-on-histogram-with-frequency-option
*Tipos de formato: http://wlm.userweb.mwn.de/Stata/wstatfor.htm
hist salario,  yla(, format(%9.4f) ang(h)) /*Keseso en el eje de las y? La densidad (VAC)... Quizás no es lo ideal*/
*Explicación histogramas: https://www.reed.edu/psychology/stata/gs/tutorials/histograms.html
hist salario, percent /*Freq rel*/
hist salario, freq  	/*Freq abs*/
hist salario, normal	/*Ponemos la normal que mejor ajusta*/
hist edad, normal	/*Ponemos la normal que mejor ajusta*/
hist salario, kdensity /*kernel*/

*Dispersión
graph twoway scatter salario educ
graph twoway scatter salario educ if sexo == 0 /*tmb podemos acotar*/
twoway scatter salario educ if sexo == 0  /*simplificar redacción*/
scatter salario educ if sexo == 0  	/*simplificar redacción*/ 

twoway (scatter salario educ) (lfit salario educ ), title(Relación educación y salario) /*Añadimos una recta de reg a modo ilustrativo (no necesariamente igual a la de una regresión multivariada)*/

*Última y comentamos opciones
graph pie region1-region5
graph pie region1-region5, title(Distribución geográfica)
graph pie region1-region5, title(Distribución geográfica) subtitle(Subdivisión en 5 regiones)

graph pie region1-region5, title(Distribución geográfica) subtitle(Subdivisión en 5 regiones) noclockwise

********************************************************************************
********************************************************************************
********************************************************************************
*REGRESIONES
reg salario educ

*Muestras acotadas
set seed 12
gen random = runiform()

reg salario educ
estimates store total
reg salario educ if random > .98
estimates store subsample1
reg salario educ if random > .989
estimates store subsample2
reg salario educ if random > .999
estimates store subsample3


estimates table total subsample1 subsample2 subsample3, star b(%9.4f) title(Comparación estimaciones)

*Otro caso
reg salario sexo
reg salario sexo if random > .99
reg salario sexo if random > .998