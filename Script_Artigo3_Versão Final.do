* INDIVIDUAL AND SITUATIONAL FACTORS ASSOCIATED WITH VIOLENCE AGAINST OLDER ADULTS IN BRAZIL: A ROUTINE ACTIVITY APPROACH
* Author: Gustavo C Moreira
* Esalq-USP
* Brazil 

clear all
set more off

cd "C:\Users\gusta\OneDrive\1 Esalq\Tese Livre Docência\Artigo 3"
cap mkdir "figs_2024"
cap mkdir "tables_2024"

set scheme s1mono
graph set window fontface "Arial"

*******************************************************
* 1) Load 2024
*******************************************************
import dbase "VIOLBR24.dbf", clear
rename *, lower
gen year = 2024

*******************************************************
* 2) Age: nu_idade -> age_years, keep 60+
*******************************************************
cap drop nu_idade_str tipo_idade valor_idade age_years older60
gen nu_idade_str = string(nu_idade)
gen tipo_idade   = real(substr(nu_idade_str, 1, 1))
gen valor_idade  = real(substr(nu_idade_str, 2, .))

gen age_years = .
replace age_years = valor_idade/8760 if tipo_idade == 1
replace age_years = valor_idade/365  if tipo_idade == 2
replace age_years = valor_idade/12   if tipo_idade == 3
replace age_years = valor_idade      if tipo_idade == 4
replace age_years = floor(age_years)

gen older60 = age_years >= 60 if !missing(age_years)
keep if older60==1

cap drop agegrp
gen agegrp = .
replace agegrp = 1 if inrange(age_years,60,69)
replace agegrp = 2 if inrange(age_years,70,79)
replace agegrp = 3 if age_years >= 80
label define agegrp_lbl 1 "60-69" 2 "70-79" 3 "80+", replace
label values agegrp agegrp_lbl

*******************************************************
* 3) Violence types: binary variables (all 5)
*******************************************************
local viol_core "viol_psico viol_finan viol_negli viol_fisic viol_sexu"
foreach v of local viol_core {
    cap drop `v'_bin
    cap confirm numeric variable `v'
    if _rc!=0 destring `v', replace force
    recode `v' (1=1) (2=0) (9=.), gen(`v'_bin)
}

cap drop n_tipos_viol
egen n_tipos_viol = rowtotal(viol_psico_bin viol_finan_bin viol_negli_bin viol_fisic_bin viol_sexu_bin)
label var n_tipos_viol "Number of violence types (1-5)"

* keep general analysis sample: any type marked
keep if n_tipos_viol>=1 & n_tipos_viol<.

* physical indicator for descriptive panel
cap drop physical
gen physical = viol_fisic_bin
label define phys_lbl 0 "No physical" 1 "Physical", replace
label values physical phys_lbl

*******************************************************
* 4) Sex
*******************************************************
cap drop sex_bin cs_sexo_str
cap confirm numeric variable cs_sexo
if _rc==0 tostring cs_sexo, gen(cs_sexo_str) usedisplayformat force
else gen cs_sexo_str = trim(lower(cs_sexo))

gen sex_bin = .
replace sex_bin = 1 if inlist(cs_sexo_str,"f","2")
replace sex_bin = 0 if inlist(cs_sexo_str,"m","1")
replace sex_bin = . if inlist(cs_sexo_str,"i","9","") | missing(cs_sexo_str)
drop cs_sexo_str
label define sex_lbl 0 "Men" 1 "Women", replace
label values sex_bin sex_lbl

*******************************************************
* 5) Race
*******************************************************
cap drop race_cat
cap confirm numeric variable cs_raca
if _rc!=0 destring cs_raca, replace force
gen race_cat = cs_raca if inlist(cs_raca,1,2,3,4,5)
label define race_lbl 1 "White" 2 "Black" 3 "Yellow" 4 "Brown" 5 "Indigenous", replace
label values race_cat race_lbl

