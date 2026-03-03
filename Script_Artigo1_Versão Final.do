*WHO FEELS VULNERABLE TO BIASED POLICING? RACE, ECONOMIC STATUS AND TRUST IN BRAZIL
* Author: Gustavo C Moreira
* Esalq-USP
* Brazil 

********************************************************************************
* 0. Setup
********************************************************************************
clear

********************************************************************************
* 1. Importando os dados
********************************************************************************
#delimit;
infix uf 6-7 urb 33-33 sexo 95-95
raca 107-107 idade 104-106 peso 50-64
trabalha 136-136 estuda 109-109
pbf 407-407
internet 488-488 iluminacao 519-519
quali_ilum 520-520 policiamento 531-531
quali_policiamento 532-532
terrenobaldio 537-537
moradorderua 538-538
assalto_roubo_redondeza 543-543
confia_vizinhos 552-552
confia_policia 555-555
seguranca_casa 559-559
seguranca_bairro 560-560
seguranca_cidade 561-561
seguranca_geral 562-562
seguranca_dia 563-563
seguranca_noite 564-564
sofreu_furto 615-615
sofreu_roubo 770-770
educ 1052-1052
upa 12-20
noticiacrimes 548-548
confundido_policia 567-567
chance_viol_pol 566-566
rdpct 1207-1214
furto_motivo_naoprocura 656-656
roubo_motivo_naoprocura 937-937
using "C:\Users\gusta\OneDrive\Repositório Artigos\Iluminação e medo\PNAD 2021\PNADC_2021_trimestre4_20221207\PNADC_2021_trimestre4.txt", clear;
#delimit cr

********************************************************************************
* 2. Estatisticas descritivas e recodes principais
********************************************************************************

*Policiamento
recode policiamento (2=0) (9=.)
la define policiamento 1 "Tem policiamento no bairro" 0 "Nao"
label values policiamento policiamento  

*Sexo
recode sexo (2=0)
la define sexo 1 "Homem" 0 "Mulher"
label values sexo sexo  

*Raca
recode raca (9=.) 
recode raca (1=0)
recode raca (2 3 4 5 = 1)
la define raca 1 "Nao branca" 0 "Branca"
label values raca raca  

********************************************************************************
* 3. Variaveis de interação: raça x sexo
********************************************************************************
g racasexo =.
replace racasexo = 1 if sexo==1 & raca == 0 // Homem branco
replace racasexo = 2 if sexo==1 & raca == 1 // Homem não branco
replace racasexo = 3 if sexo==0 & raca == 0 // Mulher branca
replace racasexo = 4 if sexo==0 & raca == 1 // Mulher não branco

la define racasexo 1 "WM" 2 "NWM" 3 "WW" 4 "NWW"
label values racasexo racasexo

ta racasexo

********************************************************************************
* 4. Outras recodificações (urbano, vitimização, educação, segurança, confiança)
********************************************************************************

*Urbano
recode urb (2=0)
la define urb 1 "Urbana" 0 "Rural"
label values urb urb  

*Furto
*Nos últimos 12 meses, algum morador sofreu outro furto fora do domicílio, SEM uso de violência ou ameça (NÃO considere moto e bicicleta. Exemplos: joias, celular, dinheiro, documentos etc.)?
recode sofreu_furto (2=0)
la define sofreu_furto 1 "Sim" 0 "Nao"
label values sofreu_furto sofreu_furto  

*Roubo
*Nos últimos 12 meses, algum morador sofreu outro roubo fora do domicílio, COM uso de violência ou ameaça (NÃO considere carro, moto e bicicleta)? 
recode sofreu_roubo (2=0)
la define sofreu_roubo 1 "Sofreu roubo" 0 "Nao"
label values sofreu_roubo sofreu_roubo  

*Educacao
recode educ (1 2 3 4 5 6 = 0) (7 = 1)
la define educ 1 "Higher education" 0 "No Higher education"
label values educ educ  

*** Incluindo características da localização do domicílio e mais outros controles
recode seguranca_bairro (9=.) (2 = 1) (3 4 = 0)
la define seguranca_bairro 1 "Seguro no bairro" 0 "Inseguro no bairro"
label values seguranca_bairro seguranca_bairro  

*** O quanto vc confia na policia militar?
recode confia_policia (9=.)
recode confia_policia (2 = 1) (3 4 = 0)
la define confia_policia 1 "Confia" 0 "Não confia" 
label values confia_policia confia_policia  

********************************************************************************
* 5. Regiões (UF -> região)
********************************************************************************
g regiao = .
replace regiao=1 if uf<=17 // N
replace regiao=2 if uf>=21 & uf <=29 // NE
replace regiao=3 if uf>=31 & uf <=35 // SE
replace regiao=4 if uf>=41&uf<=43 // S
replace regiao=5 if uf>=50 // CO

