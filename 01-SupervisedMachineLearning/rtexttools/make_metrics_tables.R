library(data.table)

cur_dir <- getwd()
setwd("01-SupervisedMachineLearning/rtexttools")

source("functions/get_accuracy_mtrx.R")
source("functions/load_results_and_create_summary_matrix.R")
source("functions/load_results_and_create_single_matrix.R")

relevant_vs_irrelevant_summary_mtrx <- load_results_and_create_summary_matrix(
    "relevant_vs_irrelevant/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"))

inequality_vs_not_inequality_summary_mtrx <- load_results_and_create_summary_matrix(
    "inequality_vs_not_inequality/results/classification_results_all_training_sets.Rdata", 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"))

inequality_vs_economic_vs_irrelevant_summary_mtrx <- load_results_and_create_summary_matrix(
    "inequality_vs_economic_vs_irrelevant/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "relchanges/releconomy", "explicit/implicit"))

relevant_vs_irrelevant_trset_10 <- load_results_and_create_single_matrix(
    "relevant_vs_irrelevant/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "explicit/implicit/relchanges/releconomy"), 10)

inequality_vs_not_inequality_trset_10 <- load_results_and_create_single_matrix(
    "inequality_vs_not_inequality/results/classification_results_all_training_sets.Rdata", 
    c("relchanges/releconomy/irrelevant", "explicit/implicit"), 10)

inequality_vs_economic_vs_irrelevant_trset_10 <- load_results_and_create_single_matrix(
    "inequality_vs_economic_vs_irrelevant/results/classification_results_all_training_sets.Rdata", 
    c("irrelevant", "relchanges/releconomy", "explicit/implicit"), 10)

for(tbl in c("relevant_vs_irrelevant_summary_mtrx", "inequality_vs_not_inequality_summary_mtrx", 
             "inequality_vs_economic_vs_irrelevant_summary_mtrx", "relevant_vs_irrelevant_trset_10", 
             "inequality_vs_not_inequality_trset_10", "inequality_vs_economic_vs_irrelevant_trset_10")) {
    write.csv(get(tbl), file=paste0("results/", tbl, ".csv"))
}

setwd(cur_dir)
