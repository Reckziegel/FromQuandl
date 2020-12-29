#' Download World Bank Data Using Quandl API
#'
#' A wrapper around \code{Quandl}. Downloads macroeconomic data for several indicators and countries covered by World Bank.
#'
#' The \code{countries} argument can be passed as an ISO code or as a country name. The only requirement is that the call must be consistent (must contain only ISO codes or country names, but not both).
#'
#' Sometimes the user may be interesoted in downloading data for certain regions, like Europe, Latin America, Middle East, etc. For that reason, the \code{countries} argument also accepts the following calls:
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
#' For any of those calls the \code{fq_wb()} will download data for all the countries in the requested region. A complete region list can be seen at: \url{https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/groups.htm}.
#'
#' The \code{...} argument can be used to calibrate the query parameters. It accepts the following calls:
#'
#'\itemize{
#'  \item \code{start_date}: \code{'YYYY-MM-DD'}
#'  \item \code{end_date}: \code{'YYYY-MM-DD'}
#'  \item \code{collapse}: \code{c("", "daily", "weekly", "monthly", "quarterly", "annual")}
#'  \item \code{transform}: \code{c("", "diff", "rdiff", "normalize", "cumul", "rdiff_from")}
#'}
#'
#' The full list can be seen at: \url{https://docs.quandl.com/docs/r}.
#'
#' \code{Quandl} has a diverse of World Bank datasets. The following items give a brief description of what you could expect to find when trying to dig further into each one of them:
#'
#' \itemize{
#'   \item \href{https://www.quandl.com/data/WWDI-World-Bank-World-Development-Indicators}{World Development Indicators}: Most current and accurate development indicators, compiled from officially-recognized international sources.
#'   \item \href{https://www.quandl.com/data/WWGI-World-Bank-Worldwide-Governance-Indicators}{Worldwide Governance Indicators}: Data on aggregate and individual governance indicators for six dimensions of governance.
#'   \item \href{https://www.quandl.com/data/WPSD-World-Bank-Public-Sector-Debt}{Public Sector Debt}: Data jointly developed by the World Bank and the International Monetary Fund, which brings together detailed public sector government debt data.
#'   \item \href{https://www.quandl.com/data/WPOV-World-Bank-Poverty-Statistics}{Poverty Statistics}: Indicators on poverty headcount ratio, poverty gap, and number of poor at both international and national poverty lines.
#'   \item \href{https://www.quandl.com/data/WMDG-World-Bank-Millennium-Development-Goals}{Millennium Development Goals}: Data drawn from the World Development Indicators, reorganized according to the goals and targets of the Millennium Development Goals (MDGs).
#'   \item \href{https://www.quandl.com/data/WJKP-World-Bank-Jobs-for-Knowledge-Platform}{Jobs for Knowledge Platform}: Indicators on labor-related topics.
#'   \item \href{https://www.quandl.com/data/WIDA-World-Bank-International-Development-Association}{International Development Association}: Data on progress on aggregate outcomes for IDA (International Development Association) countries for selected indicators.
#'   \item \href{https://www.quandl.com/data/WHNP-World-Bank-Health-Nutrition-and-Population-Statistics}{Health Nutrition and Population Statistics}: Key health, nutrition and population statistics.
#'   \item \href{https://www.quandl.com/data/WGLF-World-Bank-Global-Findex-Global-Financial-Inclusion-database}{Global Findex (Global Financial Inclusion database)}: Indicators of financial inclusion measures on how people save, borrow, make payments and manage risk.
#'   \item \href{https://www.quandl.com/data/WGFD-World-Bank-Global-Financial-Development}{Global Financial Development}: Data on financial system characteristics, including measures of size, use, access to, efficiency, and stability of financial institutions and markets.
#'   \item \href{https://www.quandl.com/data/WGEP-World-Bank-GEP-Economic-Prospects}{GEP Economic Prospects}: Data on the short-, medium, and long-term outlook for the global economy and the implications for developing countries and poverty reduction.
#'   \item \href{https://www.quandl.com/data/WGEN-World-Bank-Gender-Statistics}{Gender Statistics}: Data describing gender differences in earnings, types of jobs, sectors of work, farmer productivity, and entrepreneurs’ firm sizes and profits.
#'   \item \href{https://www.quandl.com/data/WGEM-World-Bank-Global-Economic-Monitor}{Global Economic Monitor}: Data on global economic developments, with coverage of high-income, as well as developing countries.
#'   \item \href{https://www.quandl.com/data/WGEC-World-Bank-Global-Economic-Monitor-GEM-Commodities}{Global Economic Monitor (GEM) Commodities}: Data containing commodity prices and indices from 1960 to present.
#'   \item \href{https://www.quandl.com/data/WGDF-World-Bank-Global-Development-Finance}{Global Development Finance}: Data on financial system characteristics, including measures of size, use, access to, efficiency, and stability of financial institutions and markets.
#'   \item \href{https://www.quandl.com/data/WESV-World-Bank-Enterprise-Surveys}{Enterprise Surveys}: Company-level private sector data, covering business topics including finance, corruption, infrastructure, crime, competition, and performance measures.
#'   \item \href{https://www.quandl.com/data/WEDU-World-Bank-Education-Statistics}{Education Statistics}: Internationally comparable indicators on education access, progression, completion, literacy, teachers, population, and expenditures.
#'   \item \href{https://www.quandl.com/data/WDBU-World-Bank-Doing-Business}{Doing Business}: Data on business regulations and their enforcement for member countries and selected cities at the subnational and regional level.
#'   \item \href{https://www.quandl.com/data/WCSC-World-Bank-Corporate-Scorecard}{Corporate Scorecard}: This database is designed to provide a strategic overview of the World Bank Group’s performance toward ending extreme poverty and promoting shared prosperity.
#'   \item \href{https://www.quandl.com/data/WADI-World-Bank-Africa-Development-Indicators}{Africa Development Indicators}: A collection of development indicators on Africa, including national, regional and global estimates.
#' }
#'
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
#'
#' if (FALSE) {
#'   # Download al indicators related to Rule of Law for the G7 countries from 2010 ownwards...
#'   fq_wb(countries  = 'g7',
#'         indicators = c('RL_EST', 'RL_NO_SRC'),
#'         start_date = '2010-01-01')
#' }
fq_wb <- function(countries, indicators, verbose = TRUE, ...) {

  # checking errors
  if (purrr::is_null(indicators)) {

    stop('Must provide an indicator.')

  } else if (purrr::is_null(countries)) {

    stop('Must provide a country or a group of countries.')

  }

  # tidy eval
  dots_expr  <- dplyr::quos(...)

  # check if order = 'asc'
  if ((!purrr::is_null(dots_expr[['order']])) && dots_expr[['order']][[2]] != "asc" && verbose) {

    warning("To keep consistency with other tidy functions it will be set ", crayon::green("order = 'asc'."))

    dots_expr[["order"]] <- NULL

  }

  # avoid errors
  indicators <- stringr::str_to_upper(indicators) %>%
    stringr::str_trim(., side = 'both')


  # select specific countries?
  regions <- c('ae', 'oae', 'euro', 'eu', 'ede', 'g7', 'cis', 'dea', 'asean5', 'edeuro', 'latam', 'me', 'ssa')

  # if an ISO code is supplied
  if (max(stringr::str_count(countries)) <= 3 && !(stringr::str_to_lower(countries) %in% regions)) {

    countries <- stringr::str_to_upper(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(.data$iso %in%  as.vector(countries))

    # if a region is supplied
  } else if (any(countries %in% regions)) {

    country_codes <- country_codes %>%
      dplyr::filter(.data$country %in% country_groups(countries))

    # if a country name is supplied
  } else if (any(stringr::str_to_title(countries) %in% country_codes[["country"]])) {

    countries <- stringr::str_to_title(countries) %>%
      stringr::str_trim(., side = 'both')

    country_codes <- country_codes %>%
      dplyr::filter(.data$country %in% as.vector(countries))

    # if all countries are selected
  } else if (countries == 'all') {

    country_codes <- country_codes

    # error
  } else {

    stop('Country not covered by World Bank.')

  }


  database <- wb_indicators %>%
    dplyr::filter(.data$code %in% indicators) %>%
    tidyr::crossing(country_codes) %>%
    dplyr::mutate(quandl_code = stringr::str_c(.data$prefix, '/', .data$iso, '_', .data$code))

  # error handler
  possible_quandl <- purrr::possibly(Quandl::Quandl, NA)

  # data wrangling
  database <- database %>%
    tidyr::nest(data = .data$quandl_code) %>%

    # map the selected code thought the selected countries
    dplyr::mutate(
      download = purrr::map(
        .x = .data$data,
        .f = ~ possible_quandl(.x$quandl_code, order = 'asc', !!! dots_expr)
      ),
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
              "Indicator ", crayon::cyan(warn_tbl$indicator[[i]]),
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
      dplyr::select(.data$Date, .data$country, .data$indicator, .data$Value) %>%
      dplyr::rename(date = "Date", value = "Value")

  }

}



