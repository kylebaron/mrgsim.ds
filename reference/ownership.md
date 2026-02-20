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
#> 1       mrgsims-ds-1b9ce68c51f.parquet 0x55be80157f38
#> 2      mrgsims-ds-1b9c7a8ad408.parquet 0x55be7c465970
#> 3      mrgsims-ds-1b9c7ff4a467.parquet 0x55be7c465970
#> 4      mrgsims-ds-1b9c24520f4b.parquet 0x55be7c465970
#> 5      mrgsims-ds-1b9c3deaf124.parquet 0x55be7c465970
#> 6      mrgsims-ds-1b9c5399b589.parquet 0x55be7c465970
#> 7                      example.parquet 0x55be79bc7c48
#> 8      mrgsims-ds-1b9c4dbd4245.parquet 0x55be7c465970
#> 9      mrgsims-ds-1b9c1daddb71.parquet 0x55be7c465970
#> 10                mrgsims-ds-1.parquet 0x55be70ebfff0
#> 11     mrgsims-ds-1b9c185c1434.parquet 0x55be7c465970
#> 12     mrgsims-ds-1b9c1848fcbe.parquet 0x55be7c465970
#> 13     mrgsims-ds-1b9c3dbbe982.parquet 0x55be7e53bf38
#> 14     mrgsims-ds-1b9c4f294b7f.parquet 0x55be7e9d6e20
#> 15 mrgsims-ds-reg-100-300-0001.parquet 0x55be7deb2320
#> 16     mrgsims-ds-1b9c18c1c727.parquet 0x55be7c465970
#> 17      mrgsims-ds-1b9cc87f4d6.parquet 0x55be7904e230
#> 18      mrgsims-ds-1b9c4866157.parquet 0x55be760d6630

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
