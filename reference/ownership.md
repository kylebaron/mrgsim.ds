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
#> 1                 mrgsims-ds-1.parquet 0x564c3a023e50
#> 2      mrgsims-ds-1b682ab46a7e.parquet 0x564c456488b0
#> 3      mrgsims-ds-1b683e6e899a.parquet 0x564c3f2a7978
#> 4      mrgsims-ds-1b684bce8bde.parquet 0x564c47716d88
#> 5      mrgsims-ds-1b6846585f4f.parquet 0x564c456488b0
#> 6      mrgsims-ds-1b68681883b9.parquet 0x564c456488b0
#> 7      mrgsims-ds-1b68469b9794.parquet 0x564c4837b428
#> 8  mrgsims-ds-reg-100-300-0001.parquet 0x564c46d85f40
#> 9      mrgsims-ds-1b6870057e48.parquet 0x564c456488b0
#> 10     mrgsims-ds-1b6820603c68.parquet 0x564c456488b0
#> 11     mrgsims-ds-1b68734425a8.parquet 0x564c456488b0
#> 12     mrgsims-ds-1b6834f156a3.parquet 0x564c456488b0
#> 13     mrgsims-ds-1b681a661f51.parquet 0x564c456488b0
#> 14                     example.parquet 0x564c42d8d570
#> 15     mrgsims-ds-1b681e690fee.parquet 0x564c456488b0
#> 16     mrgsims-ds-1b681c85f0a6.parquet 0x564c4524df18
#> 17     mrgsims-ds-1b685b9fee27.parquet 0x564c456488b0
#> 18     mrgsims-ds-1b68288d9f06.parquet 0x564c4221aa38

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