*******************************************************
* 6) Education groups
*******************************************************
cap drop educ_grp
cap confirm numeric variable cs_escol_n
if _rc!=0 destring cs_escol_n, replace force
gen educ_grp = .
replace educ_grp = 1 if inlist(cs_escol_n,43,1,2,3,4)
replace educ_grp = 2 if inlist(cs_escol_n,5,6,7)
replace educ_grp = 3 if cs_escol_n==8
label define educ_lbl 1 "Primary or less" 2 "Secondary or some higher" 3 "Higher education", replace
label values educ_grp educ_lbl

*******************************************************
* 7) Domestic location (Residence vs other)
*******************************************************
cap drop domestic local_ocor_str
cap confirm variable local_ocor
if _rc==0 {
    cap confirm numeric variable local_ocor
    if _rc==0 tostring local_ocor, gen(local_ocor_str) usedisplayformat force
    else gen local_ocor_str = trim(lower(local_ocor))
}
else gen local_ocor_str = ""

gen domestic = .
replace domestic = 1 if inlist(local_ocor_str,"1","01","residencia","residência")
replace domestic = 0 if !missing(local_ocor_str) & domestic==. & !inlist(local_ocor_str,"9","99","")
replace domestic = . if local_ocor_str=="" | inlist(local_ocor_str,"9","99")
drop local_ocor_str
label define dom_lbl 0 "Non-residential" 1 "Residence", replace
label values domestic dom_lbl

*******************************************************
* 8) Family-related offender (family vs non-family)
*******************************************************
local rel_fam "rel_pai rel_mae rel_pad rel_mad rel_conj rel_excon rel_namo rel_exnam rel_filho rel_irmao rel_cuida"
foreach v of local rel_fam {
    cap confirm variable `v'
    if _rc==0 {
        cap confirm numeric variable `v'
        if _rc!=0 destring `v', replace force
        recode `v' (1=1) (2=0) (9=.)
    }
}

cap drop family_related
gen family_related = 0
foreach v of local rel_fam {
    cap confirm variable `v'
    if _rc==0 replace family_related = 1 if `v'==1
}
replace family_related = . if missing(family_related)
label define fam_lbl 0 "Non-family" 1 "Family-related", replace
label values family_related fam_lbl

*******************************************************
* 9) Controls: repeated, offender alcohol, disability, region
*******************************************************

* repeated (CONTROL ONLY): out_vezes (1 yes, 2 no, 9 ign)
cap drop repeated outv_str
cap confirm variable out_vezes
if _rc==0 {
    cap confirm numeric variable out_vezes
    if _rc==0 tostring out_vezes, gen(outv_str) usedisplayformat force
    else gen outv_str = lower(trim(out_vezes))

    gen repeated = .
    replace repeated = 1 if outv_str=="1"
    replace repeated = 0 if outv_str=="2"
    replace repeated = . if inlist(outv_str,"9","99","") | missing(outv_str)
    drop outv_str
}
else gen repeated = .
label define rep_lbl 0 "No" 1 "Yes", replace
label values repeated rep_lbl

* offender alcohol (CONTROL)
cap drop offender_alcohol alco_str
cap confirm variable autor_alco
if _rc==0 {
    cap confirm numeric variable autor_alco
    if _rc==0 tostring autor_alco, gen(alco_str) usedisplayformat force
    else gen alco_str = lower(trim(autor_alco))

    gen offender_alcohol = .
    replace offender_alcohol = 1 if alco_str=="1" | strpos(alco_str,"sim")>0
    replace offender_alcohol = 0 if alco_str=="2" | strpos(alco_str,"nao")>0 | strpos(alco_str,"não")>0
    replace offender_alcohol = . if alco_str=="" | inlist(alco_str,"9","99")
    drop alco_str

    label define alco_lbl 0 "No" 1 "Yes", replace
    label values offender_alcohol alco_lbl
}
else gen offender_alcohol = .

