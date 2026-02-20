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
#> 1      mrgsims-ds-1d712e0f9345.parquet 0x55606c2f4388
#> 2                 mrgsims-ds-1.parquet 0x5560670eb870
#> 3      mrgsims-ds-1d7177b10439.parquet 0x55606a220b50
#> 4      mrgsims-ds-1d716af22be4.parquet 0x55606c666aa8
#> 5      mrgsims-ds-1d71246d865f.parquet 0x55606a220b50
#> 6      mrgsims-ds-1d7156a5b135.parquet 0x55606a220b50
#> 7      mrgsims-ds-1d711e42378b.parquet 0x55606a220b50
#> 8                      example.parquet 0x556067964158
#> 9       mrgsims-ds-1d713a395fb.parquet 0x556063e860e8
#> 10     mrgsims-ds-1d7134a4174c.parquet 0x55606a220b50
#> 11     mrgsims-ds-1d7155b4e0a6.parquet 0x55606a220b50
#> 12 mrgsims-ds-reg-100-300-0001.parquet 0x55606a9c8478
#> 13     mrgsims-ds-1d7156d046c5.parquet 0x55606a220b50
#> 14     mrgsims-ds-1d715198b192.parquet 0x556066df9730
#> 15     mrgsims-ds-1d711bba7eb3.parquet 0x55606a220b50
#> 16     mrgsims-ds-1d71503a24f4.parquet 0x55606a220b50
#> 17     mrgsims-ds-1d714c3e6388.parquet 0x55606a220b50
#> 18     mrgsims-ds-1d7139848043.parquet 0x55606c764e50

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
