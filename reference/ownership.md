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
#> 1   mrgsims-ds-19ac431f863.parquet 0x561d2292bc00
#> 2  mrgsims-ds-19ac4cf80d0d.parquet 0x561d19a522c8
#> 3  mrgsims-ds-19ac4fa1a56c.parquet 0x561d278b2630
#> 4  mrgsims-ds-19ac557c50b7.parquet 0x561d19a522c8
#> 5  mrgsims-ds-19ac5ee89e51.parquet 0x561d19a522c8
#> 6  mrgsims-ds-19ac6357fb80.parquet 0x561d2862e4a8
#> 7  mrgsims-ds-19ac678c2697.parquet 0x561d27be96c0
#> 8  mrgsims-ds-19ac54b9386d.parquet 0x561d19a522c8
#> 9  mrgsims-ds-19ac788a994f.parquet 0x561d1e64f850
#> 10 mrgsims-ds-19ac12f6b186.parquet 0x561d19a522c8
#> 11 mrgsims-ds-19ac5f660535.parquet 0x561d19a522c8
#> 12 mrgsims-ds-19ac284cd576.parquet 0x561d19a522c8
#> 13                 example.parquet 0x561d20ccfb28
#> 14 mrgsims-ds-19ac10380b5b.parquet 0x561d19a522c8
#> 15  mrgsims-ds-19accfc00e0.parquet 0x561d19a522c8
#> 16 mrgsims-ds-19ac1efdd9d2.parquet 0x561d2331b7c0
#> 17 mrgsims-ds-19ac314f6d09.parquet 0x561d27bbcd10
#> 18            mrgsims-ds-1.parquet 0x561d26658cb8
#> 19 mrgsims-ds-19ac127a795e.parquet 0x561d19a522c8
#> 20  mrgsims-ds-19acaeb226d.parquet 0x561d23784f48
#> 21 mrgsims-ds-19ac7bf28b06.parquet 0x561d27f82ec0

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