* disability (CONTROL)
cap drop disability
cap confirm variable def_trans
if _rc==0 {
    cap confirm numeric variable def_trans
    if _rc!=0 destring def_trans, replace force
    gen disability = .
    replace disability = 1 if def_trans==1
    replace disability = 0 if def_trans==2
    replace disability = . if inlist(def_trans,9,99) | missing(def_trans)
    label define dis_lbl 0 "No" 1 "Yes", replace
    label values disability dis_lbl
}
else gen disability = .

* region (optional)
cap drop region
capture confirm variable sg_uf
if _rc==0 {
    capture confirm numeric variable sg_uf
    if _rc!=0 destring sg_uf, replace force

    gen region = .
    replace region = 1 if inlist(sg_uf,11,12,13,14,15,16,17)
    replace region = 2 if inlist(sg_uf,21,22,23,24,25,26,27,28,29)
    replace region = 3 if inlist(sg_uf,31,32,33,35)
    replace region = 4 if inlist(sg_uf,41,42,43)
    replace region = 5 if inlist(sg_uf,50,51,52,53)

    label define reg_lbl 1 "North" 2 "Northeast" 3 "Southeast" 4 "South" 5 "Center-West", replace
    label values region reg_lbl
    drop if region==.
}

*******************************************************
* 10) Base categories (stable comparisons)
*******************************************************
fvset base 1 agegrp
fvset base 0 sex_bin
fvset base 1 race_cat
fvset base 1 educ_grp
cap confirm variable region
if _rc==0 fvset base 1 region

*******************************************************
* 11) Descriptive panel (4 panels, journal-style)
*******************************************************
local LEG "legend(size(vsmall) cols(2) pos(6) ring(0) region(lstyle(none)))"
local BLp "blabel(bar, format(%4.1f) size(vsmall))"
local BL  "blabel(bar, format(%4.2f) size(vsmall))"

*******************************************************
* A) Victims by age group and sex (percent within age group)
*******************************************************
preserve
    keep if inlist(sex_bin,0,1) & !missing(agegrp)

    contract agegrp sex_bin
    fillin agegrp sex_bin
    replace _freq = 0 if missing(_freq)

    bys agegrp: egen tot = total(_freq)

    gen pct_men   = 100*_freq/tot if sex_bin==0
    gen pct_women = 100*_freq/tot if sex_bin==1

    collapse (max) pct_men pct_women, by(agegrp)

    graph bar pct_men pct_women, ///
        over(agegrp, label(labsize(vsmall))) ///
        asyvars ///
        bar(1, color(black)) ///
        bar(2, color(gs6)) ///
        ytitle("Percent", size(vsmall)) ///
        title("A. Victims by age group and sex (percent)", size(small)) ///
        blabel(bar, format(%4.1f) size(vsmall) position(outside)) ///
        legend(order(1 "Men" 2 "Women") ///
               size(vsmall) ///
               cols(2) ///
               position(12) ///
               ring(0) ///
               region(lstyle(none))) ///
        graphregion(color(white)) ///
        plotregion(margin(small)) ///
        name(gA, replace)
restore

