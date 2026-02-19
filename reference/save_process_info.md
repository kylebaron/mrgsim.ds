# Save information about the R process that loaded a model

Save information about the R process that loaded a model

## Usage

``` r
save_process_info(x)
```

## Arguments

- x:

  a model object.

## Value

An updated model object suitable for using with
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md).

## Examples

``` r
mod <- mrgsolve::house()

mod <- save_process_info(mod)
```
