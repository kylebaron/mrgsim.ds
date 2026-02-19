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
mod <- modlib_ds("popex", outvars = "IPRED")
#> Building popex ... 
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
#> Model: popex
#> Dim  : 144.6K x 3
#> Files: 3 [1.5 Mb]
#> Owner: yes
#>     ID time     IPRED
#> 1:   1  0.0 0.0000000
#> 2:   1  0.0 0.0000000
#> 3:   1  0.5 0.4872955
#> 4:   1  1.0 0.9218375
#> 5:   1  1.5 1.3084607
#> 6:   1  2.0 1.6515715
#> 7:   1  2.5 1.9551852
#> 8:   1  3.0 2.2229609

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
