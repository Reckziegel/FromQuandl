#' Download IMF data using Quandl API
#'
#' A wrapper around \code{Quandl}. Downloads macroeconomic data for several indicators and countries covered by IMF in just one line of code.
#'
#' The \code{countries} argument can be passed as an ISO code or as a country name. The only requirement is that the call must be consistent (must contain only ISO codes or country names, but not both).
#'
#' Sometimes the user may be interested in downloading data for certain regions, like Europe, Latin America, Middle East, etc. For that reason, the countries argument also accepts the following calls:
#' \itemize{
#'   \item 'ae' - advanced_economics
#'   \item 'asean_5' - asean_5
#'   \item 'cis' - commonwealth_independent_states
#'   \item 'eda' - emerging_and_developing_asia
#'   \item 'ede' - emerging_and_developing_economies
#'   \item  'edeuro' - emerging_and_developing_europe
#'   \item 'euro' - euro_area
#'   \item 'eu' - european_union
#'   \item 'g7' - g7
#'   \item 'latam' - latin_america_and_caribbean
#'   \item 'me' - middle_east
#'   \item 'oae' - other_advanced_economies
#'   \item 'ssa' - sub_saharan_africa
#'}
#'
#'For any of those calls the \code{imf_from_quandl()} will download data for all the countries in the requested region. A complete region list can be seen at: \url{https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/groups.htm}.
#'
#'The \code{...} argument can be used to calibrate the query parameters. It accepts the following calls:
#'\itemize{
#'  \item \code{start_date} and \code{end_date}, if you which to filter time series:
#'  \item \code{collapse} and \code{transform}, if you which to preprocess the data
#'}
#'
#'The full list of options parameters can be seen at \url{https://docs.quandl.com/docs/r}.
#'
#' @param countries A vector or a list of character strings.
#' @param indicators A vector or a list of character strings.
#' @param ... Additional arguments to be passed into \code{Quandl} function.
#'
#' @return A tidy \code{tibble}.
#' @export
#'
#' @examples
#' # Download the Unemployment rate for all countries in Latin America
#' imf_from_quandl(countries = 'latam', indicators = 'LUR')
#'
#' # Download the Savings and the Current Account for all countries in the G7
#' imf_from_quandl(countries = 'g7', indicators = c('NGSD_NGDP', 'BCA_NGDPD'))
#'
#' # Download the Output Gap
#' imf_from_quandl('United States', 'NGAP_NPGDP')
#' imf_from_quandl('USA', 'NGAP_NPGDP') # identical to the code above
imf_from_quandl <- function(countries, indicators, ...) {


  # tidy eval
  dots_expr <- dplyr::quos(order = 'asc', ...)

  # check data
  if (purrr::is_null(countries)) {
    stop('Must specifý a country.')
  } else if (purrr::is_null(indicators)) {
    stop('Must specify an indicator.')
  } else if (any(stringr::str_detect(rlang::eval_tidy(dots_expr), 'desc'))) {
    stop('Tidy functions do not accept the "order = desc" argument')
  }

  # to avoid simple msitakes
  indicators <- stringr::str_to_upper(indicators) %>%
    stringr::str_trim(., side = 'both')

  imf_datasets_filtered <- imf_datasets %>%
    dplyr::filter(.indicators %in% indicators)


  # Must the data be filtered by country? If yes, do this:
  regions <- c('ae', 'oae', 'euro', 'eu', 'ede', 'g7', 'cis', 'dea', 'asean_5', 'edeuro', 'latam', 'me', 'ssa')
  if (!purrr::is_null(countries)) {

    if (max(stringr::str_count(countries)) <= 3 && !(countries %in% regions)) {

      countries <- stringr::str_to_upper(countries) %>%
        stringr::str_trim(., side = 'both')

      iso_codes_by_country_tbl <- iso_codes_by_country %>%
        dplyr::filter(.iso %in% countries)

    } else if (countries %in% regions) {

      countries <- country_groups(countries) %>%
        stringr::str_trim(., side = 'both')

    iso_codes_by_country_tbl <- iso_codes_by_country %>%
      dplyr::filter(.country %in% countries)

    } else {

      countries <- stringr::str_to_title(countries) %>%
        stringr::str_trim(., side = 'both')

      iso_codes_by_country_tbl <- iso_codes_by_country %>%
        dplyr::filter(.country %in% countries)

    }

  }

  # Is the indicators argument > 1?
  if (length(indicators) == 1) {

    iso_codes_by_country_tbl <- iso_codes_by_country_tbl %>%
      dplyr::mutate(code = stringr::str_c('ODA/', .iso, '_', indicators)) %>%
      tidyr::crossing(imf_datasets_filtered)

  } else {

    iso_codes_by_country_tbl <- iso_codes_by_country_tbl %>%
      tidyr::crossing(indicators) %>%
      dplyr::mutate(code = purrr::map2(
        .x = .iso,
        .y = indicators,
        .f = ~ stringr::str_c('ODA/', .x, '_', .y)
        )
      ) %>%
      tidyr::unnest(code) %>%
      tidyr::crossing(imf_datasets_filtered) %>%
      dplyr::select(-indicators)

  }


  # error handler
  possible_quandl <- purrr::possibly(Quandl::Quandl, NA)

  # data wrangling
  iso_codes_by_country_tbl %>%
    tibble::rownames_to_column(.) %>%
    tidyr::nest(code) %>%

    # map the selected code thought the diserided countries
    dplyr::mutate(download = purrr::map(
      .x = data,
      .f = ~ possible_quandl(.$code, !!! dots_expr)
      )
    ) %>%

    # exclude the countries in which the indicator is not avaiable
    dplyr::mutate(verify_download = purrr::map(
      .x = .$download,
      .f = ~ !is.logical(.))) %>%
    dplyr::filter(verify_download == TRUE) %>%

    # unnest and tidy
    tidyr::unnest(data) %>%
    tidyr::unnest(download) %>%
    dplyr::select(-rowname) %>%
    dplyr::rename(
      date       = 'Date',
      value      = 'Value',
      country    = '.country',
      iso        = '.iso',
      indicator  = '.indicators',
      name       = '.names'
      ) %>%
    dplyr::mutate_if(purrr::is_character, forcats::as_factor) %>%
    dplyr::select(date, iso, country, indicator, value, name)

}


