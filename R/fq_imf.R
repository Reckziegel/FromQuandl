#' Download IMF data using Quandl API
#'
#' A wrapper around \code{Quandl}. Downloads macroeconomic data for several indicators and countries covered by the IMF.
#'
#' The \code{countries} argument can be passed as an ISO code or as a country name. The only requirement is that the call must be consistent (must contain only ISO codes or country names, but not both).
#'
#' Sometimes the user may be interested in downloading data for certain regions, like Europe, Latin America, Middle East, etc. For that reason, the countries argument also accepts the following calls:
#'
#' \itemize{
#'   \item 'ae'     - Advanced Economics
#'   \item 'asean5' - Asean Top 5
#'   \item 'cis'    - Commonwealth and Independent States
#'   \item 'eda'    - Emerging and Developing Asia
#'   \item 'ede'    - Emerging and Developing Economies
#'   \item 'edeuro' - Emerging and Developing Europe
#'   \item 'euro'   - Euro Area
#'   \item 'eu'     - European Union
#'   \item 'g7'     - G7
#'   \item 'latam'  - Latin America & Caribbean
#'   \item 'me'     - Middle East
#'   \item 'oae'    - Other Advanced Economies
#'   \item 'ssa'    - Sub Saharan Africa
#'}
#'
#' For any of those calls the \code{fq_imf()} will download data for all the countries in the requested region. A complete region list can be seen at: \url{https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/groups.htm}.
#'
#' The \code{...} argument can be used to calibrate the query parameters. It accepts the following calls:
#'\itemize{
#'  \item \code{start_date}: \code{'YYYY-MM-DD'}
#'  \item \code{end_date}: \code{'YYYY-MM-DD'}
#'  \item \code{collapse}: \code{c("", "daily", "weekly", "monthly", "quarterly", "annual")}
#'  \item \code{transform}: \code{c("", "diff", "rdiff", "normalize", "cumul", "rdiff_from")}
#'}
#'
#' The full list can be seen at: \url{https://docs.quandl.com/docs/r}.
#'
#' @param countries A vector or a list of character strings.
#' @param indicators A vector or a list of character strings.
#' @param verbose Should warning messages be printed? Default is \code{TRUE}.
#' @param ... Additional arguments to be passed into \code{Quandl} function.
#'
#' @return A tidy \code{tibble} with four columns: \code{date}, \code{country}, \code{indicator} and \code{value}.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' # Download the Savings and the Current Account for all countries in the G7
#' fq_imf(countries = 'g7', indicators = c('NGSD_NGDP', 'BCA_NGDPD'))
#'
#' # Download the US Output Gap
#' fq_imf('United States', 'NGAP_NPGDP')
#'
#' # The example above is identical to
#' # fq_imf('USA', 'NGAP_NPGDP')
fq_imf <- function(countries, indicators, verbose = TRUE, ...) {

  # checking errors
  if (purrr::is_null(indicators)) {
    stop('Must provide an indicator.')
  } else if (purrr::is_null(countries)) {
    stop('Must provide a country or a group of countries.')
  }


  # tidy eval
  dots_expr <- dplyr::quos(...)

  # check if order = 'asc'
  if ((!purrr::is_null(dots_expr[['order']])) && dots_expr[['order']][[2]] != "asc" && verbose) {

    warning("To keep consistency with other tidy functions it will be set ", crayon::green("order = 'asc'."))

    dots_expr[["order"]] <- NULL

  }

  # to avoid simple msitakes
  indicators <- stringr::str_to_upper(indicators) %>%
    stringr::str_trim(., side = 'both')


  # read the country files
  safe_read     <- purrr::safely(readr::read_delim)

  country_codes <- suppressMessages(safe_read(
    file          = "https://s3.amazonaws.com/quandl-production-static/API+Descriptions/WHO/ccodes.txt",
    delim         = "|",
    escape_double = FALSE,
    col_names     = c('iso', 'country'),
    trim_ws       = TRUE
  )
  )

  country_codes <- country_codes[['result']]


  # Must the data be filtered by country? If yes, do this:
  regions <- c('ae', 'oae', 'euro', 'eu', 'ede', 'g7', 'cis', 'dea', 'asean5', 'edeuro', 'latam', 'me', 'ssa')

  # if an ISO code is supplied
  if (max(stringr::str_count(countries)) <= 3 && !(stringr::str_to_lower(countries) %in% regions)) {

    countries <- stringr::str_to_upper(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(.data[["iso"]] %in% as.vector(countries))

    # if a region is supplied
  } else if (any(countries %in% regions)) {

    country_codes <- country_codes %>%
      dplyr::filter(.data[["country"]] %in% country_groups(countries))

    # if a country name is supplied
  } else if (any(stringr::str_to_title(countries) %in% country_codes[["country"]])) {

    countries <- stringr::str_to_title(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(.data[["country"]] %in% as.vector(countries))

    # if all countries are selected
  } else if (countries == 'all') {

    country_codes <- country_codes

    # error
  } else {

    stop('Country not covered by World Bank.')

  }

  database <- imf_datasets %>%
    dplyr::filter(.data$imf_code %in% indicators) %>%
    tidyr::crossing(country_codes) %>%
    dplyr::mutate(quandl_code = stringr::str_c('ODA/', .data$iso, '_', .data$imf_code))


  # error handler
  possible_quandl <- purrr::possibly(Quandl::Quandl, NA)

  # data wrangling
  database <- database %>%
    tidyr::nest(.data$quandl_code) %>%

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

      stop('All downloads have failed.')

    } else {

      if (verbose) {

        warn_tbl <- database %>%
          dplyr::filter(.data$verify_download == FALSE)

        for (i in 1:nrow(warn_tbl)) {

          warning(
            stringr::str_c(
              "Indicator ", crayon::cyan(warn_tbl$imf_name[[i]]),
              " for the country ", crayon::yellow(warn_tbl$country[[i]]),
              " has failed. \n"
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

      stop("It was not possible to complete the download. \n",
           "Please check if the arguments passed to ... are valid ones. Maybe there is a typo.")

    }

    stop("It was not possible to complete the download. Please try it again!")

  } else {

    database %>%
      tidyr::unnest(.data$download) %>%
      dplyr::mutate_if(purrr::is_character, forcats::as_factor) %>%
      dplyr::select(.data$Date, .data$country, .data$imf_name, .data$Value) %>%
      dplyr::rename(date = "Date", indicator = "imf_name", value = "Value")

  }

}
