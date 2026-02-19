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
#> - mrgsims-ds-1bc411f441ae.parquet
#> - mrgsims-ds-1bc414ef6ba6.parquet
#>    ...
#> - mrgsims-ds-1bc45352f0bc.parquet
#> - mrgsims-ds-1bc45ee0d04.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1bc411f441ae.parquet
#> - mrgsims-ds-1bc414ef6ba6.parquet
#>    ...
#> - mrgsims-ds-1bc45352f0bc.parquet
#> - mrgsims-ds-1bc45ee0d04.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1bc414ef6ba6.parquet
#> - mrgsims-ds-1bc415feec8b.parquet
#>    ...
#> - mrgsims-ds-1bc45352f0bc.parquet
#> - mrgsims-ds-1bc45ee0d04.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
