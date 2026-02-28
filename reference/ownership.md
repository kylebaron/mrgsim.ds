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
#> 1  mrgsims-ds-19775f578f33.parquet 0x5573f6e9e730
#> 2  mrgsims-ds-19777266affb.parquet 0x5574007009a8
#> 3  mrgsims-ds-197777af0526.parquet 0x5573f6e9e730
#> 4  mrgsims-ds-1977651d1d20.parquet 0x5574014a6d00
#> 5  mrgsims-ds-1977506e663b.parquet 0x5574009fe838
#> 6   mrgsims-ds-19779225cab.parquet 0x5573fc981458
#> 7  mrgsims-ds-1977481d6b61.parquet 0x5573f6e9e730
#> 8  mrgsims-ds-197730480b93.parquet 0x5573f6e9e730
#> 9   mrgsims-ds-1977f568718.parquet 0x5573f6e9e730
#> 10                 example.parquet 0x5573fb8c3728
#> 11 mrgsims-ds-197741eadf45.parquet 0x5573f6e9e730
#> 12 mrgsims-ds-197734b210f7.parquet 0x557400a33bf8
#> 13 mrgsims-ds-1977299deb6a.parquet 0x557400dd3158
#> 14 mrgsims-ds-19774c9e684b.parquet 0x5573fc70ff70
#> 15 mrgsims-ds-1977561a6a72.parquet 0x5573f6e9e730
#> 16 mrgsims-ds-197763f23576.parquet 0x5573f6e9e730
#> 17 mrgsims-ds-1977162e7223.parquet 0x5573f6e988b8
#> 18 mrgsims-ds-1977733bcaef.parquet 0x5573fc0b84a0
#> 19 mrgsims-ds-197719a1a200.parquet 0x5573f6e9e730
#> 20            mrgsims-ds-1.parquet 0x5573ff4f7070
#> 21 mrgsims-ds-19771b2f406d.parquet 0x5573f6e9e730

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
