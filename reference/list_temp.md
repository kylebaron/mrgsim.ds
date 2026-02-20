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
#> - mrgsims-ds-1b72105bb4ad.parquet
#> - mrgsims-ds-1b721ecb9978.parquet
#>    ...
#> - mrgsims-ds-1b7279f4d761.parquet
#> - mrgsims-ds-1b72ce0cb8.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1b72105bb4ad.parquet
#> - mrgsims-ds-1b721ecb9978.parquet
#>    ...
#> - mrgsims-ds-1b7279f4d761.parquet
#> - mrgsims-ds-1b72ce0cb8.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b721ecb9978.parquet
#> - mrgsims-ds-1b722b7c78b0.parquet
#>    ...
#> - mrgsims-ds-1b72763a7886.parquet
#> - mrgsims-ds-1b72ce0cb8.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
