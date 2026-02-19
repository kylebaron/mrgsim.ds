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
#> 1  mrgsims-ds-1a562de9968f.parquet 0x560a6e4f5960
#> 2  mrgsims-ds-1a561b53f2e7.parquet 0x560a6e4f5960
#> 3  mrgsims-ds-1a561759d3fa.parquet 0x560a6c6a19a8
#> 4   mrgsims-ds-1a56d23eb26.parquet 0x560a6e4f5960
#> 5  mrgsims-ds-1a567922efce.parquet 0x560a6e4f5960
#> 6                  example.parquet 0x560a6e532c20
#> 7   mrgsims-ds-1a56d33f6e2.parquet 0x560a6e4f5960
#> 8  mrgsims-ds-1a5665d6843d.parquet 0x560a6e4f5960
#> 9  mrgsims-ds-1a56482ec568.parquet 0x560a6e4f5960
#> 10 mrgsims-ds-1a566a50f180.parquet 0x560a6c6a17e8
#> 11 mrgsims-ds-1a565b43c0af.parquet 0x560a6e4f5960
#> 12 mrgsims-ds-1a562a73add7.parquet 0x560a6d5e1610
#> 13 mrgsims-ds-1a564ed7021e.parquet 0x560a67d68748
#> 14            mrgsims-ds-1.parquet 0x560a7039a498
#> 15 mrgsims-ds-1a564166d999.parquet 0x560a6e4f5960
#> 16 mrgsims-ds-1a564f187b6a.parquet 0x560a6e4f5960

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