la define regiao 1 "N" 2 "NE" 3 "SE" 4 "S" 5 "CO" 
label values regiao regiao

********************************************************************************
* 6. Indicadores de vizinhança e mídia
********************************************************************************

*Terrenobaldio
recode terrenobaldio (2=0) (9=.)
ta terrenobaldio

*Morador de rua
recode moradorderua (2=0) (9=.)
ta moradorderua

*Assalto ou roubo nas redondezas
recode assalto_roubo_redondeza (2=0) (9=.)
ta assalto_roubo_redondeza

*Noticia crimes
ta noticiacrimes
recode noticiacrimes (9=.) (1 2 3 4 5 6 = 0) (7=1)

*Confia vizinhos
ta confia_vizinhos, m
recode confia_vizinhos (5 9 = .)
la define confia_vizinhos 1 "Confia muito" 2 "Confia" 3 "Confia pouco" 4 "Nao confia"
label values confia_vizinhos confia_vizinhos

*Seguranca geral
recode seguranca_geral (9=.)
la define seguranca_geral 1 "Muito seguro" 2 "Seguro" 3 "Inseguro" 4 "Muito inseguro" 
label values seguranca_geral seguranca_geral  

********************************************************************************
* 7. Labels de variáveis
********************************************************************************
la var rdpc "Renda per capita"
la var assalto_roubo_redondeza "Crime no bairro (sim)"
la var terrenobaldio "Terreno baldio no bairro (sim)"
la var moradorderua "Morador de rua no bairro (sim)"
la var idade "Idade"

********************************************************************************
* 8. Interação: raça x classe social (quartis -> 3 grupos)
********************************************************************************

*Rend domiciliar
replace rdpct = rdpct/1000 

*Criando percentil de renda
astile pct_rdpc=rdpc,nq(4)
bys pct_rdpc: sum rdpc

recode pct_rdpc (3 = 2) (4 = 3)

la define pct_rdpc 1 "Low income" 2 "Middle income" 3 "High income"
label values pct_rdpc pct_rdpc

*Interação com raca
g racaclass = .
replace racaclass = 1 if raca == 1 & pct_rdpc == 1 // HNB Q1
replace racaclass = 2 if raca == 1 & pct_rdpc == 2 // HNB Q2
replace racaclass = 3 if raca == 1 & pct_rdpc == 3 // HNB Q3

replace racaclass = 4 if raca == 0 & pct_rdpc == 1 // HB Q1
replace racaclass = 5 if raca == 0 & pct_rdpc == 2 // HB Q2
replace racaclass = 6 if raca == 0 & pct_rdpc == 3 // HB Q3

la define racaclass 1 "NW_Low" 2 "NW_Middle" 3 "NW_High" 4 "W_Low" 5 "W_Middle" 6 "W_High"
label values racaclass racaclass

********************************************************************************
********************************************************************************

global racasexo i.racasexo 

global ses rdpc i.educ idade

global locational i.seguranca_bairro i.terrenobaldio i.moradorderua ///
i.policiamento i.sofreu_roubo i.regiao

global trust i.confia_policia

keep if urb == 0

*** Medidas de police legitimacy

*Medida 1:
*Medida 1:
*Medida 1: No seu dia a dia, qual a chance de você ser confundido(a) com bandido(a) pela polícia?
recode confundido_policia (9=.)
recode confundido_policia (1 2 = 1) (3 4 = 0)

*Probabilidades
eststo m1: qui probit confundido_policia $racasexo [iw=peso]
eststo m2: qui probit confundido_policia $racasexo $ses [iw=peso]
eststo m3: qui probit confundido_policia $racasexo $ses $locational [iw=peso]
eststo m4: qui probit confundido_policia $racasexo $ses $locational $trust [iw=peso]
esttab using tabela1.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)", pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

*Efeitos Marginais
eststo clear
*1
qui probit confundido_policia $racasexo [iw=peso]
margins, dydx(*) post
esttab using x1.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*2
qui probit confundido_policia $racasexo $ses [iw=peso]
margins, dydx(*) post
esttab using x2.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*3
qui probit confundido_policia $racasexo $ses $locational [iw=peso]
margins, dydx(*) post
esttab using x3.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*4
qui probit confundido_policia $racasexo $ses $locational $trust [iw=peso]
margins, dydx(*) post
esttab using x4.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label


*Medida 2: No seu dia a dia, qual a chance de você ser vítima de violência policial?

*Medida 2:
*Medida 2:
*Medida 2: No seu dia a dia, qual a chance de você ser confundido(a) com bandido(a) pela polícia?
recode chance_viol_pol (9=.)
recode chance_viol_pol (1 2 = 1) (3 4 = 0)
la define chance_viol_pol 1 "Muita/Media" 0 "Pouca/Nenhuma"
label values chance_viol_pol chance_viol_pol  

