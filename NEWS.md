# Development

* Fixed regex for extracting `event_info` in `idmc_get_data()`.

# idmc 0.3.0

* Fully removed deprecated functions `idmc_rolling_sum()` and `idmc_flagging()`
to bring package to stable release.
* Improved documentation to include examples that run if `IDMC_API` environment
variable is available and clear return values.
* Ensure vignette does not run if `IDMC_API` environment variable not available.
* Removed memoization functionality for API call to pass CRAN checks.
* Initial release on CRAN.

# idmc 0.2.0

* `idmc_flagging()` and `idmc_rolling_sum()` deprecated as package focus pared
back.
* `idmc_rolling_sum()` functionality for infilling and extrapolation put into
`idmc_transform_daily()`.


# idmc 0.1.5

* Minimum thresholds increased in `df_thresholds_min` based on feedback from
CERF

# idmc 0.1.4

* `idmc_flagging()` adjusted to account for different displacement types
when generating `flag_total` and `flag_any`.

# idmc 0.1.3

* Implement pre-commit for development.
* Fix error in `idmc_rolling_sum()`.

# idmc 0.1.2

* Change `idmc_rolling_sum()` to not extrapolate past `Sys.date()` by
default.

# idmc 0.1.1

* Added a `NEWS.md` file to track changes to the package.
* Uses [lifecycle](https://github.com/r-lib/lifecycle) to track package status.
* Implemented minimum thresholds for flagging in `df_thresholds_min`.

# idmc 0.1.0

* Initial package release.
