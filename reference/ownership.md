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
#> 1      mrgsims-ds-1bad468acad5.parquet 0x556c1b4e80e0
#> 2      mrgsims-ds-1bad48eb53fd.parquet 0x556c1e92e800
#> 3      mrgsims-ds-1bad28d73f05.parquet 0x556c1e92e800
#> 4      mrgsims-ds-1bad7f6565e6.parquet 0x556c1e92e800
#> 5      mrgsims-ds-1bad1270b9d4.parquet 0x556c1e92e800
#> 6      mrgsims-ds-1bad3a4053d9.parquet 0x556c1e92e800
#> 7                 mrgsims-ds-1.parquet 0x556c1a921518
#> 8      mrgsims-ds-1bad2d7f5ca9.parquet 0x556c209f1b50
#> 9      mrgsims-ds-1bad330a93a9.parquet 0x556c1f75a378
#> 10     mrgsims-ds-1bad62cbabd4.parquet 0x556c1e92e800
#> 11 mrgsims-ds-reg-100-300-0001.parquet 0x556c2005e298
#> 12     mrgsims-ds-1bad6fb31ebf.parquet 0x556c1e92e800
#> 13     mrgsims-ds-1bad75f26fd4.parquet 0x556c1e92e800
#> 14                     example.parquet 0x556c1c01c4a0
#> 15     mrgsims-ds-1bad4a5b7444.parquet 0x556c18587420
#> 16     mrgsims-ds-1bad157078b2.parquet 0x556c1e92e800
#> 17     mrgsims-ds-1bad5df5590a.parquet 0x556c22142338
#> 18     mrgsims-ds-1bad2b3b002b.parquet 0x556c1e92e800

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
