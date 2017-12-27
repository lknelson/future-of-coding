library(data.table)

source("functions/get_accuracy_mtrx.r")
source("functions/load_results_and_create_summary_matrix.r")
source("functions/load_results_and_create_single_matrix.r")

binary1_summary_mtrx <- load_results_and_create_summary_matrix(
    "binary1big/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"))

binary2_summary_mtrx <- load_results_and_create_summary_matrix(
    "binary2/results/classification_results_all_training_sets.Rdata", 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"))

three_code2_summary_mtrx <- load_results_and_create_summary_matrix(
    "three_code2/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "relchanges/releconomy", "explicit/implicit"))

binary1_trset_10 <- load_results_and_create_single_matrix(
    "binary1big/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"), 10)

binary2_trset_10 <- load_results_and_create_single_matrix(
    "binary2/results/classification_results_all_training_sets.Rdata", 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"), 10)

three_code2_trset_10 <- load_results_and_create_single_matrix(
    "three_code2/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "relchanges/releconomy", "explicit/implicit"), 10)

for(tbl in c("binary1_summary_mtrx", "binary2_summary_mtrx", 
             "three_code2_summary_mtrx", "binary1_trset_10", 
             "binary2_trset_10", "three_code2_trset_10")) {
    write.csv(get(tbl), file=paste0("results/", tbl, ".csv"))
}