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
#> > Objects: 12 | Files: 21 | Size: 405.9 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-19c13c702c34.parquet 0x5582dc4cf278
#> 2   mrgsims-ds-19c1e87d173.parquet 0x5582e200f080
#> 3  mrgsims-ds-19c119c13685.parquet 0x5582e6073c28
#> 4  mrgsims-ds-19c1227dd306.parquet 0x5582dc4cf278
#> 5  mrgsims-ds-19c116c28428.parquet 0x5582dc4cf278
#> 6  mrgsims-ds-19c160bd79a9.parquet 0x5582e1d95738
#> 7  mrgsims-ds-19c17d75316e.parquet 0x5582e644ae78
#> 8  mrgsims-ds-19c11d58a79b.parquet 0x5582dc4cf278
#> 9             mrgsims-ds-1.parquet 0x5582e4b687f8
#> 10 mrgsims-ds-19c122aef5af.parquet 0x5582dc4cf278
#> 11 mrgsims-ds-19c1654d5f4d.parquet 0x5582e60a7ae8
#> 12  mrgsims-ds-19c15125d15.parquet 0x5582e17a09c8
#> 13 mrgsims-ds-19c125d27303.parquet 0x5582e6b1e6a0
#> 14 mrgsims-ds-19c13aa4f013.parquet 0x5582dc4cf278
#> 15 mrgsims-ds-19c11e00596f.parquet 0x5582e5d786c8
#> 16 mrgsims-ds-19c13d1f87e1.parquet 0x5582dc4cf5f8
#> 17                 example.parquet 0x5582e0ed41a8
#> 18 mrgsims-ds-19c178b4748f.parquet 0x5582dc4cf278
#> 19 mrgsims-ds-19c13a9146b2.parquet 0x5582dc4cf278
#> 20 mrgsims-ds-19c12e54fb2c.parquet 0x5582dc4cf278
#> 21 mrgsims-ds-19c16df957b7.parquet 0x5582dc4cf278

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 13 | Files: 23 | Size: 459.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