*******************************************************
* B) Violence types (percent), grouped bars (Men vs Women)
*******************************************************
preserve
    keep if inlist(sex_bin,0,1)

    collapse (mean) viol_psico_bin viol_finan_bin viol_negli_bin viol_fisic_bin viol_sexu_bin, by(sex_bin)

    reshape long viol_, i(sex_bin) j(vtype) string
    gen pct = 100*viol_

    gen vlabel = ""
    replace vlabel = "Psychological" if vtype=="psico_bin"
    replace vlabel = "Financial"     if vtype=="finan_bin"
    replace vlabel = "Neglect"       if vtype=="negli_bin"
    replace vlabel = "Physical"      if vtype=="fisic_bin"
    replace vlabel = "Sexual"        if vtype=="sexu_bin"

    keep sex_bin vlabel pct
    reshape wide pct, i(vlabel) j(sex_bin)

    rename pct0 pct_men
    rename pct1 pct_women

    gen pct_total = (pct_men + pct_women)/2
    gsort -pct_total

    gen vorder = _n
    label define vordlbl 1 "", replace
    levelsof vorder, local(L)
    foreach k of local L {
        local lab = vlabel[`k']
        label define vordlbl `k' "`lab'", modify
    }
    label values vorder vordlbl

    graph bar pct_men pct_women, ///
        over(vorder, label(labsize(tiny) angle(35))) ///
        asyvars ///
        bar(1, color(black)) ///
        bar(2, color(gs6)) ///
        ytitle("Percent", size(vsmall)) ///
        ylabel(0(20)80, labsize(vsmall) angle(horizontal)) ///
        yscale(range(0 80)) ///
        title("B. Violence types (percent)", size(small)) ///
        blabel(bar, format(%4.1f) size(vsmall) position(outside)) ///
        legend(order(1 "Men" 2 "Women") ///
               size(vsmall) cols(2) position(12) ring(0) ///
               region(lstyle(none))) ///
        graphregion(color(white)) ///
        plotregion(margin(small)) ///
        name(gB, replace)
restore

*******************************************************
* C) Residence (share)
*******************************************************
graph bar (mean) domestic, ///
    over(agegrp, label(labsize(vsmall))) ///
    over(sex_bin, label(labsize(vsmall))) ///
    ascategory ///
    title("C. Residence (share)", size(small)) ///
    ytitle("Proportion", size(vsmall)) ///
    `BL' `LEG' ///
    graphregion(color(white)) ///
    plotregion(margin(small)) ///
    name(gC, replace)

*******************************************************
* D) Family-related offender (share)
*******************************************************
graph bar (mean) family_related, ///
    over(agegrp, label(labsize(vsmall))) ///
    over(sex_bin, label(labsize(vsmall))) ///
    ascategory ///
    title("D. Family-related offender (share)", size(small)) ///
    ytitle("Proportion", size(vsmall)) ///
    ylabel(0(.2)1, labsize(vsmall) angle(horizontal)) ///
    yscale(range(0 .8)) ///
    `BL' `LEG' ///
    graphregion(color(white)) ///
    plotregion(margin(small)) ///
    name(gD, replace)

*******************************************************
* Combine + export
*******************************************************
graph combine gA gB gC gD, cols(2) ///
    imargin(tiny) graphregion(color(white)) plotregion(margin(small))

graph export "figs_2024\Fig1_descriptive_panel.png", replace width(3200)

*******************************************************
* 12) MAIN MODELS + AMEs (2 models only) + ONE RTF table
*******************************************************

* controls macro
* FIX: treat repeated as factor so esttab can find 1.repeated
local CTRL "i.agegrp i.sex_bin i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol"
cap confirm variable region
if _rc==0 local CTRL "`CTRL' i.region"

* Model 1: domestic
logit domestic `CTRL' if !missing(domestic), vce(robust)
estimates store BASE_dom
scalar Obs_dom = e(N)
scalar AIC_dom = -2*e(ll) + 2*e(df_m)
scalar BIC_dom = -2*e(ll) + ln(e(N))*e(df_m)
margins, dydx(*) post
estimates store M1_dom
estadd scalar Obs = Obs_dom : M1_dom
estadd scalar AIC = AIC_dom : M1_dom
estadd scalar BIC = BIC_dom : M1_dom

* Model 2: family_related
logit family_related `CTRL' if !missing(family_related), vce(robust)
estimates store BASE_fam
scalar Obs_fam = e(N)
scalar AIC_fam = -2*e(ll) + 2*e(df_m)
scalar BIC_fam = -2*e(ll) + ln(e(N))*e(df_m)
margins, dydx(*) post
estimates store M2_fam
estadd scalar Obs = Obs_fam : M2_fam
estadd scalar AIC = AIC_fam : M2_fam
estadd scalar BIC = BIC_fam : M2_fam

