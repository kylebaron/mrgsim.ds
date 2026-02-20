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
#> - mrgsims-ds-1bb514a1bad6.parquet
#> - mrgsims-ds-1bb518162ee6.parquet
#>    ...
#> - mrgsims-ds-1bb5bcae9a1.parquet
#> - mrgsims-ds-1bb5d2a718c.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1bb514a1bad6.parquet
#> - mrgsims-ds-1bb518162ee6.parquet
#>    ...
#> - mrgsims-ds-1bb5bcae9a1.parquet
#> - mrgsims-ds-1bb5d2a718c.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1bb518162ee6.parquet
#> - mrgsims-ds-1bb52540d45f.parquet
#>    ...
#> - mrgsims-ds-1bb5bcae9a1.parquet
#> - mrgsims-ds-1bb5d2a718c.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
