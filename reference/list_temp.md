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
#> - mrgsims-ds-1a1e12601d4e.parquet
#> - mrgsims-ds-1a1e13d363b9.parquet
#>    ...
#> - mrgsims-ds-1a1e77dc4517.parquet
#> - mrgsims-ds-1a1e7fa59d41.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [63.8 Kb]
#> - mrgsims-ds-1a1e12601d4e.parquet
#> - mrgsims-ds-1a1e13d363b9.parquet
#>    ...
#> - mrgsims-ds-1a1e77dc4517.parquet
#> - mrgsims-ds-1a1e7fa59d41.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1a1e12601d4e.parquet
#> - mrgsims-ds-1a1e13d363b9.parquet
#>    ...
#> - mrgsims-ds-1a1e769062d8.parquet
#> - mrgsims-ds-1a1e77dc4517.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
