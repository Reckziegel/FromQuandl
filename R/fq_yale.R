#' Yale Department of Economics
#'
#' Publishes data related to the stock and housing markets; price data for common indexes, interest rates, earnings, dividends, house prices, and CPI.
#'
#' Data provided for the US economy only.
#'
#' @param indicators A vector or a list of character strings.
#' @param verbose Should warning messages be printed? Default is \code{TRUE}.
#' @param ... Additional arguments to be passed into \code{Quandl} function.
#'
#' @return A tidy \code{tibble} with five columns: \code{date}, \code{code}, \code{indicator}, \code{description} and \code{value}.
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' # Ten-Year Average of Real Earnings for US Stock Data
#' fq_yale("SP_10YRE")
fq_yale <- function(indicators, verbose = TRUE, ...) {


  # checking errors
  if (purrr::is_null(indicators)) {
    stop('Must provide an indicator.')
  }
  assertthat::assert_that(assertthat::is.flag(verbose))

  # tidy eval
  dots_expr <- dplyr::enquos(...)

  # check if order = 'asc'
  if ((!purrr::is_null(dots_expr[['order']])) && dots_expr[['order']][[2]] != "asc" && verbose) {

    warning(
      "To keep consistency with other tidy functions it will be set ", crayon::green("order = 'asc'."),
      immediate. = TRUE
    )

    dots_expr[["order"]] <- NULL

  }

  # to avoid simple msitakes
  indicators <- stringr::str_to_upper(indicators) %>%
    stringr::str_trim(., side = 'both')


  database <- yale_data %>%
    dplyr::filter(.data$code %in% indicators) %>%
    dplyr::mutate(quandl_code = stringr::str_c('YALE/', .data$code))


  # error handler
  possible_quandl <- purrr::possibly(Quandl::Quandl, NA)

  # data wrangling
  database <- database %>%
    tidyr::nest(data = .data$quandl_code) %>%

    # map the selected code thought the diserided countries
    dplyr::mutate(
      download = purrr::map(
        .x = .data$data,
        .f = ~ possible_quandl(.x$quandl_code, order = 'asc', !!! dots_expr)
      ),

      # exclude the countries in which the indicator is not avaiable
      verify_download = purrr::map_lgl(
        .x = .data$download,
        .f = ~ !is.logical(.x)
      )
    )

  # send a message informing if the downloads worked as expected
  if (any(dplyr::select(database, .data$verify_download) == FALSE)) {

    if (all(dplyr::select(database, .data$verify_download) == FALSE)) {

      stop('All downloads have failed.', call. = FALSE)

    } else {

      if (verbose) {

        warn_tbl <- database %>%
          dplyr::filter(.data$verify_download == FALSE)

        for (i in 1:nrow(warn_tbl)) {

          warning(
            stringr::str_c(
              "Indicator ", crayon::cyan(warn_tbl$code[[i]]), " has failed. \n"
            ),
            immediate. = TRUE
          )

        }

      }

    }

  } else {

    message('All downloads have succeeded.')

  }

  # final manipulation
  database <- database %>%
    dplyr::filter(.data$verify_download == TRUE)

  if (nrow(database) == 0) {

    if (!purrr::is_empty(dots_expr)) {

      stop(
        "It was not possible to complete the download. \n",
        "Please check if the arguments passed to ... are valid ones. Maybe there is a typo."
      )

    }

    stop("It was not possible to complete the download. Please try it again!")

  } else {

    database %>%
      dplyr::mutate(
        download = purrr::map(
          .x = .data$download,
          .f = ~ dplyr::rename(
            .data  = .x,
            date   = 1,
            value  = 2
          )
        )
      ) %>%
      tidyr::unnest(.data$download) %>%
      dplyr::mutate_if(purrr::is_character, forcats::as_factor) %>%
      dplyr::select(.data$date, .data$code:.data$name, .data$value) %>%
      dplyr::rename(indicator = .data$name)

  }


}




