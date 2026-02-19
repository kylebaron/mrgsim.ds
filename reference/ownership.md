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
#> 1  mrgsims-ds-191f78dde5d2.parquet 0x5622d0886458
#> 2  mrgsims-ds-191f445d3c2f.parquet 0x5622cef96a68
#> 3  mrgsims-ds-191f72e4a06f.parquet 0x5622d0886458
#> 4  mrgsims-ds-191f4bbeed79.parquet 0x5622d0886458
#> 5  mrgsims-ds-191f6f06c1ec.parquet 0x5622d0886458
#> 6  mrgsims-ds-191f452196c3.parquet 0x5622d0886458
#> 7  mrgsims-ds-191f27ec3fb5.parquet 0x5622ca130248
#> 8  mrgsims-ds-191f333b6bfa.parquet 0x5622d0886458
#> 9             mrgsims-ds-1.parquet 0x5622d297c0a0
#> 10                 example.parquet 0x5622d08b76e0
#> 11 mrgsims-ds-191f754c7801.parquet 0x5622d0886458
#> 12 mrgsims-ds-191f2c6ec360.parquet 0x5622d0886458
#> 13 mrgsims-ds-191f2b7a17e1.parquet 0x5622cec9ca80
#> 14 mrgsims-ds-191f65f4381b.parquet 0x5622d0886458
#> 15 mrgsims-ds-191f6618bc68.parquet 0x5622d0886458
#> 16 mrgsims-ds-191f3c78ed07.parquet 0x5622cf95f040

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
