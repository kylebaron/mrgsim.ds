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
#> - mrgsims-ds-1bd619dc704a.parquet
#> - mrgsims-ds-1bd61a105f6.parquet
#>    ...
#> - mrgsims-ds-1bd67d98c78b.parquet
#> - mrgsims-ds-1bd67ed46322.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [115.5 Kb]
#> - mrgsims-ds-1bd619dc704a.parquet
#> - mrgsims-ds-1bd61a105f6.parquet
#>    ...
#> - mrgsims-ds-1bd67d98c78b.parquet
#> - mrgsims-ds-1bd67ed46322.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1bd619dc704a.parquet
#> - mrgsims-ds-1bd620a1be72.parquet
#>    ...
#> - mrgsims-ds-1bd6780901fd.parquet
#> - mrgsims-ds-1bd67d98c78b.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
