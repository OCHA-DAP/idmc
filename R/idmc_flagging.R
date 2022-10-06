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
    c("daily", "weekly", "monthly", "quarterly", "yearly")
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

    df_flagged <- df_flagged %>%
      dplyr::group_by(
        dplyr::across(
          dplyr::all_of(c(!!group_cols, "displacement_type"))
        )
      ) %>%
      dplyr::mutate(
        flag_daily = flag_percent(.data$displacement_daily),
        flag_weekly = flag_percent(.data$displacement_weekly),
        flag_monthly = flag_percent(.data$displacement_monthly),
        flag_quarterly = flag_percent(.data$displacement_quarterly),
        flag_yearly = flag_percent(.data$displacement_yearly)
      ) %>%
      dplyr::ungroup()
  }

  if (flag_global) {
    df_flagged <- df_flagged %>%
      dplyr::mutate(
        flag_daily_5k = .data$displacement_daily >= 5000,
        flag_weekly_20k = .data$displacement_weekly >= 20000,
        flag_monthly_100k = .data$displacement_monthly >= 100000,
        flag_quarterly_250k = .data$displacement_quarterly >= 250000,
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
        flag_1st_6_months = .data$displacement_daily > 0 & lag(.data$displacement_quarterly) == 0 & lag(.data$displacement_quarterly, n = 2) == 0,
        flag_1st_year = .data$displacement_daily > 0 & lag(.data$displacement_yearly) == 0,
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
      flag_total = sum(value, na.rm = TRUE),
      flag_any  = any(value, na.rm = TRUE)
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
  x >= lim
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

  quantile(x_check, probs = perc, na.rm = TRUE)
}
