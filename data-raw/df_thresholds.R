## code to prepare `DATASET` dataset goes here

library(idmc)
library(tidyverse)

df <- idmc_get_data() %>%
  filter(
    created_at <= as.Date("2022-12-31")
  ) %>%
  idmc_transform_daily() %>%
  idmc_rolling_sum()

# check 95th percentile by group and time frame

df %>%
  group_by(
    displacement_type
  ) %>%
  summarize(
    across(
      .cols = starts_with("displacement"),
      .fns = ~ quantile(x = .x, probs = .95, na.rm = TRUE)
    )
  )

# based on these, set reasonable thresholds for weekly, monthly, quarterly, and yearly
# that are below the 95th percentile at rounded numbers
df_thresholds <- data.frame(
  weekly = c(5000, 1000, NA_real_),
  monthly = c(25000, 5000, 20),
  quarterly = c(100000, 50000, 750),
  yearly = c(500000, 300000, 15000),
  row.names = c("Conflict", "Disaster", "Other")
)

usethis::use_data(df_thresholds, overwrite = TRUE)
