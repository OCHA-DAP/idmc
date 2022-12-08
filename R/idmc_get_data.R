#' Get data from the IDMC API
#'
#' `idmc_get_data()` calls the IDMC API to retrieve displacement data. The data
#' is converted from JSON to a data frame, date columns converted to `Date`
#' types, and returned as a [tibble::tibble]. A valid URL endpoint must be
#' saved in your environment as `IDMC_API`.
#'
#' @return Tibble of displacement data. Description of the data frame variables
#'     are included in the documentation for the
#'     [IDMC IDU API](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf).
#'
#' @examplesIf interactive()
#' idmc_get_data()
#'
#' @export
idmc_get_data <- function(api_url = NULL) {
  api_url <- get_api_url()
  resp <- httr::GET(api_url)

  if (httr::http_type(resp) != "application/json") {
    stop(
      "Check that the URL in `IDMC_API` is valid. If it is, get in touch with ",
      "IDMC to discuss.",
      call. = FALSE
    )
  }

  # get JSON
  js <- httr::content(
    x = resp,
    as = "text",
    encoding = "UTF-8"
  )

  # convert to DF
  jsonlite::parse_json(
    json = js,
    simplifyVector = TRUE
  ) %>%
    dplyr::tibble() %>%
    dplyr::mutate(
      dplyr::across(
        .cols = c(dplyr::contains("date"), "created_at"),
        .fns = as.Date
      )
    )
}

#' Get the IDMC API url
#'
#' Raises an error if the environment variable `IDMC_API` isn't set.
get_api_url <- function() {
  api_url <- Sys.getenv(
    x = "IDMC_API",
    unset = NA
  )

  if (is.na(api_url)) {
    stop(
      "You need a valid URL to access the IDMC API. Once you have a valid URL ",
      "save it as `IDMC_API` in your `.renviron` file. ",
      "`usethis::edit_r_environ()` provides convenient access to the file.",
      call. = FALSE
    )
  }

  api_url
}
