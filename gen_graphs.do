
//generate .dta files for stanford results
clear
import delimited "./bin2_results.txt", clear
rename v1 id
rename v2 hc_answer
rename v3 stanford_answer_bin2
drop v4 v5
save "stanford_bin2.dta",replace
clear
import delimited "./bin1_results.txt", clear
rename v1 id
rename v2 hc_answer1
rename v3 stanford_answer_bin1
drop v4 v5
save "stanford_bin1.dta",replace
clear
import delimited "./tc_results.txt", clear
rename v1 id
rename v2 hc_answer_tc
rename v3 stanford_answer_tc
drop v4 v5
save "stanford_tc.dta",replace
//merge
merge m:m id using "stanford_bin2.dta"
drop _merge
merge m:m id using "stanford_bin1.dta"
drop _merge
save "Stanford_Results.dta", replace
merge m:m id using "article_file.dta"
drop _merge

//merge with topic model and k-means results.
merge m:m id using "topic_model.dta"
drop _merge
merge m:m id using "k-means.dta"
drop _merge

//label columns and generate variables before collapsing by year
//note: some of the variables are already properly named after import

//generate dummies for each hand-coding result
//note: these codes are out of order since code_label is sorted alphabetically
//note: RTextTools data is already collapsed by year, and is imported separately
sort code
tab code_label, generate(code_)
rename code_1 code_irrelevant
rename code_2 code_relchange
rename code_3 code_relecon
rename code_4 code_explicit
rename code_5 code_implicit

//generate a 0/1 outcome for each automated method and binary categorization scheme
//naming scheme was cat_method. So for example the SVM coding using Binary 1 is bin1_svm
gen bin1_svm = 2-linearsvc_binary1
gen bin2_svm = 2-linearsvc_binary2
gen bin2_stanford = 1 if stanford_answer_bin2=="explicit/implicit"
replace bin2_stanford = 0 if stanford_answer_bin2=="relchanges/releconomy/irrelevant"
gen hc_ans = 1 if hc_answer=="explicit/implicit" 
replace hc_ans = 0 if hc_answer=="relchanges/releconomy/irrelevant"
gen bin1_stanford = 1 if stanford_answer_bin1=="explicit/implicit/relchanges/releconomy"
replace bin1_stanford = 0 if stanford_answer_bin1=="irrelevant"
gen hc_ans1 = 1 if hc_answer1=="explicit/implicit/relchanges/releconomy"
replace hc_ans1 = 0 if hc_answer1=="irrelevant"

//creates hand-coded variable for training set
gen bin1_hc = 1-code_irrelevant if missing(bin1_svm)
gen bin2_hc = code_explicit + code_implicit if missing(bin2_svm)

//generate dummy variables for the Stanford “three-code” classification
tab linearsvc_three_code2, gen(tc_svm)
gen tc_stanford1 = 0 if !missing(stanford_answer_tc)
gen tc_stanford2 = 0 if !missing(stanford_answer_tc)
gen tc_stanford3 = 0 if !missing(stanford_answer_tc)
replace tc_stanford1 = 1 if  stanford_answer_tc=="explicit/implicit"
replace tc_stanford2 = 1 if stanford_answer_tc=="relchanges/releconomy"
replace tc_stanford3 = 1 if stanford_answer_tc=="irrelevant"
tab tc, gen(tc_hc)
//need the three-code data for the training set
gen tc_hc_train1 = tc_hc1 if missing(bin2_svm)
gen tc_hc_train2 = tc_hc2 if missing(bin2_svm)
gen tc_hc_train3 = tc_hc3 if missing(bin2_svm)

rename code_label codelabel
gen reduced_ds = 1 if !missing(bin1_svm)

//save a copy of the data file
save "pre_collapse.dta", replace

//collapse by year to allow graphing/analysis
collapse (sum) bin1_svm bin2_svm code_* b2 reduced_ds bin2_stanford hc_ans bin1_stanford hc_ans1 bin1_hc bin2_hc tc_* inequal* (mean) id (count) tc [aw=weight], by(year)
//import RTextTools data
merge m:m year using "RTT_results.dta"
drop _merge
merge m:m year using "RTT_results_testonly.dta"

