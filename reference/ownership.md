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
#> 1      mrgsims-ds-1d67253e3320.parquet 0x55f4ae1327c0
#> 2      mrgsims-ds-1d6742bb390a.parquet 0x55f4a7d9e298
#> 3  mrgsims-ds-reg-100-300-0001.parquet 0x55f4b1e61ec8
#> 4                      example.parquet 0x55f4ab8986f0
#> 5      mrgsims-ds-1d67471e37fb.parquet 0x55f4b0e26158
#> 6      mrgsims-ds-1d67755d2230.parquet 0x55f4ae1327c0
#> 7      mrgsims-ds-1d677dbaf010.parquet 0x55f4ae1327c0
#> 8        mrgsims-ds-1d67463b3c.parquet 0x55f4b020c200
#> 9       mrgsims-ds-1d674b46918.parquet 0x55f4ae1327c0
#> 10     mrgsims-ds-1d6758ed6815.parquet 0x55f4ae1327c0
#> 11     mrgsims-ds-1d6756de64ce.parquet 0x55f4ae1327c0
#> 12     mrgsims-ds-1d677d4b3cc3.parquet 0x55f4ae1327c0
#> 13     mrgsims-ds-1d67568fb174.parquet 0x55f4ae1327c0
#> 14     mrgsims-ds-1d675fda100f.parquet 0x55f4ae1327c0
#> 15     mrgsims-ds-1d671e8fd302.parquet 0x55f4b0e05e80
#> 16     mrgsims-ds-1d676a51251c.parquet 0x55f4aad0f7a8
#> 17                mrgsims-ds-1.parquet 0x55f4aa1fdba0
#> 18     mrgsims-ds-1d6733b3f548.parquet 0x55f4ae1327c0

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
