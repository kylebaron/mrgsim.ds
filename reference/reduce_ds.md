# Reduce a list of mrgsimsds objects into a single object

Reduce a list of mrgsimsds objects into a single object

## Usage

``` r
reduce_ds(x, ...)
```

## Arguments

- x:

  a list of mrgsimsds objects or a single mrgsimsds object.

- ...:

  not used.

## Value

A single mrgsimsds object. For the list method, the returned object will
own all underlying files.

## Details

When `x` is a list, a new object is created and returned. This new
object will take ownership for all the files from the objects in the
list.

When `x` is an mrgsimsds object, it will be returned invisibly with no
modification.

## Examples

``` r
mod <- modlib_ds("popex", outvars = "IPRED")
#> Loading model from cache.

data <- ev_expand(amt = 100, ID = 1:10)

out <- lapply(1:3, function(rep) {
  out <- mrgsim_ds(mod, data) 
  out
})

length(out)
#> [1] 3

sims <- reduce_ds(out)

sims
#> Model: popex
#> Dim  : 14,460 x 3
#> Files: 3 [161.7 Kb]
#> Owner: yes (gc)
#>     ID time    IPRED
#> 1:   1  0.0 0.000000
#> 2:   1  0.0 0.000000
#> 3:   1  0.5 1.938575
#> 4:   1  1.0 2.999619
#> 5:   1  1.5 3.517396
#> 6:   1  2.0 3.703363
#> 7:   1  2.5 3.690902
#> 8:   1  3.0 3.563794

check_ownership(sims)
#> [1] TRUE

lapply(out, check_ownership)
#> [[1]]
#> [1] FALSE
#> 
#> [[2]]
#> [1] FALSE
#> 
#> [[3]]
#> [1] FALSE
#> 
```
