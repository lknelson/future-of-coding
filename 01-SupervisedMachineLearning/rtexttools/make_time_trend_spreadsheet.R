#################################################
# Make spreadsheet with time trend for tr_set10 #
#################################################


# Load binary1, binary2, and threecode2 results
# Use combine_algorithm_labels function to get machine code for each scheme for
#     trset_10
# Load "data/final_fixed_w_trsets_and_codes.csv"
# Merge all the data on id variable, adding binary1_machine, binary2_machine,
#     and three_code2_machine variables to original dataset
# Create dataset with weighted proportion:
#     not irrelevant for binary1 (hand and machine),
#     explicit/implicit for binary2 (hand and machine),
#     explicit/implicit for three_code2 (hand and machine), 
#     relchanges/releconomy for three_code2 (hand and machine).
# Save dataset as csv.


library(data.table)

source("functions/combine_algorithm_labels.r")

load("binary1big/results/classification_results_all_training_sets.Rdata")
binary1 <- list_of_classification_results_from_each_training_set[[10]]

load("binary2/results/classification_results_all_training_sets.Rdata")
binary2 <- list_of_classification_results_from_each_training_set[[10]]

load("three_code2/results/classification_results_all_training_sets.Rdata")
three_code2 <- list_of_classification_results_from_each_training_set[[10]]

rm(list_of_classification_results_from_each_training_set)


binary1[ , binary1_machine := combine_algorithm_labels(binary1, 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"))]

binary1 <- binary1[ , .(id, binary1_machine)]

binary2[ , binary2_machine := combine_algorithm_labels(binary2, 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"))]

binary2 <- binary2[ , .(id, binary2_machine)]

three_code2[ , three_code2_machine := combine_algorithm_labels(three_code2, 
    c("irrelevant", "relchanges/releconomy", "explicit/implicit"))]

three_code2 <- three_code2[ , .(id, three_code2_machine)]

d <- data.table(read.csv("data/final_fixed_w_trsets_and_codes.csv", stringsAsFactors=FALSE))

setkey(binary1, id)
setkey(binary2, id)
setkey(three_code2, id)
setkey(d, id)

d <- binary1[binary2[three_code2]][d]

d[is.na(binary1_machine), binary1_machine := binary1]
d[is.na(binary2_machine), binary2_machine := binary2]
d[is.na(three_code2_machine), three_code2_machine := three_code2]

setorder(d, year)

out <- d[ , .(binary1_not_irrelevant_hand_code_ppn = 
                  sum(weight[binary1=="explicit/implicit/relchanges/releconomy"])/sum(weight),
              
              binary1_not_irrelevant_machine_code_ppn = 
                  sum(weight[binary1_machine=="explicit/implicit/relchanges/releconomy"])/sum(weight),
         
              binary2_exp_imp_hand_code_ppn = 
                  sum(weight[binary2=="explicit/implicit"])/sum(weight),
              
              binary2_exp_imp_machine_code_ppn = 
                  sum(weight[binary2_machine=="explicit/implicit"])/sum(weight),
              
              three_code2_exp_imp_hand_code_ppn = 
                  sum(weight[three_code2=="explicit/implicit"])/sum(weight),
              
              three_code2_exp_imp_machine_code_ppn = 
                  sum(weight[three_code2_machine=="explicit/implicit"])/sum(weight),
              
              three_code2_rel_rel_hand_code_ppn = 
                  sum(weight[three_code2=="relchanges/releconomy"])/sum(weight),
              
              three_code2_rel_rel_machine_code_ppn = 
                  sum(weight[three_code2_machine=="relchanges/releconomy"])/sum(weight)
              
              ), by=year]

write.csv(out, file="results/RTT_time_trend_data.csv", row.names=FALSE)
