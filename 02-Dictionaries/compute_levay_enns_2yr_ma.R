library(tidyverse)

cur_dir <- getwd()
setwd("02-Dictionaries")

source("functions/get_2yr_moving_avg.R")

d <- read_csv("output/time_trend_by_one_mention_and_ppn_keywords.csv")

d <- set_names(d, c("year", "kw_per_1000", "pct_w_kw", "pct_explicit"))

d %>%
    mutate(ppn_w_kw_ma = get_2yr_moving_avg(pct_w_kw) / 100) %>%
    select(year, ppn_w_kw_ma) %>%
    as.data.frame()

setwd(cur_dir)