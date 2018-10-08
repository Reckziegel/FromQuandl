#' Search for the World Bank indicators avaiable in Quandl.
#'
#' It covers 1309 indicators spread among the Governance, Development, Poverty and Public Sector databases.
#'
#' The full list of indicators can be seen in the following links:
#'
#' \itemize{
#'     \item Governance: \url{https://www.quandl.com/data/WWGI-World-Bank-Worldwide-Governance-Indicators/documentation/data-organization}
#'     \item Development: \url{https://www.quandl.com/data/WWDI-World-Bank-World-Development-Indicators/documentation/data-organization}
#'     \item Poverty: \url{https://www.quandl.com/data/WPOV-World-Bank-Poverty-Statistics/documentation/data-organization}
#'     \item Public Sector: \url{https://www.quandl.com/data/WPSD-World-Bank-Public-Sector-Debt}
#'}
#'
#' @param query A vector or a list of character strings.
#' @param print_all Logical vector. If TRUE the all the results will be printed overwriting the standard \code{tibble} format.
#'
#' @return A \code{tibble} with the indicators' name and the respective \code{Quandl} code.
#'
#' @export
#'
#' @examples
#' # oil search
#' wb_search(query = 'oil')
#'
#' # The function is case insensitive
#' wb_search(query = 'EDuCAtion')
wb_search <- function(query, print_all = TRUE) {

  if (rlang::is_missing(query)) {
    stop('Must provide a query.')
  }


  query <- stringr::str_to_lower(query) %>%
    stringr::str_trim(., side = 'both')


  search_wb_tbl <- tibble::tibble(
    indicator = c('governance', 'development', 'public', 'poverty'),
    source    = c(
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwgi_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwdi_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpsd_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpov_indicators'
      )
    ) %>%
    dplyr::mutate(download = purrr::map(
      .x            = source,
      .f            = readr::read_delim,
      delim         = "|",
      escape_double = FALSE,
      trim_ws       = TRUE,
      col_types = readr::cols(
        CODE      = readr::col_character(),
        INDICATOR = readr::col_character())
      )
    )

  search_wb_tbl <- search_wb_tbl %>%
    tidyr::unnest(download) %>%
    dplyr::select(INDICATOR, CODE) %>%
    dplyr::mutate(
      INDICATOR   = stringr::str_to_lower(INDICATOR),
      user_filter = stringr::str_detect(string = INDICATOR, pattern = query)
      ) %>%
    dplyr::filter(user_filter == TRUE) %>%
    dplyr::select(INDICATOR, CODE) %>%
    dplyr::rename(indicator = 'INDICATOR', code = 'CODE')


  if (print_all) {
    print(search_wb_tbl, n = Inf)
  } else {
    search_wb_tbl
  }

}