gen ineq_broad = code_explicit + code_implicit 
gen tot = code_irrelevant + code_relchange + code_relecon  + code_explicit + code_implicit 

gen python_pct = (bin2_svm + bin2_hc)/ tc
gen stanford_pct = (bin2_stanford + bin2_hc) / tc
gen hcoded_pct = ineq_broad /tc 

//generate 2-year moving averages
//2-year moving averages are named ma2_measure
sort year

//for binary 2
gen ma2_tot = (tot + tot[_n-1])/2
gen ma2_python_pct = (python_pct + python_pct[_n-1])/2
gen ma2_stanford_pct = (stanford_pct + stanford_pct[_n-1])/2
gen ma2_rtt_pct = (rtt_pct + rtt_pct[_n-1])/2
gen ma2_hcoded_pct = (hcoded_pct + hcoded_pct[_n-1])/2

//using binary 1
gen python_pct1 = (bin1_svm+bin1_hc) /tc 
gen stanford_pct1 = (bin1_stanford+bin1_hc)/tc
gen ma2_python_pct1 = (python_pct1 + python_pct1[_n-1])/2
gen ma2_rtt_pct1 = (rtt_pct1 + rtt_pct1[_n-1])/2
gen ma2_stanford_pct1 = (stanford_pct1 + stanford_pct1[_n-1])/2

gen hcoded_pct1 = 1 - code_irrelevant/tc 
gen ma2_hcoded_pct1= (hcoded_pct1 + hcoded_pct1[_n-1])/2

//using three code
gen python_pct_tc1 = (tc_svm1+tc_hc_train1) /tc 
gen python_pct_tc2 = (tc_svm2+tc_hc_train2) /tc
gen python_pct_tc3 = (tc_svm3+tc_hc_train3) /tc
gen stanford_pct_tc1 = (tc_stanford1+tc_hc_train1) /tc 
gen stanford_pct_tc2 = (tc_stanford2+tc_hc_train2) /tc
gen stanford_pct_tc3 = (tc_stanford3+tc_hc_train3) /tc
gen hc_pct_tc1 = (tc_hc1) /tc 
gen hc_pct_tc2 = (tc_hc2) /tc
gen hc_pct_tc3 = (tc_hc3) /tc

//two-year moving averages
gen ma2_python_tc1 = (python_pct_tc1 + python_pct_tc1[_n-1])/2
gen ma2_stanford_tc1 = (stanford_pct_tc1 + stanford_pct_tc1[_n-1])/2
gen ma2_hc_tc1 = (hc_pct_tc1 + hc_pct_tc1[_n-1])/2
gen ma2_python_tc2 = (python_pct_tc2 + python_pct_tc2[_n-1])/2
gen ma2_stanford_tc2 = (stanford_pct_tc2 + stanford_pct_tc2[_n-1])/2
gen ma2_hc_tc2 = (hc_pct_tc2 + hc_pct_tc2[_n-1])/2
gen ma2_python_tc3 = (python_pct_tc3 + python_pct_tc3[_n-1])/2
gen ma2_stanford_tc3 = (stanford_pct_tc3 + stanford_pct_tc3[_n-1])/2
gen ma2_hc_tc3 = (hc_pct_tc3 + hc_pct_tc3[_n-1])/2

gen ma2_rtt_tc1 = (rtt_pct_tc1 + rtt_pct_tc1[_n-1])/2
gen ma2_rtt_tc2 = (rtt_pct_tc2 + rtt_pct_tc2[_n-1])/2
gen ma2_rtt_tc3 = (rtt_pct_tc3 + rtt_pct_tc3[_n-1])/2

corr ma2_stanford_tc1  ma2_python_tc1  ma2_rtt_tc1  ma2_hc_tc1
corr ma2_stanford_tc2  ma2_python_tc2  ma2_rtt_tc2  ma2_hc_tc2
corr ma2_stanford_tc3  ma2_python_tc3  ma2_rtt_tc3  ma2_hc_tc3


