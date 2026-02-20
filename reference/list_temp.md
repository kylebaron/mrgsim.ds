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
#> - mrgsims-ds-1b9c1848fcbe.parquet
#> - mrgsims-ds-1b9c185c1434.parquet
#>    ...
#> - mrgsims-ds-1b9c7ff4a467.parquet
#> - mrgsims-ds-1b9cc87f4d6.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1b9c1848fcbe.parquet
#> - mrgsims-ds-1b9c185c1434.parquet
#>    ...
#> - mrgsims-ds-1b9c7ff4a467.parquet
#> - mrgsims-ds-1b9cc87f4d6.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b9c1848fcbe.parquet
#> - mrgsims-ds-1b9c185c1434.parquet
#>    ...
#> - mrgsims-ds-1b9c7a8ad408.parquet
#> - mrgsims-ds-1b9c7ff4a467.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
