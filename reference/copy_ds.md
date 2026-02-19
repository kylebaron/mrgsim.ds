# Copy an mrgsimsds object

By default, the new object will own the data files.

## Usage

``` r
copy_ds(x, own = TRUE)
```

## Arguments

- x:

  an mrgsimsds object to copy.

- own:

  logical; if `TRUE` the new object will own the files; otherwise there
  will be no change in ownership.

## Value

An mrgsimsds object with identical fields, but updated pid.

## Examples

``` r
mod <- house_ds()

out <- mrgsim_ds(mod)

out2 <- copy_ds(out)

check_ownership(out)
#> [1] FALSE

check_ownership(out2)
#> [1] TRUE
```
