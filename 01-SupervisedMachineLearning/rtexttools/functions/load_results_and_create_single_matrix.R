load_results_and_create_single_matrix <- function(results_path, labels_in_tie_break_order, trset_number) {
    require(data.table)
    weight <- data.table(read.csv("data/final_fixed_w_trsets_and_codes.csv", stringsAsFactors=FALSE))[ , .(id, weight)]
    setkey(weight, id)
    load(results_path)
    results <- list_of_classification_results_from_each_training_set[[trset_number]]
    setkey(results, id)
    results <- weight[results]
    get_accuracy_mtrx(results, labels_in_tie_break_order)
}