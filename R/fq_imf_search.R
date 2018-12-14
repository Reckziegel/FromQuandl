#' Search for the IMF indicators avaiable in Quandl.
#'
#' It covers 44 indicators used in the World Economic Outlook and Fiscal Monitor.
#'
#' The full list of indicators can be seem here: \url{https://www.quandl.com/data/ODA-IMF-Cross-Country-Macroeconomic-Statistics/documentation/data-organization}.
#'
#' @param ... Character strings to match the desired search.
#'
#' @return A \code{tibble} with the indicators' name and the respective \code{Quandl} code.
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' # indicators with the 'gdp' letters.
#' fq_imf_search('gdp')
#'
#' # the function is case insensitive
#' fq_imf_search('goVERnment', "ReveNUE")
fq_imf_search <- function(...) {

  .dots <- list(...)

  # error handling
  verify_dots <- .dots %>%
    purrr::every(purrr::is_character)

  if (!verify_dots) {
    stop("The ... must be composed solely of character vectors.")
  }

  if (purrr::is_empty(.dots)) {
    stop("Must provide a query.")
  }


  # Avoid mistakes by trimming and lowering
  .pattern <- purrr::map_chr(
    .x = .dots,
    .f = ~ stringr::str_to_lower(.x) %>%
      stringr::str_trim(side = "both")
  )


  # filter
  imf_datasets_filtered <- imf_datasets %>%
    dplyr::filter(

      purrr::map(
        .x = stringr::str_to_lower(.data$imf_name),
        .f = ~ stringr::str_detect(
          string  = .x,
          pattern = .pattern
        )
      ) %>%
        purrr::map_lgl(
          .x = .,
          .f = ~ TRUE %in% . & !(FALSE %in% .)
        )

    )


  # if there is no match for the requested query send a message
  if (nrow(imf_datasets_filtered) == 0) {

    if (length(.dots) == 1) {

      message("I was not possible to identify the query ", crayon::cyan(.dots), " in the IMF database.")

    } else {

      message("It was not possible to find any indicator that matches the queries requested.")
      purrr::iwalk(.dots, ~ cat(.y, ":", crayon::cyan(.x), ".", "\n", sep = ""))
      message("Try just one of them in isolation, them refine your search.")

    }

    # otherwise return the output
  } else {

    return(imf_datasets_filtered)

  }


}