* require esttab
cap which esttab
if _rc!=0 {
    di as error "esttab not found. Install with: ssc install estout"
    error 111
}

* export RTF (2 columns)
cap confirm variable region
if _rc==0 {
    esttab M1_dom M2_fam ///
    using "tables_2024\Table_AME_General_Domestic_vs_Family.rtf", replace ///
    label ///
    mtitles("Residence (logit AME)" "Family-related offender (logit AME)") ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    nobaselevels nonumbers nodepvars ///
    keep(2.agegrp 3.agegrp ///
         1.sex_bin ///
         2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
         2.educ_grp 3.educ_grp ///
         1.disability 1.offender_alcohol ///
         1.repeated n_tipos_viol ///
         2.region 3.region 4.region 5.region) ///
    order(2.agegrp 3.agegrp ///
          1.sex_bin ///
          2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
          2.educ_grp 3.educ_grp ///
          1.disability 1.offender_alcohol ///
          1.repeated n_tipos_viol ///
          2.region 3.region 4.region 5.region) ///
    varlabels( ///
        2.agegrp "Age 70-79" ///
        3.agegrp "Age 80+" ///
        1.sex_bin "Women" ///
        2.race_cat "Black" ///
        3.race_cat "Yellow" ///
        4.race_cat "Brown" ///
        5.race_cat "Indigenous" ///
        2.educ_grp "Secondary or some higher" ///
        3.educ_grp "Higher education" ///
        1.disability "Disability or disorder" ///
        1.offender_alcohol "Offender alcohol" ///
        1.repeated "Repeated victimization (control)" ///
        n_tipos_viol "Number of violence types (control)" ///
        2.region "Northeast" ///
        3.region "Southeast" ///
        4.region "South" ///
        5.region "Center-West" ///
    ) ///
    stats(Obs AIC BIC, fmt(0 2 2) labels("Observations" "AIC" "BIC")) ///
    addnotes("Entries are average marginal effects. Robust standard errors in parentheses. Sample restricted to 60+ with at least one violence type marked. Controls include repeated victimization and number of violence types.")
}
else {
    esttab M1_dom M2_fam ///
    using "tables_2024\Table_AME_General_Domestic_vs_Family.rtf", replace ///
    label ///
    mtitles("Residence (logit AME)" "Family-related offender (logit AME)") ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    nobaselevels nonumbers nodepvars ///
    keep(2.agegrp 3.agegrp ///
         1.sex_bin ///
         2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
         2.educ_grp 3.educ_grp ///
         1.disability 1.offender_alcohol ///
         1.repeated n_tipos_viol) ///
    order(2.agegrp 3.agegrp ///
          1.sex_bin ///
          2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
          2.educ_grp 3.educ_grp ///
          1.disability 1.offender_alcohol ///
          1.repeated n_tipos_viol) ///
    varlabels( ///
        2.agegrp "Age 70-79" ///
        3.agegrp "Age 80+" ///
        1.sex_bin "Women" ///
        2.race_cat "Black" ///
        3.race_cat "Yellow" ///
        4.race_cat "Brown" ///
        5.race_cat "Indigenous" ///
        2.educ_grp "Secondary or some higher" ///
        3.educ_grp "Higher education" ///
        1.disability "Disability or disorder" ///
        1.offender_alcohol "Offender alcohol" ///
        1.repeated "Repeated victimization (control)" ///
        n_tipos_viol "Number of violence types (control)" ///
    ) ///
    stats(Obs AIC BIC, fmt(0 2 2) labels("Observations" "AIC" "BIC")) ///
    addnotes("Entries are average marginal effects. Robust standard errors in parentheses. Sample restricted to 60+ with at least one violence type marked. Controls include repeated victimization and number of violence types.")
}