//for correlations binary 2
gen python_pct_corr = bin2_svm/reduced_ds
gen stanford_pct_corr = bin2_stanford/reduced_ds
gen hc_pct_corr = (ineq_broad - bin2_hc)/reduced_ds
gen ma2_python_pct_corr = (python_pct_corr + python_pct_corr[_n-1])/2
gen ma2_stanford_pct_corr = (stanford_pct_corr + stanford_pct_corr[_n-1])/2
gen ma2_rtt_pct_corr = (rtt_pct_test + rtt_pct_test[_n-1])/2
gen ma2_hc_pct_corr = (hc_pct_corr + hc_pct_corr[_n-1])/2


//for correlations binary 1
gen python_pct_corr1 = bin1_svm/reduced_ds
gen stanford_pct_corr1 = bin1_stanford/reduced_ds
gen hc_pct_corr1 = ((tc - code_irrelevant)-bin1_hc)/reduced_ds
gen ma2_python_pct_corr1 = (python_pct_corr1 + python_pct_corr1[_n-1])/2
gen ma2_stanford_pct_corr1 = (stanford_pct_corr1 + stanford_pct_corr1[_n-1])/2
gen ma2_rtt_pct_corr1 = (rtt_pct1_test + rtt_pct1_test[_n-1])/2
gen ma2_hc_pct_corr1 = (hc_pct_corr1 + hc_pct_corr1[_n-1])/2

gen ma2_b1_stanford = (bin1_stanford + bin1_stanford[_n-1])/2
gen ma2_b1_svm = (bin1_svm + bin1_svm[_n-1])/2
gen ma2_b1_hc = (bin1_hc + bin1_hc[_n-1])/2

//run correlations
corr ma*pct_corr
corr ma*pct_corr1

//single-year correlations
corr python_pct_corr stanford_pct_corr rtt_pct_test hc_pct_corr
corr python_pct_corr1 stanford_pct_corr1 rtt_pct1_test hc_pct_corr1

//moving averages and correlations for the 3-code method
gen svm_corr_tc1 = tc_svm1/reduced_ds
gen svm_corr_tc2 = tc_svm2/reduced_ds
gen svm_corr_tc3 = tc_svm3/reduced_ds
gen stanford_corr_tc1 = tc_stanford1/reduced_ds
gen stanford_corr_tc2 = tc_stanford2/reduced_ds
gen stanford_corr_tc3 = tc_stanford3/reduced_ds
gen hctest_corr_tc1 = (tc_hc1 - tc_hc_train1)/reduced_ds
gen hctest_corr_tc2 = (tc_hc2 - tc_hc_train2)/reduced_ds
gen hctest_corr_tc3 = (tc_hc3 - tc_hc_train3)/reduced_ds

gen ma2_tc1_hc = (hctest_corr_tc1 + hctest_corr_tc1[_n-1])/2
gen ma2_tc2_hc = (hctest_corr_tc2 + hctest_corr_tc2[_n-1])/2
gen ma2_tc3_hc = (hctest_corr_tc3 + hctest_corr_tc3[_n-1])/2
gen ma2_tc1_svm = (svm_corr_tc1 + svm_corr_tc1[_n-1])/2
gen ma2_tc2_svm = (svm_corr_tc2 + svm_corr_tc2[_n-1])/2
gen ma2_tc3_svm = (svm_corr_tc3 + svm_corr_tc3[_n-1])/2
gen ma2_tc1_stanford = (stanford_corr_tc1 + stanford_corr_tc1[_n-1])/2
gen ma2_tc2_stanford = (stanford_corr_tc2 + stanford_corr_tc2[_n-1])/2
gen ma2_tc3_stanford = (stanford_corr_tc3 + stanford_corr_tc3[_n-1])/2
gen ma2_tc1_rtt = (rtt_pct_tc1_test + rtt_pct_tc1_test[_n-1])/2
gen ma2_tc2_rtt = (rtt_pct_tc2_test + rtt_pct_tc2_test[_n-1])/2
gen ma2_tc3_rtt = (rtt_pct_tc3_test + rtt_pct_tc3_test[_n-1])/2

corr ma2_tc1_svm ma2_tc1_stanford ma2_tc1_rtt ma2_tc1_hc
corr ma2_tc2_svm ma2_tc2_stanford ma2_tc2_rtt ma2_tc2_hc
corr ma2_tc3_svm ma2_tc3_stanford ma2_tc3_rtt ma2_tc3_hc

//1-year correlations
corr svm_corr_tc1 stanford_corr_tc1 rtt_pct_tc1_test hctest_corr_tc1

