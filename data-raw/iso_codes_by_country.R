library(readr)

iso_codes_by_country <- readr::read_delim(
  file = 'https://s3.amazonaws.com/quandl-production-static/API+Descriptions/WHO/ccodes.txt',
  delim         = "|",
  escape_double = FALSE,
  col_names     = c('.iso', '.country'),
  col_types     = list(
    readr::col_factor(levels = NULL),
    readr::col_factor(levels = NULL)),
  trim_ws       = TRUE
)

save(iso_codes_by_country, file = 'data/iso_codes_by_country.rdata')
