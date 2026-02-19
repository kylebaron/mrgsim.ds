# Get Started

``` r
library(mrgsim.ds)
library(dplyr)
```

## Load the model

Load a model using
[`mread_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mread_ds.md)
or other friends.

``` r
mod <- mread_ds("popex-2.mod", outvars = "IPRED, DV, ECL")
```

This model is almost identical to the same model loaded with
[`mread()`](https://mrgsolve.org/docs/reference/mread.html); there is
just some extra information included to make sure it works well with the
`mrgsim.ds` approach.

## Simulate

To simulate, call
[`mrgsim_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/mrgsim_ds.md)

``` r
data <- evd_expand(amt = c(100, 300, 700), ii = 24, addl = 4, ID = 1:10)

set.seed(98)
out <- mrgsim_ds(mod, data = data)
```

The output handles very similar to regular
[`mrgsim()`](https://mrgsolve.org/docs/reference/mrgsim.html) output

``` r
out
```

    ## Model: popex-2_mod
    ## Dim  : 14,460 x 5
    ## Files: 1 [295 Kb]
    ## Owner: yes
    ##     ID TIME        ECL     IPRED        DV
    ## 1:   1  0.0 -0.1397334 0.0000000 0.0000000
    ## 2:   1  0.0 -0.1397334 0.0000000 0.0000000
    ## 3:   1  0.5 -0.1397334 0.7493918 0.7493918
    ## 4:   1  1.0 -0.1397334 1.2650920 1.2650920
    ## 5:   1  1.5 -0.1397334 1.6175329 1.6175329
    ## 6:   1  2.0 -0.1397334 1.8559447 1.8559447
    ## 7:   1  2.5 -0.1397334 2.0147377 2.0147377
    ## 8:   1  3.0 -0.1397334 2.1179631 2.1179631

``` r
head(out)
```

    ## # A tibble: 6 × 5
    ##      ID  TIME    ECL IPRED    DV
    ##   <dbl> <dbl>  <dbl> <dbl> <dbl>
    ## 1     1   0   -0.140 0     0    
    ## 2     1   0   -0.140 0     0    
    ## 3     1   0.5 -0.140 0.749 0.749
    ## 4     1   1   -0.140 1.27  1.27 
    ## 5     1   1.5 -0.140 1.62  1.62 
    ## 6     1   2   -0.140 1.86  1.86

``` r
dim(out)
```

    ## [1] 14460     5

``` r
plot(out, nid = 10)
```

![](mrgsim.ds_files/figure-html/unnamed-chunk-4-1.png)

## Simulation files

Simulation files are always initially stored in
[`tempdir()`](https://rdrr.io/r/base/tempfile.html)

``` r
out1 <- mrgsim_ds(mod, data)
out2 <- mrgsim_ds(mod, data, id = "regimens")
out3 <- mrgsim_ds(mod, data = filter(data, AMT==300))

list_temp()
```

    ## 4 files [984.8 Kb]
    ## - mrgsims-ds-1b8c1283998f.parquet
    ## - mrgsims-ds-1b8c4bd47e07.parquet
    ## - mrgsims-ds-1b8cd305b59.parquet
    ## - mrgsims-ds-regimens.parquet

To save outputs to a persistent location, use
[`write_ds()`](https://kylebaron.github.io/mrgsim.ds/reference/move_ds.md).

``` r
write_ds(out, sink = file.path(save_dir, "regimen1"))
```

This re-writes all the data into a single parquet file. This can take
some time for very large outputs across multiple files.

An alternative is to rename ane move.

``` r
rename_ds(out, "regimen-1")
move_ds(out, save_dir)
```
