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
#' @param ... Character strings to match the search.
#'
#' @return A \code{tibble} with the indicators' name and the respective \code{Quandl} code.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' # oil search
#' fq_wb_search(query = 'oil')
#'
#' # The function is case insensitive
#' fq_wb_search(query = 'EDuCAtion')
fq_wb_search <- function(...) {

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


  # get the table
  search_wb_tbl <- tibble::tibble(
    database = c(
      'governance',
      'development',
      'public',
      'poverty',
      "Millennium Development Goals",
      "Jobs for Knowledge Platform",
      "International Development Association",
      "Health Nutrition and Population Statistics",
      "Bank Global Findex (Global Financial Inclusion database)",
      "Global Financial Development",
      "GEP Economic Prospects",
      "Gender Statistics",
      "Global Economic Monitor",
      "Global Economic Monitor (GEM) Commodities",
      "Global Development Finance",
      "Enterprise Surveys",
      "Education Statistics",
      "Doing Business",
      "Corporate Scorecard",
      "Africa Development Indicators"
    ),


    source    = c(
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwgi_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwdi_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpsd_indicators',
      'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpov_indicators',
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wmdg_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wjkp_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wida_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/whnp_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wglf_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgfd_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgep_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgen_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgem_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgec_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wgdf_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wesv_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wedu_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wdbu_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wcsc_indicators",
      "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wadi_indicators"
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
    tidyr::unnest(.data$download) %>%
    dplyr::rename_all(.funs = stringr::str_to_lower) %>%
    dplyr::select(.data$indicator, .data$code, .data$database) %>%
    dplyr::filter(

      purrr::map(
        .x = stringr::str_to_lower(.data$indicator),
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
  if (nrow(search_wb_tbl) == 0) {

    if (length(.dots) == 1) {

      message("I was not possible to identify the query ", crayon::cyan(.dots), " in the World Bank database.")

    } else {

      message("It was not possible to find any indicator that matches the queries requested.")
      purrr::iwalk(.dots, ~ cat(.y, ":", crayon::cyan(.x), ".", "\n", sep = ""))
      message("Try just one of them in isolation, them refine your search.")

    }

    # otherwise return the output
  } else {

    return(search_wb_tbl)

  }


}

