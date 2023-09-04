
<!-- README.md is generated from README.Rmd. Please edit that file -->

# idmc

<!-- badges: start -->

[![R-CMD-check](https://github.com/OCHA-DAP/idmc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/OCHA-DAP/idmc/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of idmc is to provide easy access and wrangling of displacement
data stored in the [Internal Displacement Monitoring
Centre’s](https://www.internal-displacement.org) (IDMC) displacement
database. The data is retrieved from the [Internal Displacement Update
API](https://www.internal-displacement.org/sites/default/files/IDMC_IDU_API_Codebook_14102020.pdf).

## Installation

You can install idmc from CRAN:

``` r
install.packages("idmc")
```

Alternatively, you can install the development version of idmc from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("OCHA-DAP/idmc")
```

## API URL

You need an IDMC endpoint URL to access the API. These are provided by
IDMC. The easiest way to save the URL for use in your R sessions is by
using `usethis::edit_r_environ()` and adding the variable there as:

    IDMC_API="Insert API URL here"

## Usage

``` r
library(idmc)
```

The simple use for the `idmc` package is to retrieve the data from the
API directly into R.

``` r
df <- idmc_get_data()
df
#> # A tibble: 20,289 × 26
#>        id country  iso3  latitude longitude centroid displacement_type qualifier
#>     <int> <chr>    <chr>    <dbl>     <dbl> <chr>    <chr>             <chr>    
#>  1 120233 United … USA      31.1     -93.2  [31.114… Disaster          total    
#>  2 120186 United … USA      39.1     -94.5  [39.092… Disaster          total    
#>  3 120191 United … USA      44.9    -123.   [44.912… Disaster          total    
#>  4 120197 Dominic… DOM      19.3     -70.0  [19.281… Disaster          total    
#>  5 120195 Dominic… DOM      19.3     -70.0  [19.281… Disaster          total    
#>  6 120110 France   FRA      44.5       6.47 [44.498… Disaster          more than
#>  7 120124 Indones… IDN      -7.46    109.   [-7.458… Disaster          total    
#>  8 120188 United … USA      30.7     -93.5  [30.706… Disaster          total    
#>  9 120208 Viet Nam VNM      22.8     105.   [22.779… Disaster          total    
#> 10 120047 Philipp… PHL       6.85    124.   [6.8514… Disaster          total    
#> # ℹ 20,279 more rows
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
#> # A tibble: 71,750 × 5
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
#> # ℹ 71,740 more rows
```

While there are a few other parameters you can play around with in these
functions, this is the primary purpose of this simple package.
