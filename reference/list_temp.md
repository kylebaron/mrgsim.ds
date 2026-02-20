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
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1be21a0f3df6.parquet
#> - mrgsims-ds-1be223db5891.parquet
#>    ...
#> - mrgsims-ds-1be28cc4b33.parquet
#> - mrgsims-ds-1be2d1437aa.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1be21a0f3df6.parquet
#> - mrgsims-ds-1be223db5891.parquet
#>    ...
#> - mrgsims-ds-1be28cc4b33.parquet
#> - mrgsims-ds-1be2d1437aa.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1be21a0f3df6.parquet
#> - mrgsims-ds-1be237c69c49.parquet
#>    ...
#> - mrgsims-ds-1be27bbee412.parquet
#> - mrgsims-ds-1be2d1437aa.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