*Probabilidades
eststo m1: qui probit chance_viol_pol $racasexo [iw=peso]
eststo m2: qui probit chance_viol_pol $racasexo $ses [iw=peso]
eststo m3: qui probit chance_viol_pol $racasexo $ses $locational [iw=peso]
eststo m4: qui probit chance_viol_pol $racasexo $ses $locational $trust [iw=peso]
esttab using tabela2.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)", pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

*Efeitos Marginais
eststo clear
*1
qui probit chance_viol_pol $racasexo [iw=peso]
margins, dydx(*) post
esttab using x5.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*2
qui probit chance_viol_pol $racasexo $ses [iw=peso]
margins, dydx(*) post
esttab using x6.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*3
qui probit chance_viol_pol $racasexo $ses $locational [iw=peso]
margins, dydx(*) post
esttab using x7.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label
*4
qui probit chance_viol_pol $racasexo $ses $locational $trust [iw=peso]
margins, dydx(*) post
esttab using x8.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label


*** Agora para o urbano

gr bar (mean) confundido_policia, over(racasexo) graphregion(color(white)) saving(3, replace) title("Percentage who believe they could be mistaken for a criminal by the police", size(small)) subtitle ("Urban", size(small)) ytitle("") graphregion(color(white))
gr bar (mean) chance_viol_pol, over(racasexo) graphregion(color(white)) saving(4, replace) title("Percentage who believe they could be victim of police violence", size(small)) subtitle ("Urban", size(small)) ytitle("") graphregion(color(white))

** Tabela descritiva
ta regiao, g(reg)

