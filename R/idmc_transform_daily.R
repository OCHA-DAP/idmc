#' Transform displacement event data to daily data
#'
#' `idmc_transform_daily()` transforms event data from the IDMC API (accessed
#' through [idmc_get_data()]). The data for each event is spread out between
#' the start and end date, with the total displacement uniformly distributed
#' across all days. For each country and displacement type (conflict, disaster,
#' or other), all displacement on a day is summed up to create a total
#' daily displacement figure.
#'
#' By default, data is backfilled for all countries and displacement types to
#' the first reported date in the IDMC dataset. Data is always infilled with 0
#' between start and end dates.
#'
#' @param df Event displacement data frame, generated from [idmc_get_data()].
#' @param min_date Date to backfill displacement data to. By default, `min_date`
#'     is set the first day of 2018. Only a few observations of the IDMC data
#'     are from before 2018, spanning back to 2011.
#'     If `NULL`, no backfilling is done, and the first reported
#'     case in the IDMC database is taken as the earliest.
#' @param max_date Date to extrapolate all data to, filling with `0`. If the
#'     The latest date in the data frame is used if later than `max_date`.
#'     If `NULL`, no extrapolation is done.
#' @param filter_min_date If `TRUE`, the default, filters the data to only
#'     contain data from `min_date` onward. Ensures that the few countries with
#'     observations from 2011 but nothing until 2018 do not skew results.
#'
#'
#' @returns Data frame of daily displacement with the following columns:
#' \describe{
#'   \item{iso3}{Country ISO3 code.}
#'   \item{country}{Country or area name.}
#'   \item{displacement_type}{Type of displacement.}
#'   \item{date}{Date.}
#'   \item{displacement_daily}{Daily level of displacement.}
#' }
#'
#' @examplesIf !is.na(Sys.getenv("IDMC_API", unset = NA))
#' idmc_get_data() %>%
#'   idmc_transform_daily()
#'
#' @export
idmc_transform_daily <- function(
    df,
    min_date = min(as.Date("2018-01-01")),
    max_date = Sys.Date(),
    filter_min_date = TRUE
  ) {
  # date columns to transform
  s_col_ <- "displacement_start_date"
  e_col_ <- "displacement_end_date"

  # columns to group by
  group_cols <- c("iso3", "country", "displacement_type", "date")

  # raise error if required columns not in input data frame
  req_cols <- c(
    s_col_,
    e_col_,
    "displacement_date",
    "figure",
    group_cols[-4]
  )

  assert_df_cols(
    df = df,
    cols = req_cols,
    derived_from = "idmc_get_data()"
  )

  # correct missing or reversed dates in the data frame
  df_correct <- df %>%
    dplyr::filter(
      !is.na(.data[["displacement_date"]]) # drop where no start/end available
    ) %>%
    dplyr::mutate(
      start_date = dplyr::if_else( # reverse and fill start_date if necessary
        is.na(.data[[e_col_]]) | .data[[s_col_]] <= .data[[e_col_]],
        .data[[s_col_]],
        .data[[e_col_]]
      ),
      end_date = dplyr::if_else( # reverse and fill end date if necessary
        !is.na(.data[[e_col_]]) & .data[[s_col_]] <= .data[[e_col_]],
        .data[[e_col_]],
        .data[[s_col_]]
      )
    )

  # create daily displacement from events
  df_daily <- df_correct %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      date = list(
        seq(.data$start_date, .data$end_date, by = "day")
      ),
      displacement_daily = .data$figure / length(.data$date)
    ) %>%
    dplyr::ungroup() %>%
    tidyr::unnest(
      cols = "date"
    ) %>%
    dplyr::group_by(
      dplyr::across(!!group_cols)
    ) %>%
    dplyr::summarize(
      displacement_daily = sum(.data$displacement_daily),
      .groups = "drop"
    )


  # replace with NA so that no backfilling or extrapolation occurs

  if (is.null(max_date)) {
    max_date <- NA
  }

  if (is.null(min_date)) {
    min_date <- NA
  }

  # completing as necessary
  df_complete <- df_daily %>%
    dplyr::group_by(
      dplyr::across(
        !!group_cols[-4] # don't include date
      )
    ) %>%
    tidyr::complete(
      date = seq(min(.data$date, min_date, na.rm = TRUE), max(.data$date, max_date, na.rm = TRUE), by = "day"),
      fill = list(
        displacement_daily = 0
      )
    )

  # filter to min date if necessary
  if (filter_min_date) {
    df_complete <- df_complete %>%
      dplyr::filter(
        .data$date >= !!min_date
      )
  }

  dplyr::ungroup(df_complete)
}
