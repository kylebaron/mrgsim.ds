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
#> 1      mrgsims-ds-1ba46f6af148.parquet 0x55596bbad050
#> 2      mrgsims-ds-1ba41ff3805e.parquet 0x55596bbad050
#> 3                      example.parquet 0x555969302550
#> 4      mrgsims-ds-1ba47db89165.parquet 0x555965814558
#> 5      mrgsims-ds-1ba44a3e6332.parquet 0x55596bbad050
#> 6                 mrgsims-ds-1.parquet 0x5559606086f0
#> 7      mrgsims-ds-1ba477a5fabd.parquet 0x55596bbad050
#> 8      mrgsims-ds-1ba4171d5f3d.parquet 0x55596bbad050
#> 9      mrgsims-ds-1ba44bf02640.parquet 0x55596bbad050
#> 10     mrgsims-ds-1ba468696dbc.parquet 0x55596f27ad90
#> 11     mrgsims-ds-1ba4125010c4.parquet 0x55596bbad050
#> 12 mrgsims-ds-reg-100-300-0001.parquet 0x55596c28df28
#> 13     mrgsims-ds-1ba4270d6db4.parquet 0x55596e6594b0
#> 14     mrgsims-ds-1ba44807f9eb.parquet 0x55596dc83640
#> 15     mrgsims-ds-1ba46f4cc243.parquet 0x55596bbad050
#> 16     mrgsims-ds-1ba427bea3d2.parquet 0x55596878caa0
#> 17     mrgsims-ds-1ba431800c34.parquet 0x55596bbad050
#> 18      mrgsims-ds-1ba4c31d482.parquet 0x55596bbad050

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
