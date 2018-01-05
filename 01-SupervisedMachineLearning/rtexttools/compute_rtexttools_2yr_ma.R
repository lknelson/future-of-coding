library(tidyverse)

cur_dir <- getwd()
setwd("01-SupervisedMachineLearning/rtexttools/")

source("functions/get_2yr_moving_avg.R")

# Test set and training set
d <- read_csv("results/RTT_time_trend_data.csv")

corrs_yr_by_yr <- cor(select(d, -year), use = "pairwise")

d_2yr_moving_avgs <- d %>%
    mutate_at(vars(-year), get_2yr_moving_avg)

corrs_2yr_ma <- cor(select(d_2yr_moving_avgs, -year), use = "pairwise")

# Test set only
d_test_set_only <- read_csv("results/RTT_time_trend_data_test_set_only.csv")

corrs_yr_by_yr_test_set_only <- cor(select(d_test_set_only, -year), use = "pairwise")

d_2yr_moving_avgs_test_set_only <- d_test_set_only %>%
  mutate_at(vars(-year), get_2yr_moving_avg)

corrs_2yr_ma_test_set_only <- cor(select(d_2yr_moving_avgs_test_set_only, -year), use = "pairwise")

setwd(cur_dir)