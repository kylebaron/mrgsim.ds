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
#> - mrgsims-ds-1b8a1812c7d5.parquet
#> - mrgsims-ds-1b8a1c79f6f1.parquet
#>    ...
#> - mrgsims-ds-1b8a5a8a4f99.parquet
#> - mrgsims-ds-1b8a62aa368.parquet

sims <- reduce_ds(out)

list_temp()
#> 12 files [60.2 Kb]
#> - mrgsims-ds-1b8a1812c7d5.parquet
#> - mrgsims-ds-1b8a1c79f6f1.parquet
#>    ...
#> - mrgsims-ds-1b8a5a8a4f99.parquet
#> - mrgsims-ds-1b8a62aa368.parquet

retain_temp(sims)
#> Discarding 2 files.

list_temp() 
#> 10 files [51.3 Kb]
#> - mrgsims-ds-1b8a1812c7d5.parquet
#> - mrgsims-ds-1b8a1c79f6f1.parquet
#>    ...
#> - mrgsims-ds-1b8a57f1318a.parquet
#> - mrgsims-ds-1b8a5a8a4f99.parquet

purge_temp() 
#> Discarding 10 files.

list_temp()
#> No files in tempdir.
```
