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
#> 13 files [63.8 Kb]
#> - mrgsims-ds-1b9c16449744.parquet
#> - mrgsims-ds-1b9c20dea047.parquet
#>    ...
#> - mrgsims-ds-1b9c6272cf0c.parquet
#> - mrgsims-ds-1b9c99b9b48.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [63.8 Kb]
#> - mrgsims-ds-1b9c16449744.parquet
#> - mrgsims-ds-1b9c20dea047.parquet
#>    ...
#> - mrgsims-ds-1b9c6272cf0c.parquet
#> - mrgsims-ds-1b9c99b9b48.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b9c16449744.parquet
#> - mrgsims-ds-1b9c20dea047.parquet
#>    ...
#> - mrgsims-ds-1b9c5baeb225.parquet
#> - mrgsims-ds-1b9c99b9b48.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
