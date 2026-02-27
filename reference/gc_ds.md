# Set collection status for mrgsimsds objects

Set collection status for mrgsimsds objects

## Usage

``` r
gc_ds(x, ...)
```

## Arguments

- x:

  a list of mrgsimsds objects or a single mrgsimsds object.

- ...:

  not used.

## Value

An mrgsimsds object or a list of those objects is returned, potentially
with the `gc` status updated.

## Examples

``` r
mod <- modlib_ds("popex", outvars = "IPRED")
#> Building popex ... 
#> done.

data <- ev_expand(amt = 100, ID = 1:5)

out <- mrgsim_ds(mod, data)

out <- gc_ds(out, value = FALSE)

out <- gc_ds(out, value = TRUE)

out <- lapply(1:3, function(rep) {
  out <- mrgsim_ds(mod, data) 
  out
})

out <- gc_ds(out, value = FALSE)
```
