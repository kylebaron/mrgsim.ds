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
#> - mrgsims-ds-1b991315f0d5.parquet
#> - mrgsims-ds-1b9915bd8307.parquet
#>    ...
#> - mrgsims-ds-1b9974d67efd.parquet
#> - mrgsims-ds-1b99e6f7145.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1b991315f0d5.parquet
#> - mrgsims-ds-1b9915bd8307.parquet
#>    ...
#> - mrgsims-ds-1b9974d67efd.parquet
#> - mrgsims-ds-1b99e6f7145.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b991315f0d5.parquet
#> - mrgsims-ds-1b99182bdd95.parquet
#>    ...
#> - mrgsims-ds-1b99687907e8.parquet
#> - mrgsims-ds-1b9974d67efd.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