asdoc proportion reg1 reg2 reg3 reg4 reg5 , dec(2) stat(mean sd) over(racasexo) save(descritivo_uabno.rtf) label replace title(por `i')

ta confia_policia, g(confia)

asdoc sum rdpc idade, dec(2) stat(mean) by(racasexo) sort save(descritivo1.rtf) replace

********************************************************************************
* 9. Criando Globals (especificações para modelos)
********************************************************************************
global raceclass ib(6).racaclass

global ses sexo i.educ idade i.sofreu_roubo

global locational urb i.seguranca_bairro i.terrenobaldio i.moradorderua ///
i.policiamento i.sofreu_roubo i.regiao

********************************************************************************
* 10. Medidas de police legitimacy: Medida 1 (confundido_policia)
********************************************************************************

*keep if confia_policia == 0

*Medida 1:
*Medida 1:
*Medida 1: No seu dia a dia, qual a chance de você ser confundido(a) com bandido(a) pela polícia?
recode confundido_policia (9=.)
recode confundido_policia (1 2 = 1) (3 4 = 0)
la define confundido_policia 1 "Muita/Media" 0 "Pouca/Nenhuma"
label values confundido_policia confundido_policia  

*Probabilidades
eststo m3: qui probit confundido_policia $raceclass [iw=peso]
estat ic
esttab using tabela11.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)", pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

*Efeitos Marginais
eststo clear
*3
qui probit confundido_policia $raceclass $ses $locational [iw=peso]
margins, dydx(*) post
esttab using x3.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

********************************************************************************
* 11. Construção do moderador: racaclass x confiança na polícia (racaclass_confia)
********************************************************************************

*Criando nova variavel de interesse
g racaclass_confia = .
replace racaclass_confia = 1 if racaclass==1 & confia_policia==1 // HNB Q1_T
replace racaclass_confia = 2 if racaclass==2 & confia_policia==1 // HNB Q2_T
replace racaclass_confia = 3 if racaclass==3 & confia_policia==1 // HNB Q3_T
replace racaclass_confia = 4 if racaclass==1 & confia_policia==0 // HNB Q1_NT
replace racaclass_confia = 5 if racaclass==2 & confia_policia==0 // HNB Q2_NT
replace racaclass_confia = 6 if racaclass==3 & confia_policia==0 // HNB Q3_NT
replace racaclass_confia = 7 if racaclass==4 & confia_policia==1 // HB Q1_T
replace racaclass_confia = 8 if racaclass==5 & confia_policia==1 // HB Q2_T
replace racaclass_confia = 9 if racaclass==6 & confia_policia==1 // HB Q3_T
replace racaclass_confia = 10 if racaclass==4 & confia_policia==0 // HB Q1_NT
replace racaclass_confia = 11 if racaclass==5 & confia_policia==0 // HB Q2_NT
replace racaclass_confia = 12 if racaclass==6 & confia_policia==0 // HB Q3_NT

label define racaclass_confia ///
1 "NW_Low_T" ///
2 "NW_Middle_T" ///
3 "NW_High_T" ///
4 "NW_Low_NT" ///
5 "NW_Middle_NT" ///
6 "NW_High_NT" ///
7 "W_Low_T" ///
8 "W_Middle_T" ///
9 "W_High_T" ///
10 "W_Low_NT" ///
11 "W_Middle_NT" ///
12 "W_High_NT", replace

label values racaclass_confia racaclass_confia

********************************************************************************
* 12. Medida 1 com moderador (racaclass_confia): AME + gráfico
********************************************************************************

*Efeitos Marginais
eststo clear
*3
qui probit confundido_policia ib(9).racaclass_confia $ses $locational [iw=peso]
estat ic

margins, dydx(*) post
esttab using x3.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

qui probit confundido_policia ib(9).racaclass_confia $ses $locational [iw=peso]
margins, dydx(i.racaclass_confia) post

set scheme s1mono

marginsplot, recast(bar) ///
    yline(0, lcolor(gs10) lpattern(solid)) ///
    ytitle("Average Marginal Effects from Table A3", size(small)) ///
    xtitle("") ///
    xlabel( ///
        1 "NW_Low_T" ///
        2 "NW_Middle_T" ///
        3 "NW_High_T" ///
        4 "NW_Low_NT" ///
        5 "NW_Middle_NT" ///
        6 "NW_High_NT" ///
        7 "W_Low_T" ///
        8 "W_Middle_T" ///
        9 "W_Low_NT" ///
        10 "W_Middle_NT" ///
        11 "W_High_NT", ///
        angle(45) labsize(small) ///
    ) ///
    ylabel(, nogrid labsize(small)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    name(me_racaclass_bar, replace)

********************************************************************************
* 13. Medida 2 (chance_viol_pol): recodes + modelos + AME + gráfico
********************************************************************************

*Medida 2: No seu dia a dia, qual a chance de você ser confundido(a) com bandido(a) pela polícia?

*Efeitos Marginais
eststo clear
*3
qui probit chance_viol_pol ib(9).racaclass_confia $ses $locational [iw=peso]
estat ic
margins, dydx(*) post
esttab using x7.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

qui probit chance_viol_pol ib(9).racaclass_confia $ses $locational [iw=peso]
margins, dydx(i.racaclass_confia) post

set scheme s1mono

marginsplot, recast(bar) ///
    yline(0, lcolor(gs10) lpattern(solid)) ///
    ytitle("Average Marginal Effects from Table A3", size(small)) ///
    xtitle("") ///
    xlabel( ///
        1 "NW_Low_T" ///
        2 "NW_Middle_T" ///
        3 "NW_High_T" ///
        4 "NW_Low_NT" ///
        5 "NW_Middle_NT" ///
        6 "NW_High_NT" ///
        7 "W_Low_T" ///
        8 "W_Middle_T" ///
        9 "W_Low_NT" ///
        10 "W_Middle_NT" ///
        11 "W_High_NT", ///
        angle(45) labsize(small) ///
    ) ///
    ylabel(, nogrid labsize(small)) ///
    legend(off) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    name(me_racaclass_bar, replace)

*****

*Probabilidades
eststo m3: qui probit chance_viol_pol $raceclass $ses $locational [iw=peso]
estat ic

esttab using tabela2.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)", pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

*Efeitos Marginais
eststo clear
*3
qui probit chance_viol_pol $raceclass $ses $locational [iw=peso]
margins, dydx(*) post
esttab using x7.rtf, replace star(*** 0.10 ** 0.05 * 0.01) cells(b(star fmt(4) vacant(-)) se(par fmt(4) vacant(-))) nobaselevels unstack ml(, none) eql(,none) collabels(, none) r2 nogaps mgroup("(1)" "(2)" "(3)" "(4)" , pattern(1 1)) nonumbers nodepvars varlabels(_cons Constante) label

*** Figura

preserve
drop if confundido_policia == 9
drop if chance_viol_pol == 9
keep if confia_policia==1
gr bar (mean) confundido_policia, over(racaclass) graphregion(color(white)) saving(3, replace) title("Percentage who believe they could be mistaken for a criminal by the police", size(small)) subtitle ("Trust", size(small)) ytitle("") graphregion(color(white)) bar(1, fcolor(black))
gr bar (mean) chance_viol_pol, over(racaclass) graphregion(color(white)) saving(4, replace) title("Percentage who believe they could be victim of police violence", size(small)) subtitle ("Trust", size(small)) ytitle("") graphregion(color(white)) bar(1, fcolor(black))
restore

** Tabela descritiva

keep if confia_policia !=.
bys confia_policia: ta urb
bys confia_policia: ta regiao
bys confia_policia: ta sexo
bys confia_policia: ta educ
bys confia_policia: ta seguranca_bairro
bys confia_policia: ta terrenobaldio
bys confia_policia: ta moradorderua
bys confia_policia: ta policiamento
bys confia_policia: ta sofreu_roubo
bys confia_policia: sum idade
bys confia_policia: ta racaclass


