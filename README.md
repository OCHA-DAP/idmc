
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
#> # A tibble: 15,168 × 24
#>       id country iso3  latit…¹ longi…² centr…³ displ…⁴ quali…⁵ figure displace…⁶
#>    <int> <chr>   <chr>   <dbl>   <dbl> <chr>   <chr>   <chr>    <int> <date>    
#>  1 82231 Malays… MYS      6.36   100.  [6.364… Disast… total      104 2022-10-26
#>  2 83287 United… USA     34.2    -92.1 [34.16… Disast… approx…     25 2022-10-26
#>  3 82337 Indone… IDN     -7.39   109.  [-7.38… Disast… total      384 2022-10-26
#>  4 81331 India   IND     23.7     91.6 [23.73… Disast… approx…     69 2022-10-25
#>  5 81330 India   IND     23.2     92.9 [23.23… Disast… approx…      5 2022-10-25
#>  6 81329 India   IND     28.0     95.1 [28.01… Disast… approx…    105 2022-10-25
#>  7 81328 India   IND     22.2     88.4 [22.17… Disast… total    65000 2022-10-25
#>  8 81059 Indone… IDN     -7.39   109.  [-7.38… Disast… total      177 2022-10-25
#>  9 83213 Philip… PHL     17.4    121.  [17.35… Disast… total      641 2022-10-25
#> 10 82336 Indone… IDN     -8.17   114.  [-8.16… Disast… total        8 2022-10-25
#> # … with 15,158 more rows, 14 more variables: displacement_start_date <date>,
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
#> # A tibble: 58,738 × 5
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
#> # … with 58,728 more rows
```

We can also generate displacement aggregates across time, such as weekly
or yearly simply using `idmc_rolling_sum()`.

``` r
df_rolling <- idmc_rolling_sum(df_daily)
df_rolling
#> # A tibble: 510,400 × 9
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
#> # … with 510,390 more rows, and abbreviated variable names ¹​displacement_type,
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
#> # A tibble: 337,920 × 33
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
#> # … with 337,910 more rows, 24 more variables: flag_daily_disaster <lgl>,
#> #   flag_daily_other <lgl>, flag_weekly_conflict <lgl>,
#> #   flag_weekly_disaster <lgl>, flag_weekly_other <lgl>,
#> #   flag_monthly_conflict <lgl>, flag_monthly_disaster <lgl>,
#> #   flag_monthly_other <lgl>, flag_quarterly_conflict <lgl>,
#> #   flag_quarterly_disaster <lgl>, flag_quarterly_other <lgl>,
#> #   flag_yearly_conflict <lgl>, flag_yearly_disaster <lgl>, …
```

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
