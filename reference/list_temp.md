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
#> - mrgsims-ds-1b5c2ad133c1.parquet
#> - mrgsims-ds-1b5c388e0006.parquet
#>    ...
#> - mrgsims-ds-1b5c7e845d9.parquet
#> - mrgsims-ds-1b5ca2909ef.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1b5c2ad133c1.parquet
#> - mrgsims-ds-1b5c388e0006.parquet
#>    ...
#> - mrgsims-ds-1b5c7e845d9.parquet
#> - mrgsims-ds-1b5ca2909ef.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b5c388e0006.parquet
#> - mrgsims-ds-1b5c3c6d3324.parquet
#>    ...
#> - mrgsims-ds-1b5c7e845d9.parquet
#> - mrgsims-ds-1b5ca2909ef.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
