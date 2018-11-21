library(tidyverse)

# read the country files
safe_read <- purrr::safely(readr::read_delim)

country_codes <- suppressMessages(
  safe_read(
    file          = "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/country_codes",
    delim         = "|",
    escape_double = FALSE,
    trim_ws       = TRUE
  )
)


if (purrr::is_null(country_codes[['result']])) {

  stop("Error while downloading country codes. Please, try again!")

} else {

  country_codes <- country_codes[['result']] %>%
    dplyr::rename(country = 'COUNTRY', iso = 'CODE')

}


# start the downlaod
prefix <- list(
  'wwdi', # World Bank World Development Indicators
  'wwgi', # World Bank Worldwide Governance Indicators
  'wpsd', # World Bank Public Sector Debt
  'wpov', # World Bank Poverty Statistics
  'wmdg', # World Bank Millennium Development Goals
  'wjkp', # World Bank Jobs for Knowledge Platform
  'wida', # World Bank International Development Association
  'whnp', # World Bank Health Nutrition and Population Statistics
  'wglf', # World Bank Global Findex (Global Financial Inclusion database)
  'wgfd', # World Bank Global Financial Development
  'wgep', # World Bank GEP Economic Prospects
  'wgen', # World Bank Gender Statistics
  'wgem', # World Bank Global Economic Monitor
  'wgec', # World Bank Global Economic Monitor (GEM) Commodities
  'wgdf', # World Bank Global Development Finance
  'wesv', # World Bank Enterprise Surveys
  'wedu', # World Bank Education Statistics
  'wdbu', # World Bank Doing Business
  'wcsc', # World Bank Corporate Scorecard
  'wadi'  # World Bank Africa Development Indicators
)

files <- c(

  stringr::str_c('https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/', prefix, '_indicators')

)

wb_indicators <- suppressMessages(
  purrr::map(
    .x            = files,
    .f            = safe_read,
    delim         = "|",
    escape_double = FALSE,
    trim_ws       = TRUE
  )
) %>%
  purrr::transpose(.)

# verify if any of the downlaods haved failed
if (length(wb_indicators[['result']]) == length(prefix) && all(purrr::map_lgl(wb_indicators[['error']], purrr::is_null))) {

  # if not, add a columns with the prefix in the 'result' lists
  for (i in seq_along(prefix)) {

    wb_indicators[['result']][[i]] <- wb_indicators[['result']][[i]] %>%
      dplyr::mutate(prefix = prefix[[i]])

  }

  # bind them all
  wb_indicators <- wb_indicators %>%
    purrr::map_df(dplyr::bind_rows) %>%
    dplyr::mutate(prefix = stringr::str_to_upper(prefix)) %>%
    dplyr::rename(indicator = 'INDICATOR', code = 'CODE')

}


# save data
usethis::use_data(wb_indicators, country_codes, imf_country_groups, imf_datasets, internal = TRUE, overwrite = TRUE)
