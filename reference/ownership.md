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
#> 1  mrgsims-ds-1bac12c6ac96.parquet 0x55f7567f5c90
#> 2  mrgsims-ds-1bac17118006.parquet 0x55f756dd21a8
#> 3  mrgsims-ds-1bac59458856.parquet 0x55f751ffe918
#> 4  mrgsims-ds-1bac36f8eac6.parquet 0x55f756dd21a8
#> 5             mrgsims-ds-1.parquet 0x55f7595a1858
#> 6  mrgsims-ds-1bac73617447.parquet 0x55f756dd21a8
#> 7  mrgsims-ds-1bac7fa3498a.parquet 0x55f756dd21a8
#> 8  mrgsims-ds-1bac4c0d6d5e.parquet 0x55f756dd21a8
#> 9  mrgsims-ds-1bac3780b6a3.parquet 0x55f756dd21a8
#> 10 mrgsims-ds-1bac611418da.parquet 0x55f75205e5a8
#> 11 mrgsims-ds-1bac14dfc5b8.parquet 0x55f756dd21a8
#> 12                 example.parquet 0x55f755a70e40
#> 13 mrgsims-ds-1bac180dddd3.parquet 0x55f756dd21a8
#> 14 mrgsims-ds-1bac31ec5ec6.parquet 0x55f751ffc870
#> 15 mrgsims-ds-1bac45ffd24c.parquet 0x55f756dd21a8
#> 16 mrgsims-ds-1bac46c0ba9d.parquet 0x55f756dd21a8

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
