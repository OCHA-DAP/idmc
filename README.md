
<!-- README.md is generated from README.Rmd. Please edit that file -->

# idmc

<!-- badges: start -->

[![R-CMD-check](https://github.com/caldwellst/idmc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/caldwellst/idmc/actions/workflows/R-CMD-check.yaml)
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
#> # A tibble: 15,601 × 24
#>       id country iso3  latit…¹ longi…² centr…³ displ…⁴ quali…⁵ figure displace…⁶
#>    <int> <chr>   <chr>   <dbl>   <dbl> <chr>   <chr>   <chr>    <int> <date>    
#>  1 92984 Sudan   SDN     20        36  [20, 3… Disast… total     1000 2022-12-15
#>  2 93265 Philip… PHL      5.98    126. [5.977… Disast… total       24 2022-12-05
#>  3 93202 Indone… IDN     -8.11    113. [-8.10… Disast… total     2489 2022-12-05
#>  4 93257 Indone… IDN     -6.93    108. [-6.93… Disast… total        4 2022-12-03
#>  5 93276 Vietnam VNM     15.6     108. [15.59… Disast… total        5 2022-12-03
#>  6 93277 Vietnam VNM     10.6     105. [10.57… Disast… total      144 2022-12-03
#>  7 93199 Indone… IDN     -6.30    107. [-6.29… Disast… total       62 2022-12-01
#>  8 93269 Philip… PHL      6.55    124. [6.55,… Confli… total      474 2022-11-30
#>  9 93200 Indone… IDN     -6.75    111. [-6.75… Disast… total      200 2022-11-30
#> 10 93083 Philip… PHL     10.4     123  [10.41… Confli… total      468 2022-11-28
#> # … with 15,591 more rows, 14 more variables: displacement_start_date <date>,
#> #   displacement_end_date <date>, year <int>, event_name <chr>,
#> #   event_start_date <date>, event_end_date <date>, category <chr>,
#> #   subcategory <chr>, type <chr>, subtype <chr>, standard_popup_text <chr>,
#> #   standard_info_text <chr>, old_id <chr>, created_at <date>, and abbreviated
#> #   variable names ¹​latitude, ²​longitude, ³​centroid, ⁴​displacement_type,
#> #   ⁵​qualifier, ⁶​displacement_date
```

This data frame, with variables described in the [API
documentation](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf),
includes 1 row per event. To generate daily displacement data across all
events for a country and type of displacement, we can use
`idmc_transform_daily()`.

``` r
df_daily <- idmc_transform_daily(df)
df_daily
#> # A tibble: 61,518 × 5
#>    iso3  country    displacement_type date       displacement_daily
#>    <chr> <chr>      <chr>             <date>                  <dbl>
#>  1 AB9   Abyei Area Conflict          2020-01-20               600 
#>  2 AB9   Abyei Area Conflict          2020-01-21               600 
#>  3 AB9   Abyei Area Conflict          2020-01-22               600 
#>  4 AB9   Abyei Area Conflict          2020-01-23               600 
#>  5 AB9   Abyei Area Conflict          2020-01-24               600 
#>  6 AB9   Abyei Area Conflict          2020-01-25               600 
#>  7 AB9   Abyei Area Conflict          2020-01-26               600 
#>  8 AB9   Abyei Area Conflict          2020-01-27               600 
#>  9 AB9   Abyei Area Conflict          2020-04-13               260 
#> 10 AB9   Abyei Area Conflict          2022-02-10              9853.
#> # … with 61,508 more rows
```

We can also generate displacement aggregates across time, such as weekly
or yearly simply using `idmc_rolling_sum()`.

``` r
df_rolling <- idmc_rolling_sum(df_daily)
df_rolling
#> # A tibble: 526,710 × 9
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
#> # … with 526,700 more rows, and abbreviated variable names ¹​displacement_type,
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
#> # A tibble: 349,330 × 33
#>    iso3  country    date       displac…¹ displ…² displ…³ displ…⁴ displ…⁵ flag_…⁶
#>    <chr> <chr>      <date>         <dbl>   <dbl>   <dbl>   <dbl>   <dbl> <lgl>  
#>  1 AB9   Abyei Area 2018-01-01         0      NA      NA      NA      NA FALSE  
#>  2 AB9   Abyei Area 2018-01-02         0      NA      NA      NA      NA FALSE  
#>  3 AB9   Abyei Area 2018-01-03         0      NA      NA      NA      NA FALSE  
#>  4 AB9   Abyei Area 2018-01-04         0      NA      NA      NA      NA FALSE  
#>  5 AB9   Abyei Area 2018-01-05         0      NA      NA      NA      NA FALSE  
#>  6 AB9   Abyei Area 2018-01-06         0      NA      NA      NA      NA FALSE  
#>  7 AB9   Abyei Area 2018-01-07         0       0      NA      NA      NA FALSE  
#>  8 AB9   Abyei Area 2018-01-08         0       0      NA      NA      NA FALSE  
#>  9 AB9   Abyei Area 2018-01-09         0       0      NA      NA      NA FALSE  
#> 10 AB9   Abyei Area 2018-01-10         0       0      NA      NA      NA FALSE  
#> # … with 349,320 more rows, 24 more variables: flag_daily_disaster <lgl>,
#> #   flag_daily_other <lgl>, flag_weekly_conflict <lgl>,
#> #   flag_weekly_disaster <lgl>, flag_weekly_other <lgl>,
#> #   flag_monthly_conflict <lgl>, flag_monthly_disaster <lgl>,
#> #   flag_monthly_other <lgl>, flag_quarterly_conflict <lgl>,
#> #   flag_quarterly_disaster <lgl>, flag_quarterly_other <lgl>,
#> #   flag_yearly_conflict <lgl>, flag_yearly_disaster <lgl>, …
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