*******************************************************
* Optional quick diagnostics (keeps you from surprises)
*******************************************************
di "Check repeated variation in each model sample:"
qui logit domestic `CTRL' if !missing(domestic), vce(robust)
tab repeated if e(sample), missing
qui logit family_related `CTRL' if !missing(family_related), vce(robust)
tab repeated if e(sample), missing

*******************************************************
* 13) Age-profile figures (2 models only): domestic + family_related
* FIX: allow age gradients to differ by sex (interaction with age and age^2)
*******************************************************
local a0 = 60
local a1 = 95

local MP_OPTS ///
    xtitle("Age", size(vsmall)) ///
    ytitle(, size(vsmall)) ///
    xlabel(`a0'(5)`a1', labsize(vsmall)) ///
    ylabel(, labsize(vsmall) angle(horizontal)) ///
    legend(order(1 "Men" 2 "Women") size(vsmall) cols(2) pos(6) ring(0) region(lstyle(none))) ///
    recast(line) recastci(rarea)

* Residence outcome
cap confirm variable region
if _rc==0 {
    logit domestic i.sex_bin##c.age_years##c.age_years ///
        i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol i.region ///
        if !missing(domestic, sex_bin, age_years), vce(robust)
}
else {
    logit domestic i.sex_bin##c.age_years##c.age_years ///
        i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol ///
        if !missing(domestic, sex_bin, age_years), vce(robust)
}

margins sex_bin, at(age_years=(`a0'(1)`a1')) post
marginsplot, title("Residence", size(small)) ///
    ytitle("Adjusted probability", size(vsmall)) ///
    `MP_OPTS' name(g_dom_age, replace)
graph export "figs_2024\Fig2_residence_age_sex.png", replace width(2800)

* Family-related offender outcome
cap confirm variable region
if _rc==0 {
    logit family_related i.sex_bin##c.age_years##c.age_years ///
        i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol i.region ///
        if !missing(family_related, sex_bin, age_years), vce(robust)
}
else {
    logit family_related i.sex_bin##c.age_years##c.age_years ///
        i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol ///
        if !missing(family_related, sex_bin, age_years), vce(robust)
}

margins sex_bin, at(age_years=(`a0'(1)`a1')) post
marginsplot, title("Family-related offender", size(small)) ///
    ytitle("Adjusted probability", size(vsmall)) ///
    `MP_OPTS' name(g_fam_age, replace)
graph export "figs_2024\Fig3_family_age_sex.png", replace width(2800)

* Combined 1x2 panel (no main title)
graph combine g_dom_age g_fam_age, cols(2) imargin(tiny) ///
    graphregion(color(white)) plotregion(margin(small))
graph export "figs_2024\Fig4_age_profiles_panel.png", replace width(3000)


* Fix r(110): "e(ll) already defined"
* Solution: do not use the name "ll". Use a unique scalar name (e.g., LogLik).
* Also: clear any prior stored estimates with same names (optional but helps).

*******************************************************
* APPENDIX TABLE – COEFFICIENTS (AGE QUADRATIC x SEX)
*******************************************************

cap which esttab
if _rc!=0 {
    di as error "esttab not found. Install with: ssc install estout"
    error 111
}

* optional: drop previous stored estimates with same names
cap estimates drop APP_dom
cap estimates drop APP_fam

local CTRL2 "i.sex_bin##c.age_years##c.age_years i.race_cat i.educ_grp i.disability i.offender_alcohol i.repeated c.n_tipos_viol"
cap confirm variable region
if _rc==0 local CTRL2 "`CTRL2' i.region"

fvset base 0 sex_bin
fvset base 1 race_cat
fvset base 1 educ_grp
cap confirm variable region
if _rc==0 fvset base 1 region

*******************************************************
* Model A: domestic
*******************************************************
quietly logit domestic `CTRL2' if !missing(domestic, sex_bin, age_years), vce(robust)
estimates store APP_dom
estadd scalar Obs    = e(N)  : APP_dom
estadd scalar LogLik = e(ll) : APP_dom

*******************************************************
* Model B: family_related
*******************************************************
quietly logit family_related `CTRL2' if !missing(family_related, sex_bin, age_years), vce(robust)
estimates store APP_fam
estadd scalar Obs    = e(N)  : APP_fam
estadd scalar LogLik = e(ll) : APP_fam

*******************************************************
* Export
*******************************************************
*******************************************************
* Export (corrigido)
*******************************************************
esttab APP_dom APP_fam ///
using "tables_2024\Appendix_Table_Coefs_AgeQuad_SexInteract.rtf", replace ///
label ///
mtitles("Residence (logit coef.)" "Family-related offender (logit coef.)") ///
cells(b(star fmt(3)) se(par fmt(3))) ///
starlevels(* 0.10 ** 0.05 *** 0.01) ///
nobaselevels nonumbers nodepvars ///
keep( ///
    1.sex_bin ///
    age_years ///
    c.age_years#c.age_years ///
    1.sex_bin#c.age_years ///
    1.sex_bin#c.age_years#c.age_years ///
    2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
    2.educ_grp 3.educ_grp ///
    1.disability 1.offender_alcohol 1.repeated ///
    n_tipos_viol ///
    2.region 3.region 4.region 5.region ///
) ///
order( ///
    1.sex_bin ///
    age_years ///
    c.age_years#c.age_years ///
    1.sex_bin#c.age_years ///
    1.sex_bin#c.age_years#c.age_years ///
    2.race_cat 3.race_cat 4.race_cat 5.race_cat ///
    2.educ_grp 3.educ_grp ///
    1.disability 1.offender_alcohol 1.repeated ///
    n_tipos_viol ///
    2.region 3.region 4.region 5.region ///
) ///
varlabels( ///
    1.sex_bin "Women" ///
    age_years "Age (years)" ///
    c.age_years#c.age_years "Age squared" ///
    1.sex_bin#c.age_years "Women x Age" ///
    1.sex_bin#c.age_years#c.age_years "Women x Age squared" ///
    2.race_cat "Black" ///
    3.race_cat "Yellow" ///
    4.race_cat "Brown" ///
    5.race_cat "Indigenous" ///
    2.educ_grp "Secondary or some higher" ///
    3.educ_grp "Higher education" ///
    1.disability "Disability or disorder" ///
    1.offender_alcohol "Offender alcohol" ///
    1.repeated "Repeated victimization" ///
    n_tipos_viol "Number of violence types" ///
    2.region "Northeast" ///
    3.region "Southeast" ///
    4.region "South" ///
    5.region "Center-West" ///
) ///
stats(Obs LogLik, fmt(0 3) labels("Observations" "Log-likelihood")) ///
addnotes( ///
"Entries are logit coefficients (log-odds). Robust standard errors in parentheses." ///
"Men is the reference category for sex. White is the reference for race. Primary or less is the reference for education. North is the reference region (when included)." ///
"Age enters as a quadratic polynomial and is interacted with sex to allow sex-specific age gradients." ///
)


*******************************************************
* Optional: joint test of interaction terms
*******************************************************
quietly estimates restore APP_dom
testparm 1.sex_bin#c.age_years 1.sex_bin#c.age_years#c.age_years

quietly estimates restore APP_fam
testparm 1.sex_bin#c.age_years 1.sex_bin#c.age_years#c.age_years



*******************************************************
* 14) End summary
*******************************************************
di "N (older adults 60+, any violence type): " _N


