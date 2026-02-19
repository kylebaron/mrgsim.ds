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
#> Objects: 7 | Files: 16 | Size: 276.9 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-195d15f9f5fc.parquet 0x5614dde957c0
#> 2  mrgsims-ds-195d7d235495.parquet 0x5614dde957c0
#> 3  mrgsims-ds-195d34cdcc06.parquet 0x5614d5bc71e8
#> 4  mrgsims-ds-195d523fa2e4.parquet 0x5614dde957c0
#> 5  mrgsims-ds-195d47dac2d0.parquet 0x5614dde957c0
#> 6                  example.parquet 0x5614ddf7df10
#> 7  mrgsims-ds-195d56856f47.parquet 0x5614dde957c0
#> 8  mrgsims-ds-195d51b6d825.parquet 0x5614dc90ae28
#> 9             mrgsims-ds-1.parquet 0x5614dad743f0
#> 10  mrgsims-ds-195dbef36a5.parquet 0x5614dde957c0
#> 11 mrgsims-ds-195d7219804a.parquet 0x5614dde957c0
#> 12 mrgsims-ds-195d7b79dc48.parquet 0x5614dc902fe8
#> 13 mrgsims-ds-195d7f0709c5.parquet 0x5614dde957c0
#> 14 mrgsims-ds-195d3d48765a.parquet 0x5614dde957c0
#> 15 mrgsims-ds-195d27b4d7e4.parquet 0x5614dce35bd0
#> 16 mrgsims-ds-195d5a080ec8.parquet 0x5614dde957c0

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> Objects: 8 | Files: 18 | Size: 330.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
