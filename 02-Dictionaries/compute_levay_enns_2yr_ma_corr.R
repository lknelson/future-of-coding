library(tidyverse)

cur_dir <- getwd()
setwd("02-Dictionaries")

d <- read_csv("output/time_trend_by_one_mention_and_ppn_keywords.csv")

d <- set_names(d, c("year", "kw_per_1000", "pct_w_kw", "pct_explicit"))

d %>%
    mutate(
        pct_w_kw_ma = get_2yr_moving_avg(pct_w_kw), 
        pct_explicit_ma = get_2yr_moving_avg(pct_explicit)
    ) %>%
    with(cor(pct_w_kw_ma, pct_explicit_ma, use = "pairwise"))

setwd(cur_dir)