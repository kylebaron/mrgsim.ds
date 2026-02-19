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
#> > Objects: 7 | Files: 16 | Size: 276.9 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-1b99182bdd95.parquet 0x55d31b3101e8
#> 2  mrgsims-ds-1b99290c466a.parquet 0x55d31654da00
#> 3  mrgsims-ds-1b9974d67efd.parquet 0x55d31b3101e8
#> 4   mrgsims-ds-1b993192ffb.parquet 0x55d3169efb08
#> 5  mrgsims-ds-1b99687907e8.parquet 0x55d31b3101e8
#> 6  mrgsims-ds-1b991315f0d5.parquet 0x55d31b3101e8
#> 7             mrgsims-ds-1.parquet 0x55d31da90a00
#> 8  mrgsims-ds-1b991ac06322.parquet 0x55d31b3101e8
#> 9                  example.parquet 0x55d319bb4b88
#> 10 mrgsims-ds-1b9915bd8307.parquet 0x55d316535a00
#> 11  mrgsims-ds-1b9924179f4.parquet 0x55d31b3101e8
#> 12 mrgsims-ds-1b995c15d0ee.parquet 0x55d31b3101e8
#> 13  mrgsims-ds-1b99e6f7145.parquet 0x55d31ad36528
#> 14 mrgsims-ds-1b9949650fea.parquet 0x55d31b3101e8
#> 15 mrgsims-ds-1b994c4b9041.parquet 0x55d31b3101e8
#> 16 mrgsims-ds-1b995bf5fa94.parquet 0x55d31b3101e8

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 8 | Files: 18 | Size: 330.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
