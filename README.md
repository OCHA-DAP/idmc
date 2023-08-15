
<!-- README.md is generated from README.Rmd. Please edit that file -->

# idmc

<!-- badges: start -->

[![R-CMD-check](https://github.com/OCHA-DAP/idmc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/OCHA-DAP/idmc/actions/workflows/R-CMD-check.yaml)
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

The simple use for the `idmc` package is to retrieve the data from the
API directly into R.

``` r
df <- idmc_get_data()
df
#> # A tibble: 19,916 × 26
#>        id country  iso3  latitude longitude centroid displacement_type qualifier
#>     <int> <chr>    <chr>    <dbl>     <dbl> <chr>    <chr>             <chr>    
#>  1 118931 Myanmar  MMR      13.0      98.7  [13.014… Disaster          total    
#>  2 118836 India    IND      20.2      84.7  [20.190… Disaster          total    
#>  3 118595 Canada   CAN      63.6    -136.   [63.595… Disaster          approxim…
#>  4 118909 Viet Nam VNM      12.2     108.   [12.175… Disaster          total    
#>  5 118907 Viet Nam VNM      22.2     104.   [22.176… Disaster          total    
#>  6 118621 Indones… IDN      -1.46    120.   [-1.462… Disaster          total    
#>  7 118593 France   FRA      43.7       3.90 [43.714… Disaster          total    
#>  8 118899 United … USA      58.4    -134.   [58.379… Disaster          total    
#>  9 118827 India    IND      26.1      90.8  [26.054… Disaster          total    
#> 10 118560 China    CHN      37.1     116.   [37.134… Disaster          total    
#> # ℹ 19,906 more rows
#> # ℹ 18 more variables: figure <int>, displacement_date <date>,
#> #   displacement_start_date <date>, displacement_end_date <date>, year <int>,
#> #   event_name <chr>, event_start_date <date>, event_end_date <date>,
#> #   category <chr>, subcategory <chr>, type <chr>, subtype <chr>,
#> #   standard_popup_text <chr>, event_url <chr>, event_info <chr>,
#> #   standard_info_text <chr>, old_id <chr>, created_at <date>
```

This data frame, with variables described in the [API
documentation](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf),
includes 1 row per event. We can normalize this to daily displacement,
assuming uniform distribution of displacement between start and end
date, for all countries and type of displacement.
`idmc_transform_daily()`.

``` r
idmc_transform_daily(df)
#> # A tibble: 71,296 × 5
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
#> 10 AB9   Abyei Area Conflict          2022-02-10              9937.
#> # ℹ 71,286 more rows
```

While there are a few other parameters you can play around with in these
functions, this is the primary purpose of this simple package. \## API
URL

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
