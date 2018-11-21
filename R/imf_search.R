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
#'
#' @importFrom rlang .data
#'
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

  search_imf_tbl <- imf_datasets %>%
    dplyr::mutate(imf_name = stringr::str_to_lower(.data[["imf_name"]]))

  # filter search
  if (length(query) == 1) {

    search_imf_tbl <- search_imf_tbl %>%
      dplyr::filter(stringr::str_detect(
        string  = .data[["imf_name"]],
        pattern = query
        )
      )

  } else {

    query <- query %>%
      stringr::str_flatten(., collapse = '|')

    search_imf_tbl <- search_imf_tbl %>%
      dplyr::filter(stringr::str_detect(
        string  = .data[["imf_name"]],
        pattern = query
        )
      )

  }

  if (nrow(search_imf_tbl) == 0) {

    warning("I was not possible to identify the pattern ", query, " in the IMF database.")

  }

  # output
  if (print_all) {

    print(search_imf_tbl, n = Inf)

  } else {

    print(search_imf_tbl, n = 10)

  }

}




