# Ownership of simulation files

Functions to check ownership or disown simulation output files on disk.

## Usage

``` r
ownership()

list_ownership(full.names = FALSE)

check_ownership(x)

disown(x)

take_ownership(x)
```

## Arguments

- full.names:

  if `TRUE`, include the directory path when listing file ownership.

- x:

  an mrgsimsds object.

## Value

- `check_ownership`: `TRUE` if `x` owns the underlying files; `FALSE`
  otherwise.

- `list_ownership`: a data.frame of ownership information.

- `ownership`: nothing; used for side effects.

- `disown`: `x` is returned invisibly; it is not modified.

- `take_ownership`: `x` is returned invisibly after getting modified in
  place.

## Details

One situation were you need to take over ownership is when you are
simulating in parallel, and the simulation happens in another R process.
`mrgsim.ds` ownership is established when the simulation returns and the
`mrgsimsds` object is created. When this happens in another R process
(e.g., on a worker node, there is no way to transfer that information
back to the parent process. In that case, a call to `take_ownership()`
once the results are returned to the parent process would be
appropriate. Typically, these results are returned as a list and a call
to
[`reduce_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/reduce_ds.md)
will create a single object pointing to and owning multiple files.
Therefore, it should be rare to call `take_ownership()` directly; if
doing so, please make sure you understand what is going on.

## See also

[`reduce_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/reduce_ds.md),
[`copy_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/copy_ds.md).

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod, id = 1)

check_ownership(out)
#> [1] TRUE

ownership()
#> > Objects: 9 | Files: 18 | Size: 405.9 Kb

list_ownership()
#>                                   file        address
#> 1      mrgsims-ds-1be241648f9f.parquet 0x55f59a8a9d70
#> 2      mrgsims-ds-1be223db5891.parquet 0x55f5940638e8
#> 3       mrgsims-ds-1be2d1437aa.parquet 0x55f59a8a9d70
#> 4      mrgsims-ds-1be237c69c49.parquet 0x55f59a8a9d70
#> 5                      example.parquet 0x55f59819e0a0
#> 6       mrgsims-ds-1be28cc4b33.parquet 0x55f59c975138
#> 7  mrgsims-ds-reg-100-300-0001.parquet 0x55f59e2a0230
#> 8      mrgsims-ds-1be26aaee7a0.parquet 0x55f59a8a9d70
#> 9      mrgsims-ds-1be24244e3d3.parquet 0x55f59a8a9d70
#> 10     mrgsims-ds-1be27cf201cb.parquet 0x55f59c63afc8
#> 11     mrgsims-ds-1be21a0f3df6.parquet 0x55f59a8a9d70
#> 12     mrgsims-ds-1be23eacc495.parquet 0x55f59a8a9d70
#> 13     mrgsims-ds-1be27bbee412.parquet 0x55f59a8a9d70
#> 14     mrgsims-ds-1be22ed6135b.parquet 0x55f5975eb1c0
#> 15     mrgsims-ds-1be241a09d02.parquet 0x55f59ccf0a80
#> 16                mrgsims-ds-1.parquet 0x55f58f9d5a28
#> 17     mrgsims-ds-1be2605c214a.parquet 0x55f59a8a9d70
#> 18     mrgsims-ds-1be24f10f069.parquet 0x55f59a8a9d70

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 10 | Files: 20 | Size: 459.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
