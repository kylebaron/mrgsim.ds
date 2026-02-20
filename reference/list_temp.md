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
#> - mrgsims-ds-1b9d1a7e0a46.parquet
#> - mrgsims-ds-1b9d275254a2.parquet
#>    ...
#> - mrgsims-ds-1b9d78f17ed8.parquet
#> - mrgsims-ds-1b9da6d36b0.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1b9d1a7e0a46.parquet
#> - mrgsims-ds-1b9d275254a2.parquet
#>    ...
#> - mrgsims-ds-1b9d78f17ed8.parquet
#> - mrgsims-ds-1b9da6d36b0.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b9d1a7e0a46.parquet
#> - mrgsims-ds-1b9d275254a2.parquet
#>    ...
#> - mrgsims-ds-1b9d78f17ed8.parquet
#> - mrgsims-ds-1b9da6d36b0.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
