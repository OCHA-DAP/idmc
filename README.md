
<!-- README.md is generated from README.Rmd. Please edit that file -->

# idmc

<!-- badges: start -->

[![R-CMD-check](https://github.com/caldwellst/idmc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/caldwellst/idmc/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of idmc is to provide easy access and wrangling of displacement
data stored in the [Internal Displacement Monitoring
Centre’s](https://www.internal-displacement.org) displacement database.
The data is retrieved from the [Internal Displacement Update
API](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf).

## Installation

You can install the development version of idmc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ocha-dap/idmc")
```

## Usage

``` r
library(idmc)
```

The simplest use case for the `idmc` package is to retrieve the data
from the API directly into R.

``` r
df <- idmc_get_data()
df
#> # A tibble: 16,266 × 26
#>        id country           iso3  latit…¹ longi…² centr…³ displ…⁴ quali…⁵ figure
#>     <int> <chr>             <chr>   <dbl>   <dbl> <chr>   <chr>   <chr>    <int>
#>  1 100701 West Bank and Ga… PSE     31.9     35.3 [31.94… Confli… total       65
#>  2 103365 Indonesia         IDN     -7.71   111.  [-7.70… Disast… total        4
#>  3 103358 Sri Lanka         LKA      9.47    80.5 [9.467… Disast… total        4
#>  4 103287 Türkiye           TUR     37.5     37.4 [37.47… Disast… total   380500
#>  5 103349 Philippines       PHL      9.89   123.  [9.891… Confli… total      391
#>  6 103263 Indonesia         IDN     -2.97   120.  [-2.96… Disast… total      155
#>  7 103268 Indonesia         IDN     -7.53   111.  [-7.53… Disast… total       19
#>  8 103361 Sri Lanka         LKA      7.04    81.2 [7.041… Disast… total       12
#>  9 103262 Indonesia         IDN    -10.2    124.  [-10.1… Disast… total       27
#> 10 103356 Philippines       PHL     17.9    122.  [17.93… Confli… total      235
#> # … with 16,256 more rows, 17 more variables: displacement_date <date>,
#> #   displacement_start_date <date>, displacement_end_date <date>, year <int>,
#> #   event_name <chr>, event_start_date <date>, event_end_date <date>,
#> #   category <chr>, subcategory <chr>, type <chr>, subtype <chr>,
#> #   standard_popup_text <chr>, event_url <chr>, event_info <chr>,
#> #   standard_info_text <chr>, old_id <chr>, created_at <date>, and abbreviated
#> #   variable names ¹​latitude, ²​longitude, ³​centroid, ⁴​displacement_type, …
```

This data frame, with variables described in the [API
documentation](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf),
includes 1 row per event. To generate daily displacement data across all
events for a country and type of displacement, we can use
`idmc_transform_daily()`.

``` r
df_daily <- idmc_transform_daily(df)
df_daily
#> # A tibble: 63,684 × 5
#>    iso3  country    displacement_type date       displacement_daily
#>    <chr> <chr>      <chr>             <date>                  <dbl>
#>  1 AB9   Abyei Area Conflict          2020-01-20              600  
#>  2 AB9   Abyei Area Conflict          2020-01-21              600  
#>  3 AB9   Abyei Area Conflict          2020-01-22              600  
#>  4 AB9   Abyei Area Conflict          2020-01-23              600  
#>  5 AB9   Abyei Area Conflict          2020-01-24              600  
#>  6 AB9   Abyei Area Conflict          2020-01-25              600  
#>  7 AB9   Abyei Area Conflict          2020-01-26              600  
#>  8 AB9   Abyei Area Conflict          2020-01-27              600  
#>  9 AB9   Abyei Area Conflict          2020-04-13              260  
#> 10 AB9   Abyei Area Conflict          2022-02-01               13.3
#> # … with 63,674 more rows
```

We can also generate displacement aggregates across time, such as weekly
or yearly simply using `idmc_rolling_sum()`.

``` r
df_rolling <- idmc_rolling_sum(df_daily)
df_rolling
#> # A tibble: 637,581 × 9
#>    iso3  country    displac…¹ date       displ…² displ…³ displ…⁴ displ…⁵ displ…⁶
#>    <chr> <chr>      <chr>     <date>       <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#>  1 AB9   Abyei Area Conflict  2018-01-01       0      NA      NA      NA      NA
#>  2 AB9   Abyei Area Conflict  2018-01-02       0      NA      NA      NA      NA
#>  3 AB9   Abyei Area Conflict  2018-01-03       0      NA      NA      NA      NA
#>  4 AB9   Abyei Area Conflict  2018-01-04       0      NA      NA      NA      NA
#>  5 AB9   Abyei Area Conflict  2018-01-05       0      NA      NA      NA      NA
#>  6 AB9   Abyei Area Conflict  2018-01-06       0      NA      NA      NA      NA
#>  7 AB9   Abyei Area Conflict  2018-01-07       0       0      NA      NA      NA
#>  8 AB9   Abyei Area Conflict  2018-01-08       0       0      NA      NA      NA
#>  9 AB9   Abyei Area Conflict  2018-01-09       0       0      NA      NA      NA
#> 10 AB9   Abyei Area Conflict  2018-01-10       0       0      NA      NA      NA
#> # … with 637,571 more rows, and abbreviated variable names ¹​displacement_type,
#> #   ²​displacement_daily, ³​displacement_weekly, ⁴​displacement_monthly,
#> #   ⁵​displacement_quarterly, ⁶​displacement_yearly
```

Last, part of the use of this data is to flag abnormal levels of
displacement. These flags are generated through `idmc_flagging()` and
the function is also made available for other interested users. However,
note that these flags are under development and simply meant to be
indicative of potential anomalies.

``` r
df_flagging <- idmc_flagging(df_rolling)
df_flagging
#> # A tibble: 637,581 × 26
#>    iso3  country    displac…¹ date       displ…² displ…³ displ…⁴ displ…⁵ displ…⁶
#>    <chr> <chr>      <chr>     <date>       <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#>  1 AB9   Abyei Area Conflict  2018-01-01       0      NA      NA      NA      NA
#>  2 AB9   Abyei Area Conflict  2018-01-02       0      NA      NA      NA      NA
#>  3 AB9   Abyei Area Conflict  2018-01-03       0      NA      NA      NA      NA
#>  4 AB9   Abyei Area Conflict  2018-01-04       0      NA      NA      NA      NA
#>  5 AB9   Abyei Area Conflict  2018-01-05       0      NA      NA      NA      NA
#>  6 AB9   Abyei Area Conflict  2018-01-06       0      NA      NA      NA      NA
#>  7 AB9   Abyei Area Conflict  2018-01-07       0       0      NA      NA      NA
#>  8 AB9   Abyei Area Conflict  2018-01-08       0       0      NA      NA      NA
#>  9 AB9   Abyei Area Conflict  2018-01-09       0       0      NA      NA      NA
#> 10 AB9   Abyei Area Conflict  2018-01-10       0       0      NA      NA      NA
#> # … with 637,571 more rows, 17 more variables: flag_weekly <lgl>,
#> #   flag_monthly <lgl>, flag_quarterly <lgl>, flag_yearly <lgl>,
#> #   flag_global_weekly <lgl>, flag_global_monthly <lgl>,
#> #   flag_global_quarterly <lgl>, flag_global_yearly <lgl>,
#> #   flag_global_flag_weekly <lgl>, flag_global_flag_monthly <lgl>,
#> #   flag_global_flag_quarterly <lgl>, flag_global_flag_yearly <lgl>,
#> #   flag_1st_3_months <lgl>, flag_1st_6_months <lgl>, flag_1st_year <lgl>, …
```

## API URL

You need an API endpoint URL saved to your environment. These are
provided by IDMC. The easiest way to save the URL for use in your R
sessions is by using `usethis::edit_r_environ()` and adding the variable
there as:

    IDMC_API="Insert API URL here"

## Memoisation

`idmc_get_data()`, the function that requests to the IDU API, has cached
functionality based on `memoise::memeoise()` so that calls to the
`idmc_get_data()` function are cached in your local memory in a single
session. This means that once you’ve made a call to retrieve the
displacement data from, the API, running an identical request will use
the cached data rather than re-request the data from the IDU database.

If you need to ensure that the idmc package is making new requests to
the API each time `idmc_get_data()` is called, then you will need to run
`memoise::forget(idmc::idmc_get_data)` to clear the cache prior to
repeating a call. See the documentation of the [memoise
package](https://github.com/r-lib/memoise) for more details.
