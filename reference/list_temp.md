# Manage simulated outputs in tempdir()

Manage simulated outputs in tempdir()

## Usage

``` r
list_temp()

retain_temp(...)

purge_temp()
```

## Arguments

- ...:

  objects whose files will not be purged.

## Examples

``` r
mod <- house_ds()

out <- lapply(1:10, \(x) mrgsim_ds(mod))

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1965104c02e5.parquet
#> - mrgsims-ds-19651449fc56.parquet
#>    ...
#> - mrgsims-ds-19656f86a56.parquet
#> - mrgsims-ds-19657fc636ce.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1965104c02e5.parquet
#> - mrgsims-ds-19651449fc56.parquet
#>    ...
#> - mrgsims-ds-19656f86a56.parquet
#> - mrgsims-ds-19657fc636ce.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-19651449fc56.parquet
#> - mrgsims-ds-196517e384c4.parquet
#>    ...
#> - mrgsims-ds-196566eebff8.parquet
#> - mrgsims-ds-19657fc636ce.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
