#' Download World Bank Public Sector Data From Quandl
#'
#' A wrapper around \code{Quandl}. Download Public Sector data covered by the World Bank with just one line of code.
#'
#' The \code{countries} argument can be passed as an ISO code or as a country name. The only requirement is that the call must be consistent (must contain only ISO codes or only country names, but not both).
#'
#' Sometimes the user may be interested in downloading data for certain regions, like Europe, Latin America, Middle East, etc. For that reason, the countries argument also accepts the following calls:
#'
#' \itemize{
#'   \item 'ae'     - Advanced Economics
#'   \item 'asean_5'- Asean Top 5
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
#' For any of those calls the \code{wb_publicsector_from_quandl()} will download data for all the countries in the requested region. A complete region list can be seen at: \url{https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/groups.htm}.
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
#' @param ...  Additional parameters to be passed to the Quandl API.
#'
#' @return A tidy \code{tibble}.
#'
#' @importFrom magrittr %>%
#'
#' @export
#'
#' @examples
#' library(FromQuandl)
#'
#' # Downlaod Argentina Public Sector Debt at Market Value
#' wb_publicsector_from_quandl(countries = 'ARG', indicators = 'DP_DOD_DLDS_CR_MV_PS_CD')
#'
#' # Download the G7 standardize value for Debt Securities with maturity < 1 year.
#' wb_publicsector_from_quandl('g7', 'DP_DOD_DLDS_CR_L1_GG_CD', transform = 'normalize')
wb_publicsector_from_quandl <- function(countries, indicators, ...) {

  # checking errors
  if (purrr::is_null(indicators)) {
    stop('Must provide an indicator.')
  } else if (purrr::is_null(countries)) {
    stop('Must provide a country or a group of countries.')
  }

  # tidy eval
  dots_expr  <- dplyr::quos(order = 'asc', ...)

  # avoid errors
  indicators <- stringr::str_to_upper(indicators) %>%
    stringr::str_trim(., side = 'both')

  # read the country files
  country_codes <- list(result = NULL, error = NULL)
  safe_read     <- purrr::safely(readr::read_delim)
  n_tries       <- 0

  while (purrr::is_null(country_codes[['result']])) {

    country_codes <- suppressMessages(safe_read(
      file          = "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/country_codes",
      delim         = "|",
      escape_double = FALSE,
      trim_ws       = TRUE
    )
    )

    n_tries <- n_tries + 1

    if (n_tries > 1) {

      Sys.sleep(1)

      if (n_tries > 10) {

        warning('Download failed after 10 attemps. Check the intenet connection.')

        break

      }

    }

  }

  country_codes <- country_codes[['result']] %>%
    dplyr::rename(country = 'COUNTRY', iso = 'CODE')


  # start the downlaod
  wbi_indicators <- list(result = NULL, error = NULL)
  n_tries        <- 0

  while (purrr::is_null(wbi_indicators[['result']])) {

    wbi_indicators <- suppressMessages(safe_read(
      file          = 'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpsd_indicators',
      delim         = "|",
      escape_double = FALSE,
      trim_ws       = TRUE
    )
    )

    n_tries <- n_tries + 1

    if (n_tries > 1) {

      Sys.sleep(1)

      if (n_tries > 10) {

        warning('Download failed after 10 attemps. Check the intenet connection.')

        break

      }

    }

  }

  # select specific countries?
  regions <- c('ae', 'oae', 'euro', 'eu', 'ede', 'g7', 'cis', 'dea', 'asean_5', 'edeuro', 'latam', 'me', 'ssa')

  # if an ISO code is supplied
  if (max(stringr::str_count(countries)) <= 3 && !(stringr::str_to_lower(countries) %in% regions)) {

    countries <- stringr::str_to_upper(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(iso %in%  as.vector(countries))

    # if a region is supplied
  } else if (any(countries %in% regions)) {

    country_codes <- country_codes %>%
      dplyr::filter(country %in% country_groups(countries))

    # if a country name is supplied
  } else if (any(stringr::str_to_title(countries) %in% country_codes[["country"]])) {

    countries <- stringr::str_to_title(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(country %in% as.vector(countries))

    # if all countries are selected
  } else if (countries == 'all') {

    country_codes <- country_codes

    # error
  } else {

    stop('Country not covered by World Bank.')

  }


  database <- wbi_indicators[['result']] %>%
    dplyr::filter(CODE %in% indicators) %>%
    tidyr::crossing(country_codes) %>%
    dplyr::mutate(quandl_code = stringr::str_c('WPSD/', iso, '_', CODE))

  # error handler
  possible_quandl <- purrr::possibly(Quandl::Quandl, NA)

  # final manipulation
  database %>%
    tidyr::nest(quandl_code) %>%

    # 5.1. map the selected code thought the selected countries
    dplyr::mutate(
      download = purrr::map(
        .x = data,
        .f = ~ possible_quandl(.$quandl_code, !!! dots_expr)
      ),
      verify_download = purrr::map(
        .x = download,
        .f = ~ !is.logical(.)
      )
    ) %>%
    dplyr::filter(verify_download == TRUE) %>%

    tidyr::unnest(.$download) %>%
    dplyr::rename(date = 'Date', value = 'Value') %>%
    dplyr::mutate_if(purrr::is_character, forcats::as_factor) %>%
    dplyr::rename(indicator = 'INDICATOR') %>%
    dplyr::select(date, country, indicator, value)

}
