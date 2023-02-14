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
