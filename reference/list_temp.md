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
#> - mrgsims-ds-19c116c28428.parquet
#> - mrgsims-ds-19c119c13685.parquet
#>    ...
#> - mrgsims-ds-19c178b4748f.parquet
#> - mrgsims-ds-19c17d75316e.parquet

sims <- reduce_ds(out)

list_temp()
#> 16 files [148.9 Kb]
#> - mrgsims-ds-19c116c28428.parquet
#> - mrgsims-ds-19c119c13685.parquet
#>    ...
#> - mrgsims-ds-19c178b4748f.parquet
#> - mrgsims-ds-19c17d75316e.parquet

retain_temp(sims)
#> Discarding 6 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-19c116c28428.parquet
#> - mrgsims-ds-19c11d58a79b.parquet
#>    ...
#> - mrgsims-ds-19c16df957b7.parquet
#> - mrgsims-ds-19c178b4748f.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
