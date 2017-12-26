library(data.table)
library(stringr)
library(knitr)

cur_dir <- getwd()
setwd("02-Dictionaries")

# Helper functions
apply_word_boundaries <- function(strings) paste0("\\b", strings, "s*\\b") # allow optional "s" at end of word

remove_punctuation <- function(texts) {
    sapply(texts, function(x) {
        x <- str_replace_all(x, regex("[^\\s\\w]"), " ") # replace punctuation with a space
        x <- str_replace_all(x, "\\s+", " ") # replace multiple adjacent spaces with one space
        return(x)
    }, USE.NAMES=FALSE)
}

word_count <- function(texts) sapply(str_split(texts, " "), length)

pattern_count <- function(texts, pattern) sapply(str_extract_all(texts, pattern), length)

calculate_kw_count <- function(texts, kws) {
    kws <- apply_word_boundaries(kws)
    texts <- remove_punctuation(texts)
    kw_lengths <- word_count(kws)
    pattern_count_mtrx <- sapply(kws, function(x) pattern_count(texts, x))
    kw_word_count_by_text <- apply(kw_lengths*t(pattern_count_mtrx), 2, sum)
    return(kw_word_count_by_text)
}

# Load data
d <- data.table(read.csv("final_fixed_w_trsets_and_codes.csv", stringsAsFactors=FALSE))

# Input dictionaries
levay <- tolower(c("Economic disparities", "Economic disparity", "Economic distribution", "Economic equality", "Economic inequalities", "Economic inequality", "Economic insecurity", "Employment insecurity", "Equal economic outcomes", "Equal income", "Equal pay", "Equal wage", "Equal wealth", "Equality of economic outcomes", "Income difference", "Income differential", "Income disparities", "Income disparity", "Income distribution", "Income equality", "Income gap", "Income inequalities", "Income inequality", "Inequality of economic outcomes", "Job insecurity", "Pay difference", "Pay differential", "Pay equality", "Pay gap", "Pay inequality", "Unequal economic outcomes", "Unequal economy", "Unequal income", "Unequal pay", "Unequal wage", "Unequal wealth", "Wage difference", "Wage differential", "Wage disparities", "Wage disparity", "Wage equality", "Wage gap", "Wage inequalities", "Wage inequality", "Wealth difference", "Wealth differential", "Wealth disparities", "Wealth disparity", "Wealth distribution", "Wealth equality", "Wealth gap", "Wealth inequalities", "Wealth inequality", "Economic divide", "Income divide", "Pay divide", "Wage divide", "Wealth divide"))

enns <- tolower(c("Gini", "income quintile", "income decile", "top incomes", "inegalitarian income", "inegalitarian wealth", "egalitarian income", "egalitarian wealth", "income disparity", "wealth disparity", "income disparities", "wealth disparities", "income stratification", "wealth stratification", "unequal income", "unequal wealth", "income inequality", "wealth inequality", "inequality of income", "inequality of incomes", "inequality of wealth", "income equality", "wealth equality", "equality of incomes", "equality of income", "equality of wealth", "income distribution", "wealth distribution", "distribution of income", "distribution of incomes", "distribution of wealth", "redistribution of income", "redistribution of incomes", "redistribution of wealth", "income redistribution", "wealth redistribution", "equitable income", "equitable wealth", "equitable distribution", "inequitable income", "inequitable wealth", "inequitable distribution", "equity of incomes", "equity of income", "equity of wealth", "equity in incomes", "equity in income", "equity in wealth", "equality of incomes", "equality of income", "equality of wealth", "concentration of income", "concentration of wealth", "income concentration", "wealth concentration", "equalize incomes", "equalize income", "equalize wealth", "equalizing incomes", "equalizing income", "equalizing wealth", "income equalization", "wealth equalization", "unequal income", "unequal incomes", "unequal wealth", "inequity of incomes", "inequity of wealth", "income inequity", "wealth inequity", "uneven distribution", "income polarization", "wealth polarization", "distributional", "maldistribution"))

all <- unique(c(levay, enns))

# Calculate weighted count of words in each article comprised by keywords
d[ , levay_count := weight*calculate_kw_count(tolower(text), levay)]
d[ , enns_count := weight*calculate_kw_count(tolower(text), enns)]
d[ , all_count := weight*calculate_kw_count(tolower(text), all)]

# Calculate keywords per 1,000 words in each year, using article weights
d[ , wtd_word_count := weight*word_count(text)]

setkey(d, year)

levay_count_by_year <- d[ , 1000*sum(levay_count)/sum(wtd_word_count), by=key(d)]
enns_count_by_year <- d[ , 1000*sum(enns_count)/sum(wtd_word_count), by=key(d)]
all_count_by_year <- d[ , 1000*sum(all_count)/sum(wtd_word_count), by=key(d)]

