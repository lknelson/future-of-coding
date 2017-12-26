get_2yr_moving_avg <- function(x) {
  x_lag <- c(NA_real_, head(x, -1))
  (x + x_lag) / 2
}