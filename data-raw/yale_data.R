library(tidyverse)

# data downloaded from: https://www.quandl.com/data/YALE-Yale-Department-of-Economics/usage/export

yale_data <- readr::read_csv("YALE_metadata.csv") %>%
  dplyr::select(1:3)

# save data
usethis::use_data(wb_indicators, country_codes, imf_country_groups, imf_datasets, yale_data,
                  internal = TRUE, overwrite = TRUE)