//Dictionary Methods
drop _merge
merge 1:1 year using "leslie_dict.dta"
drop _merge
merge 1:1 year using "levay_enns_dict.dta"

gen dict_pct = withatleastonekeyword / (100)
gen hc_exp_pct =  codedasexplicit / (100)
//these two steps just make sure the results from the dictionary data set are matching the primary data set.
gen test_exp = code_explicit/tc
gen ma2_dict_pct = (dict_pct + dict_pct[_n-1])/2
gen ma2_hc_pct = (hc_exp_pct + hc_exp_pct[_n-1])/2

gen ma2_hc_pct_les = (hand_explicit_or_implicit + hand_explicit_or_implicit[_n-1])/2
gen ma2_dict_pct_les = (dict_explicit_or_implicit + dict_explicit_or_implicit[_n-1])/2


twoway (line dict_pct year, sort lcolor(black) lpattern(dash)) (line hcoded_pct year, lcolor(black)), ytitle(Proportion Inequality) ylabel(#5) xtitle(Year) xlabel(1980(5)2010) title(Inequality Articles as a Proportion of Total) legend(on order(1 "Dictionary" 2 "hand-coded"))

corr ma2_dict_pct ma2_hc_pct
twoway (line ma2_dict_pct year, sort lcolor(black) lpattern(dash)) (line ma2_hc_pct year, lcolor(black)), ytitle(Proportion Inequality (2-year MA)) ylabel(#5) xtitle(Year) xlabel(1980(5)2010) title(Inequality Articles as a Proportion of Total (2-year MA)) legend(on order(1 "Dictionary Levay-Enns (corr=.42)" 2 "Hand-Coded Explicit"))
graph export "Dict_Levay_Enns.pdf", as(pdf) replace
corr ma2_dict_pct_les  ma2_hc_pct_les
corr hand_explicit_or_implicit dict_explicit_or_implicit
twoway (line ma2_dict_pct_les year, sort lcolor(black) lpattern(dash)) (line ma2_hc_pct_les year, lcolor(black)), ytitle(Proportion Inequality (2-year MA)) ylabel(#5) xtitle(Year) xlabel(1980(5)2010) title(Inequality Articles as a Proportion of Total (2-year MA)) legend(on order(1 "Dictionary McCall (corr=.62)" 2 "Hand-Coded Explicit"))
graph export "Dict_Leslie.pdf", as(pdf) replace

//Topic Models
gen topic_pct = inequal_topic/tc
gen ma2_topic_pct = (topic_pct + topic_pct[_n-1])/2
corr ma2_topic_pct ma2_hc_pct
twoway (line ma2_topic_pct year, sort lcolor(black) lpattern(dash)) (line ma2_hc_pct year, lcolor(black)), ytitle(Proportion Inequality (2-year MA)) ylabel(#5) xtitle(Year) xlabel(1980(5)2010) title(Inequality Articles as a Proportion of Total (2-year MA)) legend(on order(1 "Topic Model (corr = .58)" 2 "Hand-Coded Explicit"))
graph export "Topic_Model.pdf", as(pdf) replace

//save a final version of the data
save "post_collapse.dta", replace

// FINAL GRAPHS
//graph
corr ma2_*_pct

//create graphs using pre-processed data file
twoway (line ma2_stanford_pct year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_python_pct year, sort lcolor(black) lpattern(longdash)) (line ma2_rtt_pct year, sort lcolor(black) lpattern(dot)) (line ma2_hcoded_pct year, lcolor(black)) , xtitle("") ytitle("Proportion Explicit/Implicit Inequality") ytitle("(2 yr. moving avg.)", suffix) ylabel(#5) xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Stanford NLP  ({it:r} =.88)" 2 "Python  ({it:r} =.82)" 3 "RTextTools      ({it:r} =.79)" 4 "Hand Coded") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 	
graph export "F4 Binary 2.pdf", as(pdf) replace

corr ma2_*pct1
twoway (line ma2_stanford_pct1 year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_python_pct1 year, sort lcolor(black) lpattern(longdash)) (line ma2_rtt_pct1 year, sort lcolor(black) lpattern(dot)) (line ma2_hcoded_pct1 year, lcolor(black)) , xtitle("") ytitle("Proportion Relevant", size(medium)) ytitle("(2 yr. moving avg.)", size(medsmall) suffix) ylabel(#5) xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Stanford NLP  ({it:r} =.98)" 2 "Python  ({it:r} =.89)" 3 "RTextTools      ({it:r} =.93)" 4 "Hand Coded") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "F3 Binary 1 v2.pdf", as(pdf) replace

corr ma2_hc_tc3 ma2*tc3
twoway (line ma2_stanford_tc1 year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_python_tc1 year, sort lcolor(black) lpattern(longdash)) (line ma2_rtt_tc1 year, sort lcolor(black) lpattern(dot)) (line ma2_hc_tc1 year, lcolor(black)) , xtitle("") ytitle(Proportion Explicit/Implicit Inequality) ytitle("(2 yr. moving avg.)",suffix) ylabel(#5) xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Stanford NLP  ({it:r} =.93)" 2 "Python  ({it:r} =.86)" 3 "RTextTools      ({it:r} =.88)" 4 "Hand Coded") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "F5 Three Code ExpImp.pdf", as(pdf) replace
twoway (line ma2_stanford_tc2 year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_python_tc2 year, sort lcolor(black) lpattern(longdash)) (line ma2_rtt_tc2 year, sort lcolor(black) lpattern(dot)) (line ma2_hc_tc2 year, lcolor(black)) , xtitle("") ytitle(Proportion General Economic) ytitle("(2 yr. moving avg.)",suffix) ylabel(#5)  xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Stanford NLP  ({it:r} =.74)" 2 "Python  ({it:r} =.70)" 3 "RTextTools      ({it:r} =.74)" 4 "Hand Coded") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "All_methods_TC_2.pdf", as(pdf) replace
twoway (line ma2_stanford_tc3 year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_python_tc3 year, sort lcolor(black) lpattern(longdash)) (line ma2_rtt_tc3 year, sort lcolor(black) lpattern(dot)) (line ma2_hc_tc3 year, lcolor(black)) , xtitle("") ytitle(Proportion Irrelevant) ytitle("(2 yr. moving avg.)",suffix) ylabel(#5)  xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Stanford NLP  ({it:r} =.93)" 2 "Python  ({it:r} =.91)" 3 "RTextTools      ({it:r} =.91)" 4 "Hand Coded") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "All_methods_TC_3.pdf", as(pdf) replace
twoway (line ma2_hc_tc3 year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_hc_tc2 year, sort lcolor(black) lpattern(dot)) (line ma2_hc_tc1 year, lcolor(black)) , xtitle("") ytitle(Proportion of All Articles) ytitle("(2 yr. moving avg.)",suffix) ylabel(#5)  xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(3 "Explicit/Implicit" 2 "General Economic" 1 "Irrelevant") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "F1 Three Code Hand-Coded.pdf", as(pdf) replace

corr hc_exp_pct topic_pct
corr ma2_topic_pct ma2_hc_pct
twoway (line ma2_topic_pct year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_hc_pct year, lcolor(black)) , ytitle("Proportion Explicit Inequality") ytitle("(2 yr. moving avg.)", suffix) xtitle("") ylabel(#5) xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Topic Model ({it:r} = .58)" 2 "Hand-Coded Explicit") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "F6 Topic_Model.pdf", as(pdf) replace

twoway (line ma2_dict_pct year, sort lcolor(black) lpattern(dash)) (line ma2_hc_pct year, lcolor(black) lpattern(dot)) (line ma2_dict_pct_les year, sort lcolor(black) lpattern(shortdash_dot)) (line ma2_hc_pct_les year, lcolor(black)), xtitle("") ytitle(" Proportion Inequality") ytitle("(2 yr. moving avg.)", suffix) ylabel(#5) xlabel(1980(5)2010) ylabel(0(.2)1) legend(cols(2) symxsize(11) order(1 "Dictionary Levay-Enns ({it:r} =.42)" 2 "Hand-Coded Explicit" 3 "Dictionary McCall ({it:r} =.62)" 4 "Hand-Coded Explicit/Implicit") region(lpattern (blank)) position(6)) graphregion(fcolor(white)) 
graph export "F2 Dictionary Analysis.pdf", as(pdf) replace


