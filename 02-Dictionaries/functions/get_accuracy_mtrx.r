get_accuracy_mtrx = function(results_datatable, dict_codes_variable, hand_codes_variable, tie_break_order) {
    
    # data.table -> matrix 
    # matrix has colnames precision, recall, f1, support, and trend_correlation, and row names 1:5, "avg_sum"
    
    # > test_dt = data.table(MAXENT_LABEL = c(4, 5, 5, 1, 2), SVM_LABEL = c(3, 5, 5, 3, 2), RF_LABEL = c(4, 4, 5, 2, 1), code = c(3, 5, 4, 1, 2), year = c(1980, 1980, 1990, 1990, 1990))
    # > test_dt
    #    MAXENT_LABEL SVM_LABEL RF_LABEL code year
    # 1:            4         3        4    3 1980
    # 2:            5         5        4    5 1980
    # 3:            5         5        5    4 1990
    # 4:            1         3        2    1 1990
    # 5:            2         2        1    2 1990
    # > round(get_accuracy_mtrx(test_dt, labels=), 2)
    #           precision   recall     f1     support    trend correlation
    # 1               NaN        0    NaN           1                   NA
    # 2                 1        1      1           1                    1
    # 3                 0        0    NaN           1                   -1
    # 4                 0        0    NaN           1                   -1
    # 5               0.5        1   0.67           1                    1
    # overall         NaN      NaN    NaN           5                   NA
    
    get_precision = function(tp, fp) {
        # two integer values -> single numeric value
        # > get_precision(0, 0)
        # [1] NaN
        # > get_precision(1, 0)
        # [1] 1
        # > get_precision(0, 1)
        # [1] 0
        # > get_precision(0, 1)
        # [1] 0
        # > get_precision(1, 1)
        # [1] 0.5
        return(tp/(tp+fp))
    }
    
    get_recall = function(tp, fn) {
        # two integer values -> single numeric value
        # > get_recall(0, 1)
        # [1] 0
        # > get_recall(1, 0)
        # [1] 1
        # > get_recall(0, 1)
        # [1] 0
        # > get_recall(0, 1)
        # [1] 0
        # > get_recall(1, 0)
        # [1] 1
        return(tp/(tp+fn))
    }
    
    get_f1 = function(precision, recall) {
        # two integer values -> single numeric value
        # > get_f1(NaN, 0)
        # [1] NaN
        # > get_f1(1, 1)
        # [1] 1
        # > get_f1(0, 0)
        # [1] NaN
        # > get_f1(0, 0)
        # [1] NaN
        # > get_f1(0.5, 1)
        # [1] 0.6666667
        return(2*precision*recall/(precision + recall))
    }
    
    get_support = function(tp, fn) {
        # two integer values -> single integer value
        # > get_support(0, 1)
        # [1] 1
        # > get_support(1, 0)
        # [1] 1
        # > get_support(0, 1)
        # [1] 1
        # > get_support(0, 1)
        # [1] 1
        # > get_support(1, 0)
        # [1] 1
        return(tp + fn)
    }
    
    get_tp = function(hand_coded_logical, dict_coded_logical) {
        # two logical vectors -> single integer value
        # > get_tp(c(FALSE, FALSE, FALSE, TRUE, FALSE), c(FALSE, FALSE, FALSE, FALSE, FALSE))
        # [1] 0
        # > get_tp(c(FALSE, FALSE, FALSE, FALSE, TRUE), c(FALSE, FALSE, FALSE, FALSE, TRUE))
        # [1] 1  
        # > get_tp(c(TRUE, FALSE, FALSE, FALSE, FALSE), c(FALSE, FALSE, FALSE, TRUE, FALSE))
        # [1] 0
        # > get_tp(c(FALSE, FALSE, TRUE, FALSE, FALSE), c(TRUE, FALSE, FALSE, FALSE, FALSE))
        # [1] 0
        # > get_tp(c(FALSE, TRUE, FALSE, FALSE, FALSE), c(FALSE, TRUE, TRUE, FALSE, FALSE))
        # [1] 1
        out = 0
        for(i in 1:length(hand_coded_logical)) {
            if(hand_coded_logical[i] & dict_coded_logical[i]) out = out + 1
        }
        return(out)
    }
    
    get_fp = function(hand_coded_logical, dict_coded_logical) {
        # two logical vectors -> single integer value
        # > get_fp(c(FALSE, FALSE, FALSE, TRUE, FALSE), c(FALSE, FALSE, FALSE, FALSE, FALSE))
        # [1] 0
        # > get_fp(c(FALSE, FALSE, FALSE, FALSE, TRUE), c(FALSE, FALSE, FALSE, FALSE, TRUE))
        # [1] 0     
        # > get_fp(c(TRUE, FALSE, FALSE, FALSE, FALSE), c(FALSE, FALSE, FALSE, TRUE, FALSE))
        # [1] 1
        # > get_fp(c(FALSE, FALSE, TRUE, FALSE, FALSE), c(TRUE, FALSE, FALSE, FALSE, FALSE))
        # [1] 1
        # > get_fp(c(FALSE, TRUE, FALSE, FALSE, FALSE), c(FALSE, TRUE, TRUE, FALSE, FALSE))
        # [1] 1
        out = 0
        for(i in 1:length(hand_coded_logical)) {
            if(!hand_coded_logical[i] & dict_coded_logical[i]) out = out + 1
        }
        return(out)
    }
    
    get_fn = function(hand_coded_logical, dict_coded_logical) {
        # two logical vectors -> single integer value
        # > get_fn(c(FALSE, FALSE, FALSE, TRUE, FALSE), c(FALSE, FALSE, FALSE, FALSE, FALSE))
        # [1] 1
        # > get_fn(c(FALSE, FALSE, FALSE, FALSE, TRUE), c(FALSE, FALSE, FALSE, FALSE, TRUE))
        # [1] 0     
        # > get_fn(c(TRUE, FALSE, FALSE, FALSE, FALSE), c(FALSE, FALSE, FALSE, TRUE, FALSE))
        # [1] 1
        # > get_fn(c(FALSE, FALSE, TRUE, FALSE, FALSE), c(TRUE, FALSE, FALSE, FALSE, FALSE))
        # [1] 1
        # > get_fn(c(FALSE, TRUE, FALSE, FALSE, FALSE), c(FALSE, TRUE, TRUE, FALSE, FALSE))
        # [1] 0
        out = 0
        for(i in 1:length(hand_coded_logical)) {
            if(hand_coded_logical[i] & !dict_coded_logical[i]) out = out + 1
        }
        return(out)
    }
    
    get_hand_coded_logical = function(category, hand_codes_variable) {
        # character/integer value and character/integer vector -> logical vector
        # > get_hand_coded_logical(1, test_dt$code)
        # [1] FALSE FALSE FALSE TRUE FALSE        
        # > get_hand_coded_logical(2, test_dt$code)
        # [1] FALSE FALSE FALSE FALSE TRUE
        # > get_hand_coded_logical(3, test_dt$code)
        # [1] TRUE FALSE FALSE FALSE FALSE
        # > get_hand_coded_logical(4, test_dt$code)
        # [1] FALSE FALSE TRUE FALSE FALSE
        # > get_hand_coded_logical(5, test_dt$code)
        # [1] FALSE TRUE FALSE FALSE FALSE        
        return(hand_codes_variable==category)
    }
    
    get_dict_coded_logical = function(category, dict_codes_variable) {
        # character/integer value and character vector -> logical vector
        # > get_dict_coded_logical(1, as.character(c(4, 5, 5, 3, 2)))
        # [1] FALSE FALSE FALSE FALSE FALSE
        # > get_dict_coded_logical(2, as.character(c(4, 5, 5, 3, 2)))
        # [1] FALSE FALSE FALSE FALSE TRUE
        # > get_dict_coded_logical(3, as.character(c(4, 5, 5, 3, 2)))
        # [1] FALSE FALSE FALSE TRUE FALSE
        # > get_dict_coded_logical(4, as.character(c(4, 5, 5, 3, 2)))
        # [1] TRUE FALSE FALSE FALSE FALSE
        # > get_dict_coded_logical(5, as.character(c(4, 5, 5, 3, 2)))
        # [1] FALSE TRUE TRUE FALSE FALSE        
        return(dict_codes_variable==category)
    }
    
    get_time_corr = function(hand_coded_logical, dict_coded_logical) {
        # two logical vectors -> single numeric value (correlation)
        # > get_time_corr(c(FALSE, FALSE, FALSE, TRUE, FALSE), c(FALSE, FALSE, FALSE, FALSE, FALSE))
        # [1] NA        
        # > get_time_corr(c(FALSE, FALSE, FALSE, FALSE, TRUE), c(FALSE, FALSE, FALSE, FALSE, TRUE))
        # [1] 1
        # > get_time_corr(c(TRUE, FALSE, FALSE, FALSE, FALSE), c(FALSE, FALSE, FALSE, TRUE, FALSE))
        # [1] -1
        # > get_time_corr(c(FALSE, FALSE, TRUE, FALSE, FALSE), c(TRUE, FALSE, FALSE, FALSE, FALSE))
        # [1] -1        
        # > get_time_corr(c(FALSE, TRUE, FALSE, FALSE, FALSE), c(FALSE, TRUE, TRUE, FALSE, FALSE))
        # [1] 1
        get_hand_coded_proportion_by_year = function(hand_coded_logical) {
            # logical vector -> numeric vector
            # > get_hand_coded_proportion_by_year(c(FALSE, FALSE, FALSE, TRUE, FALSE))
            # [1] 0 0.333333
            # > get_hand_coded_proportion_by_year(c(FALSE, FALSE, FALSE, FALSE, TRUE))
            # [1] 0 0.333333
            # > get_hand_coded_proportion_by_year(c(TRUE, FALSE, FALSE, FALSE, FALSE))
            # [1] 0.5 0
            # > get_hand_coded_proportion_by_year(c(FALSE, FALSE, TRUE, FALSE, FALSE))
            # [1] 0 0.333333                 
            # > get_hand_coded_proportion_by_year(c(FALSE, TRUE, FALSE, FALSE, FALSE))
            # [1] 0.5 0
            hand_coded_logical_by_year = data.table(year=results_datatable$year, weight=results_datatable$weight, hand_coded_logical = hand_coded_logical)
            proportion_by_year = hand_coded_logical_by_year[ , sum(weight[hand_coded_logical])/sum(weight), by=year]
            setorder(proportion_by_year, year)
            return(proportion_by_year$V1)
        }		
        
        get_dict_coded_proportion_by_year = function(dict_coded_logical) {
            # logical vector -> numeric vector
            # > get_dict_coded_proportion_by_year(c(FALSE, FALSE, FALSE, FALSE, FALSE))
            # [1] 0 0            
            # > get_dict_coded_proportion_by_year(c(FALSE, FALSE, FALSE, FALSE, TRUE))
            # [1] 0 0.333333
            # > get_dict_coded_proportion_by_year(c(FALSE, FALSE, FALSE, TRUE, FALSE))
            # [1] 0 0.333333
            # > get_dict_coded_proportion_by_year(c(TRUE, FALSE, FALSE, FALSE, FALSE))
            # [1] 0.5 0
            # > get_dict_coded_proportion_by_year(c(FALSE, TRUE, TRUE, FALSE, FALSE))
            # [1] 0.5 0.333333
            
            dict_coded_logical_by_year = data.table(year=results_datatable$year, weight=results_datatable$weight, dict_coded_logical = dict_coded_logical)
            proportion_by_year = dict_coded_logical_by_year[ , sum(weight[dict_coded_logical])/sum(weight), by=year]
            setorder(proportion_by_year, year)
            return(proportion_by_year$V1)
        }
        
        hand_coded_proportion_by_year = get_hand_coded_proportion_by_year(hand_coded_logical)
        dict_coded_proportion_by_year = get_dict_coded_proportion_by_year(dict_coded_logical)
        
        return(cor(hand_coded_proportion_by_year, dict_coded_proportion_by_year))
    }
    
    labels = rev(tie_break_order)
    hand_coded_logical = sapply(labels, get_hand_coded_logical, hand_codes_variable) # should return matrix with a column for each code
    dict_coded_logical = sapply(labels, get_dict_coded_logical, dict_codes_variable)
    
    tp = sapply(labels, function(x) get_tp(hand_coded_logical[,x], dict_coded_logical[,x])) # should return a length-5 vector of counts
    fp = sapply(labels, function(x) get_fp(hand_coded_logical[,x], dict_coded_logical[,x])) # "
    fn = sapply(labels, function(x) get_fn(hand_coded_logical[,x], dict_coded_logical[,x])) # "
    
    precision = sapply(labels, function(x) get_precision(tp[x], fp[x]), USE.NAMES=FALSE)
    recall = sapply(labels, function(x) get_recall(tp[x], fn[x]), USE.NAMES=FALSE)
    f1 = sapply(labels, function(x) get_f1(precision[x], recall[x]), USE.NAMES=FALSE)
    support = sapply(labels, function(x) get_support(tp[x], fn[x]), USE.NAMES=FALSE)
    trend_correlation = sapply(labels, function(x) get_time_corr(hand_coded_logical[,x], dict_coded_logical[,x]), USE.NAMES=FALSE)
    accuracy_mtrx = cbind(precision, recall, f1, support, trend_correlation)
    
    overall_precision = sum(precision*support)/sum(support)
    overall_recall = sum(recall*support)/sum(support)
    overall_f1 = sum(f1*support)/sum(support)
    sum_support = sum(support)
    avg_correlation = sum(trend_correlation*support)/sum(support)
    
    overall = c(overall_precision, overall_recall, overall_f1, sum_support, avg_correlation)
    
    accuracy_mtrx = rbind(accuracy_mtrx, overall)
    dimnames(accuracy_mtrx) = list(c(labels, "overall"), c("precision", "recall", "f1", "support", "trend_correlation"))
    return(accuracy_mtrx)
}