# load packages
library(RTextTools)
library(data.table)
library(stringr)

# create functions
train_model_and_classify_test_set_with_it = function(container, algorithm, trset_name) {
    cat(paste0(trset_name, " ", algorithm, ": "))
    saved_trained_model = paste0(algorithm, ".Rdata")
    saved_classification_results = paste0(algorithm, "_classification_results.Rdata")
    trset_results_dir = paste0("results/", trset_name, "/")
    if(saved_classification_results %in% list.files(trset_results_dir)) {
        cat("Found saved results.\n")
        load(paste0(trset_results_dir, saved_classification_results)) # loads object "classification_results"
    }
    else {
        if(saved_trained_model %in% list.files("trained_models")) {
            cat("Loading trained model... ")
            load(paste0("trained_models/", saved_trained_model)) # loads object "model"
        }
        else {
            model = 0
            cat("Training model... ")
            try(model <- train_model(container, algorithm))
            if(class(model)=="numeric") return(NA)
            save(model, file=paste0("trained_models/", saved_trained_model))
        }
        cat("Classifying... ")
        classification_results = data.table(modified_classify_model(container, model))
        save(classification_results, file=paste0(trset_results_dir, saved_classification_results))
        cat("Done.\n")
        file.remove(paste0("trained_models/", saved_trained_model))
    }
    setnames(classification_results, names(classification_results), paste0(algorithm, c("_LABEL", "_PROB")))
    classification_results[] = lapply(classification_results, function(x) {if(is.factor(x)) as.character(x) else x})
    return(classification_results)
}

# I had to modify the classify_model function because of problems arising with the NNET procedure when there are only 2 categories
load("functions/modified_classify_model.Rdata")

# Don't use this, because we are sticking to built-in options, just use built-in punctuation remover
remove_punctuation <- function(texts) {
    sapply(texts, function(x) {
        x <- str_replace_all(x, perl("[^\\s\\w]"), " ") # replace punctuation with a space
        x <- str_replace_all(x, "\\s+", " ") # replace multiple adjacent spaces with one space
        return(x)
    }, USE.NAMES=FALSE)
}

# Also don't use this
remove_common_words <- function(text_matrix, maxDocFrequency=.95) {
    threshold <- maxDocFrequency*text_matrix$nrow
    docFrequency <- table(text_matrix$j)
    to_keep <- as.numeric(names(docFrequency)[docFrequency < threshold])
    indices_to_keep <- text_matrix$j %in% to_keep
    text_matrix$i <- text_matrix$i[indices_to_keep]
    text_matrix$j <- text_matrix$j[indices_to_keep]
    text_matrix$v <- text_matrix$v[indices_to_keep]
    text_matrix$dimnames[[2]] <- text_matrix$dimnames[[2]][to_keep]
    text_matrix$ncol <- length(to_keep)
    return(text_matrix)
}

# run main program

# here we load/create the main dataset and text_matrix in tandem to ensure that the articles are in the same order in each
if("newsweekly_articles_and_text_matrix.Rdata" %in% list.files("data")) {
    load("data/newsweekly_articles_and_text_matrix.Rdata") # loads objects "newsweekly_articles" and "text_matrix"
} else {
    newsweekly_articles = 
data.table(read.csv("data/final_fixed_w_trsets_and_codes.csv", 
stringsAsFactors=FALSE))
    text_matrix = create_matrix(newsweekly_articles$text, minWordLength=1, 
                                stemWords=FALSE, removePunctuation=TRUE, removeStopwords=TRUE,
                                weighting=tm::weightTfIdf, removeSparseTerms=.995)
    save(newsweekly_articles, text_matrix, file="data/newsweekly_articles_and_text_matrix.Rdata")
}

list_of_classification_results_from_each_training_set = vector(mode="list", length=25)

matrix_of_trainingsets = apply(as.matrix(newsweekly_articles)[ , grep("trset_", names(newsweekly_articles))], 2, as.integer)

algorithms = list("SVM", 
                  #"SLDA", 
                  "BOOSTING", "BAGGING", "RF", "GLMNET", "TREE", "NNET", "MAXENT")

for(i in 1:25) {
    dir.create(paste0("results/trset_", i), showWarnings = FALSE)
    training_set = which(matrix_of_trainingsets[ , i] == 1)
    test_set = which(matrix_of_trainingsets[ , i] == 0)
    label_variable = newsweekly_articles$three_code2
    container = create_container(text_matrix, labels = label_variable, trainSize = training_set, testSize = test_set, virgin=FALSE)
    classification_results = lapply(algorithms, function(a) train_model_and_classify_test_set_with_it(container, a, paste0("trset_", i)))
    classification_results = Filter(is.data.table, classification_results) # remove NAs from models that didn't converge
    classification_results = Reduce(data.table, classification_results)
    classification_results = data.table(newsweekly_articles[test_set, list(id, year)], label=label_variable[test_set], classification_results)
    list_of_classification_results_from_each_training_set[[i]] = classification_results
}

save(list_of_classification_results_from_each_training_set, file="results/classification_results_all_training_sets.Rdata")
