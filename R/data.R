#' Displacement thresholds data frame
#'
#' A data frame of global thresholds for flagging different types of
#' displacement (Conflict, Disaster, and Other) across different periods of
#' time (weekly, monthly, quarterly, and yearly). Thresholds were set to
#' be a clear whole number near to but below the 95th percentile of data
#' calculated for all data uploaded in the database at the end of 2022.
#'
#' Used with [idmc_flagging()] to generate the global flags that do not rely on
#' country-level anomalies. Displacement for that time frame above the threshold
#' is flagged, as long as it is greater than the minimum for flagging, defined
#' in [idmc::df_thresholds_min].
#'
#' @format
#' A data frame with 3 rows and 4 columns:
#' \describe{
#'   \item{weekly}{Weekly thresholds.}
#'   \item{monthly}{Monthly thresholds.}
#'   \item{quarterly}{Quarterlythresholds.}
#'   \item{yearly}{Yearly thresholds.}
#' }
"df_thresholds_lim"

#' Displacement threshold minimum data frame
#'
#' A data frame of global minimums for flagging across different periods of
#' time (weekly, monthly, quarterly, and yearly). Thresholds were set based on
#' agreement with CERF to reduce the total number of flags.
#'
#' Used with [idmc_flagging()] to generate the global flags that do not rely on
#' country-level anomalies. Displacement for that time frame below the threshold
#' minimum will not flag, even if it is greater than the country anomaly
#' threshold.
#'
#' @format
#' A data frame with 1 rows and 4 columns:
#' \describe{
#'   \item{weekly}{Weekly thresholds.}
#'   \item{monthly}{Monthly thresholds.}
#'   \item{quarterly}{Quarterlythresholds.}
#'   \item{yearly}{Yearly thresholds.}
#' }
"df_thresholds_min"
