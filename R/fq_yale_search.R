#' Search in Yale Department of Economics
#'
#' haha
#'
#' The search is case insensitive. There is no difference between looking for "GDP" of "gdp", they yield the same output.
#'
#' @param ... Character strings to match the search.
#'
#' @return A \code{tibble} with the series that fit the search.
#'
#' @export
#'
#' @examples
#' fq_yale_search("gdp", "per capita")
fq_yale_search <- function(...) {

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
  yale_filtered <- yale_data %>%
    dplyr::filter(

      purrr::map(
        .x = stringr::str_to_lower(.data$name),
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
  if (nrow(yale_filtered) == 0) {

    if (length(.dots) == 1) {

      message("I was not possible to identify the query ", crayon::cyan(.dots), " in Yale database.")

    } else {

      message("It was not possible to find any indicator that matches the queries requested.")
      purrr::iwalk(.dots, ~ cat(.y, ":", crayon::cyan(.x), ".", "\n", sep = ""))
      message("Try just one of them in isolation, them refine your search.")

    }

  # otherwise return the output
  } else {

    return(yale_filtered)

  }


}