*******************************************************
* TABLE 1 – DESCRIPTIVE STATISTICS (EMPIRICAL SAMPLE)
* Output: DOCX (Word) via putdocx
* FIX: avoid r(110) "cat already defined" by dropping temp vars
*******************************************************

*------------------------------------------------------*
* 0) Empirical sample used in modeling
*------------------------------------------------------*
cap drop sample_model
gen sample_model = !missing(domestic, family_related, ///
                            agegrp, sex_bin, race_cat, ///
                            educ_grp, disability, ///
                            offender_alcohol, repeated, ///
                            n_tipos_viol)

cap confirm variable region
if _rc==0 replace sample_model = sample_model & !missing(region)

preserve
keep if sample_model==1

* Save master empirical sample
tempfile master
save `master', replace

*------------------------------------------------------*
* Labels (Panel A)
*------------------------------------------------------*
label var age_years        "Age (years)"
label var domestic         "Residence"
label var family_related   "Family-related offender"
label var sex_bin          "Women"
label var disability       "Disability or disorder"
label var offender_alcohol "Offender alcohol"
label var repeated         "Repeated victimization"
label var n_tipos_viol     "Number of violence types"

*******************************************************
* Panel A: mean, sd, min, max
*******************************************************
tempfile panelA
postfile PA str60 varname double mean sd min max using `panelA', replace

