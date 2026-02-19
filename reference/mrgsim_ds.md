# Simulate from a model object, returning an arrow-backed output object

All simulation data is saved to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html) according to the
parent or head node that the computation is run from. See
[`move_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
to
[`write_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md)
change the location of the files, protecting them from the garbage
collector. Note that full names must be used for all arguments.

## Usage

``` r
mrgsim_ds(x, ..., id = NULL, tags = list(), verbose = FALSE, gc = TRUE)
```

## Arguments

- x:

  a model object loaded through
  [`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
  [`mcode_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
  [`modlib_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
  [`mread_cache_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md),
  or
  [`house_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md).

- ...:

  passed to
  [`mrgsolve::mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html).

- id:

  used to generate an output file name.

- tags:

  a named list of atomic data to tag (or mutate) the simulated output.

- verbose:

  if `TRUE`, print progress information to the console.

- gc:

  if `TRUE`, a finalizer function will attempt to remove files once the
  object is out of scope; set to `FALSE` to protect from automatic
  cleanup. Otherwise, move the files from
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

## Value

An object with class `mrgsimsds`.

## See also

[`as_mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/as_mrgsim_ds.md),
[mrgsimsds-methods](https://kylebaron.github.io/mrgsim.ds/reference/mrgsimsds-methods.md).

## Examples

``` r
mod <- house_ds()

data <- ev_expand(amt = 100, ID = 1:10)

out <- mrgsim_ds(mod, data, end = 72, delta = 0.1)

out <- mrgsim_ds(mod, data, tags = list(rep = 1))

head(out)
#> # A tibble: 6 × 8
#>      ID  time   GUT  CENT  RESP    DV    CP   rep
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     1  0      0     0    50    0     0        1
#> 2     1  0    100     0    50    0     0        1
#> 3     1  0.25  74.1  25.7  48.7  1.29  1.29     1
#> 4     1  0.5   54.9  44.5  46.2  2.23  2.23     1
#> 5     1  0.75  40.7  58.1  43.6  2.90  2.90     1
#> 6     1  1     30.1  67.8  41.4  3.39  3.39     1
```
