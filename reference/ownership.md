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
#> Objects: 7 | Files: 16 | Size: 276.9 Kb

list_ownership()
#>                               file        address
#> 1  mrgsims-ds-19577bfa607e.parquet 0x559dec438bb0
#> 2  mrgsims-ds-19575af0a781.parquet 0x559dec438bb0
#> 3  mrgsims-ds-1957187eeaf9.parquet 0x559dec438bb0
#> 4  mrgsims-ds-19572bfbc665.parquet 0x559dec438bb0
#> 5                  example.parquet 0x559dec4731c0
#> 6  mrgsims-ds-195717df93f4.parquet 0x559dec438bb0
#> 7   mrgsims-ds-1957d52a1fc.parquet 0x559dec438bb0
#> 8   mrgsims-ds-1957994bf9f.parquet 0x559dec438bb0
#> 9  mrgsims-ds-195760df1a06.parquet 0x559dec438bb0
#> 10 mrgsims-ds-19572c88f54b.parquet 0x559dea7a22a8
#> 11            mrgsims-ds-1.parquet 0x559def810140
#> 12 mrgsims-ds-19576ee6dcbc.parquet 0x559de5ca6518
#> 13  mrgsims-ds-19578ca81b9.parquet 0x559dec438bb0
#> 14 mrgsims-ds-195776f9c507.parquet 0x559dea7aba90
#> 15 mrgsims-ds-19574f0457c7.parquet 0x559deb5175c8
#> 16 mrgsims-ds-1957137ac4ce.parquet 0x559dec438bb0

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> Objects: 8 | Files: 18 | Size: 330.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
