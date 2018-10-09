#' Download World Bank data using Quandl API
#'
#' A wrapper around \code{Quandl}. Download Governance and Poverty data covered by the World Bank with just one line of code.
#'
#' The \code{countries} argument can be passed as an ISO code or as a country name. The only requirement is that the call must be consistent (must contain only ISO codes or country names, but not both).
#'
#' Sometimes the user may be interested in downloading data for certain regions, like Europe, Latin America, Middle East, etc. For that reason, the countries argument also accepts the following calls:
#'
#' \itemize{
#'   \item advanced_economics
#'   \item asean_5
#'   \item commonwealth_independent_states
#'   \item emerging_and_developing_asia
#'   \item emerging_and_developing_economies
#'   \item emerging_and_developing_europe
#'   \item euro_area
#'   \item european_union
#'   \item g7
#'   \item latin_america_and_caribbean
#'   \item middle_east
#'   \item other_advanced_economies
#'   \item sub_saharan_africa
#'}
#'
#'For any of those calls the \code{imf_from_quandl()} will download data for all the countries in the requested region. A complete region list can be seen at: \url{https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/groups.htm}.
#'
#'
#'The \code{...} argument can be used to calibrate the query parameters. It accepts the following calls:
#'\itemize{
#'  \item \code{start_date} and \code{end_date}, to filter time series:
#'  \item \code{collapse} and \code{transform}, for preprocess
#'}
#'
#'The full list can be seen at: \url{https://docs.quandl.com/docs/r}.
#'
#' @param countries A vector or a list of character strings.
#' @param indicators A vector or a list of character strings.
#' @param ... Additional arguments to be passed into \code{Quandl} function.
#'
#' @return A tidy \code{tibble}.
#' @export
#'
#' @examples
#' library(FromQuandl)
#' wb_from_quandl(countries = c('CAN', 'USA'), indicator = 'poverty')
#'
#' # the function arguments are case insensitive
#' wb_from_quandl(countries = 'g7', indicators = 'develOPMENT', start_date = '2016-01-01)
wb_from_quandl <- function(countries, indicators, ...) {


  # checking errors
  if (purrr::is_null(indicators)) {
    stop('Must provide an indicator.')
  } else if (purrr::is_null(countries)) {
    stop('Must provide a country or a group of countries.')
  }

  dots_expr  <- dplyr::quos(order = 'asc', ...)

  indicators <- stringr::str_to_lower(indicators) %>%
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

    if (n_tries > 10) {

      warning('Download failed after 10 attemps. Check the intenet connection.')

      break

    }

    Sys.sleep(1)

  }

  country_codes <- country_codes[['result']] %>%
    dplyr::rename(country = 'COUNTRY', iso = 'CODE')


  # each indicator has a specific path
  if (indicators == 'governance') {

    file <- "https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwgi_indicators"

    # } else if (indicators == 'development') {
    #
    #   file <- 'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wwdi_indicators'
    #
    # } else if (indicators %>% stringr::str_detect(., pattern = 'public')) {
    #
    #   file <- 'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpsd_indicators'
  } else if (indicators == 'poverty') {

    file <- 'https://s3.amazonaws.com/quandl-production-static/World+Bank+Descriptions/wpov_indicators'

  } else {

    stop('Indicator not supported.')

  }


  # start the downlaod
  wbi_indicators <- list(result = NULL, error = NULL)
  n_tries        <- 0

  while (purrr::is_null(wbi_indicators[['result']])) {

    wbi_indicators <- suppressMessages(safe_read(
      file          = file,
      delim         = "|",
      escape_double = FALSE,
      trim_ws       = TRUE
    )
    )

    n_tries <- n_tries + 1

    if (n_tries > 10) {

      warning('Download failed after 10 attemps. Check the intenet connection.')

      break

    }

    Sys.sleep(1)

  }


  # Manipulate the downloaded tibble
  if (indicators == 'governance') {

    wbi_indicators <-  wbi_indicators[['result']] %>%
      tidyr::separate(
        col  = INDICATOR,
        into = c('category', 'indicator'),
        sep  = ': '
      ) %>%
      dplyr::rename(code = 'CODE')

    first_letters <- 'WWGI'

    # } else if (indicators == 'development') {
    #
    #   wbi_indicators <-  wbi_indicators[['result']] %>%
    #     dplyr::rename(indicator = 'INDICATOR', code = 'CODE')
    #
    #   first_letters <- 'WWDI'
    #
    # } else if (indicators %>% stringr::str_detect(., pattern = 'public')) {
    #
    #   wbi_indicators <-  wbi_indicators[['result']] %>%
    #     dplyr::rename(indicator = 'INDICATOR', code = 'CODE')
    #
    #   first_letters <- 'WPSD'

  } else if (indicators == 'poverty') {

    wbi_indicators <-  wbi_indicators[['result']] %>%
      dplyr::rename(indicator = 'INDICATOR', code = 'CODE')

    first_letters <- 'WPOV'

  }


  # select specific countries?
  regions <- c('ae', 'oae', 'euro', 'eu', 'ede', 'g7', 'cis', 'dea', 'asean_5', 'edeuro', 'latam', 'me', 'ssa')
  if (!purrr::is_null(countries)) {

    if (max(stringr::str_count(countries)) <= 3 && !(countries %in% regions)) {

      countries <- stringr::str_to_upper(countries) %>%
        stringr::str_trim(., side = 'both')

      country_codes <- country_codes %>%
        dplyr::filter(iso %in%  as.vector(countries))

    } else if (countries %in% regions) {

      countries <- country_groups(countries) %>%
        stringr::str_trim(., side = 'both')

    } else {

      countries <- stringr::str_to_title(countries) %>%
        stringr::str_trim(., side = 'both')

      country_codes <- country_codes %>%
        dplyr::filter(country %in% as.vector(countries))

    }

  }

  database <- tidyr::crossing(wbi_indicators, country_codes) %>%
    dplyr::mutate(quandl_code = stringr::str_c(first_letters, '/', iso, '_', wbi_indicators[['code']]))

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
    tibbletime::as_tbl_time(., index = Date) %>%
    dplyr::rename(date = 'Date', value = 'Value') %>%
    dplyr::mutate_if(is_character, forcats::as_factor) %>%
    dplyr::select(date, country, indicator, value)

}

