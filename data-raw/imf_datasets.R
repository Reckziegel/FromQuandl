library(readxl)

imf_datasets <- readxl::read_excel(
  "R/imf_datasets.xlsx",
  col_names = c('.names', '.indicators')
)

save(imf_datasets, file = 'data/imf_datasets.rdata')
