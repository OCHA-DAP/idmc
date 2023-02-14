#' Flag IDMC displacement data
#'
#' `idmc_flagging()` generates flags on IDMC displacement data. Flags can be
#' generated based country-level anomalies, global thresholds, and if the
#' displacement is the first reported displacement in a period of time. The
#' input dataset should be generated from [idmc_rolling_sum()]. All flags are
#' calculated separately on displacement type in the IDMC database: conflict,
#' displacement, and other.
#'
#' Flags are generated as:
#'
#' * Country-level flags. Anomalies are generated based
#' on the values being in the top %5 of observed displacement values for that
#' country (excluding 0, days without displacement). These flags are generated
#' across time spans from daily to yearly to detect anomalies at different
#' levels. Anomalies are calculated separately for each type of displacement
#' (conflict, disaster, other) to ensure that new shifts in conflict
#' displacement dynamics in a country like Mozambique are not missed due to
#' previous large displacements due to natural disasters.
#' * Global flags based on static thresholds. These are calculated for total
#' daily displacement in a country from daily to yearly to find overall
#' anomalies. The thresholds are set based on the quantiles for displacement
#' data in the database by the end of 2022. Details in
#' [idmc::df_thresholds_lim].
#' * Flags if there is displacement for the first time in 3 months, 6 months,
#' or one year.
#'
#' For country-level and global flags, a minimum number of individuals are
#' needed across all timepoints. This is defined in [idmc::df_thresholds_min].
#'
#' @param df Event displacement data frame, generated from [idmc_rolling_sum()].
#'
#' @examplesIf interactive()
#' idmc_get_data() %>%
#'   idmc_transform_daily() %>%
#'   idmc_rolling_sum() %>%
#'   idmc_flagging()
#'
#' @importFrom dplyr .data
#'
#' @export
idmc_flagging <- function(df) {
  # check columns presence
  group_cols <- c("iso3", "country", "displacement_type")
  displacement_cols <- paste0(
    "displacement_",
    c("weekly", "monthly", "quarterly", "yearly")
  )

  assert_df_cols(
    df = df,
    cols = c(group_cols, "date", displacement_cols),
    derived_from = "idmc_rolling_sum()"
  )

  # flag all anomalies by country and type
  df_flagged <- df %>%
    dplyr::group_by(
      dplyr::across(
        dplyr::all_of(c(!!group_cols))
      )
    ) %>%
    dplyr::mutate(
      dplyr::across(
        .cols = dplyr::any_of(!!displacement_cols),
        .fns = list(
          "flag" = ~ flag_percent(.x, col = dplyr::cur_column()),
          "flag_global" = ~ flag_percent_global(
            x = .x,
            col = dplyr::cur_column(),
            group = dplyr::cur_group()
          )
        ),
        .names = "{.fn}_{.col}"
      ),
      chk_dly = .data$displacement_daily > 0,
      chk_qrt = dplyr::lag(.data$displacement_quarterly) == 0,
      chk_qrt2 = dplyr::lag(.data$displacement_quarterly, n = 2) == 0,
      chk_yrl = dplyr::lag(.data$displacement_yearly) == 0,
      flag_1st_3_months = .data$chk_dly & .data$chk_qrt,
      flag_1st_6_months = .data$chk_dly & .data$chk_qrt & .data$chk_qrt2,
      flag_1st_year = .data$chk_dly & .data$chk_yrl
    ) %>%
    dplyr::select(
      -dplyr::starts_with("chk_")
    ) %>%
    dplyr::ungroup() %>%
    dplyr::rename_with(
      .fn = ~ tolower(stringr::str_remove(.x, "displacement_")),
      .cols = dplyr::starts_with("flag_")
    )

  # look at total flags
  # faster to pivot than do rowwise sums
  df_flagged_total <- df_flagged %>%
    tidyr::pivot_longer(
      cols = tidyr::starts_with("flag_")
    ) %>%
    dplyr::group_by(
      .data$iso3,
      .data$date,
      .data$displacement_type
    ) %>%
    dplyr::summarize(
      flag_total = sum(.data[["value"]], na.rm = TRUE),
      flag_any = any(.data[["value"]], na.rm = TRUE)
    )

  # return all
  dplyr::left_join(
    df_flagged,
    df_flagged_total,
    by = c("iso3", "date", "displacement_type")
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
flag_percent <- function(x, col, perc = 0.95, exclude_zero = TRUE) {
  time_col <- stringr::str_match(col, "displacement_(.*)")[2]
  lim_min <- idmc::df_thresholds_min[1, time_col]
  lim <- flag_lim(x = x, perc = perc, exclude_zero = exclude_zero)
  x >= max(lim, lim_min)
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

#' Flag values in top percentiles based on set thresholds
#'
#' Minimum flag is set at 100.
#'
#' @param x Numeric vector
#' @param col Column name to identify displacement timeline
#' @param group Group, used to identify displacement type
#'
#' @noRd
flag_percent_global <- function(x, col, group) {
  time_col <- stringr::str_match(col, "displacement_(.*)")[2]
  lim <- idmc::df_thresholds_lim[group[["displacement_type"]], time_col]
  lim_min <- idmc::df_thresholds_min[1, time_col]
  x >= max(lim, lim_min)
}
