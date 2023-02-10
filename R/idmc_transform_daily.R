#' Transform displacement event data to daily data
#'
#' `idmc_transform_daily()` transforms event data from the IDMC API (accessed
#' through [idmc_get_data()]). The data for each event is spread out between
#' the start and end date, with the total displacement uniformly distributed
#' across all days. For each country and displacement type (conflict, disaster,
#' or other), all displacement on a day is summed up to create a total
#' daily displacement figure.
#'
#' @param df Event displacement data frame, generated from [idmc_get_data()].
#'
#' @return Data frame of daily displacement by country and displacement type.
#'
#' @examplesIf interactive()
#' idmc_get_data() %>%
#'   idmc_transform_daily()
#'
#' @export
idmc_transform_daily <- function(df) {
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
      start_date = dplyr::if_else( # reverse and fill start_date if necess
        is.na(.data[[e_col_]]) | .data[[s_col_]] <= .data[[e_col_]],
        .data[[s_col_]],
        .data[[e_col_]]
      ),
      end_date = dplyr::if_else( # reverse and fill end date if necess
        !is.na(.data[[e_col_]]) & .data[[s_col_]] <= .data[[e_col_]],
        .data[[e_col_]],
        .data[[s_col_]]
      )
    )

  # create daily displacement from events
  df_correct %>%
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
}
