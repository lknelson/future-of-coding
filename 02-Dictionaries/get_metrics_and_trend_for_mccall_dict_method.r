library(data.table)
library(stringr)


cur_dir <- getwd()
setwd("02-Dictionaries")

source("functions/remove_punctuation.r")
source("functions/get_accuracy_mtrx.r")

# Load newest data
texts <- data.table(read.csv("final_fixed_w_trsets_and_codes.csv", stringsAsFactors = FALSE))

# Remove punctuation
texts[ , text := remove_punctuation(text, exceptions="%")]

# Create function that returns a logical vector indicating whether a given
# document contains at least one of the patterns
has_any <- function(documents, patterns) {
    combined_patterns <- paste0(patterns, collapse="|")
    contains_pattern <- str_detect(documents, regex(combined_patterns, ignore_case = TRUE))
    return(contains_pattern)
}

# Create function that adds plural forms to a list of terms with following rules:
# 1. If a term ends in "y" preceded by a consonant, replace "y" with "ies"
# 2. If a term ends in "ch", "s", or "x", add "es" to the end
# 3. Otherwise, just add "s" to the end
add_plurals <- function(term_list) {
    plurals <- sapply(term_list, function(x) {
        if(str_detect(x, "[^aeiou]y$")) {
            return(str_replace(x, "y$", "ies"))
        } else if (str_detect(x, "ch$|s$|x$")) {
            return(paste0(x, "es"))
        } else {
            return(paste0(x, "s"))
        }
    }, USE.NAMES=FALSE)
    return(c(term_list, plurals))
}

# Create function to add word boundaries to beginning and end of strings
apply_word_boundaries <- function(strings) paste0("\\b", strings, "\\b")

# Get indices of articles with explicit distributive language

# 1. Distribution
patterns <- c("inequality", "equality", "unequal", "distribution", "gap", 
              "divide", "differential", "difference", "disparity", 
              "polarization", "dualism", "dual society", "equity", "inequity",
              "inequitable", "egalitarian", "inegalitarian", "concentration")

distribution <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# AND

# 2. Private income/wealth
patterns <- c("economic", "wage", "income", "earning", "pay", "compensation", 
              "benefit", "wealth", "asset", "stock return", "bonus", 
              "investment", "tax", "stock")

private <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# OR

# 3. Gov't income/wealth
patterns <- c("cash transfer", "non cash transfer", "welfare", "food stamp", 
              "unemployment insurance", "social security", "Medicaid", 
              "Medicare", "housing assistance", "public housing", 
              "earned income tax credit", "EITC", "social spending", 
              "social program", "redistribution", "redistributive")

govt <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# Explicit = distribution AND (private OR govt)
explicit <- distribution & (private | govt)



# Implicit

# 1. Social class groups

# Part 1
patterns <- c("top", "rich", "executive", "CEO", "affluent", "wealthy", 
              "wealthier", "wealthiest", "professional", "white collar", 
              "high income", "high wage", "high skill", "investor", 
              "upper class", "employer", "manager", "1%")

social_class1 <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# Part 2
patterns <- c("middle class", "blue collar", "middle income", "median wage", 
              "median earner", "average wage", "average earner", "union", 
              "99%")

social_class2 <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# Part 3
patterns <- c("poor", "worker", "minimum wage worker", "low income", 
              "lower class", "bottom", "low wage", "unemployed")

social_class3 <- has_any(texts$text, apply_word_boundaries(add_plurals(patterns)))

# Social class = (part 1 + part 2 + part 3) > 1
# part 1 AND (part 2 OR part 3)
social_class <- (social_class1 + social_class2 + social_class3) > 1

# Implicit = social class AND (private OR govt)
implicit <- social_class & (private | govt)


# Make explicit and implicit indicator variables
texts[ , dict_explicit := ifelse(explicit, "explicit", "not explicit")]
texts[ , dict_implicit := ifelse(implicit, "implicit", "not implicit")]
texts[ , hand_explicit := ifelse(five_code=="explicit", "explicit", "not explicit")]
texts[ , hand_implicit := ifelse(five_code=="implicit", "implicit", "not implicit")]
texts[ , dict_ineq := ifelse(explicit|implicit, "inequality", "not inequality")]
texts[ , hand_ineq := ifelse(five_code %in% c("explicit", "implicit"), 
                             "inequality", "not inequality")]


# Create metrics tables comparing:
# Explicit or implicit dict to explicit or implicit hand-coding

ineq_ineq_table <- get_accuracy_mtrx(texts, texts$dict_ineq, texts$hand_ineq, 
                                     c("not inequality", "inequality"))

write.csv(ineq_ineq_table, file="output/mccall_dict_explicit_or_implicit_metrics.csv")

# Get weighted proportions by year
out <- texts[ , .("hand_explicit"=sum(weight[five_code=="explicit"])/sum(weight), 
                  "dict_explicit"=sum(weight[dict_explicit=="explicit"])/sum(weight), 
                  "hand_implicit"=sum(weight[five_code=="implicit"])/sum(weight),
                  "dict_implicit"=sum(weight[dict_implicit=="implicit"])/sum(weight), 
                  "hand_explicit_or_implicit"=sum(weight[five_code %in% c("explicit", "implicit")])/sum(weight),
                  "dict_explicit_or_implicit"=sum(weight[dict_ineq=="inequality"])/sum(weight)), 
              by=year]

setorder(out, year)

write.csv(out, file="output/mccall_dict_proportions_by_year.csv", row.names=FALSE)

setwd(cur_dir)