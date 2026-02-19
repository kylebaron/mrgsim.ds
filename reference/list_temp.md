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
#> - mrgsims-ds-195d15f9f5fc.parquet
#> - mrgsims-ds-195d27b4d7e4.parquet
#>    ...
#> - mrgsims-ds-195d7f0709c5.parquet
#> - mrgsims-ds-195dbef36a5.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-195d15f9f5fc.parquet
#> - mrgsims-ds-195d27b4d7e4.parquet
#>    ...
#> - mrgsims-ds-195d7f0709c5.parquet
#> - mrgsims-ds-195dbef36a5.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-195d15f9f5fc.parquet
#> - mrgsims-ds-195d3d48765a.parquet
#>    ...
#> - mrgsims-ds-195d7f0709c5.parquet
#> - mrgsims-ds-195dbef36a5.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