use `master', clear
foreach v in age_years domestic family_related sex_bin disability offender_alcohol repeated n_tipos_viol {
    quietly summarize `v'
    local lab : variable label `v'
    post PA ("`lab'") (r(mean)) (r(sd)) (r(min)) (r(max))
}
postclose PA

use `panelA', clear
tempfile Aready
save `Aready', replace

*******************************************************
* Panel B: categorical distributions (%)
*******************************************************
tempfile panelB
postfile PB str40 group str60 category double pct using `panelB', replace

capture program drop _oneway_pct
program define _oneway_pct
    syntax varname, Groupname(string) Refcode(integer)

    preserve
        keep `varlist'
        drop if missing(`varlist')

        contract `varlist', freq(n)
        quietly summarize n
        local N = r(sum)
        gen pct = 100*n/`N'

        tempvar tcat
        local vl : value label `varlist'
        if "`vl'" != "" {
            decode `varlist', gen(`tcat')
        }
        else {
            tostring `varlist', gen(`tcat') usedisplayformat force
        }

        replace `tcat' = `tcat' + " (ref.)" if `varlist' == `refcode'

        local nrows = _N
        forvalues i = 1/`nrows' {
            post PB ("`groupname'") (`tcat'[`i']) (pct[`i'])
        }
    restore
end

use `master', clear

_oneway_pct agegrp,   groupname("Age group")  refcode(1)
_oneway_pct sex_bin,  groupname("Sex")        refcode(0)
_oneway_pct race_cat, groupname("Race")       refcode(1)
_oneway_pct educ_grp, groupname("Education")  refcode(1)
cap confirm variable region
if _rc==0 _oneway_pct region, groupname("Region") refcode(1)

postclose PB

use `panelB', clear
tempfile Bready
save `Bready', replace

*******************************************************
* Export DOCX with Panel A + Panel B
*******************************************************
putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("Table 1. Descriptive statistics (Empirical sample, 60+)")

putdocx paragraph
putdocx text ("Sample restricted to individuals aged 60+ with at least one violence type recorded and complete information for model variables.")

* Panel A
use `Aready', clear
putdocx paragraph, style(Heading2)
putdocx text ("Panel A. Continuous and binary variables")

putdocx table tabA = data(varname mean sd min max), varnames
putdocx table tabA(.,2), nformat(%9.3f)
putdocx table tabA(.,3), nformat(%9.3f)
putdocx table tabA(.,4), nformat(%9.0f)
putdocx table tabA(.,5), nformat(%9.0f)

* Panel B
use `Bready', clear
putdocx paragraph, style(Heading2)
putdocx text ("Panel B. Categorical distributions (%)")

putdocx table tabB = data(group category pct), varnames
putdocx table tabB(.,3), nformat(%9.1f)

putdocx paragraph
putdocx text ("Percentages are shares within the empirical sample. Reference categories are marked as (ref.).")

putdocx save "tables_2024\Table1_Descriptive_Statistics.docx", replace

restore

putdocx save "tables_2024\Appendix_Table_A1_Model_Summary.docx", replace
