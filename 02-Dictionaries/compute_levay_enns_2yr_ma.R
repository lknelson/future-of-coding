library(tidyverse)

d <- read_csv("output/time_trend_by_one_mention_and_ppn_keywords.csv")

d <- set_names(d, c("year", "kw_per_1000", "pct_w_kw", "pct_explicit"))

d %>%
    mutate(
        pct_w_kw_lag = c(NA_real_, head(pct_w_kw, -1)),
        ppn_w_kw_ma = (pct_w_kw + pct_w_kw_lag) / 200
    ) %>%
    select(year, ppn_w_kw_ma) %>%
    as.data.frame()