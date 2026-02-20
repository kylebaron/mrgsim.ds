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
#> 1      mrgsims-ds-1b9d275254a2.parquet 0x55671382def0
#> 2  mrgsims-ds-reg-100-300-0001.parquet 0x556714f667f8
#> 3      mrgsims-ds-1b9d496bc29a.parquet 0x55671382def0
#> 4      mrgsims-ds-1b9d2dd90ffc.parquet 0x5567158f4cc0
#> 5      mrgsims-ds-1b9d68b0dd94.parquet 0x55671382def0
#> 6      mrgsims-ds-1b9d1a7e0a46.parquet 0x55671382def0
#> 7                 mrgsims-ds-1.parquet 0x55670dfbf5d0
#> 8      mrgsims-ds-1b9d5a295694.parquet 0x55671382def0
#> 9      mrgsims-ds-1b9d34aafd41.parquet 0x55670d493900
#> 10     mrgsims-ds-1b9d78f17ed8.parquet 0x55671382def0
#> 11     mrgsims-ds-1b9d3ddd1d5c.parquet 0x55671382def0
#> 12     mrgsims-ds-1b9d53f69f85.parquet 0x5567103fab28
#> 13     mrgsims-ds-1b9d32609fed.parquet 0x55671382def0
#> 14     mrgsims-ds-1b9d46f75539.parquet 0x55671382def0
#> 15     mrgsims-ds-1b9d1bef25c3.parquet 0x556716c61008
#> 16      mrgsims-ds-1b9d6d7e9f7.parquet 0x556716de70e0
#> 17                     example.parquet 0x556710f5c160
#> 18      mrgsims-ds-1b9da6d36b0.parquet 0x55671382def0

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
