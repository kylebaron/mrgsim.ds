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
#> > Objects: 8 | Files: 17 | Size: 350.3 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-1b721ecb9978.parquet 0x55afa7db2140
#> 2  mrgsims-ds-1b723b0d30e2.parquet 0x55afa7db2140
#> 3  mrgsims-ds-1b723b66aebf.parquet 0x55afa7db2140
#> 4    mrgsims-ds-1b72ce0cb8.parquet 0x55afa7db2140
#> 5                  example.parquet 0x55afa569c2c8
#> 6  mrgsims-ds-1b72105bb4ad.parquet 0x55afa4ae7cd8
#> 7  mrgsims-ds-1b722fbdbd08.parquet 0x55afa7db2140
#> 8  mrgsims-ds-1b72692ed47a.parquet 0x55afa158dbb0
#> 9  mrgsims-ds-1b72763a7886.parquet 0x55afa7db2140
#> 10 mrgsims-ds-1b7279f4d761.parquet 0x55afa9e898a0
#> 11            mrgsims-ds-1.parquet 0x55afa6e1efe8
#> 12 mrgsims-ds-1b7254857b86.parquet 0x55afa7db2140
#> 13 mrgsims-ds-1b7262577249.parquet 0x55afa965d858
#> 14 mrgsims-ds-1b7279428d5a.parquet 0x55afabaee838
#> 15 mrgsims-ds-1b723f1e8947.parquet 0x55afa7db2140
#> 16 mrgsims-ds-1b722b7c78b0.parquet 0x55afa7db2140
#> 17 mrgsims-ds-1b7240546edd.parquet 0x55afa7db2140

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 9 | Files: 19 | Size: 403.5 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
