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
#> > Objects: 6 | Files: 15 | Size: 243.9 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-19554763cd1f.parquet 0x55f5d0256518
#> 2   mrgsims-ds-195563cf0dd.parquet 0x55f5d2b9e368
#> 3  mrgsims-ds-195571b7af31.parquet 0x55f5d3032580
#> 4             mrgsims-ds-1.parquet 0x55f5d58fead0
#> 5   mrgsims-ds-1955e997b59.parquet 0x55f5d2b9e368
#> 6  mrgsims-ds-19552bc47ade.parquet 0x55f5d2b9e368
#> 7   mrgsims-ds-1955f85c34d.parquet 0x55f5d2b9e368
#> 8  mrgsims-ds-19552aaca229.parquet 0x55f5d2b9e368
#> 9  mrgsims-ds-1955726bf730.parquet 0x55f5d2b9e368
#> 10 mrgsims-ds-19555a95d617.parquet 0x55f5cf7c7f90
#> 11 mrgsims-ds-19551205827c.parquet 0x55f5d2b9e368
#> 12 mrgsims-ds-195514cf772f.parquet 0x55f5d0818768
#> 13 mrgsims-ds-19552b95409f.parquet 0x55f5d2b9e368
#> 14 mrgsims-ds-19554d3913c1.parquet 0x55f5d2b9e368
#> 15 mrgsims-ds-195523d1697c.parquet 0x55f5d2b9e368

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 7 | Files: 17 | Size: 297.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
