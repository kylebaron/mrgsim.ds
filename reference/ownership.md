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
#> 1      mrgsims-ds-1b5244100254.parquet 0x5595f2439480
#> 2      mrgsims-ds-1b52418f83c6.parquet 0x5595f2439480
#> 3      mrgsims-ds-1b5275dff0a8.parquet 0x5595f41cc240
#> 4      mrgsims-ds-1b52288ff86c.parquet 0x5595ef019258
#> 5      mrgsims-ds-1b524124cf75.parquet 0x5595f4513028
#> 6      mrgsims-ds-1b527c3bd79f.parquet 0x5595f488d7b8
#> 7  mrgsims-ds-reg-100-300-0001.parquet 0x5595f593cfb8
#> 8      mrgsims-ds-1b525139baf4.parquet 0x5595f2439480
#> 9       mrgsims-ds-1b52c9d8d9b.parquet 0x5595f2439480
#> 10                mrgsims-ds-1.parquet 0x5595e6e76790
#> 11     mrgsims-ds-1b52464ccc79.parquet 0x5595f2439480
#> 12     mrgsims-ds-1b521c4010bf.parquet 0x5595f2439480
#> 13     mrgsims-ds-1b5269e43c6f.parquet 0x5595ec09b2f0
#> 14     mrgsims-ds-1b5222e4ef33.parquet 0x5595f2439480
#> 15                     example.parquet 0x5595efb8e598
#> 16     mrgsims-ds-1b52131797a2.parquet 0x5595f2439480
#> 17     mrgsims-ds-1b526a585430.parquet 0x5595f2439480
#> 18     mrgsims-ds-1b526065b65f.parquet 0x5595f2439480

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
