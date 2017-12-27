load_results_and_create_summary_matrix <- function(results_path, labels_in_tie_break_order) {
    require(data.table)
    load(results_path)
    weight <- data.table(read.csv("data/final_fixed_w_trsets_and_codes.csv", stringsAsFactors=FALSE))[ , .(id, weight)]
    setkey(weight, id)
    results <- lapply(list_of_classification_results_from_each_training_set, function(x) {
        setkey(x, id)
        return(weight[x])
    })
    # get accuracy matrices
    accuracy_matrices = lapply(results, get_accuracy_mtrx, tie_break_order = labels_in_tie_break_order)
    # create summary matrix
    avg_matrix = round(Reduce("+", accuracy_matrices)/25, 2)
    matrix_with_accuracy_matrices_as_rows = Reduce(rbind, lapply(accuracy_matrices, as.vector))
    min_matrix = round(matrix(apply(matrix_with_accuracy_matrices_as_rows, 2, min), ncol=5), 2)
    max_matrix = round(matrix(apply(matrix_with_accuracy_matrices_as_rows, 2, max), ncol=5), 2)
    summary_matrix = matrix(paste0(as.vector(avg_matrix), " (", as.vector(min_matrix), "-", as.vector(max_matrix), ")"), ncol=5)
    dimnames(summary_matrix) = dimnames(accuracy_matrices[[1]])
    return(summary_matrix)
}