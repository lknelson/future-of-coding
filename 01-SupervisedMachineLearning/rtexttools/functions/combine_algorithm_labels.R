combine_algorithm_labels <- function(results_datatable, tie_break_order) {
    # unit test
    {
    
    # > test_dt = data.table(MAXENT_LABEL = c(4, 5, 5, 1, 2), SVM_LABEL = c(3, 5, 5, 3, 2), RF_LABEL = c(4, 4, 5, 2, 1), code = c(3, 5, 4, 1, 2), year = c(1980, 1980, 1990, 1990, 1990))
    # > test_dt
    #    MAXENT_LABEL SVM_LABEL RF_LABEL code year
    # 1:            4         3        4    3 1980
    # 2:            5         5        4    5 1980
    # 3:            5         5        5    4 1990
    # 4:            1         3        2    1 1990
    # 5:            2         2        1    2 1990
    # > combine_algorithm_labels(test_dt, 5:1)
    # [1] "4" "5" "5" "3" "2"
    }    
    
    require(data.table)
    
    get_matrix_of_algorithm_labels = function(results_datatable) {
        # data.table -> matrix of character vectors
        # unit tests
        {
        # > get_matrix_of_algorithm_labels(test_dt)
        #      MAXENT_LABEL SVM_LABEL RF_LABEL
        # [1,] "4"          "3"       "4"     
        # [2,] "5"          "5"       "4"     
        # [3,] "5"          "5"       "5"     
        # [4,] "1"          "3"       "2"     
        # [5,] "2"          "2"       "1"
        }
        label_column_indices = grep("_LABEL$", names(results_datatable))
        out = as.matrix(results_datatable)
        out = out[ , label_column_indices]
        if(is.matrix(out)) out = apply(out, 2, as.character)
        else out = as.matrix(as.character(out)) # need to return a matrix even if there is only one vector of labels
        return(out)
    }
    
    get_mode = function(vector, tie_break_order) {
        # vector -> single character value
        # unit tests
        {
        # in cases with more than one modal value, use tie_break_order to choose
        # > get_mode(c(4, 3, 4))
        # [1] "4"
        # > get_mode(c(5, 5, 4))
        # [1] "5"
        # > get_mode(c(5, 5, 5))
        # [1] "5"
        # > get_mode(c(1, 3, 2))
        # [1] "3"
        # > get_mode(c(2, 2, 1))
        # [1] "2"
        }
        freq_table = table(vector)
        modal_values = names(freq_table)[which(freq_table==max(freq_table))]
        if(length(modal_values) > 1) {
            get_first_in_tie_break_order = function(modal_values) {
                names(sort(sapply(modal_values, function(x) which(tie_break_order==x))))[1]
            }
            return(get_first_in_tie_break_order(modal_values))
        }
        else return(modal_values)
    }
    
    get_machine_coded_category = function(matrix_of_algorithm_labels, tie_break_order) {
        # matrix of character vectors -> character vector
        # unit tests
        {
        # > get_machine_coded_category(get_matrix_of_algorithm_labels(test_dt))
        # [1] "4" "5" "5" "3" "2"
        }
        return(apply(matrix_of_algorithm_labels, 1, get_mode, tie_break_order))
    }
    
    # Fix NNET labels
    if(length(setdiff(results_datatable$NNET_LABEL, results_datatable$label)) > 0) {
        nnet_labels <- levels(factor(results_datatable$NNET_LABEL))
        correct_labels <- levels(factor(results_datatable$label))
        results_datatable[ , NNET_LABEL := recode(NNET_LABEL, paste0(nnet_labels, "='", correct_labels, "'", collapse="; "))]       
    }
    
    
    return(get_machine_coded_category(get_matrix_of_algorithm_labels(results_datatable), tie_break_order))
}