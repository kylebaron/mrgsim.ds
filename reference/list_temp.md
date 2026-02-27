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
#> 16 files [148.9 Kb]
#> - mrgsims-ds-19b71ac4cc58.parquet
#> - mrgsims-ds-19b71fce4d22.parquet
#>    ...
#> - mrgsims-ds-19b77e5c10b0.parquet
#> - mrgsims-ds-19b799d3fa7.parquet

sims <- reduce_ds(out)

list_temp()
#> 16 files [148.9 Kb]
#> - mrgsims-ds-19b71ac4cc58.parquet
#> - mrgsims-ds-19b71fce4d22.parquet
#>    ...
#> - mrgsims-ds-19b77e5c10b0.parquet
#> - mrgsims-ds-19b799d3fa7.parquet

retain_temp(sims)
#> Discarding 6 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-19b71fce4d22.parquet
#> - mrgsims-ds-19b7246900a2.parquet
#>    ...
#> - mrgsims-ds-19b77e5c10b0.parquet
#> - mrgsims-ds-19b799d3fa7.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
