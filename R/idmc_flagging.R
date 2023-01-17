#' Flag IDMC displacement data
#'
#' `idmc_flagging()` generates flags on IDMC displacement data. Flags can be
#' generated based country-level anomalies, global thresholds, and if the
#' displacement is the first reported displacement in a period of time. The
#' input dataset should be generated from [idmc_rolling_sum()].
#'
#' Flags are generated as:
#'
#' * Country-level flags by displacement type. Anomalies are generated based
#' on the values being in the top %5 of observed displacement values for that
#' country (excluding 0, days without displacement). These flags are generated
#' across time spans from daily to yearly to detect anomalies at different
#' levels. Anomalies are calculated separately for each type of displacement
#' (conflict, disaster, other) to ensure that new shifts in conflict
#' displacement dynamics in a country like Mozambique are not missed due to
#' previous large displacements due to natural disasters.
#' * Global flags based on static thresholds. These are calculated for total
#' daily displacement in a country from daily to yearly to find overall
#' anomalies. The thresholds are 5,000 individuals daily, 20,000 weekly,
#' 100,000 monthly, 250,000 quarterly, and 500,000 yearly.
#' * Flags if there is displacement for the first time in 3 months, 6 months,
#' or one year.
#'
#' @param df Event displacement data frame, generated from [idmc_rolling_sum()].
#' @param flag_country Flag country-level anomalies based on anomalies in the
#'     95th percentile.
#' @param flag_global Flag based on globally set thresholds for total
#'     displacement in a country.
#' @param flag_first Flag for first displacements in a set of time.
#' @return Data frame of daily displacement by country and displacement type
#'     with flags added.
#'
#' @examplesIf interactive()
#' idmc_get_data() %>%
#'     idmc_transform_daily() %>%
#'     idmc_rolling_sum() %>%
#'     idmc_flagging()
#'
#' @export
idmc_flagging <- function(
    df,
    flag_country = TRUE,
    flag_global = TRUE,
    flag_first = TRUE
) {
  # check columns presence

  group_cols = c("iso3", "country")
  displacement_cols <- paste0(
    "displacement_",
    c("weekly", "monthly", "quarterly", "yearly")
  )

  assert_df_cols(
    df = df,
    cols = c(group_cols, "date", displacement_cols),
    derived_from = "idmc_rolling_sum()"
  )

  # saving data frame
  df_flagged <- df

  if (flag_country) {
    assert_df_cols(
      df = df,
      cols = "displacement_type",
      derived_from = "idmc_rolling_sum()"
    )

    df_type_flagged <- df %>%
      tidyr::pivot_wider(
        names_from = "displacement_type",
        values_from = displacement_cols
      ) %>%
      dplyr::group_by(
        dplyr::across(
          dplyr::all_of(c(!!group_cols))
        )
      ) %>%
      dplyr::mutate(
        dplyr::across(
          .cols = dplyr::matches(
            paste(!!displacement_cols, collapse = "|")
          ),
          .fns = flag_percent,
          .names = "flag_{.col}"
        )
      ) %>%
      dplyr::ungroup() %>%
      dplyr::rename_with(
        .fn = ~tolower(stringr::str_remove(.x, "displacement_")),
        .cols = dplyr::starts_with("flag_")
      ) %>%
      dplyr::select(
        dplyr::all_of(c(!!group_cols, "date")),
        dplyr::starts_with("flag")
      )

    # summarize to total displacement for later flagging
    df_flagged <- df %>%
      dplyr::select(
        -"displacement_type"
      ) %>%
      dplyr::group_by(
        dplyr::across(
          dplyr::all_of(c(!!group_cols, "date"))
        )
      ) %>%
      dplyr::summarise(
        dplyr::across(
          .cols = dplyr::starts_with("displacement_"),
          .fns = sum
        )
      ) %>%
      dplyr::left_join(
        df_type_flagged,
        by = c(group_cols, "date")
      )
  } else {
    # create flagged df for use down the line
    df_flagged <- df
  }

  if (flag_global) {
    df_flagged <- df_flagged %>%
      dplyr::mutate(
        flag_weekly_5k = .data$displacement_weekly >= 5000,
        flag_monthly_30k = .data$displacement_monthly >= 30000,
        flag_quarterly_100k = .data$displacement_quarterly >= 100000,
        flag_yearly_500k = .data$displacement_yearly >= 500000
      )
  }

  if (flag_first) {
    df_flagged <- df_flagged %>%
      dplyr::group_by(
        dplyr::across(
          !!group_cols
        )
      ) %>%
      dplyr::mutate(
        flag_1st_3_months = .data$displacement_daily > 0 & dplyr::lag(.data$displacement_quarterly) == 0,
        flag_1st_6_months = .data$displacement_daily > 0 & dplyr::lag(.data$displacement_quarterly) == 0 & dplyr::lag(.data$displacement_quarterly, n = 2) == 0,
        flag_1st_year = .data$displacement_daily > 0 & dplyr::lag(.data$displacement_yearly) == 0,
      ) %>%
      dplyr::ungroup()
  }

  # look at total flags
  # faster to pivot than do rowwise sums
  df_flagged_total <- df_flagged %>%
    tidyr::pivot_longer(
      cols = tidyr::starts_with("flag_")
    ) %>%
    dplyr::group_by(
      .data$iso3,
      .data$date
    ) %>%
    dplyr::summarize(
      flag_total = sum(.data[["value"]], na.rm = TRUE),
      flag_any  = any(.data[["value"]], na.rm = TRUE)
    )

  # return all
  dplyr::left_join(
    df_flagged,
    df_flagged_total,
    by = c("iso3", "date")
  )
}

#' Flag values in top percentiles
#'
#' @param x Numeric vector
#' @param perc % to flag. Defaults to flagging values in the top 5% (above
#'     95% of values).
#' @param exclude_zero Exclude zero from quantile calculation. Defaults to TRUE.
#'
#' @noRd
flag_percent <- function(x, perc = 0.95, exclude_zero = TRUE) {
  lim <- flag_lim(x = x, perc = perc, exclude_zero = exclude_zero)
  x >= max(lim, 1) # value at least of 1 for flagging
}

#' Get limits for flagging
#'
#' @inheritParams flag_percent
#'
#' @noRd
flag_lim <- function(x, perc = 0.95, exclude_zero = TRUE) {
  if (exclude_zero) {
    x_check <- x[x != 0]
  } else {
    x_check <- x
  }

  stats::quantile(x_check, probs = perc, na.rm = TRUE)
}
