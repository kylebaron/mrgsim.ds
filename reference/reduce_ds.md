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

## Details

When `x` is a list, a new object is created and returned. This new
object will take ownership for all the files from the objects in the
list.

When `x` is an mrgsimsds object, it will be returned invisibly with no
modification.

## Examples

``` r
mod <- modlib_ds("1005", outvars = "IPRED")
#> Building 1005 ... 
#> done.

data <- ev_expand(amt = 100, ID = 1:100)

out <- lapply(1:3, function(rep) {
  out <- mrgsim_ds(mod, data) 
  out
})

length(out)
#> [1] 3

sims <- reduce_ds(out)

sims
#> Model: 1005
#> Dim  : 7,800 x 3
#> Files: 3 [74.8 Kb]
#> Owner: yes
#>     ID time     IPRED
#> 1:   1    0 0.0000000
#> 2:   1    0 0.0000000
#> 3:   1    1 0.1184027
#> 4:   1    2 0.1768468
#> 5:   1    3 0.2030177
#> 6:   1    4 0.2119433
#> 7:   1    5 0.2117742
#> 8:   1    6 0.2069247

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
