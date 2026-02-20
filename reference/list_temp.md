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
#> - mrgsims-ds-1c1e1a5e2717.parquet
#> - mrgsims-ds-1c1e1ea03961.parquet
#>    ...
#> - mrgsims-ds-1c1e92265e7.parquet
#> - mrgsims-ds-1c1ed37c80b.parquet

sims <- reduce_ds(out)

list_temp()
#> 13 files [63.8 Kb]
#> - mrgsims-ds-1c1e1a5e2717.parquet
#> - mrgsims-ds-1c1e1ea03961.parquet
#>    ...
#> - mrgsims-ds-1c1e92265e7.parquet
#> - mrgsims-ds-1c1ed37c80b.parquet

retain_temp(sims)
#> Discarding 3 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1c1e1a5e2717.parquet
#> - mrgsims-ds-1c1e1ea03961.parquet
#>    ...
#> - mrgsims-ds-1c1e77e5fc5a.parquet
#> - mrgsims-ds-1c1e92265e7.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
