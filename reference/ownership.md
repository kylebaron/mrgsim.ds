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
#> > Objects: 10 | Files: 19 | Size: 455 Kb

list_ownership()
#>                                   file        address
#> 1      mrgsims-ds-1bd6780901fd.parquet 0x558866095b40
#> 2                 mrgsims-ds-1.parquet 0x558865d393e0
#> 3      mrgsims-ds-1bd641d01977.parquet 0x55886868aa90
#> 4      mrgsims-ds-1bd65f54075b.parquet 0x558866095b40
#> 5      mrgsims-ds-1bd674e7c172.parquet 0x558866095b40
#> 6      mrgsims-ds-1bd618ad08ad.parquet 0x55886992d468
#> 7  mrgsims-ds-reg-100-300-0001.parquet 0x558867ea8648
#> 8       mrgsims-ds-1bd61a105f6.parquet 0x558862c4e460
#> 9      mrgsims-ds-1bd67d98c78b.parquet 0x558866095b40
#> 10     mrgsims-ds-1bd620a1be72.parquet 0x558866095b40
#> 11                     example.parquet 0x55886376e940
#> 12     mrgsims-ds-1bd63c435e16.parquet 0x5588681542f0
#> 13     mrgsims-ds-1bd67f20c469.parquet 0x558869404f60
#> 14     mrgsims-ds-1bd63fe3aa4d.parquet 0x558866095b40
#> 15     mrgsims-ds-1bd621f22b4c.parquet 0x558866095b40
#> 16     mrgsims-ds-1bd622fe7c1f.parquet 0x558866095b40
#> 17     mrgsims-ds-1bd619dc704a.parquet 0x558866095b40
#> 18     mrgsims-ds-1bd64a8b348e.parquet 0x558866095b40
#> 19     mrgsims-ds-1bd67ed46322.parquet 0x55885fcea240

e1 <- ev(amt = 100)
e2 <- ev(amt = 200)

out <- list(mrgsim_ds(mod, e1), mrgsim_ds(mod, e2))

sims <- reduce_ds(out)

ownership()
#> > Objects: 11 | Files: 21 | Size: 508.2 Kb

check_ownership(sims)
#> [1] TRUE

check_ownership(out[[1]])
#> [1] FALSE

check_ownership(out[[2]])
#> [1] FALSE

```
