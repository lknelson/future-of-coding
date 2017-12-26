remove_punctuation <- function(texts, exceptions) {
    # specify exceptions in a single string
    sapply(texts, function(x) {
        x <- str_replace_all(x, paste0("[^\\s\\w", exceptions, "]"), " ") # replace punctuation with a space
        x <- str_replace_all(x, "\\s+", " ") # replace multiple adjacent spaces with one space
        return(x)
    }, USE.NAMES=FALSE)
}