#' Search for the IMF indicators avaiable in Quandl.
#'
#' It covers 44 indicators used in the World Economic Outlook and Fiscal Monitor.
#'
#' The full list of indicators can be seem here: \url{https://www.quandl.com/data/ODA-IMF-Cross-Country-Macroeconomic-Statistics/documentation/data-organization}.
#'
#' @param query A character string.
#' @param print_all Logical vector. TRUE if you want to overwrite the tibble printing format.
#'
#' @return A \code{tibble} with the indicators' name and the respective \code{Quandl} code.
#' @export
#'
#' @examples
#' # indicators with the 'gdp' letters.
#' imf_search('gdp')
#'
#' # prints only the first 10 results.
#' # the function is case insensitive
#' imf_search('goVERnment', print_all = FALSE)
imf_search <- function(query, print_all = TRUE) {

  if (rlang::is_missing(query)) {
    stop('Must provide a query.')
  }

  # to diminish mistakes
  query <- stringr::str_to_lower(query) %>%
    stringr::str_trim(., side = 'both')

  search_imf_tbl <- readr::read_csv(
    file = "data-raw/imf_datasets.csv",
    col_types = readr::cols(
      `Indicator Code` = readr::col_character(),
      `Indicator Name` = readr::col_character()
    )
  ) %>%
    dplyr::rename(
      indicator = `Indicator Name`,
      code      = `Indicator Code`
    ) %>%
    dplyr::mutate(indicator = stringr::str_to_lower(indicator))


  # filter search
  if (length(query) == 1) {

    search_imf_tbl <- search_imf_tbl %>%
      dplyr::filter(stringr::str_detect(
        string  = indicator,
        pattern = query
        )
      )

  } else {

    query <- query %>%
      stringr::str_flatten(., collapse = '|')

    search_imf_tbl <- search_imf_tbl %>%
      dplyr::filter(stringr::str_detect(
        string  = indicator,
        pattern = query
        )
      )

  }

  # output
  if (print_all) {
    print(search_imf_tbl, n = Inf)
  } else {
    print(search_imf_tbl, n = 10)
  }

}




