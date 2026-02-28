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
#> - mrgsims-ds-1977162e7223.parquet
#> - mrgsims-ds-197719a1a200.parquet
#>    ...
#> - mrgsims-ds-197777af0526.parquet
#> - mrgsims-ds-1977f568718.parquet

sims <- reduce_ds(out)

list_temp()
#> 16 files [148.9 Kb]
#> - mrgsims-ds-1977162e7223.parquet
#> - mrgsims-ds-197719a1a200.parquet
#>    ...
#> - mrgsims-ds-197777af0526.parquet
#> - mrgsims-ds-1977f568718.parquet

retain_temp(sims)
#> Discarding 6 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-197719a1a200.parquet
#> - mrgsims-ds-19771b2f406d.parquet
#>    ...
#> - mrgsims-ds-197777af0526.parquet
#> - mrgsims-ds-1977f568718.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
