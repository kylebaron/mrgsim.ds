# Coerce an mrgsims object to 'Arrow'-backed mrgsimsds object

All simulation data is saved to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) according to the
parent or head node that the computation is run from. See
[`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
to
[`write_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
change the location of the files, protecting them from the garbage
collector.

## Usage

``` r
as_mrgsim_ds(x, id = NULL, verbose = FALSE, gc = TRUE)
```

## Arguments

- x:

  an mrgsims object.

- id:

  used to generate an output file name.

- verbose:

  if `TRUE`, print progress information to the console.

- gc:

  if `TRUE`, a finalizer function will attempt to remove files once the
  object is out of scope; set to `FALSE` to protect from automatic
  cleanup. Otherwise, move the files from
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

## Value

An object with class `mrgsimsds`.

## Details

This function will only take output from
[`mrgsolve::mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html).

## See also

[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

## Examples

``` r
mod <- house_ds()

data <- ev_expand(amt = 100, ID = 1:10)

out <- mrgsolve::mrgsim(mod, data)

obj <- as_mrgsim_ds(out)

obj
#> Model: housemodel
#> Dim  : 4,820 x 7
#> Files: 1 [55.4 Kb]
#> Owner: yes
#>     ID time       GUT     CENT     RESP       DV       CP
#> 1:   1 0.00   0.00000  0.00000 50.00000 0.000000 0.000000
#> 2:   1 0.00 100.00000  0.00000 50.00000 0.000000 0.000000
#> 3:   1 0.25  74.08182 25.74883 48.68223 1.287441 1.287441
#> 4:   1 0.50  54.88116 44.50417 46.18005 2.225208 2.225208
#> 5:   1 0.75  40.65697 58.08258 43.61333 2.904129 2.904129
#> 6:   1 1.00  30.11942 67.82976 41.37943 3.391488 3.391488
#> 7:   1 1.25  22.31302 74.74256 39.57649 3.737128 3.737128
#> 8:   1 1.50  16.52989 79.55944 38.18381 3.977972 3.977972
```
