#' Create rolling sums of displacement data
#'
#' `idmc_rolling_sum()` generates rolling sums of displacement data that has
#' already been transformed into daily data using `idmc_transform_daily()`.
#' Rolling sums are generated at weekly (7 days), monthly (30 days), quarterly
#' (90 days), and yearly (365 days) levels.
#'
#' By default, data is backfilled for all countries and displacement types to
#' the first reported date in the IDMC dataset.
#'
#' @param df Daily displacement data frame, generated with [idmc_get_data()] and
#'     [idmc_transform_daily()].
#' @param backfill_zero If `TRUE`, the default, dates prior to the first
#'     reported displacement are infilled with zero. Dates are backfilled to
#'     `min_date`. If `FALSE`, the displacement data is only infilled
#'     from the first reported displacement for a given `country` and
#'     `displacement_type`.
#' @param min_date Date to backfill displacement data to. By default, `min_date`
#'     is set the first day of 2018. Only a few observations of the IDMC data
#'     are from before 2018, spanning back to 2011. Only used if
#'     `backfill_zero`.
#' @param max_date Date to extrapolate all data to. Based on the latest reported
#'     date in the IDMC dataset.
#' @param filter_min_date If `TRUE`, the default, filters the data to only
#'     contain data from `min_date` onward. Ensures that the few countries with
#'     observations from 2011 but nothing until 2018 do not skew results.
#'
#' @examplesIf interactive()
#' idmc_get_data() %>%
#'     idmc_transform_daily() %>%
#'     idmc_rolling_sum()
#'
#' @export
idmc_rolling_sum <- function(
    df,
    backfill_zero = TRUE,
    min_date = min(as.Date("2018-01-01")),
    max_date = max(df[["date"]]),
    filter_min_date = TRUE
  ) {
  # check columns present
  group_cols = c("iso3", "country", "displacement_type")

  assert_df_cols(
    df = df,
    cols = c(group_cols, "date", "displacement_daily"),
    derived_from = "idmc_transform_daily()"
  )
  # infill the days and calculate rolling sums
  # don't backfill first because increases computational time

  df_complete <- df %>%
    dplyr::group_by(
      dplyr::across(
        !!group_cols
      )
    ) %>%
    tidyr::complete(
      date = seq(min(.data$date), max_date, by = "day"),
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

  # calculate rolling sums
  df_rolling <- df_complete %>%
    dplyr::mutate(
      displacement_weekly = zoo::rollsum(
        x = .data[["displacement_daily"]],
        k = 7,
        fill = 0,
        align = "left"
      ),
      displacement_monthly = zoo::rollsum(
        x = .data[["displacement_daily"]],
        k = 30,
        fill = 0,
        align = "left"
      ),
      displacement_quarterly = zoo::rollsum(
        x = .data[["displacement_daily"]],
        k = 90,
        fill = 0,
        align = "left"
      ),
      displacement_yearly = zoo::rollsum(
        x = .data[["displacement_daily"]],
        k = 365,
        fill = 0,
        align = "left"
      )
    )

  # now backfill zeroes as necessary
  if (backfill_zero) {
    # global min and max dates
    df_rolling <- df_rolling %>%
      tidyr::complete(
        date = seq(min_date, max_date, by = "day"),
        fill = list(
          displacement_daily = 0,
          displacement_weekly = 0,
          displacement_monthly = 0,
          displacement_quarterly = 0,
          displacement_yearly = 0
        )
      )
  }

  # make NA values for rolling sums with insufficient data
  # doing now rather than original calc so we except any amount of infilling

  # named vector for applying thresholds to vectors
  cols <- paste(
    "displacement",
    c("weekly", "monthly", "quarterly", "yearly"),
    sep = "_"
  )
  lims <- c(7, 30, 90, 365)
  names(lims) <- cols

  # adjust the rolled sums based on row numbers
  df_rolling <- df_rolling %>%
    dplyr::mutate(
      dplyr::across(
        .cols = cols,
        .fns = ~ ifelse(
          dplyr::row_number() < lims[dplyr::cur_column()],
          NA_real_,
          .x
        )
      )
    )

  dplyr::ungroup(df_rolling)
}
