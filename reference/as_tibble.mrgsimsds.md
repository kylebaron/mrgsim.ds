# Coerce an mrgsimsds object to a tbl

Coerce an mrgsimsds object to a tbl

## Usage

``` r
# S3 method for class 'mrgsimsds'
as_tibble(x, ...)

# S3 method for class 'mrgsimsds'
collect(x, ...)

# S3 method for class 'mrgsimsds'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  an mrgsimsds object.

- ...:

  passed to
  [`dplyr::as_tibble()`](https://dplyr.tidyverse.org/reference/reexports.html)
  or
  [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html).

- row.names:

  passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- optional:

  passed to
  [`base::as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

## Value

A `tbl` containing simulated data.

## Examples

``` r
mod <- house_ds(end = 5)

out <- mrgsim_ds(mod, events = ev(amt = 100))

tibble::as_tibble(out)
#> # A tibble: 22 × 7
#>       ID  time    GUT  CENT  RESP    DV    CP
#>    <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     1  0      0      0    50    0     0   
#>  2     1  0    100      0    50    0     0   
#>  3     1  0.25  74.1   25.7  48.7  1.29  1.29
#>  4     1  0.5   54.9   44.5  46.2  2.23  2.23
#>  5     1  0.75  40.7   58.1  43.6  2.90  2.90
#>  6     1  1     30.1   67.8  41.4  3.39  3.39
#>  7     1  1.25  22.3   74.7  39.6  3.74  3.74
#>  8     1  1.5   16.5   79.6  38.2  3.98  3.98
#>  9     1  1.75  12.2   82.8  37.1  4.14  4.14
#> 10     1  2      9.07  85.0  36.4  4.25  4.25
#> # ℹ 12 more rows

dplyr::collect(out)
#> # A tibble: 22 × 7
#>       ID  time    GUT  CENT  RESP    DV    CP
#>    <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     1  0      0      0    50    0     0   
#>  2     1  0    100      0    50    0     0   
#>  3     1  0.25  74.1   25.7  48.7  1.29  1.29
#>  4     1  0.5   54.9   44.5  46.2  2.23  2.23
#>  5     1  0.75  40.7   58.1  43.6  2.90  2.90
#>  6     1  1     30.1   67.8  41.4  3.39  3.39
#>  7     1  1.25  22.3   74.7  39.6  3.74  3.74
#>  8     1  1.5   16.5   79.6  38.2  3.98  3.98
#>  9     1  1.75  12.2   82.8  37.1  4.14  4.14
#> 10     1  2      9.07  85.0  36.4  4.25  4.25
#> # ℹ 12 more rows
```