# Calculate percent of articles in each year hand-coded as explicit or either explicit or implicit
pct_explicit_by_year <- d[ , 100*sum((five_code=="explicit")*weight)/sum(weight), by=key(d)]
pct_implicit_or_explicit_by_year <- d[ , 100*sum((five_code %in% c("explicit", "implicit"))*weight)/sum(weight), by=key(d)]

# Calculate proportion of words comprised by keywords for articles in each hand-coded category, using article weights
kw_count_by_code <- d[ , list(levay=1000*sum(levay_count)/sum(wtd_word_count), 
                              enns=1000*sum(enns_count)/sum(wtd_word_count), 
                              all=1000*sum(all_count)/sum(wtd_word_count)),
                              by="five_code"]

kw_count_by_code <- kw_count_by_code[sapply(c("explicit", "implicit", "relchanges", "releconomy", "irrelevant"), function(x) which(five_code==x)), ] # Sort from most relevant to inequality to least

kw_count_by_code_table <- round(t(as.matrix(kw_count_by_code[ , .(levay, enns, all)])), 2)
dimnames(kw_count_by_code_table) <- list(c("Levay", "Enns", "Combined"), kw_count_by_code$five_code)

# Calculate proportions within articles hand-coded as explicit
# explicit_levay_count_by_year <- d[five_code=="explicit", 1000*sum(levay_count)/sum(wtd_word_count), by=key(d)]
# 
# explicit_enns_count_by_year <- d[five_code=="explicit", 1000*sum(enns_count)/sum(wtd_word_count), by=key(d)]
# 
# explicit_all_count_by_year <- d[five_code=="explicit", 1000*sum(all_count)/sum(wtd_word_count), by=key(d)]


# Calculate proportions within articles hand-coded as explicit or implicit
# ineq_levay_count_by_year <- d[five_code %in% c("explicit", "implicit"), 1000*sum(levay_count)/sum(wtd_word_count), by=key(d)]
# 
# ineq_enns_count_by_year <- d[five_code %in% c("explicit", "implicit"), 1000*sum(enns_count)/sum(wtd_word_count), by=key(d)]
# 
# ineq_all_count_by_year <- d[five_code %in% c("explicit", "implicit"), 1000*sum(all_count)/sum(wtd_word_count), by=key(d)]


# Create a dummy variable indicating whether article has at least one keyword
d[ , one_mention := all_count > 0]

# Save a copy of d with one mention articles flagged
out <- d[ , .(year, title, month, five_code, weight, one_mention, text)]
write.csv(out, file="output/levay_enns_dictionary_results.csv", row.names = FALSE)


one_mention_by_year <- d[ , 100*sum(one_mention*weight)/sum(weight), by=key(d)]

# Save percent explicit and percent w/ one mention by year as csv to send to Marcel
setkey(pct_explicit_by_year, year)
setkey(one_mention_by_year, year)

out <- one_mention_by_year[pct_explicit_by_year]
setnames(out, names(out), c("Year", "% With at Least One Keyword", "% Coded as Explicit"))

# write.csv(out, file="output/explicit and one-mention by year.csv", row.names = FALSE)

# Save all_count_by_year to construct time trend by proportion of keywords
# (rather than proportion of articles with one mention)
setnames(all_count_by_year, c("year", "V1"), c("Year", "Keywords per 1,000 Words"))
setkey(all_count_by_year, Year)
out <- all_count_by_year[out]

# png(filename = "output/time_trend_by_one_mention_and_ppn_keywords.png",
#     width=800, height=600)
# par(mar=c(5, 4, 4, 4))
# plot(out[ , .(Year, `% Coded as Explicit`)], type="l", lty=1, ylim=c(0, 55), 
#      ylab="% Coded as Explicit / % with One Keyword", 
#      main="Time trend in coverage of inequality")
# lines(out[ , .(Year, `% With at Least One Keyword`)], lty=2)
# par(new=TRUE, ann=FALSE)
# plot(out[ , .(Year, `Keywords per 1,000 Words`)], type="l", lty=3, axes=F, 
#      ylim=c(0, 0.41))
# axis(side=4)
# mtext("Keywords per 1,000 Words", side=4, line=2)
# legend(2002, 0.41, c("% Coded as Explicit", "% with One Keyword", 
#                      "Keywords per 1,000 Words"), 
#        lty=1:3)
# dev.off()

cor(out)

write.csv(out, file="output/time_trend_by_one_mention_and_ppn_keywords.csv",
          row.names = FALSE)
rm(out)

# Save table of precision, recall, and F1 for one keyword as indicator of explicit article
source("functions/get_accuracy_mtrx.r")
d[ , dict_explicit := ifelse(one_mention, "explicit", "not explicit")]
d[ , hand_explicit := ifelse(five_code=="explicit", "explicit", "not explicit")]
out <- get_accuracy_mtrx(d, d$dict_explicit, d$hand_explicit, c("not explicit", "explicit"))
write.csv(out, file="output/metrics_for_levay_enns_dict_as_indicator_of_explicit_article.csv")
rm(out)

setwd(cur_dir)