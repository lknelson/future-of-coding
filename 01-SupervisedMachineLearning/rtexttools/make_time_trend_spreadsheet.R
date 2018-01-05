#################################################
# Make spreadsheet with time trend for tr_set10 #
#################################################


# Load relevant_vs_irrelevant, inequality_vs_not_inequality, and inequality_vs_economic_vs_irrelevant results
# Use combine_algorithm_labels function to get machine code for each scheme for
#     trset_10
# Load "data/final_fixed_w_trsets_and_codes.csv"
# Merge all the data on id variable, adding rel_vs_irrel_machine, inequality_vs_not_inequality_machine,
#     and ineq_vs_econ_vs_irrel_machine variables to original dataset
# Create dataset with weighted proportion:
#     not irrelevant for relevant_vs_irrelevant (hand and machine),
#     explicit/implicit for inequality_vs_not_inequality (hand and machine),
#     explicit/implicit for inequality_vs_economic_vs_irrelevant (hand and machine), 
#     relchanges/releconomy for inequality_vs_economic_vs_irrelevant (hand and machine).
# Save dataset as csv.

library(data.table)

cur_dir <- getwd()
setwd("01-SupervisedMachineLearning/rtexttools")

source("functions/combine_algorithm_labels.R")

load("relevant_vs_irrelevant/results/classification_results_all_training_sets.Rdata")
relevant_vs_irrelevant <- list_of_classification_results_from_each_training_set[[10]]

load("inequality_vs_not_inequality/results/classification_results_all_training_sets.Rdata")
inequality_vs_not_inequality <- list_of_classification_results_from_each_training_set[[10]]

load("inequality_vs_economic_vs_irrelevant/results/classification_results_all_training_sets.Rdata")
inequality_vs_economic_vs_irrelevant <- list_of_classification_results_from_each_training_set[[10]]

rm(list_of_classification_results_from_each_training_set)


relevant_vs_irrelevant[ , rel_vs_irrel_machine := combine_algorithm_labels(relevant_vs_irrelevant, 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"))]

relevant_vs_irrelevant <- relevant_vs_irrelevant[ , .(id, rel_vs_irrel_machine)]

inequality_vs_not_inequality[ , ineq_vs_not_ineq_machine := combine_algorithm_labels(inequality_vs_not_inequality, 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"))]

inequality_vs_not_inequality <- inequality_vs_not_inequality[ , .(id, ineq_vs_not_ineq_machine)]

inequality_vs_economic_vs_irrelevant[ , ineq_vs_econ_vs_irrel_machine := combine_algorithm_labels(inequality_vs_economic_vs_irrelevant, c("irrelevant", "relchanges/releconomy", "explicit/implicit"))]

inequality_vs_economic_vs_irrelevant <- inequality_vs_economic_vs_irrelevant[ , .(id, ineq_vs_econ_vs_irrel_machine)]

d <- data.table(read.csv("data/final_fixed_w_trsets_and_codes.csv", stringsAsFactors=FALSE))

setkey(relevant_vs_irrelevant, id)
setkey(inequality_vs_not_inequality, id)
setkey(inequality_vs_economic_vs_irrelevant, id)
setkey(d, id)

d <- relevant_vs_irrelevant[inequality_vs_not_inequality[inequality_vs_economic_vs_irrelevant]][d]

d[is.na(rel_vs_irrel_machine), rel_vs_irrel_machine := binary1]
d[is.na(ineq_vs_not_ineq_machine), ineq_vs_not_ineq_machine := binary2]
d[is.na(ineq_vs_econ_vs_irrel_machine), ineq_vs_econ_vs_irrel_machine := three_code2]

setorder(d, year)

out <- d[ , .(two_code_relevant_hand_code_ppn = 
                  sum(weight[binary1=="explicit/implicit/relchanges/releconomy"])/sum(weight),
              
              two_code_relevant_machine_code_ppn = 
                  sum(weight[rel_vs_irrel_machine=="explicit/implicit/relchanges/releconomy"])/sum(weight),
         
              two_code_inequality_hand_code_ppn = 
                  sum(weight[binary2=="explicit/implicit"])/sum(weight),
              
              two_code_inequality_machine_code_ppn = 
                  sum(weight[ineq_vs_not_ineq_machine=="explicit/implicit"])/sum(weight),
              
              three_code_inequality_hand_code_ppn = 
                  sum(weight[three_code2=="explicit/implicit"])/sum(weight),
              
              three_code_inequality_machine_code_ppn = 
                  sum(weight[ineq_vs_econ_vs_irrel_machine=="explicit/implicit"])/sum(weight),
              
              three_code_economic_hand_code_ppn = 
                  sum(weight[three_code2=="relchanges/releconomy"])/sum(weight),
              
              three_code_economic_machine_code_ppn = 
                  sum(weight[ineq_vs_econ_vs_irrel_machine=="relchanges/releconomy"])/sum(weight)
              
              ), by=year]

write.csv(out, file="results/RTT_time_trend_data.csv", row.names=FALSE)

# Test set only
out <- d[trset_10 == 0, .(two_code_relevant_hand_code_ppn = 
                sum(weight[binary1=="explicit/implicit/relchanges/releconomy"])/sum(weight),
              
              two_code_relevant_machine_code_ppn = 
                sum(weight[rel_vs_irrel_machine=="explicit/implicit/relchanges/releconomy"])/sum(weight),
              
              two_code_inequality_hand_code_ppn = 
                sum(weight[binary2=="explicit/implicit"])/sum(weight),
              
              two_code_inequality_machine_code_ppn = 
                sum(weight[ineq_vs_not_ineq_machine=="explicit/implicit"])/sum(weight),
              
              three_code_inequality_hand_code_ppn = 
                sum(weight[three_code2=="explicit/implicit"])/sum(weight),
              
              three_code_inequality_machine_code_ppn = 
                sum(weight[ineq_vs_econ_vs_irrel_machine=="explicit/implicit"])/sum(weight),
              
              three_code_economic_hand_code_ppn = 
                sum(weight[three_code2=="relchanges/releconomy"])/sum(weight),
              
              three_code_economic_machine_code_ppn = 
                sum(weight[ineq_vs_econ_vs_irrel_machine=="relchanges/releconomy"])/sum(weight)
              
), by=year]

write.csv(out, file="results/RTT_time_trend_data_test_set_only.csv", row.names=FALSE)

setwd(cur_dir)
