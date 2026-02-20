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
#> 1      mrgsims-ds-1bb57f0277ac.parquet 0x5562ad2f6338
#> 2      mrgsims-ds-1bb52540d45f.parquet 0x5562ad2f6338
#> 3  mrgsims-ds-reg-100-300-0001.parquet 0x5562ae556ac0
#> 4      mrgsims-ds-1bb55e95a05b.parquet 0x5562ad2f6338
#> 5      mrgsims-ds-1bb5695f169d.parquet 0x5562ad2f6338
#> 6      mrgsims-ds-1bb513b0a5a4.parquet 0x5562b1a4e118
#> 7       mrgsims-ds-1bb5d2a718c.parquet 0x5562ad2f6338
#> 8       mrgsims-ds-1bb5bcae9a1.parquet 0x5562ad2f6338
#> 9       mrgsims-ds-1bb54caf56d.parquet 0x5562a9ed8c28
#> 10                     example.parquet 0x5562aaa54870
#> 11     mrgsims-ds-1bb5295de744.parquet 0x5562ad2f6338
#> 12                mrgsims-ds-1.parquet 0x5562a1d4bd88
#> 13      mrgsims-ds-1bb526cd5d3.parquet 0x5562ad2f6338
#> 14     mrgsims-ds-1bb5364019d8.parquet 0x5562af85b180
#> 15     mrgsims-ds-1bb5289430cb.parquet 0x5562af3c7530
#> 16     mrgsims-ds-1bb57f0da185.parquet 0x5562ad2f6338
#> 17     mrgsims-ds-1bb514a1bad6.parquet 0x5562a6f5ce28
#> 18     mrgsims-ds-1bb518162ee6.parquet 0x5562ad2f6338

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
