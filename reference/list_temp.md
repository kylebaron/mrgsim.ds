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
#> 15 files [71.2 Kb]
#> - mrgsims-ds-19551205827c.parquet
#> - mrgsims-ds-195523d1697c.parquet
#>    ...
#> - mrgsims-ds-1955e997b59.parquet
#> - mrgsims-ds-1955f85c34d.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-19551205827c.parquet
#> - mrgsims-ds-195523d1697c.parquet
#>    ...
#> - mrgsims-ds-1955e997b59.parquet
#> - mrgsims-ds-1955f85c34d.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-19551205827c.parquet
#> - mrgsims-ds-195523d1697c.parquet
#>    ...
#> - mrgsims-ds-1955e997b59.parquet
#> - mrgsims-ds-1955f85c34d.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
