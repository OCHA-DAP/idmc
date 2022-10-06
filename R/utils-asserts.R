#' Check that all columns in a data frame
#' @param df Data frame
#' @param cols Required columns (character)
#' @param derived_from String of generating function to paste into error msg.
#' @noRd
assert_df_cols <- function(df, cols, derived_from) {
  cols_in_df <- cols %in% names(df)

  if (!all(cols_in_df)) {
    stop(
      "Not all necessary columns present in the data frame. Input `df` should ",
      "be derived from `",
      derived_from,
      "`. Missing columns are: ",
      paste(req_cols[!cols_in_df], collapse = ", "),
      call. = FALSE
    )
  }
}
